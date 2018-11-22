@RestResource(urlMapping='/add_products/*')
global with sharing class AddProductAPI 
{	
	@HttpGet
	global static String[] getSubscriptions()
	{
		Set<String> results = new Set<String>();

		RestRequest req = RestContext.request;
		String subscriberId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

		RecurSoft__Product_Subscription__c[] subscriptions = ProductSubscriptionsSelector.newInstance().selectActiveSubscriptionsBySubscriberId(subscriberId);

		for(RecurSoft__Product_Subscription__c subscription : subscriptions)
		{
			results.add(subscription.RecurSoft__Product__r.Family);
		}

		return new List<String>(results);
	}

	@HttpPost
	global static Result addProducts(OppData opp_data)
	{
		Result result = new Result();
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		SR_Default_Values__c isProduction = SR_Default_Values__c.getValues('Current Environment');
		String contractBaseURL = isProduction.Value__c == 'Production' ? SR_Default_Values__c.getValues('Production Contract URL').Value__c : SR_Default_Values__c.getValues('Sandbox Contract URL').Value__c;

		try
		{
			Opportunity existingOpp = getExistingOpp(opp_data.subscriberId);

			if(existingOpp != null)
			{
				uow.registerDeleted(existingOpp);
			}
		}
		catch(Exception e)
		{}

		createNewOpp(uow, opp_data, 30);	

		uow.commitWork();

		Opportunity newOpp = getExistingOpp(opp_data.subscriberId);

		Result.contractUrl = contractBaseURL + '/SRContractForm?id=' + newOpp.Id + '&source=api';
		return Result;
	}

	private static Opportunity getExistingOpp(String subscriberId)
	{
		return [SELECT Id, StageName 
					FROM Opportunity 
					WHERE Account.Subscriber_Id__c = :subscriberId 
					AND RecordType.Name = 'Add Product' 
					AND StageName = 'Qualified' 
					AND CreatedBy.Name = 'API User'
					LIMIT 1];
	}

	private static void createNewOpp(fflib_SObjectUnitOfWork uow, OppData opp_data, Integer daysToAdd)
	{
		Account a = [SELECT Id, Name FROM Account WHERE Subscriber_Id__c = :opp_data.subscriberId];
		RecurSoft__Product_Subscription__c ps = ProductSubscriptionsSelector.newInstance().selectActiveSRSubscriptionsBySubscriberId(opp_data.subscriberId);
		Integer term;
		
		if(ps.RecurSoft__Contract_Term_End_Date__c != null)
		{
			Integer monthsLeft = Date.today().addDays(daysToAdd).monthsBetween(ps.RecurSoft__Contract_Term_End_Date__c);
			term = monthsLeft > 0 ? monthsLeft : monthsLeft + 12;
		}
		else
		{
			term = 12;
		}
	
		Pricebook2[] pBook = PricebooksSelector.newInstance().selectByNameWithPricebookEntries(new Set<String>{'8. Add Product - API Only'});
		PricebookEntry[] pBookEntries = pBook[0].PricebookEntries;

		for(PricebookEntry pbEntry : pBookEntries)
		{
			if(pbEntry.ProductCode == '3022') productToPricebookEntry.put('conversations_contract', pbEntry);
			if(pbEntry.ProductCode == '3021') productToPricebookEntry.put('conversations_monthly', pbEntry);
			if(pbEntry.ProductCode == '3014') productToPricebookEntry.put('schedule_contract', pbEntry);
			if(pbEntry.ProductCode == '3013') productToPricebookEntry.put('schedule_monthly', pbEntry);
			if(pbEntry.ProductCode == '3032') productToPricebookEntry.put('smart_reviews_contract', pbEntry);
			if(pbEntry.ProductCode == '3031') productToPricebookEntry.put('smart_reviews_monthly', pbEntry);
		}

		Opportunity o = new Opportunity(AccountId = a.Id,
			Name = a.Name + ' - Add Products(via Platform): ' + System.now().format('MM/dd/yyyy','America/Denver'),
			StageName = 'Qualified',
			Pricebook2Id = pBook[0].Id,
			RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get('Add Product').getRecordTypeId(),
			RecurSoft__Trial__c = 'None',
	        CloseDate = Date.today().addDays(daysToAdd),
	        RecurSoft__Initial_Contract_Term__c = term,
	        RecurSoft__Contract_Term_Start_Date__c = Date.today().addDays(daysToAdd),
	        RecurSoft__Billing_Contact__c = ps != null ? ps.RecurSoft__Bill_to_Contact__c : null,
	        RecurSoft__Shipping_Contact__c = ps != null ? ps.RecurSoft__Ship_to_Contact__c : null,
	        RecurSoft__Bill_to_Account__c = ps != null ? ps.RecurSoft__Bill_to_Account__c : null);

		uow.registerNew(o);

		for(ProductData product : opp_data.products)
		{
			OpportunityLineItem oppLi = new OpportunityLineItem(Quantity = 1, 
				UnitPrice = productToPricebookEntry.get(product.name + '_' + product.term).UnitPrice,
				SR_Conversations_Phone_Number__c = product.conversations_phone,
				PricebookEntryId = productToPricebookEntry.get(product.name + '_' + product.term).Id);
			uow.registerNew(oppLi, OpportunityLineItem.OpportunityId, o);
		}
	}

	private static Map<String, PricebookEntry> productToPricebookEntry = new Map<String, PricebookEntry>();

	global class OppData 
	{
		global String subscriberId;
		global ProductData[] products;
	}

	global class ProductData
	{
		global String name;
		global String term;
		global String conversations_phone;
	}

	global class Result
	{
		global String contractUrl;
	}
}