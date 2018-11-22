global class ContactCleanWithinAcct implements Database.Batchable<sObject> 
{	
	String query = 'SELECT Id, (SELECT Id, RecurSoft__Intacct_Contact_ID__c, Email, CreatedDate FROM ' +
	'Contacts ORDER BY RecurSoft__Intacct_Contact_ID__c DESC NULLS LAST, CreatedDate ASC) FROM Account WHERE ' +
	'Contact_Email_Duplicates__c = true';

	global Database.QueryLocator start(Database.BatchableContext BC) 
	{	
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Account> scope) 
	{
		Map<Id, SObject> updateMap = new Map<Id, SObject>();
      	Set<String> emailSet = new Set<String>();

		for(Account a : scope) 
		{
			emailSet.clear();

			for(Contact c : a.Contacts)
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
		}

		update updateMap.values();
	}
			
	global void finish(Database.BatchableContext BC) 
	{

	}
}