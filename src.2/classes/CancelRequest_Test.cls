@isTest
private class CancelRequest_Test {
	
	@testSetup static void testData() {

        Account a = TestUtilities.insertBasicAccount(true);

    }

    @isTest static void activeChangeTest() {

    	Account a = [SELECT Id FROM Account LIMIT 1];
    	Product2 p = [SELECT Id FROM Product2 LIMIT 1];

    	Asset ast = new Asset(Name = 'Test Asset',
    		AccountId = a.Id,
    		Product2Id = p.Id,
    		Active__c = false);

    	insert ast;

    	Opportunity o = TestUtilities.insertRecordTypeOpportunity(a.Id, 'Retention');

    	Cancel_Request__c cr = new Cancel_Request__c(Asset__c = ast.Id,
    		Opportunity__c = o.Id);

    	insert cr;

    	Test.startTest();

    	cr.Stage__c = 'Save';
        cr.Original_Setup_Fee__c = 399;
        cr.Current_MSF__c = 379;
        cr.Most_Recent_Contract_Date__c = Date.today().addDays(-30);
        cr.Cancellation_Reasons__c = 'Not interested';
        cr.Cancel_Request_Type__c = 'Trial';
        cr.Save_MSF__c = 359;
        cr.Months_Gained__c = 2;
        cr.Description__c = 'Description';
        cr.Projected_Contract_Expiration_Renewal__c = Date.today().addDays(5);
        cr.Months_Paid_Trial__c = 1;
    	update cr;

    	Test.stopTest();

    }
}