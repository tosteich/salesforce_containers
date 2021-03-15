trigger ConsignmentTrigger on Consignment__c (before insert, before update, before delete,
                                    after insert, after update, after delete) {
                                        
    new ConsignmentTriggerHandler().run();

}