public with sharing class AccountOpportunityDetails_Controller 
{
	public Id acctId { get; set; }
	public Account acct { get; set; }
	public Opportunity[] listOpps { get; set; }
	public Opportunity o { get; set; }
	public Task t { get; set; }
	public Boolean hasError { get { return ApexPages.hasMessages(); } }
	
	public AccountOpportunityDetails_Controller(ApexPages.StandardController stdController) 
	{	
		this.acctId = stdController.getId();
		
        try
        {
	    	acct = [SELECT Id, Name FROM Account WHERE Id = :acctId];
	    	listOpps = OpportunitiesSelector.newInstance().selectActiveOpportunitiessByAccountId(new Set<Id>{acctId});
	    	System.debug(listOpps);
	    	if(listOpps.isEmpty())
	    	{
	    		o = new Opportunity();
	    		t = new Task(RecordTypeId = SRUtilities.getRecordTypeMap('Task').get('Inside Sales Task').getRecordTypeId());
	    	} 
		} 
		catch(Exception e) 
		{
			System.debug(e);
		}
	}

	public PageReference claimAccount()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		try
		{
			if(listOpps.size() > 0)
			{
				//Close and open new opp
				listOpps[0].OwnerId = UserInfo.getUserId();
				acct.OwnerId = UserInfo.getUserId();
				uow.registerDirty(listOpps[0]);
				uow.registerDirty(acct);
			}
			else
			{
				if(o.LeadSource == null)
				{
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please add a Lead Source'));
				}
				else if(t.Subject == null ||
					t.Status == null ||
					t.Activity_Type__c == null ||
					t.Activity_Results__c == null ||
					t.Talked_To__c == null)
				{
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please complete the Task Information fields'));
				}
				else
				{
					Pricebook2[] pBook = PricebooksSelector.newInstance().selectByNameWithPricebookEntries(new Set<String>{'1.1 SR Platform'});

					acct.OwnerId = UserInfo.getUserId();
					uow.registerDirty(acct);

					o.Name = acct.Name + '-';
					o.AccountId = acctId;
					o.OwnerId = UserInfo.getUserId();
		            o.StageName = 'Qualified';
		            o.Pricebook2Id = pBook[0].Id;
		            o.RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get('New Practice Business').getRecordTypeId();
		            o.RecurSoft__Trial__c = 'None';
		            o.CloseDate = Date.today().addDays(30);
		            o.RecurSoft__Initial_Contract_Term__c = 24;
		            o.RecurSoft__Bill_to_Account__c = acctId;
					uow.registerNew(o);

					t.WhatId = acct.Id;
					t.OwnerId = UserInfo.getUserId();
					t.ActivityDate = Date.today();
					uow.registerNew(t);
				}
			}
			uow.commitWork();
		}
		catch (Exception e)
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
		}

		return null;
	}
}