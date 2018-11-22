@isTest
private class HealthgradesSyncButtonController_Test {
	
	@isTest static void testHGSyncButtonController() {
		
		Account a = TestUtilities.insertBasicAccount(true);
		Contact c = TestUtilities.insertBasicContact(a.Id);
		Provider__c p = TestUtilities.insertProvider(a.Id, c.Id, '1');

		PageReference pageRef = Page.HealthgradesSyncButton;

		pageRef.getParameters().put('id', p.Id);
		
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController stdController = new ApexPages.StandardController(p);
		HealthgradesSyncButtonController controller = new HealthgradesSyncButtonController(stdController);
	}	
}