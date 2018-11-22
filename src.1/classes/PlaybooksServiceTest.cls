@IsTest
private with sharing class PlaybooksServiceTest 
{
	@testSetup
	private	static void createTestData()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Playbook__c playbook = new Playbook__c(Name = 'Test Playbook',
		Active__c = true,
        Survey_to_be_Sent__c = 'Fast Track Survey');

		uow.registerNew(playbook);
		Task t1 = new Task();
		t1.Subject = 'Task 1';
		t1.Playbook_Number_of_Days__c = 5;
		t1.Playbook_Before_After__c = 'After';
		t1.ActivityDate = Date.today();
		uow.registerNew(t1, Task.WhatId, playbook);
		Account a = TestUtilities.insertBasicAccount(true);

		uow.commitWork();
	}

	@IsTest
	private	static void addPlaybookToAccount()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Set<Id> playbookIds = new Map<Id, Playbook__c>([SELECT Id FROM Playbook__c]).keySet();
		Id accountId = [SELECT Id FROM Account LIMIT 1].Id;

		PlaybooksService.addPlaybooks(accountId, playbookIds, uow);
		uow.commitWork();

		Case[] newCases = CasesSelector.newInstance().selectByAccountIdWithTasks(new Set<Id>{accountId});
		System.assertEquals(1, newCases.size());
		System.assertEquals(1, newCases[0].Tasks.size());
		System.assertEquals(Date.today().addDays(5), newCases[0].Tasks[0].ActivityDate);
        System.assertEquals('Fast Track Survey', newCases[0].Survey_to_be_Sent__c);
	}

	@IsTest
	private	static void testPlaybookController()
	{
		Account a = [SELECT Id FROM Account LIMIT 1];
		
		Test.startTest();

		ApexPages.StandardController stdController = new ApexPages.StandardController(a);
		PageReference pageRef = Page.Playbooks;
		pageRef.getParameters().put('id', a.Id);
		
		Test.setCurrentPage(pageRef);

		Playbook_Controller controller = new Playbook_Controller(stdController);
		controller.getPlaybooks();
		controller.addRemove();
		controller.cancel();
		controller.saveAddRemove();

		Test.stopTest();
	}
}