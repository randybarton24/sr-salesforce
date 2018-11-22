@isTest
private class AddendaTest {
	
	@testSetup static void testData() {

        Account a = TestUtilities.insertBasicAccount(true);
    }

    @isTest static void activeChangeTest() {

    	Account a = [SELECT Id FROM Account LIMIT 1];
    	Product2 p = [SELECT Id FROM Product2 WHERE Family = 'SR Platform' LIMIT 1];

    	Asset ast = new Asset(Name = 'Test Asset',
    		AccountId = a.Id,
    		Product2Id = p.Id,
    		Active__c = false);
    	insert ast;

    	Addendum__c add = new Addendum__c(Account__c = a.Id,
    		Name = 'Test Addendum');

    	insert add;

    	Addendum_Line_Item__c ali = new Addendum_Line_Item__c(Addendum__c = add.Id,
    		Asset__c = ast.Id);

    	insert ali;

    	Addendum_Snippet__c snip = new Addendum_Snippet__c(Name = 'SR_Defer_Billing__c',
    		Snippet_Text__c = 'test snippet text');

    	insert snip;

    	Test.startTest();

    	ali.Defer_Billing__c = true;
    	ali.Deferred_Months__c = 2;
    	update ali;

    	Test.stopTest();

    }
}