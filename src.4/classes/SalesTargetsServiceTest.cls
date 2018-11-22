@IsTest
private with sharing class SalesTargetsServiceTest 
{
	@testSetup
	private	static void createTestData()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Comp_Plan__c plan = new Comp_Plan__c();
		plan.Name = 'Comp Plan';
		uow.registerNew(plan);
		Comp_Plan_Rule__c rule1 = new Comp_Plan_Rule__c();
		rule1.Name = 'Tier 1';
		rule1.Type__c = 'Multiplier';
		rule1.Result__c = 1;
		rule1.Variable__c = 'Sales_Rep_Revenue_Credit__c';
		rule1.Operator__c = '>';
		rule1.Value__c = '1000';
		uow.registerNew(rule1, Comp_Plan_Rule__c.Comp_Plan__c, plan);
		Comp_Plan_Rule__c rule2 = new Comp_Plan_Rule__c();
		rule2.Name = 'Tier 2';
		rule2.Type__c = 'Multiplier';
		rule2.Result__c = 1.5;
		rule2.Variable__c = 'Sales_Rep_Revenue_Credit__c';
		rule2.Operator__c = '>';
		rule2.Value__c = '1000';
		rule2.Variable2__c = 'Sales_Rep_Tier_Qualify_Sales_Credit__c';
		rule2.Operator2__c = '>';
		rule2.Value2__c = '2';
		uow.registerNew(rule2, Comp_Plan_Rule__c.Comp_Plan__c, plan);

		Comp_Plan__c plan2 = new Comp_Plan__c();
		plan2.Name = 'Comp Plan Marginal';
		uow.registerNew(plan2);
		Comp_Plan_Rule__c rule_1 = new Comp_Plan_Rule__c();
		rule_1.Name = 'Tier 1';
		rule_1.Type__c = 'Marginal';
		rule_1.Result__c = 0.5;
		rule_1.Variable__c = 'Commission_Qualified_Sales__c';
		rule_1.Operator__c = '>';
		rule_1.Value__c = '0';		
		uow.registerNew(rule_1, Comp_Plan_Rule__c.Comp_Plan__c, plan2);
		Comp_Plan_Rule__c rule_2 = new Comp_Plan_Rule__c();
		rule_2.Name = 'Tier 2';
		rule_2.Type__c = 'Marginal';
		rule_2.Result__c = 1.5;
		rule_2.Variable__c = 'Commission_Qualified_Sales__c';
		rule_2.Operator__c = '>';
		rule_2.Value__c = '800';			
		uow.registerNew(rule_2, Comp_Plan_Rule__c.Comp_Plan__c, plan2);
		Comp_Plan_Rule__c rule_3 = new Comp_Plan_Rule__c();
		rule_3.Name = 'Tier 3';
		rule_3.Type__c = 'Marginal';
		rule_3.Result__c = 2.0;
		rule_3.Variable__c = 'Commission_Qualified_Sales__c';
		rule_3.Operator__c = '>';
		rule_3.Value__c = '1400';			
		uow.registerNew(rule_3, Comp_Plan_Rule__c.Comp_Plan__c, plan2);
		Comp_Plan_Rule__c rule_4 = new Comp_Plan_Rule__c();
		rule_4.Name = 'Tier 4';
		rule_4.Type__c = 'Marginal';
		rule_4.Result__c = 2.5;
		rule_4.Variable__c = 'Commission_Qualified_Sales__c';
		rule_4.Operator__c = '>';
		rule_4.Value__c = '2000';			
		uow.registerNew(rule_4, Comp_Plan_Rule__c.Comp_Plan__c, plan2);

		Sales_Target__c target = new Sales_Target__c();
		target.Sales_Rep_Revenue_Credit__c = 1001;
		target.Sales_Rep_Tier_Qualify_Sales_Credit__c = 2;
		uow.registerNew(target, Sales_Target__c.Comp_Plan__c, plan);

		uow.commitWork();
	}

	@IsTest
	private	static void calculateMultiplierWithSingleCriteria()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Set<Id> targetIds = new Map<Id, Sales_Target__c>([SELECT Id FROM Sales_Target__c]).keySet();

		SalesTargetsService.calculateMultiplier(targetIds, uow);
		uow.commitWork();

		Sales_Target__c[] targetsAfter = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		System.assertEquals(1, targetsAfter[0].Multiplier__c);
	}

	@IsTest
	private	static void calculateMultiplierWithTwoCriteria()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Set<Id> targetIds = new Map<Id, Sales_Target__c>([SELECT Id FROM Sales_Target__c]).keySet();
		Sales_Target__c[] targetsBefore = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		targetsBefore[0].Sales_Rep_Tier_Qualify_Sales_Credit__c = 3;
		uow.registerDirty(targetsBefore[0]);
		uow.commitWork();

		SalesTargetsService.calculateMultiplier(targetIds, uow);
		uow.commitWork();

		Sales_Target__c[] targetsAfter = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		System.assertEquals(1.5, targetsAfter[0].Multiplier__c);
	}

	@IsTest
	private	static void calculateAvailableCommissionTier1()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();		

		Comp_Plan__c compPlan = [SELECT Id FROM Comp_Plan__c WHERE Name = 'Comp Plan Marginal'];
		Set<Id> targetIds = new Map<Id, Sales_Target__c>([SELECT Id FROM Sales_Target__c]).keySet();
		Sales_Target__c[] targetsBefore = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		targetsBefore[0].Comp_Plan__c = compPlan.Id;
		targetsBefore[0].Commission_Qualified_Sales_Credits__c = 750;
		uow.registerDirty(targetsBefore[0]);
		uow.commitWork();
		Sales_Target__c[] targets = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		Map<Id, Comp_Plan__c> compPlanMap = new Map<Id, Comp_Plan__c>([SELECT Id, Name, 
			(SELECT Id, Type__c, Variable__c, Variable2__c, Operator__c, Operator2__c, Value__c, Value2__c, Result__c 
				FROM Comp_Plan_Rules__r ORDER BY Result__c) 
			FROM Comp_Plan__c]);

		SalesTargetsService.calculateAvailableCommission(targets[0], compPlanMap.get(targets[0].Comp_Plan__c));
		uow.commitWork();

		Sales_Target__c[] targetsAfter = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		System.assertEquals(375, targetsAfter[0].Available_Commission__c);
	}

	@IsTest
	private	static void calculateAvailableCommissionTier2()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		Comp_Plan__c compPlan = [SELECT Id FROM Comp_Plan__c WHERE Name = 'Comp Plan Marginal'];		
		Set<Id> targetIds = new Map<Id, Sales_Target__c>([SELECT Id FROM Sales_Target__c]).keySet();
		Sales_Target__c[] targetsBefore = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		targetsBefore[0].Comp_Plan__c = compPlan.Id;
		targetsBefore[0].Commission_Qualified_Sales_Credits__c = 1200;
		uow.registerDirty(targetsBefore[0]);
		uow.commitWork();
		Sales_Target__c[] targets = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		Map<Id, Comp_Plan__c> compPlanMap = new Map<Id, Comp_Plan__c>([SELECT Id, Name, 
			(SELECT Id, Type__c, Variable__c, Variable2__c, Operator__c, Operator2__c, Value__c, Value2__c, Result__c 
				FROM Comp_Plan_Rules__r ORDER BY Result__c) 
			FROM Comp_Plan__c]);

		SalesTargetsService.calculateAvailableCommission(targets[0], compPlanMap.get(targets[0].Comp_Plan__c));
		uow.commitWork();

		Sales_Target__c[] targetsAfter = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		System.assertEquals(1000, targetsAfter[0].Available_Commission__c);
	}

	@IsTest
	private	static void calculateAvailableCommissionTier3()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Comp_Plan__c compPlan = [SELECT Id FROM Comp_Plan__c WHERE Name = 'Comp Plan Marginal'];		
		Set<Id> targetIds = new Map<Id, Sales_Target__c>([SELECT Id FROM Sales_Target__c]).keySet();
		Sales_Target__c[] targetsBefore = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		targetsBefore[0].Comp_Plan__c = compPlan.Id;
		targetsBefore[0].Commission_Qualified_Sales_Credits__c = 1600;
		uow.registerDirty(targetsBefore[0]);
		uow.commitWork();
		Sales_Target__c[] targets = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		Map<Id, Comp_Plan__c> compPlanMap = new Map<Id, Comp_Plan__c>([SELECT Id, Name, 
			(SELECT Id, Type__c, Variable__c, Variable2__c, Operator__c, Operator2__c, Value__c, Value2__c, Result__c 
				FROM Comp_Plan_Rules__r ORDER BY Result__c) 
			FROM Comp_Plan__c]);

		SalesTargetsService.calculateAvailableCommission(targets[0], compPlanMap.get(targets[0].Comp_Plan__c));
		uow.commitWork();

		Sales_Target__c[] targetsAfter = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		System.assertEquals(1700, targetsAfter[0].Available_Commission__c);
	}

	@IsTest
	private	static void calculateAvailableCommissionTier4()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Comp_Plan__c compPlan = [SELECT Id FROM Comp_Plan__c WHERE Name = 'Comp Plan Marginal'];		
		Set<Id> targetIds = new Map<Id, Sales_Target__c>([SELECT Id FROM Sales_Target__c]).keySet();
		Sales_Target__c[] targetsBefore = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		targetsBefore[0].Comp_Plan__c = compPlan.Id;
		targetsBefore[0].Commission_Qualified_Sales_Credits__c = 2200;
		uow.registerDirty(targetsBefore[0]);
		uow.commitWork();
		Sales_Target__c[] targets = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		Map<Id, Comp_Plan__c> compPlanMap = new Map<Id, Comp_Plan__c>([SELECT Id, Name, 
			(SELECT Id, Type__c, Variable__c, Variable2__c, Operator__c, Operator2__c, Value__c, Value2__c, Result__c 
				FROM Comp_Plan_Rules__r ORDER BY Result__c) 
			FROM Comp_Plan__c]);

		SalesTargetsService.calculateAvailableCommission(targets[0], compPlanMap.get(targets[0].Comp_Plan__c));
		uow.commitWork();

		Sales_Target__c[] targetsAfter = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		System.assertEquals(3000, targetsAfter[0].Available_Commission__c);
	}
}