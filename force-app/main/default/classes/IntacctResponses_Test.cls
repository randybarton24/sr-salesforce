/**
 * File:        IntacctResponses_Test.cls
 * Project:     Sererra 
 * Date:        March 7, 2013
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: Intacct Responses Test Class
 * *************************************************************************
 * History:
 */
 @isTest
public with sharing class IntacctResponses_Test 
{
    /**
     * Test method
    */
    public static testmethod void myTestMethod()
    {
    	//instantiate the controller
    	IntacctResponses testInstance = new IntacctResponses();
    	
    	//create test data
    	List<Intacct_Error__c> testRecords = CRUDSalesforceTestData.createIntacctErrors(5);
        Set<ID> testRecordsId = new Set<ID>();
        for(Intacct_Error__c testRecord : testRecords)
        {
            testRecordsId.add(testRecord.Id);
        }
    	DOM.Document testDocument = new DOM.Document();
    	String testXMLEmptyGetResponse = '<response>' +
                                                  '<operation>' + 
    	                                                 '<result>' +
											                  '<status>success</status>' +
											                  '<function>get_list</function>' +
											                  '<controlid>get_customer__' + testRecords[0].Id + '</controlid>' +
											                  '<listtype start="0" end="-1">customer</listtype>' +
											             '</result>' +
											       '</operation>' +
                                          '</response>'; 
        String testXMLGetResponseWithData = '<response>' +
											      '<operation>' +
											            '<result>' +
											                  '<status>success</status>' +
											                  '<function>get_list</function>' +
											                  '<controlid>get_customer__' + testRecords[0].Id + '</controlid>' +
											                  '<listtype start="0" end="0" total="192">customer</listtype>' +
											            '</result>' +
											      '</operation>' +
											'</response>';
		String testXMLResponseWithIntacctErrors = '<response>' +
												      '<control>' +
												            '<status>success</status>' +
												            '<senderid>sererra</senderid>' +
												            '<controlid>ControlIdHere</controlid>' +
												            '<uniqueid>false</uniqueid>' +
												            '<dtdversion>2.1</dtdversion>' +
												      '</control>' +
												      '<operation>' +
												            '<authentication>' +
												                  '<status>success</status>' +
												                  '<userid>xml_gateway_sfdc</userid>' +
												                  '<companyid>Varitronics-Copy</companyid>' +
												                  '<sessiontimestamp>2013-03-06T23:45:27-08:00</sessiontimestamp>' +
												            '</authentication>' +
												            '<result>' +
												                 '<status>failure</status>' +
												                  '<function>create_customer</function>' +
												                  '<controlid>create_intaccterror__' + testRecords[0].Id + '</controlid>' +
												                  '<errormessage>' +
												                        '<error>' +
												                              '<errorno>BL34000061</errorno>' +
												                              '<description></description>' +
												                              '<description2>Another Customer with the given value(s)  already exists</description2>' +
												                              '<correction>Use a unique value instead.</correction>' +
												                        '</error>' +
												                        '<error>' +
												                              '<errorno>BL01001973</errorno>' +
												                              '<description></description>' +
												                              '<description2>Could not create  record!</description2>' +
												                              '<correction></correction>' +
												                        '</error>' +
												                        '<error>' +
												                              '<errorno>BL01001973</errorno>' +
												                              '<description></description>' +
												                              '<description2>Could not create Customer record!</description2>' +
												                              '<correction></correction>' +
												                        '</error>' +
												                  '</errormessage>' +
												            '</result>' +
												      '</operation>' +
												'</response>';		
		Map<String, String> testActionType = new Map<String, String>();
		Map<ID, Boolean> testParseErrors = new Map<ID, Boolean>();
		
		//test controller methods											
        testDocument.load(testXMLEmptyGetResponse);     
        testActionType = testInstance.getActionType(testDocument);
        System.assertEquals(testActionType.isEmpty(), false);
        
        testDocument = new DOM.Document();
        testDocument.load(testXMLGetResponseWithData);	
        testActionType = testInstance.getActionType(testDocument);
        System.assertEquals(testActionType.isEmpty(), false);
        
        testDocument = new DOM.Document();
        testDocument.load(testXMLResponseWithIntacctErrors);	
        testParseErrors = testInstance.parseErrors(testDocument, testRecordsId, true);
        System.assertEquals(testParseErrors.isEmpty(), false);			             
    }
}