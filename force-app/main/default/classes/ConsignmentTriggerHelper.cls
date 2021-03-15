public with sharing class ConsignmentTriggerHelper {

    /**
     * @description Function to prevent saving consignments which adding in bulkify method and could possible 
     *              occupy same containers which already need inspection but their status not updated yet
     * @author      Konstantin Konstantinov
     * @date        Created: 14-Mar-2021
     * @event       Before Insert
     * @param       newConsignments: new Consignments records
     */
    
    public static void preventAddConsWithWrongContainer(List <Consignment__c> newConsignments) {

        Map <Id, Box> tempContainers = createMapOfTempContainers(newConsignments);

        for (Consignment__c cons : newConsignments) {

            Box tempContainer = tempContainers.get(cons.Container__c);
            if (tempContainer.status == Constants.CONTAINER_STATUS_NEED_INSPECTION) {
                cons.addError (Constants.CONSIGNMENT_ADD_ERROR_MESSAGE);
            } else {
                tempContainer.updateStatus();
            }
        }

    } 

    /**
     * @description Function to call Approval Process for containers which used in current consignments list and 
     *              reached limited number of voyages 
     * @author      Konstantin Konstantinov
     * @date        Created: 14-Mar-2021
     * @event       After Insert
     * @param       newConsignments: new Consignments records
     */

    public static void callApproveRequestForContainers(List <Consignment__c> newConsignments) {

        Map <Id, Box> tempContainers = createMapOfTempContainers(newConsignments);                                                    

        for (Consignment__c cons : newConsignments) {

            Box tempContainer = tempContainers.get(cons.Container__c);
            tempContainer.updateStatus();
            if (tempContainer.status == Constants.CONTAINER_STATUS_NEED_INSPECTION) {
                Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
                submitRequest.setObjectId(cons.Container__c);
                Approval.ProcessResult result = Approval.process (submitRequest);
            }
            
        }

    } 
    
    private static Map <Id, Box> createMapOfTempContainers (List <Consignment__c> newConsignments) {

        Set<Id> containerIds = new Set<Id>();

        for (Consignment__c cons : newConsignments) {
            containerIds.add(cons.Container__c);
        }

        Map <Id, Container__c> loadedContainers = new Map <Id, Container__c > ([SELECT  Id, 
                                                                                Container__c.TotalVoyages__c,
                                                                                Container__c.Status__c
                                                                                FROM Container__c
                                                                                WHERE Id IN :containerIds
                                                                                ]);
        Map <Id, Box> tempContainers = new Map <Id, Box> ();
        
        for (Id contId : loadedContainers.keySet()) {
            Container__c cont = loadedContainers.get(contId);
            tempContainers.put(contId, new Box(cont));
        }

        return tempContainers;

    }
    
    private class Box {
        private Integer voyages;
        private String status;

        public Box (Container__c container) {
            this.voyages = (Integer) container.TotalVoyages__c;
            this.status = container.Status__c;
        }

        public void updateStatus () {
            if (this.status == Constants.CONTAINER_STATUS_ACTIVE) {
                this.voyages++;
                if (math.mod(this.voyages, Constants.INSPECTION_LOOP) == 0) {
                    this.status = Constants.CONTAINER_STATUS_NEED_INSPECTION;
                } 
            }
        }

    }

}
