/**
 * File:        CRUDSalesforceTestData.cls
 * Project:     Sererra 
 * Date:        March 6, 2013
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: Contains methods to create/update/read/delete salesforce data used for testing.
 * *************************************************************************
 * History:
 */
global class CRUDSalesforceTestData 
{
    /**
     * Create a intacct error record
     * @return testIntacctError
    */
    public static Intacct_Error__c createIntacctError(Boolean doInsert)
    {
    	Intacct_Error__c testIntacctError = new Intacct_Error__c();
    	ObjectPrefixes allPrefixes = new ObjectPrefixes();
    	Schema.DescribeSObjectResult testDescribeSObjectResult = testIntacctError.getSObjectType().getDescribe();
        String testParentId = allPrefixes.getPrefixByObjectName(testDescribeSObjectResult.getName()) + IntacctGlobalVariables.TEST_SFDC_ID;
    	testIntacctError.Parent_Id__c = testParentId;
    	if(doInsert)
    	{
    	   insert testIntacctError;
    	}
    	return testIntacctError;
    }
    
    /**
     * Create a intacct error list of records
     * @return testIntacctErrors
    */
    public static List<Intacct_Error__c> createIntacctErrors(Integer numberOfRecords)
    {
        List<Intacct_Error__c> testIntacctErrors = new List<Intacct_Error__c>();
        for(Integer i=0; i < numberOfRecords; i++)
        {
            testIntacctErrors.add(createIntacctError(false));
        }
        insert testIntacctErrors;
        return testIntacctErrors;
    }
    
    /**
     * Create a logical expression
     * @return testLogicalExpression 
    */
    public static IntacctGetListExpression createLogicalExpression()
    {
    	IntacctGetListExpression testLogicalExpression;
    	IntacctObjectsInterface.ExpressionFilter testFilter = new IntacctObjectsInterface.ExpressionFilter();
        testFilter.fieldName = IntacctGlobalVariables.TEST_VALUE;
        testFilter.operator = IntacctGlobalVariables.TEST_VALUE;
        testFilter.value = IntacctGlobalVariables.TEST_VALUE;
        DOM.Document testDocument = new DOM.Document();
        testDocument.load('<root></root>');
        DOM.xmlNode testFilterNode = testDocument.getRootElement();
        testLogicalExpression = (new IntacctGetListExpressionAndOperator())
               .add(new IntacctGetListFilterVariable(IntacctGlobalVariables.TEST_VALUE + 'AND'))
               .add((new IntacctGetListExpressionOrOperator())
                    .add(new IntacctGetListFilterVariable(IntacctGlobalVariables.TEST_VALUE + 'OR'))
               )
               .set(IntacctGlobalVariables.TEST_VALUE + 'AND', testFilter)
               .set(IntacctGlobalVariables.TEST_VALUE + 'OR', testFilter);
    	return testLogicalExpression;
    } 
}