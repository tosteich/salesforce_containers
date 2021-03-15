public with sharing class ConsignmentTriggerHandler extends TriggerHandler{

    public override void beforeInsert() {
        ConsignmentTriggerHelper.preventAddConsWithWrongContainer((List <Consignment__c>) Trigger.new);
    }

    public override void afterInsert() {
        ConsignmentTriggerHelper.callApproveRequestForContainers((List <Consignment__c>) Trigger.new);
    }

    
    // There is no possibility to update container or voyage field in junction record, so no reason to init the trigger
    // before/after update.

}
