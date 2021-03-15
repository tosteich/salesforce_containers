public with sharing class Constants {

    public static final String CUSTOM_NOTIFICATION_NAME = 'Contracted_Ship_Due_Date';
    public static final String NOTIFICATION_TITLE = 'Ships record has been changed!';
    public static final String NOTIFICATION_BODY_START= 'Contract due date of m/v "';
    public static final String NOTIFICATION_BODY_END = '" has been changed, please review';
    public static final String NOTIFICATION_SENDING_ERROR_MESSAGE = 'Problem sending notification: ';

    public static final String EMAIL_SUBJECT_START = 'You have been assigned to ship "';
    public static final String EMAIL_SUBJECT_END = '"';
    public static final String EMAIL_BODY_DEAR_CPT = 'Dear cpt. ';
    public static final String EMAIL_BODY_SHIP_DETAILS = ',<br/>Ship details: ';
    public static final String EMAIL_BODY_SHIP_CAPACITY = '<br/>Capacity, TEUs: ';

    public static final String SHIP_CLASS_CHANGE_ERROR_MESSAGE = 'Ship\'s class can\'t be changed';

    public static final String DIRECTOR_OF_TRANSPORTATION_ROLE = 'Director of Transportation';

    public static final Integer INSPECTION_LOOP = 5;

    public static final String CONSIGNMENT_ADD_ERROR_MESSAGE = 'This consignment can\'t be added since container needs inspection';
    public static final String CONTAINER_STATUS_ACTIVE = 'Active';
    public static final String CONTAINER_STATUS_NEED_INSPECTION = 'Need Inspection';
}
