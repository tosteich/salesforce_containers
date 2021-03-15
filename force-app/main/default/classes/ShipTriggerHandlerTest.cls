@isTest
public with sharing class ShipTriggerHandlerTest {

    private static final Integer RECORDS_NUMBER = 6;

    @TestSetup
    static void makeData(){
  
        List<Contact> captains = new List<Contact>();
        for (Integer i = 0; i < RECORDS_NUMBER; i++) {
            captains.add(new Contact(FirstName ='FirstName' + i, 
                                        LastName = 'LastName' + i, 
                                        Email = 'con'+ i + '@email.com'
                                        ));
        }
        insert captains;

        List<Ship__c> ships = new List<Ship__c>();
        Integer middle = RECORDS_NUMBER / 2;
        for (Integer i = 0; i < RECORDS_NUMBER; i++) {
            String shipDetails = i > middle ? 'Some details': '';
            ships.add(new Ship__c(Name ='ShipName' + i, 
                                Serial_Number__c = 'STA-' + i, 
                                Ship_Class__c = 'Panamax',
                                Breadth_m__c = i,
                                Capacity_TEU__c = i,
                                Depth_m__c = i,
                                Length_m__c = i,
                                Captain__c = captains.get(i).Id,
                                Contract_Start_Date__c = date.newinstance(2020, 1, 1),
                                Contract_Due_Date__c = Date.today(),
                                Ship_Details__c = shipDetails
                                ));
               
        }
        insert ships;
        
    }

    @isTest
    static void checkPreventClassChangeTest() {

        List<Ship__c> ships = [SELECT Id, Ship_Class__c FROM Ship__c];

        for (Ship__c ship : ships) {
            ship.Ship_Class__c = 'Feeder';
        }
     
        Test.startTest();
        List<Database.SaveResult> results = Database.update(ships, false);
        Test.stopTest();

        boolean isSuccess = false;
        Integer errors = 0;

        for (Database.SaveResult result: results) {
            if (result.isSuccess()) {
                isSuccess = true;
            }
            if (result.getErrors().size() > 0) {
                errors++;
            }

        }

        System.assert(!isSuccess);
        System.assertEquals(errors, RECORDS_NUMBER);
        System.assertEquals(Constants.SHIP_CLASS_CHANGE_ERROR_MESSAGE,
                             results.get(0).getErrors()[0].getMessage());

    }

    @isTest
    static void checkChangeContractDueDateTest() {

        List<Ship__c> ships = [SELECT Id, Name FROM Ship__c];

        for (Integer i = 0; i < RECORDS_NUMBER; i++) {
            ships.get(i).Contract_Due_Date__c = Date.today().addDays(10);
        }
     
        Test.startTest();
        List<Database.SaveResult> results = Database.update(ships, false);
        Test.stopTest();

        boolean isSuccess = true;

        for (Database.SaveResult result: results) {
            if (result.isSuccess() == false) {
                isSuccess = false;
                break;
            }
        }

        System.assert(isSuccess);
        System.assertEquals(results.size(), RECORDS_NUMBER);

    }

    @isTest
    static void addRowToShipDetailsTest() {

        List<Ship__c> ships = [SELECT Serial_Number__c, Name, Ship_Details__c FROM Ship__c];

        boolean isIncluded = true;

        for (Ship__c ship : ships) {
            String row = ship.Serial_Number__c + ' ' + ship.name;
            if (!ship.Ship_Details__c.contains(row)) {
                isIncluded = false;
                break;
            }

        }

        System.assert(isIncluded);

    }

    @isTest
    static void checkChangeCaptainAndSendEmailTest() {
        //Checking only few records due to limitation on mass mail sending in dev org
        Integer recordsLimit = 3;
        List<Ship__c> ships = [SELECT Id, Name FROM Ship__c LIMIT :recordsLimit];
        List<Contact> captains = [SELECT Id FROM Contact LIMIT :recordsLimit];

        for (Integer i = 0; i < recordsLimit; i++) {
            Integer j = (i < recordsLimit - 1)? i + 1 : 0;
            ships.get(i).Captain__c = captains.get(j).Id; 
        }

        Test.startTest();
        List<Database.SaveResult> results = Database.update(ships, false);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        boolean isSuccess = true;

        for (Database.SaveResult result: results) {
            if (result.isSuccess() == false) {
                isSuccess = false;
                break;
            }
        }

        System.assert(isSuccess);
        System.assertEquals(results.size(), recordsLimit);
        System.assertEquals(1, invocations, 'An email should be sent');

    }

}
