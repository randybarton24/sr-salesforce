global class ContactClean implements Database.Batchable<sObject> 
{	
	String query = 'SELECT Id, RecurSoft__Intacct_Contact_ID__c, Email, Account.ParentId, CreatedDate FROM ' +
	'Contact WHERE Email != null ORDER BY Email DESC NULLS LAST, RecurSoft__Intacct_Contact_ID__c DESC NULLS LAST, Account.ParentId ASC, CreatedDate ASC';

	global Database.QueryLocator start(Database.BatchableContext BC) 
	{	
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Contact> scope) 
	{
		Map<Id, SObject> updateMap = new Map<Id, SObject>();
      	Set<String> emailSet = new Set<String>();

		for(Contact c : scope)
		{
			if(emailSet.contains(c.Email))
			{
				if(c.RecurSoft__Intacct_Contact_ID__c == null)
				{
					c.Email = null;
					updateMap.put(c.Id, c);
				}
			}
			else
			{
				emailSet.add(c.Email);
			}
		}
		update updateMap.values();
	}
			
	global void finish(Database.BatchableContext BC) 
	{

	}
}