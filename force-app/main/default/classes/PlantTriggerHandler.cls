public class PlantTriggerHandler {

	public static void onAfterInsert(List<CAMPX__Plant__c> newRecords) {
		setDefaultValuesOnNewRecords(newRecords);
		setTotalPlantCountOnGarden(newRecords, null);
		aggregateUnhealthyPlantCount(newRecords,null);
	}

	public static void onAfterUpdate(List<CAMPX__Plant__c> newRecords, Map<Id,CAMPX__Plant__c> oldRecordsMap) {
		setTotalPlantCountOnGarden(newRecords, oldRecordsMap);
		aggregateUnhealthyPlantCount(newRecords,oldRecordsMap);
	}

	public static void onAfterDelete(List<CAMPX__Plant__c> oldRecords) {
		setTotalPlantCountOnGarden(oldRecords, null);
		aggregateUnhealthyPlantCount(oldRecords,null);
	}

	private static void aggregateUnhealthyPlantCount(List<CAMPX__Plant__c> newRecords,Map<Id,CAMPX__Plant__c> oldRecordsMap) {
		Set<Id> gardenIds = new Set<Id>();
		for (CAMPX__Plant__c plant : newRecords) { 
			if (plant.isUnhealthy__c || (oldRecordsMap != null && plant.isUnhealthy__c != oldRecordsMap.get(plant.Id).isUnhealthy__c)) {
				gardenIds.add(plant.CAMPX__Garden__c);
			}
			
			if (oldRecordsMap != null && plant.CAMPX__Garden__c != oldRecordsMap.get(plant.Id).CAMPX__Garden__c) {
				gardenIds.add(oldRecordsMap.get(plant.Id).CAMPX__Garden__c);
			}
		}

		List<CAMPX__Garden__c> gardensToUpdate = [
			SELECT Id, CAMPX__Total_Unhealthy_Plant_Count__c,
				(SELECT Id 
				FROM CAMPX__Plants__r 
				WHERE isUnhealthy__c = true) 
			FROM CAMPX__Garden__c 
			WHERE Id IN :gardenIds];

		for (CAMPX__Garden__c garden : gardensToUpdate) {
			garden.CAMPX__Total_Unhealthy_Plant_Count__c = garden.CAMPX__Plants__r.size();
		}

		update gardensToUpdate;
	}

	private static void setTotalPlantCountOnGarden(List<CAMPX__Plant__c> newRecords,Map<Id,CAMPX__Plant__c> oldRecordsMap) {
		Set<Id> gardenIds = new Set<Id>();
		for (CAMPX__Plant__c plant : newRecords) { 
			gardenIds.add(plant.CAMPX__Garden__c);
			if (oldRecordsMap != null && plant.CAMPX__Garden__c != oldRecordsMap.get(plant.Id).CAMPX__Garden__c) {
				gardenIds.add(oldRecordsMap.get(plant.Id).CAMPX__Garden__c);
			}
		}

		List<CAMPX__Garden__c> gardensToUpdate = [
			SELECT Id, CAMPX__Total_Plant_Count__c,
				(SELECT Id 
				FROM CAMPX__Plants__r) 
			FROM CAMPX__Garden__c 
			WHERE Id IN :gardenIds];


		for (CAMPX__Garden__c garden : gardensToUpdate) {
			garden.CAMPX__Total_Plant_Count__c = garden.CAMPX__Plants__r.size();
		}

		update gardensToUpdate;
	}

	private static void setDefaultValuesOnNewRecords(List<CAMPX__Plant__c> newRecords) {
		List<CAMPX__Plant__c> plantsToUpdate = [SELECT CAMPX__Soil_Type__c , CAMPX__Water__c , CAMPX__Sunlight__c ,CAMPX__Garden__r.CAMPX__Sun_Exposure__c 
													FROM CAMPX__Plant__c 
													WHERE Id IN :newRecords];

			for (CAMPX__Plant__c plant : plantsToUpdate ) {
				if(String.isEmpty(plant.CAMPX__Soil_Type__c)) { 
					plant.CAMPX__Soil_Type__c = 'All Purpose Potting Soil';
				}
				if(String.isEmpty(plant.CAMPX__Water__c)) {
					plant.CAMPX__Water__c = 'Once Weekly';
				}
				if(String.isEmpty(plant.CAMPX__Sunlight__c)) { 
					if (String.isEmpty(plant.CAMPX__Garden__r.CAMPX__Sun_Exposure__c)) {
						plant.CAMPX__Sunlight__c = 'Partial Sun';
					} else {
						plant.CAMPX__Sunlight__c = plant.CAMPX__Garden__r.CAMPX__Sun_Exposure__c;
					}
				}
			}
			
		update plantsToUpdate ;
	}

}