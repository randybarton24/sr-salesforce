global class RevenueScheduleDuplicates_Batch implements Database.Batchable<sObject>, Schedulable 
{		
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{	
		return ProductSubscriptionsSelector.newInstance().queryLocatorWithSchedules();
	}

	global void execute(Database.BatchableContext BC, List<RecurSoft__Product_Subscription__c> scope) 
	{
      	fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
      	Map<Date, RecurSoft__Revenue_Schedule__c> revenueSchedules = new Map<Date, RecurSoft__Revenue_Schedule__c>();

		for(RecurSoft__Product_Subscription__c subscription : scope) 
		{
			revenueSchedules.clear();

			if(subscription.RecurSoft__RecurSoft_Revenue_Schedules__r.size() == 0) continue;

			for(RecurSoft__Revenue_Schedule__c schedule : subscription.RecurSoft__RecurSoft_Revenue_Schedules__r)
			{
				if(revenueSchedules.containsKey(schedule.RecurSoft__Date__c))
				{
					
					if(schedule.CreatedDate > revenueSchedules.get(schedule.RecurSoft__Date__c).CreatedDate)
					{
						if(schedule.RecurSoft__Revenue_Entry_Status__c == 'To be invoiced') uow.registerDeleted(schedule);
					}
					else
					{
						if(revenueSchedules.get(schedule.RecurSoft__Date__c).RecurSoft__Revenue_Entry_Status__c == 'To be invoiced')
						{
							uow.registerDeleted(revenueSchedules.get(schedule.RecurSoft__Date__c));
							revenueSchedules.put(schedule.RecurSoft__Date__c, schedule);
						}
					}
				}
				else
				{
					revenueSchedules.put(schedule.RecurSoft__Date__c, schedule);
				}
			}
		}

		uow.commitWork();
	}
			
	global void finish(Database.BatchableContext BC) 
	{	

	}

	global void execute(SchedulableContext sc) 
	{	
		RevenueScheduleDuplicates_Batch batch = new RevenueScheduleDuplicates_Batch();
		Database.executebatch(batch);
	}
}