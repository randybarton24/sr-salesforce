public class AddendaService 
{
	public static void processSignatureReceived(Set<Id> ids, fflib_SObjectUnitOfWork uow)
	{
		Addendum__c[] addenda = AddendaSelector.newInstance().selectByIdWithAddendumLineItems(ids);

		for(Addendum__c addendum : addenda)
		{
			if(addendum.New_Subscription_Needed__c == null)
			{
				AddendaService.updateTrialDate(addendum, uow);
				addendum.Status__c = 'Closed';
				addendum.OwnerId = addendum.CreatedById;
				uow.registerDirty(addendum);
			}
			else
			{
				AddendaService.newAddendumOpp(addendum, uow);
				AddendaService.newAddendumOppAddProduct(addendum, uow);
			}
		}
	}

	public static void updateTrialDate(Addendum__c addendum, fflib_SObjectUnitOfWork uow)
	{
		for(Addendum_Line_Item__c ali : addendum.Addendum_Line_Items__r)
		{
			if(ali.Asset__r.Current_Product_Subscription__c != null)
			{
				RecurSoft__Product_Subscription__c ps = new RecurSoft__Product_Subscription__c(Id = ali.Asset__r.Current_Product_Subscription__c);
				ps.Trial_End_Date__c = ali.New_Trial_End_Date__c;
				uow.registerDirty(ps);

				Asset a = new Asset(Id = ali.Asset__c);
				a.Trial_End_Date__c = ali.New_Trial_End_Date__c;
				uow.registerDirty(a);
			}
			else
			{
				Asset a = new Asset(Id = ali.Asset__c);
				a.Trial_End_Date__c = ali.New_Trial_End_Date__c;
				uow.registerDirty(a);
			}
		}
	}

	public static void newAddendumOpp(Addendum__c addendum, fflib_SObjectUnitOfWork uow)
	{		
		Opportunity o = new Opportunity(RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get('Add-On Business').getRecordTypeId(),
			AccountId = addendum.Account__c,
			CloseDate = Date.today(),
			StageName = 'Qualified',
			RecurSoft__Contract_Signed_Date__c = Date.today(),
			Name = 'Modify Product: ' + addendum.Name,
			RecurSoft__Initial_Contract_Term__c = addendum.Contract_Term_Months__c,
			Pricebook2Id = SRUtilities.getStdPricebookId(),
			Addendum__c = addendum.Id,
			OwnerId = '005i0000002gn9T');
		uow.registerNew(o);			

		for(Addendum_Line_Item__c ali : addendum.Addendum_Line_Items__r)
		{			
			if(ali.Asset__c == null) continue;
			OpportunityLineItem oppLi = new OpportunityLineItem(PricebookEntryId = ali.Pricebook_Entry_Id__c,
				Quantity = 1,
				UnitPrice = ali.New_Price__c,
				Number_of_Free_Months__c = ali.New_Free_Months__c,
				Free_Month_Setting__c = ali.New_Free_Month_Setting__c,
				Trial__c = String.valueOf(ali.New_Trial_Period_Days__c),
				RecurSoft__Contract_Term_Start_Date_New__c = ali.New_Contract_Start_Date__c,
				RecurSoft__Contract_Term_End_Date_Editable__c = ali.New_Renewal_Date__c
				);
			uow.registerNew(oppLi, OpportunityLineItem.OpportunityId, o);			
		}

		addendum.OwnerId = '00Gi00000034JUX';
		uow.registerRelationship(addendum, Addendum__c.Opportunity__c, o);
		uow.registerDirty(addendum);
	}

	public static void newAddendumOppAddProduct(Addendum__c addendum, fflib_SObjectUnitOfWork uow)
	{			
		Opportunity o = new Opportunity(RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get('Add Product').getRecordTypeId(),
			AccountId = addendum.Account__c,
			CloseDate = Date.today(),
			StageName = 'Qualified',
			RecurSoft__Contract_Signed_Date__c = Date.today(),
			Name = 'Add Product: ' + addendum.Name,
			RecurSoft__Initial_Contract_Term__c = addendum.Contract_Term_Months__c,
			Pricebook2Id = addendum.Price_Book__c,
			Addendum__c = addendum.Id,
			OwnerId = '005i0000002gn9T');

		for(Addendum_Line_Item__c ali : addendum.Addendum_Line_Items__r)
		{			
			if(ali.Asset__c != null) continue;

			uow.registerNew(o);	

			OpportunityLineItem oppLi = new OpportunityLineItem(PricebookEntryId = ali.Pricebook_Entry_Id__c,
				Quantity = ali.New_Quantity__c,
				UnitPrice = ali.New_Price__c);
			uow.registerNew(oppLi, OpportunityLineItem.OpportunityId, o);			
		}		
	}
}