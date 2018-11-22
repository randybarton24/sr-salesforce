@isTest
private class CorporateISBStatusUpdate_Batch_Test 
{	
	@testSetup static void setupTestData()
	{
		Account parentacc = TestUtilities.insertBasicAccount(true);
		Account acc = TestUtilities.insertBasicAccount(false);
		parentacc.RecurSoft__Status__c = 'Cancelled';
		parentacc.Type = 'Corporate';
		update parentacc;
		acc.ParentId = parentacc.Id;
		acc.RecurSoft__Status__c = 'Active';
		update acc;
	}

	@isTest	static void test_method_one() 
	{
		Account parentacc = [SELECT Id,RecurSoft__Status__c FROM Account WHERE ParentId = null LIMIT 1];
		Account acc = [SELECT Id,RecurSoft__Status__c FROM Account WHERE ParentId != null LIMIT 1];

		Test.startTest();
		
        CorporateISBStatusUpdate_Batch batch = new CorporateISBStatusUpdate_Batch();
        Database.executebatch(batch);
        
        Test.stopTest();

        Account acct = [SELECT Id,RecurSoft__Status__c FROM Account WHERE Id = :parentacc.Id LIMIT 1];
		System.assertEquals('Active', acct.RecurSoft__Status__c);
	}
	
	@isTest static void test_method_two() 
	{
		Account parentacc = [SELECT Id,RecurSoft__Status__c FROM Account WHERE ParentId = null LIMIT 1];
		Account acc = [SELECT Id,RecurSoft__Status__c FROM Account WHERE ParentId != null LIMIT 1];
		acc.RecurSoft__Status__c = 'Cancelled';
		update acc;
		
		Test.startTest();
		
        CorporateISBStatusUpdate_Batch batch = new CorporateISBStatusUpdate_Batch();
        Database.executebatch(batch);
        
        Test.stopTest();

        Account acct = [SELECT Id,RecurSoft__Status__c FROM Account WHERE Id = :parentacc.Id LIMIT 1];
		System.assertEquals('Cancelled', acct.RecurSoft__Status__c);
	}
	
	@isTest static void test_method_three() 
	{
		Account parentacc = [SELECT Id,RecurSoft__Status__c FROM Account WHERE ParentId = null LIMIT 1];
		Account acc = [SELECT Id,RecurSoft__Status__c FROM Account WHERE ParentId != null LIMIT 1];
		Account acc1 = TestUtilities.insertBasicAccount(false);
		acc1.ParentId=parentacc.Id;
		acc1.RecurSoft__Status__c = 'Active';
		update acc1;

		Test.startTest();
		
        CorporateISBStatusUpdate_Batch batch = new CorporateISBStatusUpdate_Batch();
        Database.executebatch(batch);
        
        Test.stopTest();

        Account acct = [SELECT Id,RecurSoft__Status__c FROM Account WHERE Id = :parentacc.Id LIMIT 1];
		System.assertEquals('Active', acct.RecurSoft__Status__c);
	}

	@isTest static void test_method_four() 
	{
		Account parentacc = [SELECT Id,RecurSoft__Status__c FROM Account WHERE ParentId = null LIMIT 1];
		Account acc = [SELECT Id,RecurSoft__Status__c FROM Account WHERE ParentId != null LIMIT 1];
		Account acc1 = TestUtilities.insertBasicAccount(false);
		acc1.ParentId=parentacc.Id;
		acc1.RecurSoft__Status__c = 'Cancelled';
		update acc1;

		Test.startTest();
		
        CorporateISBStatusUpdate_Batch batch = new CorporateISBStatusUpdate_Batch();
        Database.executebatch(batch);
        
        Test.stopTest();

        Account acct = [SELECT Id,RecurSoft__Status__c FROM Account WHERE Id = :parentacc.Id LIMIT 1];
		System.assertEquals('Active', acct.RecurSoft__Status__c);
	}
}