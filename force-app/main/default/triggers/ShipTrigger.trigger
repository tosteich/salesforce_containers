trigger ShipTrigger on Ship__c (before insert, before update, before delete,
                                    after insert, after update, after delete) {
                                        
    new ShipTriggerHandler().run();

}