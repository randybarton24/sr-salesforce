public with sharing class ProductEditController extends WebFormsUtilityClass {
	
	public ApexPages.StandardController stdCtrl { get; set; }
	public Opportunity opp { get; set; }
	public OpportunityLineItem[] listOppLis { get; set; }
	public Boolean renderEdit { get; set; }
	public Boolean error { get; set; }
	public Map<Id, User> userMap { get; set; }
	
	public ProductEditController(ApexPages.StandardController stdController) {
		
		this.opp = (Opportunity)stdController.getRecord();
		stdCtrl = stdController;
		renderEdit = false;
		error = false;
		userMap = new Map<Id, User>((User[]) UsersSelector.newInstance().selectSObjectsById(new Set<Id>{UserInfo.getUserId()}));
		
        try{

        listOppLis = [SELECT Id,
	    	Is_Promo_Item__c,
	    	ListPrice,
	    	UnitPrice,
	    	TotalPrice,
	    	Quantity,
	    	OpportunityId, 
	    	Opportunity.RecordType.Name,
	    	Opportunity.RecurSoft__Billing_Contact__r.Email,
	    	Opportunity.RecurSoft__Billing_Contact__r.Phone,
	    	Opportunity.RecurSoft__Shipping_Contact__r.Email,
	    	Opportunity.RecurSoft__Shipping_Contact__r.Phone,
	    	Number_of_Free_Months__c, 
	    	Promotional_Price__c,
	    	Co_Terminate__c, 
	    	Trial__c,
	    	Free_Month_Setting__c, 
	    	Base_Contract_Term__c, 
	    	RecurSoft__Contract_Term1__c, 
	    	RecurSoft__Contract_Term_End_Date_Editable__c, 
	    	RecurSoft__Contract_Term_Start_Date_New__c, 
	    	PricebookEntryId,
	    	PriceBookEntry.Name,
	    	PriceBookEntry.UnitPrice,
	    	PricebookEntry.Product2Id, 
	    	PricebookEntry.Product2.Name,
	    	PricebookEntry.Product2.ProductCode,
	    	PricebookEntry.Pricebook2Id, 
	    	PricebookEntry.Price_Discount_Floor__c,
	    	PricebookEntry.Trial_Period_Floor__c,
	    	PricebookEntry.Free_Months_Floor__c,
	    	Product2.Default_Renewal_Rule__c, 
	    	Product2.Family, 
	    	Product2.Default_Contract_Term__c, 
	    	Product2.Default_Co_Terminate__c, 
	    	Product2.RecurSoft__Billing_Frequency__c 
	    	FROM OpportunityLineItem
			WHERE OpportunityId = :opp.Id];

			} catch(Exception e) {}
	}

	public PageReference edit() 
	{
		renderEdit = true;
		return null;
	}

	public PageReference cancel() 
	{
		renderEdit = false;
		return null;
	}

	public PageReference saveOppLis() 
	{
		Boolean hasError = false;

		for(OpportunityLineItem oppLi : listOppLis) 
		{
			if(oppLi.Number_of_Free_Months__c > 0 && (oppLi.Free_Month_Setting__c == null || oppLi.Free_Month_Setting__c == 'None')) 
			{
				hasError = true;
				oppLi.Free_Month_Setting__c.addError('You must select an Orientation Month Setting with Orientation Months');
			}

			if(oppLi.Number_of_Free_Months__c > 0 && oppLi.Promotional_Price__c == null) 
			{
				hasError = true;
				oppLi.Promotional_Price__c.addError('You must set an Orientation Price with Orientation Months');
			}

			if((oppLi.Number_of_Free_Months__c == 0 || oppLi.Number_of_Free_Months__c == null) && oppLi.Promotional_Price__c != null) 
			{
				hasError = true;
				oppLi.Promotional_Price__c.addError('You must set the number of Orientation Months or leave Orientation Price blank');
			}

			if(oppLi.Base_Contract_Term__c <= oppLi.Number_of_Free_Months__c && 
				oppLi.Free_Month_Setting__c == 'Include in Contract Period - At the Beginning') 
			{
				hasError = true;
				oppLi.Free_Month_Setting__c.addError('The number of Orientation Months exceeds the number of months in the Contract period.' +
					'Please adjust the Number of Orientation Months or the Orientation Month Setting.');
			}

			if(oppLi.Opportunity.RecurSoft__Billing_Contact__c != null && (oppLi.Opportunity.RecurSoft__Billing_Contact__r.Email == null || oppLi.Opportunity.RecurSoft__Billing_Contact__r.Phone == null))
			{
				hasError = true;
				oppLi.UnitPrice.addError('The Bill To Contact Needs To Have A Phone & Email');
			}

			if(oppLi.Opportunity.RecurSoft__Shipping_Contact__c != null && (oppLi.Opportunity.RecurSoft__Shipping_Contact__r.Email == null || oppLi.Opportunity.RecurSoft__Shipping_Contact__r.Phone == null))
			{
				hasError = true;
				oppLi.UnitPrice.addError('The Ship To Contact Needs To Have A Phone & Email');
			}

			if(oppLi.Product2.RecurSoft__Billing_Frequency__c == 'One-Time' &&
				oppLi.Number_of_Free_Months__c > 0) 
			{
				hasError = true;
				oppLi.Number_of_Free_Months__c.addError('One-Time products cannot have Orientation Months.');
			}

			if(oppLi.Product2.RecurSoft__Billing_Frequency__c == 'One-Time' &&
				oppLi.Trial__c != null) 
			{
				hasError = true;
				oppLi.Trial__c.addError('One-Time products cannot have a Trial Period.');
			}

			if((oppLi.Opportunity.RecordType.Name == 'Add Product' ||
				oppLi.Opportunity.RecordType.Name == 'Healthgrades') && 
				oppLi.Co_Terminate__c &&
				oppLi.Free_Month_Setting__c == 'Extend Contract - At the Beginning') 
			{
				hasError = true;
				oppLi.Free_Month_Setting__c.addError('This Product is set to Co-Terminate with an existing Subscription. You cannot extend the term.');
			}

			if(oppLi.PricebookEntry.Price_Discount_Floor__c != null &&
				oppLi.PricebookEntry.Price_Discount_Floor__c > oppLi.UnitPrice &&
				UserInfo.getProfileId() != '00ei0000001ZJPd' && //Finance
				!userMap.get(UserInfo.getUserId()).Approval_Exempt__c &&
				oppLi.Opportunity.RecordType.Name != 'Add-On Business') 
			{
				hasError = true;
				oppLi.UnitPrice.addError('The price is lower than the minimum allowable price.');
			}

			if(oppLi.PricebookEntry.Trial_Period_Floor__c != null &&
				oppLi.Trial__c != null &&
				oppLi.PricebookEntry.Trial_Period_Floor__c < Decimal.valueOf(oppLi.Trial__c) &&
				UserInfo.getProfileId() != '00ei0000001ZJPd' && //Finance
				!userMap.get(UserInfo.getUserId()).Approval_Exempt__c &&
				oppLi.Opportunity.RecordType.Name != 'Add-On Business') 
			{
				hasError = true;
				oppLi.Trial__c.addError('The trial period is greater than the maximum allowable period.');
			}

			if(oppLi.PricebookEntry.Free_Months_Floor__c != null &&
				oppLi.PricebookEntry.Free_Months_Floor__c < oppLi.Number_of_Free_Months__c &&
				UserInfo.getProfileId() != '00ei0000001ZJPd' && //Finance
				!userMap.get(UserInfo.getUserId()).Approval_Exempt__c &&
				oppLi.Opportunity.RecordType.Name != 'Add-On Business') 
			{
				hasError = true;
				oppLi.Number_of_Free_Months__c.addError('The number of Orientation Months is greater than the maximum allowable Orientation Months.');
			}

			if(oppLi.Product2.RecurSoft__Billing_Frequency__c == 'Yearly' &&
				opp.RecurSoft__Initial_Contract_Term__c != 12)
			{
				hasError = true;
				opp.RecurSoft__Initial_Contract_Term__c.addError('Annual Billing requires a 12 Month Term');
			}
		}

		if(!hasError) 
		{
			update listOppLis;
			stdCtrl.save();
			renderEdit = false;
			return ApexPages.currentPage();
		} 
		else 
		{
			error = true;
			renderEdit = true;
			return null;
		}
	}
}