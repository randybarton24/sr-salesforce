@isTest
private class AssetUtilities_Test {
	
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

    	Test.startTest();

    	ast.Active__c = true;
    	update ast;

    	Test.stopTest();

    }
}