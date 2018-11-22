/**
 * File:        IntacctGlobalVariables.cls
 * Project:     Sererra 
 * Date:        January 8, 2013
 * Created By:  Anca Comaneciu
 * *************************************************************************
 * Description: Holds all the global variables used by the integration
 * *************************************************************************
 * History:
 */
global with sharing class IntacctGlobalVariables 
{
    public static final String CONTROLID_SEPARATOR = '__';
    public static final String actionType_Create = 'create';
    public static final String actionType_Update = 'update';

    public static final String NO_ERROR_STRING = '';
    public static final String ERROR_SEVERITY = 'error';
    public static final String WARNING_SEVERITY = 'warning';
    public static final String CONFIRM_SEVERITY = 'confirm';
    public static final Integer NUMBER_OF_RECORDS_ON_PAGE = 10;
    
    //static final variables that contain response node names 
    public static final String GET_NAME_CONTROL = 'control';
    public static final String GET_NAME_CONTROLID = 'controlid';
    public static final String GET_NAME_ERRORMESSAGE = 'errormessage';
    public static final String GET_NAME_OPERATION = 'operation';
    public static final String GET_NAME_RESULT = 'result';
    public static final String GET_NAME_FUNCTION = 'function';
    public static final String GET_NAME_ERROR = 'error';
    public static final String GET_NAME_ERRORNO = 'errorno';
    public static final String GET_NAME_DESCRIPTION = 'description';
    public static final String GET_NAME_DESCRIPTION2 = 'description2';
    public static final String GET_NAME_CORRECTION = 'correction';
    public static final String GET_NAME_LISTTYPE = 'listtype';
    public static final String GET_NAME_ATTRIBUTE_END = 'end';
    public static final String GET_NAME_STATUS = 'status';
    
    //static final variable used to manipulate soql queries
    public static final String ACTION_TYPE_GROUP_BY = 'group by';
    public static final String ACTION_TYPE_PREFIX = 'prefix';
    public static final String ACTION_TYPE_DELETE = 'delete';
    
    //static final test strings
    public static final String TEST_VALUE = 'test value';
    
    public static final String CUSTOM_ERROR_OBJECT_NAME = 'Intacct_Error__c';
    public static final String TEST_SFDC_ID = '00testSfdcId';
    
    public void IntacctGlobalVariables(){}
}