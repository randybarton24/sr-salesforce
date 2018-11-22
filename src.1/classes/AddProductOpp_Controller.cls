public with sharing class AddProductOpp_Controller extends WebFormsUtilityClass 
{
	public String acctId { get; set; }
	public Account a { get; set; }
	public Map<Id, Pricebook2> pricebooks { get; set; }
	public SelectOption[] pricebookOptions { get; set; }
	public PricebookEntry[] pBookEntries { get; set; }
	public Opportunity o { get; set; }
	public RecurSoft__Product_Subscription__c ps { get; set; }
	public WrappedProduct[] wrapProductOptions { get; set; }
	public WrappedProduct[] wrapProductSelections { get; set; }
	public Boolean renderPricebookOptions { get; set ; }
	public Boolean renderOptions { get; set; }
	public Boolean renderSelections { get; set; }
	Set<String> assetFamilyNames = new Set<String>();
	public Boolean hasError { get; set; }
	public Boolean isEligible { get; set; }
	public String errorMsg { get; set; }
	Set<String> productFamily = new Set<String>();
	public Date nextInvoice { get; set; }
	public Date endDate { get; set; }
	public Decimal term { get; set; }
	public String pBookId { get; set; }

	public AddProductOpp_Controller() 
	{
		acctId = getURParameter('id');
		a = retrieveAccountData(acctId);

        pricebooks = new Map<Id, Pricebook2>(PricebooksSelector.newInstance().selectByTypeWithPricebookEntries(new Set<String>{'Add Product'}));
        pricebookOptions = new List<SelectOption>();

        for(Pricebook2 pb : pricebooks.values())
        {  
            SelectOption so = new SelectOption(pb.Id, pb.Name);
            pricebookOptions.add(so);
        }
		
		try 
		{
			RecurSoft__Product_Subscription__c ps = ProductSubscriptionsSelector.newInstance().selectActiveSRSubscriptionsBySubscriberId(a.Subscriber_Id__c);

			if(ps.RecurSoft__Contract_Term_End_Date__c != null)
			{
				Integer monthsLeft = Date.today().monthsBetween(ps.RecurSoft__Contract_Term_End_Date__c);
				term = monthsLeft > 0 ? monthsLeft : monthsLeft + 12;
			}
			else
			{
				term = 12;
			}

			hasError = false;
			errorMsg = '';
			isEligible = true;
		} 

		catch(Exception e) 
		{
			hasError = true;
			errorMsg = 'The Account must be a current customer.  If they are a customer, then billing needs to be migrated to Salesforce.' + e.getMessage();
			isEligible = false;
			renderPricebookOptions = true;
			renderOptions = false;
			renderSelections = false;
		}

		renderPricebookOptions = true;
		renderOptions = false;
		renderSelections = false;
	}

	public WrappedProduct[] getWrapProductOptions() 
	{
		wrapProductOptions = new List<WrappedProduct>();

		for(PricebookEntry pBookEntry : pBookEntries) 
		{
			if(!pBookEntry.IsActive) continue;
			if(!assetFamilyNames.contains(pBookEntry.Product2.Family)) 
			{
				wrapProductOptions.add(new WrappedProduct(pBookEntry));
			}
		}
		
		return wrapProductOptions;
	}

	public WrappedProduct[] getWrapProductSelections() {

		wrapProductSelections = new List<WrappedProduct>();

		for(WrappedProduct wrapProduct : wrapProductOptions) {

			if(wrapProduct.isChecked) {

				wrapProductSelections.add(wrapProduct);
			}
		}
		
		return wrapProductSelections;
	}

	public void nextPage2() 
	{
		pBookEntries = pricebooks.get(pBookId).PricebookEntries;

		o = new Opportunity(AccountId = acctId,
			Name = a.Name + ' - Add Products: ' + System.now().format('MM/dd/yyyy','America/Denver'),
			StageName = 'Qualified',
			Pricebook2Id = pBookId,
			RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get('Add Product').getRecordTypeId(),
			RecurSoft__Trial__c = 'None',
	        CloseDate = Date.today(),
	        RecurSoft__Initial_Contract_Term__c = term,
	        RecurSoft__Billing_Contact__c = ps != null ? ps.RecurSoft__Bill_to_Contact__c : null,
	        RecurSoft__Shipping_Contact__c = ps != null ? ps.RecurSoft__Ship_to_Contact__c : null,
	        RecurSoft__Bill_to_Account__c = ps != null ? ps.RecurSoft__Bill_to_Account__c : null);

		wrapProductOptions = getWrapProductOptions();

		renderPricebookOptions = hasError ? true : false;
		renderOptions = hasError ? false : true;
	}

	public void nextPage3() 
	{
		productFamily.clear();
		hasError = false;

		wrapProductSelections = getWrapProductSelections();

		for(WrappedProduct wrapProduct : wrapProductSelections) {

			if(wrapProduct.pBookEntry.Product2.Family == null) continue;

			if(productFamily.contains(wrapProduct.pBookEntry.Product2.Family)) 
			{
				hasError = true;
				errorMsg = 'You can only select one product from the same family.';

			} 
			else 
			{
				productFamily.add(wrapProduct.pBookEntry.Product2.Family);
			}

			if(wrapProduct.pBookEntry.Product2.Family == 'SR Conversations' && 
				a.BillingCountry != 'United States' && 
				a.BillingCountry != 'Canada' &&
				a.BillingCountry != 'Puerto Rico')
			{
				hasError = true;
				errorMsg = 'SR Conversations is not available in this country.';
			}
		}

		renderOptions = hasError ? true : false;
		renderSelections = hasError ? false : true;
	}

	public void next() {

		productFamily.clear();
		hasError = false;

		wrapProductSelections = getWrapProductSelections();

		for(WrappedProduct wrapProduct : wrapProductSelections) {

			if(wrapProduct.pBookEntry.Product2.Family == null) continue;

			if(productFamily.contains(wrapProduct.pBookEntry.Product2.Family)) 
			{
				hasError = true;
				errorMsg = 'You can only select one product from the same family.';

			} 
			else 
			{
				productFamily.add(wrapProduct.pBookEntry.Product2.Family);
			}

			if(wrapProduct.pBookEntry.Product2.Family == 'SR Conversations' && a.BillingCountry != 'United States' && a.BillingCountry != 'Canada')
			{
				hasError = true;
				errorMsg = 'Currently SR Conversations is only available in the United States.';
			}
		}

		renderOptions = hasError ? true : false;
		renderSelections = hasError ? false : true;
	}

	public void backPage1() 
	{
		renderPricebookOptions = true;
		renderOptions = false;
		renderSelections = false;
	}

	public void backPage2() 
	{
		renderPricebookOptions = false;
		renderOptions = true;
		renderSelections = false;
	}

	public PageReference cancel() 
	{
		PageReference page = new PageReference('/' + a.id);
	    page.setRedirect(true);

	    return page;
	}

	public PageReference saveOpp() 
	{
		hasError = false;
		OpportunityLineItem[] oppLisToInsert = new List<OpportunityLineItem>();

		for(WrappedProduct wrapProduct : wrapProductSelections) 
		{
			if(wrapProduct.numberOfFreeMonths > 0 && (wrapProduct.freeMonthSetting == null || wrapProduct.freeMonthSetting == '--None--')) 
			{
				hasError = true;
				errorMsg = 'You must select a Orientation Month Setting with Orientation Months';
			}

			if(wrapProduct.numberOfFreeMonths > 0 && wrapProduct.promotionalPrice == null) 
			{
				hasError = true;
				errorMsg = 'You must set an Orientation Price with Orientation Months';
			}

			if((wrapProduct.numberOfFreeMonths == 0 || wrapProduct.numberOfFreeMonths == null) && wrapProduct.promotionalPrice != null && wrapProduct.promotionalPrice != 0) 
			{
				hasError = true;
				errorMsg = 'You must set the number of Orientation Months or leave Orientation Price blank';
			}

			if(wrapProduct.pBookEntry.Product2.Default_Contract_Term__c < wrapProduct.numberOfFreeMonths && 
				wrapProduct.freeMonthSetting == 'Include in Contract Period - At the Beginning') 
			{
				hasError = true;
				errorMsg = 'The number of Orientation Months exceeds the number of months in the Contract period.' +
					'Please adjust the Number of Orientation Months or the Orientation Month Setting.';
			}

			if(wrapProduct.pBookEntry.Product2.RecurSoft__Billing_Frequency__c == 'One-Time' &&
				wrapProduct.numberOfFreeMonths > 0) 
			{
				hasError = true;
				errorMsg = 'One-Time products cannot have Orientation Months.';
			}

			if(wrapProduct.pBookEntry.Product2.RecurSoft__Billing_Frequency__c == 'One-Time' &&
				wrapProduct.trialPeriod != '--None--') 
			{
				hasError = true;
				errorMsg = 'One-Time products cannot have a Trial Period.';
			}

			if(wrapProduct.pBookEntry.Product2.Default_Co_Terminate__c &&
				wrapProduct.freeMonthSetting == 'Extend Contract - At the Beginning' &&
				wrapProduct.numberOfFreeMonths > 0) 
			{
				hasError = true;
				errorMsg = 'This Product is set to Co-Terminate with an existing Subscription. You cannot extend the term.';
			}

			if(wrapProduct.pBookEntry.Price_Discount_Floor__c != null &&
				wrapProduct.pBookEntry.Price_Discount_Floor__c > wrapProduct.salesPrice) 
			{
				hasError = true;
				errorMsg = 'The price is lower than the minimum allowable price.';
			}

			if(wrapProduct.pBookEntry.Trial_Period_Floor__c != null &&
				wrapProduct.trialPeriod != '--None--' &&
				wrapProduct.pBookEntry.Trial_Period_Floor__c < Decimal.valueOf(wrapProduct.trialPeriod)) 
			{
				hasError = true;
				errorMsg = 'The trial period is greater than the maximum allowable period.';
			}

			if(wrapProduct.pBookEntry.Free_Months_Floor__c != null &&
				wrapProduct.pBookEntry.Free_Months_Floor__c < wrapProduct.numberOfFreeMonths) 
			{
				hasError = true;
				errorMsg = 'The number of Orientation Months is greater than the maximum allowable Orientation Months.';
			}
		}

		if(!hasError) 
		{
			insert o;
        
	        for(WrappedProduct wrapProduct : wrapProductSelections) 
	        {
	        	OpportunityLineItem oppLi = new OpportunityLineItem(OpportunityId = o.Id,
	        		PricebookEntryId = wrapProduct.pBookEntry.Id,
	        		Quantity = 1,
	        		Promotional_Price__c = wrapProduct.promotionalPrice == null ? null : wrapProduct.promotionalPrice,
	        		Free_Month_Setting__c = wrapProduct.freeMonthSetting == '--None--' ? null : wrapProduct.freeMonthSetting,
	        		Trial__c = wrapProduct.trialPeriod == '--None--' ? null : wrapProduct.trialPeriod,
	        		Number_of_Free_Months__c = wrapProduct.numberOfFreeMonths == null ? null : wrapProduct.numberOfFreeMonths,
	        		RecurSoft__Contract_Term_Start_Date_New__c = nextInvoice,
	        		RecurSoft__Contract_Term_End_Date_Editable__c = endDate,
	        		UnitPrice = wrapProduct.salesPrice);

	        	oppLisToInsert.add(oppLi);
	        }

	        if(oppLisToInsert.size() > 0) 
	        {
	        	insert oppLisToInsert;
	        }

			PageReference page = new PageReference('/' + o.id);
	        page.setRedirect(true);

	        return page;
		} 
		else 
		{
			return null;
		}
	}

	public class WrappedProduct 
	{
		public PricebookEntry pBookEntry { get; set; }
		public Boolean isChecked { get; set; }
		public Decimal promotionalPrice { get; set; }
		public Integer numberOfFreeMonths { get; set; }
		public SelectOption[] freeMonthOptions { get; set; }
		public SelectOption[] trialPeriodOptions { get; set; }
		public String freeMonthSetting { get; set; }
		public String trialPeriod { get; set; }
		public Decimal salesPrice { get; set; }

		public WrappedProduct(PricebookEntry pbEntry) 
		{
			pBookEntry = pbEntry;	
			isChecked = false;
			promotionalPrice = pbEntry.Auto_Add_Promotional_Price__c == null ? null : pbEntry.Auto_Add_Promotional_Price__c;
			numberOfFreeMonths = pbEntry.Auto_Add_Free_Months__c == null ? null : Integer.valueOf(pbEntry.Auto_Add_Free_Months__c);
			freeMonthOptions = getFreeMonthOptions();
			trialPeriodOptions = getTrialPeriodOptions();
			salesPrice = pbEntry.Auto_Add_Price__c == null ? null : pbEntry.Auto_Add_Price__c;
			trialPeriod = pbEntry.Auto_Add_Trial__c == null ? null : pbEntry.Auto_Add_Trial__c;
			freeMonthSetting = pbEntry.Auto_Add_Free_Month_Setting__c == null ? null : pbEntry.Auto_Add_Free_Month_Setting__c;
		}

		public SelectOption[] getFreeMonthOptions() 
		{
	        SelectOption[] options = new List<SelectOption>();

	        options.add(new SelectOption('--None--', '--None--'));

	        for(Schema.PicklistEntry entry : OpportunityLineItem.sObjectType.field.Free_Month_Setting__c.getDescribe().getPickListValues())
	        { 
	            SelectOption so = new SelectOption(entry.getValue(), entry.getLabel());
	            options.add(so);
	        }

	        return options;
	    }

	    public SelectOption[] getTrialPeriodOptions() 
	    {
	        SelectOption[] options = new List<SelectOption>();

	        options.add(new SelectOption('--None--', '--None--'));

	        for(Schema.PicklistEntry entry : OpportunityLineItem.sObjectType.field.Trial__c.getDescribe().getPickListValues())
	        { 
	            SelectOption so = new SelectOption(entry.getValue(), entry.getLabel());
	            options.add(so);
	        }

	        return options;
	    }
	}
}