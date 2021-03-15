public with sharing class ShipTriggerHandler extends TriggerHandler{

    public override void beforeInsert() {
        ShipTriggerHelper.addRowToShipDetails((List<Ship__c>) Trigger.new);
    }

    public override void beforeUpdate() {
        ShipTriggerHelper.preventShipClassChange((List<Ship__c>) Trigger.new, (Map <Id, Ship__c>) Trigger.oldMap);
    }

    public override void afterInsert() {
        ShipTriggerHelper.sendEmailToCaptain((Map <Id, Ship__c>) Trigger.newMap);
    }

    public override void afterUpdate() {
        ShipTriggerHelper.sendNotificationIfContractDateChanged((List<Ship__c>) Trigger.new, (Map <Id, Ship__c>) Trigger.oldMap);   
        ShipTriggerHelper.sendEmailToCaptain((List<Ship__c>) Trigger.new, (Map <Id, Ship__c>) Trigger.oldMap);         
    }


}
