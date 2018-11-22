@IsTest
private with sharing class SalesSchedulingSuccessCoach_Test 
{
	@testSetup
	private	static void createTestData()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Account a = TestUtilities.insertBasicAccount(true);
		a.Success_Coach__c = UserInfo.getUserId();
		uow.registerDirty(a);
		Opportunity o = TestUtilities.insertBasicOpportunity(a.Id);

		uow.commitWork();
	}

	@IsTest
	private	static void testController()
	{
		Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
		
		Test.startTest();

		ApexPages.StandardController stdController = new ApexPages.StandardController(o);
		PageReference pageRef = Page.SalesSchedulingSuccessCoach;
		pageRef.getParameters().put('id', o.Id);
		
		Test.setCurrentPage(pageRef);

		SalesSchedulingSuccessCoach_Controller controller = new SalesSchedulingSuccessCoach_Controller(stdController);
		controller.getTimeZoneDifference();
		controller.getStartTime();
		controller.getEndTime();
		controller.start();

		Test.stopTest();
	}
}