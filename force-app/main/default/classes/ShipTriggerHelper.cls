public with sharing class ShipTriggerHelper {

    /**
     * @description Function to prevent changes in Ship's class when record is updating
     * @author      Konstantin Konstantinov
     * @date        Created: 13-Mar-2021
     * @event       Before Update
     * @param       newShips: new Ship records
     * @param       oldShips: old Ship records 
     */
    
    public static void preventShipClassChange (List <Ship__c> newShips, Map <Id, Ship__c> oldShips) {

        for (Ship__c newShip: newShips) {
            Ship__c oldShip = oldShips.get(newShip.ID);
            if (oldShip.Ship_Class__c != newShip.Ship_Class__c) {
                newShip.addError(Constants.SHIP_CLASS_CHANGE_ERROR_MESSAGE);
            }
        }
    }

    /**
     * @description Function to add row in Ship's details when record is creating
     * @author      Konstantin Konstantinov
     * @date        Created: 13-Mar-2021
     * @event       Before Insert
     * @param       newShips: new Ship records
     */

    public static void addRowToShipDetails (List <Ship__c> newShips) {
        for (Ship__c newShip: newShips) {
            String newRow = newShip.Serial_Number__c + ' ' + newShip.name;
            if (newShip.Ship_Details__c == null || String.isEmpty(newShip.Ship_Details__c)) {
                newShip.Ship_Details__c = newRow;
            } else {
                String shipDetails = newShip.Ship_Details__c;
                newShip.Ship_Details__c = shipDetails + '\n' + newRow;
            }
        }
    }

    /**
     * @description Function to monitor changes in Ship's Contract due date and call
     *              notification composer and sender if changes are present.
     * @author      Konstantin Konstantinov
     * @date        Created: 13-Mar-2021
     * @event       After Update
     * @param       newShips: new Ship records
     * @param       oldShips: old Ship records 
     */    

    public static void sendNotificationIfContractDateChanged (List <Ship__c> newShips, Map <Id, Ship__c> oldShips) {

        List <Ship__c> changedContractShips = new List <Ship__c>();  

        for (Ship__c newShip: newShips) {
            Ship__c oldShip = oldShips.get(newShip.ID);
            if (oldShip.Contract_Due_Date__c != newShip.Contract_Due_Date__c) {
                changedContractShips.add(newShip);
            }
        }
    
        if (changedContractShips.size() > 0) {

            CustomNotificationType notificationType = [SELECT Id 
                                                                FROM CustomNotificationType
                                                                WHERE DeveloperName = :Constants.CUSTOM_NOTIFICATION_NAME
                                                                ];

            List <User> users = [SELECT Id 
                                        FROM User 
                                        WHERE UserRole.Name = :Constants.DIRECTOR_OF_TRANSPORTATION_ROLE 
                                        AND isActive = true
                                        ];

            Set<String> usersToNotify = new Set<String>();

            for (User usr : users) {
                usersToNotify.add(usr.Id);
            }

            for (Ship__c ship : changedContractShips) {
                //There is no functionality to bulkify sending of list of notifications, so sending for each ship separately
                notifyUsers(notificationType, usersToNotify, ship);
            }

        }

    }

    /**
     * @description Function creating and sending custom notification about Ship record in list of users
     * @author      Konstantin Konstantinov
     * @date        Created: 13-Mar-2021
     * @param       notificationType: type of custom notification using
     * @param       recipientsIds: list of recepients' ID
     * @param       ship: record used for notification
     */  

    private static void notifyUsers (CustomNotificationType notificationType , Set<String> recipientsIds, Ship__c ship) {

        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(Constants.NOTIFICATION_TITLE);
        notification.setBody(Constants.NOTIFICATION_BODY_START + ship.name + Constants.NOTIFICATION_BODY_END);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(ship.Id);
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug(Constants.NOTIFICATION_SENDING_ERROR_MESSAGE + e.getMessage());
        }

    }

    /**
     * @description Function sending emails to just assigned Captains of Ship's.
     * @author      Konstantin Konstantinov
     * @date        Created: 13-Mar-2021
     * @param       newShips: new Ship records
     * @param       oldShips: old Ship records 
     */  

    public static void sendEmailToCaptain(List <Ship__c> newShips, Map <Id, Ship__c> oldShips) {

        Map <Id, Ship__c> changedCaptainShips = new Map <Id, Ship__c>();  

        for (Ship__c newShip: newShips) {
            Ship__c oldShip = oldShips.get(newShip.ID);
            if (oldShip.Captain__c != newShip.Captain__c) {
                changedCaptainShips.put(newShip.Id, newShip);
            }
        }

        if (changedCaptainShips.size() > 0) {
            sendEmailToCaptain(changedCaptainShips);
        }

    }

    /**
     * @description Function sending emails to new Captains of Ship's.
     * @author      Konstantin Konstantinov
     * @date        Created: 13-Mar-2021
     * @param       ships: Ship records which Captains who shall get email notification
     */  

    public static void sendEmailToCaptain(Map <Id, Ship__c> ships) {

        Map <Id, Ship__c> relatedCaptains = new Map<Id, Ship__c> ([SELECT  Id, 
                                                                            Captain__r.Name 
                                                                            FROM Ship__c
                                                                            WHERE Id IN :ships.keySet()
                                                                            ]);

        List <Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for (Id id: ships.keyset()) {
            mails.add(createEmailToShipCaptain(ships.get(id), relatedCaptains.get(id)));
        }

        Messaging.sendEmail(mails);

    }

    /**
     * @description Function creating email to new Captain of Ship.
     * @author      Konstantin Konstantinov
     * @date        Created: 13-Mar-2021
     * @param       ship: Ship record with new Captain
     * @param       relatedCaptain: Ship record with details of new Captain
     * @return      mail: generated email with Ship's details addressed to Ship's Captain
     */  

    private static Messaging.SingleEmailMessage createEmailToShipCaptain (Ship__c ship, Ship__c relatedCaptain) {

        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();

        mail.setTargetObjectId(ship.Captain__c);
        mail.setReplyTo(ship.LastModifiedBy.Email);
        mail.setSenderDisplayName(ship.LastModifiedBy.Name);
        mail.setSubject(Constants.EMAIL_SUBJECT_START + ship.Name + Constants.EMAIL_SUBJECT_END);
        String body = Constants.EMAIL_BODY_DEAR_CPT + relatedCaptain.Captain__r.Name 
                        + Constants.EMAIL_BODY_SHIP_DETAILS + ship.Ship_Details__c
                        + Constants.EMAIL_BODY_SHIP_CAPACITY + ship.Capacity_TEU__c;
        mail.setHtmlBody(body);

        return mail;

    }

}
