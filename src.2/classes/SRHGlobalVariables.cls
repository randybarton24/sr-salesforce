/**
 * File:        SRHGlobalVariables.cls
 * Project:     Solutionreach 
 * Date:        Feb, 2014
 * Created By:  Sid Maganti
 * *************************************************************************
 * Description: Global Class for global variables
 * *************************************************************************
 * History:
 */

global class SRHGlobalVariables 
{

	global static final String SP_BILLING_STATUS_REGULAR_INVOICING = 'Regular Invoicing';
    global static final String BILLING_FREQUENCY_ONE_TIME = 'One-Time';
    global static final String BILLING_FREQUENCY_MONTHLY = 'Monthly';
    global static final String BILLING_FREQUENCY_QUARTERLY = 'Quarterly';
    global static final String BILLING_FREQUENCY_ANNUALLY = 'Annually';
    global static final String TRANSACTION_TYPE_ENROLLMENT = 'Enrollment';
    global static final String TRANSACTION_TYPE_TRAINING_COMPLETE = 'Training Complete';
	global static final String TRANSACTION_TYPE_SUBSCRIPTION = 'Subscription Invoice';
	global static final String TRANSACTION_TYPE_USAGE = 'Usage Invoice';
	global static final String TRANSACTION_TYPE_PRO_RATED = 'Pro Rated Invoice';
	global static final String TRANSACTION_TYPE_SALES_INVOICE = 'Sales Invoice';
	global static final String STAGE_CLOSED_WON = 'Closed Won';
	global static final String STAGE_CLOSED_LOST = 'Closed Lost';
	global static final String STAGE_VERBAL_AGREEMENT = 'Verbal Agreement';
	global static final String STAGE_NEGOTIATION_REVIEW = 'Negotiation Review';
	global static final String STAGE_DEMO_COMPLETE = 'Demo Complete';
	global static final String STAGE_VY_ABANDON = 'VY-Abandon';
	global static final String STAGE_PENDING_SETUP = 'Pending Setup';
	global static final String STAGE_PROSPECTING = 'Prospecting';
	global static final String INTEGRATED = 'Success';
	global static final String NOT_INTEGRATED = 'Failure';
	global static final String OPPTY_TYPE_INITIAL_SALES = 'Initial Sales';
	global static final String OPPTY_TYPE_ADDITIONAL_SALES = 'Additional Sales';
	global static final String OPPTY_TYPE_ADJUSTMENT = 'Adjustment';
	global static final String OPPTY_TYPE_CHANGE_ORDER = 'Change Order';
	global static final String PAYMENTSTATUS_PAID = 'Paid';
	global static final String ACTION_TYPE_CREATE = 'create';
	global static final String ACTION_TYPE_UPDATE = 'update';
	global static final String STATUS_PROCESSING = 'Processing';
	global static final String MONTHLY_SERVICE_FEE = '1000';
    global static final String ADDITIONAL_PROVIDERS = '3001';
    global static final String MONTHLY_SERVICE_FEE_NEW = '3000';
    global static final String ADDITIONAL_PROVIDERS_NEW = 'AP';
    global static final String SET_UP_FEE = '2000';
    global static final String SET_UP_FEE_NEW = '4000';
    global static final String PRODUCTION_ORGID = '00Di0000000dHcr';
    global static final String READY_TO_SYNC = 'ready to sync';
    
	global static final String GET_NAME_CONTROL = 'control';
	global static final String GET_NAME_CONTROLID = 'controlid';
	global static final String GET_NAME_ERRORMESSAGE = 'errormessage';
	global static final String GET_NAME_OPERATION = 'operation';
	global static final String GET_NAME_RESULT = 'result';
	global static final String GET_NAME_FUNCTION = 'function';
	global static final String GET_NAME_ERROR = 'error';
	global static final String GET_NAME_ERRORNO = 'errorno';
	global static final String GET_NAME_DESCRIPTION = 'description';
	global static final String GET_NAME_DESCRIPTION2 = 'description2';
	global static final String GET_NAME_CORRECTION = 'correction';
	global static final String GET_NAME_STATUS = 'status';
	global static final String GET_NAME_KEY = 'key';
	global static final String GET_NAME_DATA = 'data';
	global static final String GET_NAME_SOTRANSACTION = 'sotransaction';
	global static final String GET_NAME_SOTRANSACTIONID = 'sotransactionid';
	global static final String GET_NAME_TRANSACTION_ID = 'transactionid';
	global static final String GET_NAME_PRRECORDKEY = 'prrecordkey';
	global static final String GET_NAME_TOTALAMOUNT = 'totalamount';
	global static final String GET_NAME_TOTALDUE = 'totaldue';
	global static final String GET_NAME_CUSTOMFIELDS = 'customfields';
	global static final String GET_NAME_PAYMENTSTATUS = 'paymentstatus';
	global static final String GET_NAME_RECORDNO = 'recordno';
	global static final String GET_NAME_CUSTOMER_CHARGE_CARD = 'customerchargecard';
	global static final String GET_NAME_CARD_NUM = 'cardnum';
	global static final String GET_NAME_EXP_MONTH = 'exp_month';
	global static final String GET_NAME_EXP_YEAR = 'exp_year';
	global static final String GET_NAME_CARD_TYPE = 'cardtype';	
	global static final String GET_NAME_TOTAL_DUE = 'totaldue';
	
	global static Boolean doCCardUpdate = false;
	global static Boolean updateOpportunity = false;
	global static String testResponse = '';

}