@isTest
public with sharing class TestDataFactory {
    
    public static List<Consignment__c> generateConsignmentRecords (List <Container__c> containers, Voyage__c voyage, Integer loops) {

        List<Consignment__c> consignments = new List<Consignment__c>();
        Integer recordsNumber = containers.size() * loops;
        Integer cntrs = containers.size();

        for (Integer i = 0; i < recordsNumber; i++) {
            Integer j = math.mod(i, cntrs);
            consignments.add(new Consignment__c(Container__c = containers.get(j).Id,
                                                Voyage__c = voyage.Id,
                                                Weight_kg__c = 2000,
                                                Goods__c = 'Grain'
                                                ));
        }

        return consignments;

    }


}
