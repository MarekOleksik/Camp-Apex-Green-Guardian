trigger GardenTrigger on CAMPX__Garden__c (before insert, before update, after insert, after update) {

    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            GardenTriggerHandler.onBeforeInsert(Trigger.new);
        } else if (Trigger.isAfter) {
            GardenTriggerHandler.onAfterInsert(Trigger.new);
        }
    }

    if (Trigger.isUpdate) {
        if (Trigger.isBefore) {
            GardenTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isAfter) {
            GardenTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        
    }

}