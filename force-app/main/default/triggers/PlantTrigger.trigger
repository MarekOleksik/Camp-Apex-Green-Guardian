trigger PlantTrigger on CAMPX__Plant__c (after insert, after update, after delete) {

	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
		  PlantTriggerHandler.onAfterInsert(Trigger.new); 
		}
		if (Trigger.isUpdate) {
			PlantTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap); 
		}
		if (Trigger.isDelete) {
			PlantTriggerHandler.onAfterDelete(Trigger.old); 
		}
	}
}