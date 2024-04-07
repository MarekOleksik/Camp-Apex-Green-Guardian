public class GardenTriggerHandler {

	private static final String PERMANENT_CLOSURE_STATUS = 'Permanent Closure';
	private static final String OPERATIONAL_STATUS = 'Operational';
	private static final String TEMPORARY_CLOSURE_STATUS = 'Temporary Closure';
	private static final String OVER_CAPACITY_STATUS = 'Over Capacity';
	private static final String AWAITING_RESOURCES_STATUS = 'Awaiting Resources';
	private static final String COMPLETED_STATUS = 'Completed';


	public static void onBeforeInsert(List<CAMPX__Garden__c > newRecords) {
		setDefaultValuesOnNewRecords(newRecords);  
		setManagerStartDate(newRecords, null);
		calculateCapacity(newRecords, null);
		calculateHealthIndex(newRecords, null);
		setGardenStatus(newRecords, null);
	}
	
	public static void onAfterInsert(List<CAMPX__Garden__c > newRecords) {
		createTasksWhenManagerIsPopulated(newRecords, null);
	}

	public static void onBeforeUpdate(List<CAMPX__Garden__c > newRecords, Map<Id,CAMPX__Garden__c> oldRecordsMap) { 
		setManagerStartDate(newRecords, oldRecordsMap);
		calculateCapacity(newRecords, oldRecordsMap);
		calculateHealthIndex(newRecords, oldRecordsMap);
		setGardenStatus(newRecords, oldRecordsMap);
	}
	
	public static void onAfterUpdate(List<CAMPX__Garden__c > newRecords, Map<Id,CAMPX__Garden__c> oldRecordsMap) {
		createTasksWhenManagerIsPopulated(newRecords, oldRecordsMap);
	}

	private static void setGardenStatus(List<CAMPX__Garden__c > newRecords, Map<Id,CAMPX__Garden__c> oldRecordsMap) {
		for (CAMPX__Garden__c garden : newRecords) {  
			if (garden.CAMPX__Status__c != PERMANENT_CLOSURE_STATUS
				&& (oldRecordsMap == null 
				|| (garden.CAMPX__Total_Plant_Count__c != oldRecordsMap.get(garden.Id).CAMPX__Total_Plant_Count__c) 
				|| (garden.CAMPX__Capacity__c != oldRecordsMap.get(garden.Id).CAMPX__Capacity__c) 
				|| (garden.CAMPX__Health_Index__c != oldRecordsMap.get(garden.Id).CAMPX__Health_Index__c) 
				|| (garden.CAMPX__Minimum_Plant_Count__c != oldRecordsMap.get(garden.Id).CAMPX__Minimum_Plant_Count__c))) {
				garden.CAMPX__Status__c = setStatusForGarden(garden);
				}
		}
	}

	private static String setStatusForGarden(CAMPX__Garden__c garden) {
		if (garden.CAMPX__Capacity__c >= 70 
			&& garden.CAMPX__Capacity__c <= 100 
			&& garden.CAMPX__Total_Plant_Count__c >= garden.CAMPX__Minimum_Plant_Count__c 
			&& garden.CAMPX__Health_Index__c >= 70) {
				return garden.CAMPX__Status__c = OPERATIONAL_STATUS;	
		} else if (garden.CAMPX__Capacity__c == 0) {
			return garden.CAMPX__Status__c = TEMPORARY_CLOSURE_STATUS;
		} else if (garden.CAMPX__Capacity__c > 100) {
			return garden.CAMPX__Status__c = OVER_CAPACITY_STATUS;
		} else if ((garden.CAMPX__Capacity__c > 0
					&& garden.CAMPX__Capacity__c < 70) 
					|| garden.CAMPX__Health_Index__c < 70 
					|| garden.CAMPX__Total_Plant_Count__c < garden.CAMPX__Minimum_Plant_Count__c) {
			return garden.CAMPX__Status__c = AWAITING_RESOURCES_STATUS;
		}
		return '';
	}

	private static void calculateHealthIndex(List<CAMPX__Garden__c > newRecords, Map<Id,CAMPX__Garden__c> oldRecordsMap) {
		for (CAMPX__Garden__c garden : newRecords) {  
			if (oldRecordsMap == null 
				|| (garden.CAMPX__Total_Plant_Count__c != oldRecordsMap.get(garden.Id).CAMPX__Total_Plant_Count__c) 
				|| (garden.CAMPX__Total_Unhealthy_Plant_Count__c != oldRecordsMap.get(garden.Id).CAMPX__Total_Unhealthy_Plant_Count__c)) {
				garden.CAMPX__Health_Index__c = calculateHealthIndexForGarden(garden);
				}
		}
	}

	private static Decimal calculateHealthIndexForGarden(CAMPX__Garden__c garden) {
		if (garden.CAMPX__Total_Plant_Count__c != null && garden.CAMPX__Total_Unhealthy_Plant_Count__c != null && garden.CAMPX__Total_Plant_Count__c != 0){
			return ((garden.CAMPX__Total_Plant_Count__c - garden.CAMPX__Total_Unhealthy_Plant_Count__c)/garden.CAMPX__Total_Plant_Count__c)*100;
		} else {
			return 0;
		}
	}

	private static void calculateCapacity(List<CAMPX__Garden__c > newRecords, Map<Id,CAMPX__Garden__c> oldRecordsMap) {
		for (CAMPX__Garden__c garden : newRecords) { 
			if (oldRecordsMap == null 
				|| (oldRecordsMap != null && (garden.CAMPX__Total_Plant_Count__c != oldRecordsMap.get(garden.Id).CAMPX__Total_Plant_Count__c 
				|| garden.CAMPX__Max_Plant_Count__c != oldRecordsMap.get(garden.Id).CAMPX__Max_Plant_Count__c))) {
					Decimal totalPlants = garden.CAMPX__Total_Plant_Count__c ?? 0;
					Decimal maxPlants =  garden.CAMPX__Max_Plant_Count__c ?? 0;
				if (maxPlants != 0) {
					garden.CAMPX__Capacity__c = totalPlants / maxPlants * 100;
				} else {
					garden.CAMPX__Capacity__c = 0;
				}
			}
		}
	}

	private static void setManagerStartDate(List<CAMPX__Garden__c> newRecords, Map<Id,CAMPX__Garden__c> oldRecordsMap ) {
		for (CAMPX__Garden__c garden : newRecords) { 
			if ((oldRecordsMap == null && garden.CAMPX__Manager__c != null) 
				|| (garden.CAMPX__Manager__c != null && garden.CAMPX__Manager__c != oldRecordsMap.get(garden.Id).CAMPX__Manager__c)) {
				garden.CAMPX__Manager_Start_Date__c = Date.today();
			} else if (garden.CAMPX__Manager__c == null && oldRecordsMap != null && oldRecordsMap.get(garden.Id).CAMPX__Manager__c != null) {
				garden.CAMPX__Manager_Start_Date__c = null;
			}
		}
	}

	private static void setDefaultValuesOnNewRecords(List<CAMPX__Garden__c > newRecords) {
		for (CAMPX__Garden__c garden : newRecords) {
			if (String.isBlank(garden.CAMPX__Status__c)) {
				garden.CAMPX__Status__c = AWAITING_RESOURCES_STATUS;
			}
			if (garden.CAMPX__Max_Plant_Count__c == null) {
				garden.CAMPX__Max_Plant_Count__c = 100;
			}
			if (garden.CAMPX__Minimum_Plant_Count__c == null) {
				garden.CAMPX__Minimum_Plant_Count__c = 1;
			}
			if (garden.CAMPX__Total_Plant_Count__c == null) {
				garden.CAMPX__Total_Plant_Count__c = 0;
			}
			if (garden.CAMPX__Total_Unhealthy_Plant_Count__c == null) {
				garden.CAMPX__Total_Unhealthy_Plant_Count__c = 0;
			}
		}
	}
	
	private static void createTasksWhenManagerIsPopulated(List<CAMPX__Garden__c> newRecords, Map<Id,CAMPX__Garden__c> oldRecordsMap ) {
		List<Task> tasksToInsert = new List<Task>();
		Map<String,Id> oldManagerWithGardenToNewManagerMap = new Map<String,Id>();
		Set<String> oldManagerWithGardenList = new Set<String>();
		
			 for (CAMPX__Garden__c garden : newRecords) {
				 if ((oldRecordsMap == null && garden.CAMPX__Manager__c != null) || (garden.CAMPX__Manager__c != null && oldRecordsMap.get(garden.Id).CAMPX__Manager__c == null )) {
					 tasksToInsert.add(createTask(garden.Id, garden.CAMPX__Manager__c, 'Acquire Plants'));
				 } else if(garden.CAMPX__Manager__c != null && oldRecordsMap.get(garden.Id).CAMPX__Manager__c != null && garden.CAMPX__Manager__c != oldRecordsMap.get(garden.Id).CAMPX__Manager__c ) {
					String key = oldRecordsMap.get(garden.Id).CAMPX__Manager__c + '-' + garden.Id;
					oldManagerWithGardenToNewManagerMap.put(key, garden.CAMPX__Manager__c);
				 } else if(garden.CAMPX__Manager__c == null  && oldRecordsMap != null && oldRecordsMap.get(garden.Id).CAMPX__Manager__c != null) {
					String key = oldRecordsMap.get(garden.Id).CAMPX__Manager__c + '-' + garden.Id;
					oldManagerWithGardenList.add(key);
				 }
			 }
			 
		insert tasksToInsert;
		
		if (oldManagerWithGardenToNewManagerMap.size() > 0) {
			reassignActiveTasks(oldManagerWithGardenToNewManagerMap);
		}

		if (oldManagerWithGardenList.size() > 0) {
			deleteActiveTasks(oldManagerWithGardenList);
		}
	}

	private static void deleteActiveTasks(Set<String> oldManagerWithGardenList) {
		List<Task> tasks = getActiveTasks(oldManagerWithGardenList);
		delete tasks;
	}
	
	private static void reassignActiveTasks(Map<String,Id> oldManagerWithGardenToNewManagerMap) {
		List<Task> activeTasks =  getActiveTasks(oldManagerWithGardenToNewManagerMap.keySet());
		
		for(Task task : activeTasks) {
			String key = task.OwnerId + '-' + task.WhatId;
			if (oldManagerWithGardenToNewManagerMap.containsKey(key)) {
			   task.OwnerId = oldManagerWithGardenToNewManagerMap.get(key);
		   }
		}
		
		update activeTasks;
	}

	private static List<Task> getActiveTasks(Set<String> oldManagerWithGardenList) { 
		Set<Id> gardenIds = new Set<Id>();
		Set<Id> oldManagers= new Set<Id>();
		for (String key : oldManagerWithGardenList) {
			String[] keys = key.split('-');
			oldManagers.add(keys[0]);
			gardenIds.add(keys[1]); 
		}
		return [SELECT Id, OwnerId, WhatId FROM Task WHERE Status != :COMPLETED_STATUS AND WhatId IN :gardenIds AND OwnerId IN :oldManagers];
	}

	
	private static Task createTask(Id whatId, Id ownerId, String subject) {
		return new Task(Subject = subject, WhatId = whatId, OwnerId = ownerId);
	}
	
}