@isTest
public with sharing class ConsignmentTriggerHandlerTest {

    private static final Integer RECORDS_NUMBER = 200;

    @TestSetup
    static void makeData(){

        Contact captain = new Contact(FirstName ='Ivan', 
                                        LastName = 'Petrov', 
                                        Email = 'petrov@email.com'
                                        );

        insert captain;

        Ship__c ship = new Ship__c(Name ='ShipName', 
                                    Serial_Number__c = 'STA-1', 
                                    Ship_Class__c = 'Panamax',
                                    Breadth_m__c = 20,
                                    Capacity_TEU__c = 500,
                                    Depth_m__c = 12,
                                    Length_m__c = 180,
                                    Captain__c = captain.Id
                                    );

        insert ship;

        Voyage__c voyage = new Voyage__c (Loading_Port__c = 'Odessa',
                                            Ship__c = ship.Id
                                    );

        insert voyage;

        Integer length = 20;
        List <Container__c> containers = new List <Container__c>();
        for (Integer i = 0; i < length; i++) {
            containers.add(new Container__c(Color__c = 'RED',
                                            Container_Type__c = '20 DV',
                                            Max_Payload_kg__c = 26000,
                                            Tare_Weight_kg__c = 2300,
                                            Status__c = Constants.CONTAINER_STATUS_ACTIVE
                                           ));
        }

        insert containers;
        
    }

    @isTest
    static void checkConsignmentsInsertTest() {

        Map<Id, Container__c> containers = new Map <Id, Container__c> ([SELECT Id FROM Container__c]);
        Voyage__c voyage = [SELECT Id FROM Voyage__c];
        Integer numberOfLoops = Constants.INSPECTION_LOOP + 4;

        List<Consignment__c> consignments = TestDataFactory.generateConsignmentRecords(containers.values(), voyage, numberOfLoops);
     
        Test.startTest();
        List<Database.SaveResult> results = Database.insert(consignments, false);
        List <ProcessInstance> pInstances = [SELECT TargetObjectId, 
                                                    CreatedDate 
                                                    FROM ProcessInstance 
                                                    WHERE TargetObjectId 
                                                    IN :containers.keySet()
                                                    ];
        Test.stopTest();

        Integer success = 0;
        Integer errors = 0;
        String error;

        for (Database.SaveResult result: results) {
            if (result.isSuccess()) {
                success++;
            }
            if (result.getErrors().size() > 0) {
                if (error == null) {
                    error = result.getErrors()[0].getMessage();
                }
                errors++;
            }

        }

        Integer expectedSuccess = containers.size() * Constants.INSPECTION_LOOP;
        Integer expectedErrors = consignments.size() - expectedSuccess;

        System.assertEquals(containers.size(), pInstances.size());
        System.assertEquals(errors, expectedErrors);
        System.assertEquals(success, expectedSuccess);
        System.assertEquals(Constants.CONSIGNMENT_ADD_ERROR_MESSAGE, error);

    }

}
