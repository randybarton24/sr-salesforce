public class OpportunitiesSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Opportunity.Id,
			Opportunity.AccountId,
			Opportunity.Ambassador_Commission_Created__c,
			Opportunity.Ambassador_Commission_Paid__c,
			Opportunity.Amount,
			Opportunity.Approval_Level_Required__c,
			Opportunity.Approval_Level_Required_Orientation__c,
			Opportunity.CampaignId,
			Opportunity.CloseDate,
			Opportunity.Contract_Date_Time__c,
			Opportunity.Contract_Signed__c,
			Opportunity.Contract_Signed_IP__c,
			Opportunity.Contract_Signer__c,
			Opportunity.CreatedById,
			Opportunity.CreatedDate,
			Opportunity.Deal_Desk_Approval_Date__c,
			Opportunity.Demo_Request_Reason__c,
			Opportunity.Description,
			Opportunity.Do_Not_Send_Login_Details__c,
			Opportunity.HasOpportunityLineItem,
			Opportunity.IsClosed,
			Opportunity.IsLegacy__c,
			Opportunity.LeadSource,
			Opportunity.Monthly_Revenue__c,
			Opportunity.Name,
			Opportunity.Number_of_Locations__c,
			Opportunity.Number_of_Providers__c,
			Opportunity.Number_of_PRT__c,
			Opportunity.Ok_to_Sync_to_Intacct__c,
			Opportunity.Opportunity_Owner__c,
			Opportunity.OwnerId,
			Opportunity.Pricebook2Id,
			Opportunity.RecordTypeId,
			Opportunity.RecurSoft__Billing_Contact__c,
			Opportunity.RecurSoft__Bill_to_Account__c,
			Opportunity.RecurSoft__Contract_Signed_Date__c,
			Opportunity.RecurSoft__Contract_Term_End_Date__c,
			Opportunity.RecurSoft__Contract_Term_Start_Date__c,
			Opportunity.RecurSoft__Free_Months_Setting__c,
			Opportunity.RecurSoft__Initial_Contract_Term__c,
			Opportunity.RecurSoft__Number_of_Free_Months__c,
			Opportunity.RecurSoft__Shipping_Contact__c,
			Opportunity.RecurSoft__Trial__c,
			Opportunity.RecurSoft__Trial_End_Date1__c,
			Opportunity.Referred_Contact__c,
			Opportunity.Sales_Engineer_Call_Completed__c,
			Opportunity.Set_Product_Approvals__c,
			Opportunity.Source_User__c,
			Opportunity.StageName,
			Opportunity.Type };
	}

	public Schema.SObjectType getSObjectType()
	{
		return Opportunity.SObjectType;
	}

	public static OpportunitiesSelector newInstance()
	{
		return (OpportunitiesSelector) Application.Selector.newInstance(Opportunity.SObjectType);
	}

	public Opportunity[] selectByIdWithAccountAndProducts(Set<Id> ids)
	{
		fflib_QueryFactory opportunityQueryFactory = newQueryFactory();

		fflib_QueryFactory opportunityLineItemQueryFactory = opportunityQueryFactory.subselectQuery('OpportunityLineItems')
        	.selectFields(new OpportunityLineItemsSelector().getSObjectFieldList())
        	.addOrdering('UnitPrice', fflib_QueryFactory.SortOrder.DESCENDING);

        fflib_QueryFactory paymentRecordQueryFactory = opportunityQueryFactory.subselectQuery('RecurSoft__RecurSoft_Payment_Records__r')
        	.selectFields(new PaymentRecordsSelector().getSObjectFieldList())
        	.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);

		new AccountsSelector().configureQueryFactoryFields(opportunityQueryFactory, 'Account');

		new ContactsSelector().configureQueryFactoryFields(opportunityQueryFactory, 'RecurSoft__Billing_Contact__r');

		new ManagementSystemsSelector().configureQueryFactoryFields(opportunityQueryFactory, 'Account.Practice_Management_Software__r');
		
		new PricebooksSelector().configureQueryFactoryFields(opportunityQueryFactory, 'Pricebook2');

		new PricebookEntriesSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'PriceBookEntry');

		new ProductsSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'PriceBookEntry.Product2');

		new ProvidersSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'Provider__r');

		return (Opportunity[]) Database.query(
			opportunityQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	} 

	public Opportunity[] selectByIdWithManagerAndVP(Set<Id> ids)
	{
		fflib_QueryFactory opportunityQueryFactory = newQueryFactory();

		new UsersSelector().configureQueryFactoryFields(opportunityQueryFactory, 'Owner');

		new UsersSelector().configureQueryFactoryFields(opportunityQueryFactory, 'Owner.Manager');

		new UsersSelector().configureQueryFactoryFields(opportunityQueryFactory, 'Source_User__r');

		new UsersSelector().configureQueryFactoryFields(opportunityQueryFactory, 'Source_User__r.Manager');

		return (Opportunity[]) Database.query(
			opportunityQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	} 

	public Opportunity[] selectByIdWithAccountsContactsAndProducts(Set<Id> ids)
	{
		fflib_QueryFactory opportunityQueryFactory = newQueryFactory();

		fflib_QueryFactory opportunityLineItemQueryFactory = opportunityQueryFactory.subselectQuery('OpportunityLineItems')
        	.selectFields(new OpportunityLineItemsSelector().getSObjectFieldList());

		new AccountsSelector().configureQueryFactoryFields(opportunityQueryFactory, 'Account');

		new AccountsSelector().configureQueryFactoryFields(opportunityQueryFactory, 'RecurSoft__Bill_to_Account__r');

		new AccountsSelector().configureQueryFactoryFields(opportunityQueryFactory, 'RecurSoft__Billing_Contact__r.Account');

		new AccountsSelector().configureQueryFactoryFields(opportunityQueryFactory, 'Account.Parent');

		new ContactsSelector().configureQueryFactoryFields(opportunityQueryFactory, 'RecurSoft__Billing_Contact__r');

		new ContactsSelector().configureQueryFactoryFields(opportunityQueryFactory, 'RecurSoft__Bill_to_Account__r.Office_Contact__r');

		new ContactsSelector().configureQueryFactoryFields(opportunityQueryFactory, 'Account.Office_Contact__r');

		new ManagementSystemsSelector().configureQueryFactoryFields(opportunityQueryFactory, 'Account.Practice_Management_Software__r');
		
		new PricebooksSelector().configureQueryFactoryFields(opportunityQueryFactory, 'Pricebook2');

		new PricebookEntriesSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'PriceBookEntry');

		new ProductsSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'PriceBookEntry.Product2');

		new ProvidersSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'Provider__r');

		return (Opportunity[]) Database.query(
			opportunityQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	} 

	public Opportunity[] selectByIdWithAddenda(Set<Id> ids)
	{
		fflib_QueryFactory opportunityQueryFactory = newQueryFactory();

		fflib_QueryFactory addendaQueryFactory = opportunityQueryFactory.subselectQuery('Addenda__r')
        	.selectFields(new AddendaSelector().getSObjectFieldList());

		return (Opportunity[]) Database.query(
			opportunityQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}

	public Opportunity[] selectByTaskList(List<Task> taskList)
	{
		Set<Id> ids = new Set<Id>();
		
		for(Task t : taskList) 
		{
			ids.add(t.WhatId);
		}

		fflib_QueryFactory opportunityQueryFactory = newQueryFactory();

		return (Opportunity[]) Database.query(
			opportunityQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}

	public Opportunity[] selectByOpportunityLineItemsWithProducts(List<OpportunityLineItem> oppLiList)
	{
		Set<Id> ids = new Set<Id>();
		
		for(OpportunityLineItem oppLi : oppLiList) 
		{
			ids.add(oppLi.OpportunityId);
		}

		fflib_QueryFactory opportunityQueryFactory = newQueryFactory();

		fflib_QueryFactory opportunityLineItemQueryFactory = opportunityQueryFactory.subselectQuery('OpportunityLineItems')
        	.selectFields(new OpportunityLineItemsSelector().getSObjectFieldList());

        new PricebookEntriesSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'PriceBookEntry');

		new ProductsSelector().configureQueryFactoryFields(opportunityLineItemQueryFactory, 'PriceBookEntry.Product2');

		return (Opportunity[]) Database.query(
			opportunityQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}

	public Opportunity[] selectActiveOpportunitiessByAccountId(Set<Id> acctIds)
	{
		fflib_QueryFactory opportunityQueryFactory = newQueryFactory();

		return Database.query(
			opportunityQueryFactory
				.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('AccountId IN :acctIds AND RecordType.Name IN (\'New Practice Business\',\'Enterprise New Business\') AND IsClosed = false')
				.toSOQL());
	}

	public Map<Id, Opportunity> selectByIdWithCIs(Set<Id> ids)
	{
		fflib_QueryFactory opportunityQueryFactory = newQueryFactory();

		fflib_QueryFactory campaignInfluenceQueryFactory = opportunityQueryFactory.subselectQuery('Campaign_Influence__r')
        	.selectFields(new CampaignInfluencesSelector().getSObjectFieldList())
        	.addOrdering('Campaign_Add_Date__c', fflib_QueryFactory.SortOrder.ASCENDING);

        new CampaignsSelector().configureQueryFactoryFields(campaignInfluenceQueryFactory, 'Campaign__r');

		return new Map<Id, Opportunity>((Opportunity[]) Database.query(
			opportunityQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL()));
	}

	public Map<Id, Decimal> selectOwnerStagingOpps(Opportunity[] opportunities)
	{
		Set<Id> ids = new Set<Id>();
		for(Opportunity opportunity : opportunities)
		{
			ids.add(opportunity.OwnerId);
		}

		Map<Id, Decimal> resultMap = selectOwnerStagingOpps(ids);
		return resultMap;
	}

	public Map<Id, Decimal> selectOwnerPipelineOpps(Opportunity[] opportunities)
	{
		Set<Id> ids = new Set<Id>();
		for(Opportunity opportunity : opportunities)
		{
			ids.add(opportunity.OwnerId);
		}

		Map<Id, Decimal> resultMap = selectOwnerPipelineOpps(ids);
		return resultMap;
	}

	public Map<Id, Decimal> selectOwnerStagingOpps(Set<Id> ids)
	{		
		Map<Id, Decimal> resultMap = new Map<Id, Decimal>();
		AggregateResult[] aggregateResults = Database.query('SELECT OwnerId, COUNT_DISTINCT(Id) staging ' +
			'FROM Opportunity ' +
			'WHERE IsClosed = false ' +
			'AND StageName IN (\'Pre-Qualified\',\'Qualified\') ' +
			'AND RecordType.Name IN (\'New Practice Business\',\'Add Product\',\'Enterprise New Business\') ' +
			'AND OwnerId IN :ids ' +
			'GROUP BY OwnerId');

		for(AggregateResult result :aggregateResults)
		{
			resultMap.put((Id) result.get('OwnerId'), (Decimal) result.get('staging'));
		}

		return resultMap;
	}

	public Map<Id, Decimal> selectOwnerPipelineOpps(Set<Id> ids)
	{		
		Map<Id, Decimal> resultMap = new Map<Id, Decimal>();
		AggregateResult[] aggregateResults = Database.query('SELECT OwnerId, COUNT_DISTINCT(Id) pipeline ' +
			'FROM Opportunity ' +
			'WHERE IsClosed = false ' +
			'AND StageName NOT IN (\'Pre-Qualified\',\'Qualified\') ' +
			'AND RecordType.Name IN (\'New Practice Business\',\'Add Product\',\'Enterprise New Business\') ' +
			'AND OwnerId IN :ids ' +
			'GROUP BY OwnerId');

		for(AggregateResult result :aggregateResults)
		{
			resultMap.put((Id) result.get('OwnerId'), (Decimal) result.get('pipeline'));
		}

		return resultMap;
	}

	public Opportunity[] selectByIdWithAmbassadorContacts(Set<Id> ids)
	{
		fflib_QueryFactory opportunityQueryFactory = newQueryFactory();

		fflib_QueryFactory opportunityLineItemQueryFactory = opportunityQueryFactory.subselectQuery('OpportunityLineItems')
        	.selectFields(new OpportunityLineItemsSelector().getSObjectFieldList());

		new ContactsSelector().configureQueryFactoryFields(opportunityQueryFactory, 'Referred_Contact__r');
		
		return (Opportunity[]) Database.query(
			opportunityQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	} 

	public Database.QueryLocator queryOpportunityCloseApiUser_Batch()
	{
		fflib_QueryFactory opportunityQueryFactory = newQueryFactory();

		return Database.getQueryLocator(
			opportunityQueryFactory
				.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('CreatedDate <= N_DAYS_AGO:7 AND IsClosed != true AND RecordType.Name = \'Add Product\' AND CreatedBy.UserName = \'apiuser@solutionreach.com\'')
				.toSOQL());
	}
}