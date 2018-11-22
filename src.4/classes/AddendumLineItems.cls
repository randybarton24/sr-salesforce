public class AddendumLineItems extends fflib_SObjectDomain 
{
	public Map<String, String> snipMap;
	public Map<String, Schema.SObjectField> fieldMap;
	public Map<Id, Addendum_Line_Item__c> addAllCotermProducts;
	public Map<Id, Addendum_Line_Item__c> syncNewTerm;
	public Map<Id, Addendum_Line_Item__c> syncDeferredBilling;
	public Map<Id, Addendum_Line_Item__c> deleteNewTermOrDeferred;
	public Map<Id, Addendum_Line_Item__c> alisInUpdate;
	public Map<Id, PricebookEntry> pricebookEntries;
	public Map<Id, Id> addendumtoAccountId;
	public Map<Id, Account> accountWithAssetMap;
	public static Set<Id> assetIds;
	public static Addendum_Line_Item__c[] listAddmItems;
	public static Boolean syncNewTermDeferredRecursion = false;
	public static Boolean addAllCotermProductsRecursion = false;

	public AddendumLineItems(Addendum_Line_Item__c[] addendumLineItems) 
	{
		super(addendumLineItems);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new AddendumLineItems(sObjectList);
		}
	}

	public override void onBeforeInsert()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Addendum_Line_Item__c ali : (Addendum_Line_Item__c[]) Records) 
        {        	
			this.setRecordType(ali, null);
			this.setNewNextInvoiceDate(ali, null);
			this.setNewRenewalDate(ali, null);
			this.setNewContractStartDate(ali, null);
			this.setNewContractTermMonths(ali, null);
        	this.setNewPrice(ali, null);
			this.setNewTrialEndDate(ali, null);
			this.setNewTrialPeriodDays(ali, null);
        }
        uow.commitWork();
	}

	public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Addendum_Line_Item__c ali : (Addendum_Line_Item__c[]) Records) 
        {
        	Addendum_Line_Item__c existingAli = (Addendum_Line_Item__c) existingRecords.get(ali.Id);

			this.setRecordType(ali, existingAli);
			this.setNewNextInvoiceDate(ali, existingAli);
			this.setNewRenewalDate(ali, existingAli);
			this.setNewContractStartDate(ali, existingAli);
			this.setNewContractTermMonths(ali, existingAli);
        	this.setNewPrice(ali, existingAli);
			this.setNewTrialEndDate(ali, existingAli);
			this.setNewTrialPeriodDays(ali, existingAli);
			this.updateSnippets(ali, existingAli); 
        }   
       
		uow.commitWork();   
	}

	public override void onAfterUpdate(Map<Id, SObject> existingRecords)
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		alisInUpdate = new Map<Id, Addendum_Line_Item__c>((Addendum_Line_Item__c[]) Records);
        
        for(Addendum_Line_Item__c ali : (Addendum_Line_Item__c[]) Records) 
        {        	
			Addendum_Line_Item__c existingAli = (Addendum_Line_Item__c) existingRecords.get(ali.Id);
			
			this.checkAddAllCotermProducts(ali, existingAli);
			this.checkSyncNewTerm(ali, existingAli);
			this.checkSyncDeferredBilling(ali, existingAli);		
        }

        if(addAllCotermProducts != null ||
        	syncNewTerm != null ||
        	syncDeferredBilling != null) this.addAllProductsAndSync(uow);

        uow.commitWork();
	}

	public override void onAfterDelete()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		alisInUpdate = new Map<Id, Addendum_Line_Item__c>((Addendum_Line_Item__c[]) Records);
        
        for(Addendum_Line_Item__c ali : (Addendum_Line_Item__c[]) Records) 
        {        				
			this.checkDeleteNewTermOrDeferred(ali);		
        }

        if(deleteNewTermOrDeferred != null) this.addAllProductsAndSync(uow);

        uow.commitWork();
	}

	public void checkAddAllCotermProducts(Addendum_Line_Item__c ali, Addendum_Line_Item__c existingAli)
	{
		if(existingAli != null && 
            existingAli.NewTerm__c == ali.NewTerm__c &&
            existingAli.NewTerm_Months__c == ali.NewTerm_Months__c &&
            existingAli.Defer_Billing__c == ali.Defer_Billing__c &&
            existingAli.Deferred_Months__c == ali.Deferred_Months__c) return;
		if(!ali.NewTerm__c && !ali.Defer_Billing__c) return;

		if(addAllCotermProducts == null) addAllCotermProducts = new Map<Id, Addendum_Line_Item__c>();
		addAllCotermProducts.put(ali.Addendum__c, ali);
	}

	public void checkSyncNewTerm(Addendum_Line_Item__c ali, Addendum_Line_Item__c existingAli)
	{
		if(existingAli != null && 
            existingAli.NewTerm__c == ali.NewTerm__c &&
            existingAli.NewTerm_Months__c == ali.NewTerm_Months__c) return;

		if(syncNewTerm == null) syncNewTerm = new Map<Id, Addendum_Line_Item__c>();
		syncNewTerm.put(ali.Addendum__c, ali);
	}

	public void checkSyncDeferredBilling(Addendum_Line_Item__c ali, Addendum_Line_Item__c existingAli)
	{
		if(existingAli != null &&
            existingAli.Defer_Billing__c == ali.Defer_Billing__c &&
            existingAli.Deferred_Months__c == ali.Deferred_Months__c) return;

		if(syncDeferredBilling == null) syncDeferredBilling = new Map<Id, Addendum_Line_Item__c>();
		syncDeferredBilling.put(ali.Addendum__c, ali);
	}

	public void checkDeleteNewTermOrDeferred(Addendum_Line_Item__c ali)
	{
		if(!ali.Defer_Billing__c && !ali.NewTerm__c) return;
		if(ali.Asset_Type__c == 'Healthgrades') return;

		if(deleteNewTermOrDeferred == null) deleteNewTermOrDeferred = new Map<Id, Addendum_Line_Item__c>();
		deleteNewTermOrDeferred.put(ali.Addendum__c, ali);
	}

	public void addAllProductsAndSync(fflib_SObjectUnitOfWork uow)
	{
		if(syncNewTermDeferredRecursion) return;
		if(listAddmItems == null) listAddmItems = AddendumLineItemsSelector.newInstance().selectByAddendumId((Addendum_Line_Item__c[]) Records);	
		if(assetIds == null) assetIds = new Set<Id>();
		if(addendumtoAccountId == null) addendumtoAccountId = new Map<Id, Id>();

		for (Addendum_Line_Item__c aliItem : listAddmItems) 
		{
			if(addAllCotermProducts != null && addAllCotermProducts.containsKey(aliItem.Addendum__c)) addendumtoAccountId.put(aliItem.Addendum__c, aliItem.Addendum__r.Account__c);
			assetIds.add(aliItem.Asset__c);
			if(alisInUpdate.containsKey(aliItem.Id)) continue;
	
			if(syncNewTerm != null && syncNewTerm.containsKey(aliItem.Addendum__c))
			{
				aliItem.NewTerm__c = syncNewTerm.get(aliItem.Addendum__c).NewTerm__c;
				aliItem.NewTerm_Months__c = syncNewTerm.get(aliItem.Addendum__c).NewTerm_Months__c;			
				uow.registerDirty(aliItem);	
			}

			if(syncDeferredBilling != null && syncDeferredBilling.containsKey(aliItem.Addendum__c))
			{			
				aliItem.Defer_Billing__c = syncDeferredBilling.get(aliItem.Addendum__c).Defer_Billing__c;
				aliItem.Deferred_Months__c = aliItem.Defer_Billing__c ? (aliItem.Deferred_Months__c == null ? 0 : aliItem.Deferred_Months__c) : null;					
				uow.registerDirty(aliItem);							
			}

			if(deleteNewTermOrDeferred != null && deleteNewTermOrDeferred.containsKey(aliItem.Addendum__c))
			{
				aliItem.Defer_Billing__c = false;
				aliItem.Deferred_Months__c = null;
				aliItem.NewTerm__c = false;
				aliItem.NewTerm_Months__c = null;
				uow.registerDirty(aliItem);
			}
		}
		syncNewTermDeferredRecursion = true;
		this.addAllCotermProducts(uow);
	}

	public void addAllCotermProducts(fflib_SObjectUnitOfWork uow)
	{
		if(addAllCotermProductsRecursion) return;
		if(addendumtoAccountId.isEmpty()) return;
		if(accountWithAssetMap == null) accountWithAssetMap = new Map<Id, Account>(AccountsSelector.newInstance().selectByIdWithAssets(new Set<Id>(addendumtoAccountId.values())));

		for(Id addendumId : addAllCotermProducts.keySet())
		{
			for(Asset ast : accountWithAssetMap.get(addendumtoAccountId.get(addendumId)).Assets)
			{
				if(assetIds.contains(ast.Id)) continue;
				if(ast.Product2.Default_Contract_Term__c == 1) continue;
				if(ast.Current_Product_Subscription__c == null) continue;
			
				Addendum_Line_Item__c aliNew = new Addendum_Line_Item__c(
					Asset__c = ast.Id,
					NewTerm__c = addAllCotermProducts.get(addendumId).NewTerm__c,
					NewTerm_Months__c = addAllCotermProducts.get(addendumId).NewTerm_Months__c,
					Defer_Billing__c = addAllCotermProducts.get(addendumId).Defer_Billing__c,
					Deferred_Months__c = addAllCotermProducts.get(addendumId).Defer_Billing__c ? 0 : null,
					Addendum__c = addendumId);					
				uow.registerNew(aliNew);		
			}
		}

		addAllCotermProductsRecursion = true;
	}

	public void setRecordType(Addendum_Line_Item__c ali, Addendum_Line_Item__c existingAli)
	{
		if(existingAli != null && 
            existingAli.RecordTypeId == ali.RecordTypeId) return;

		if(ali.Asset_Type__c == 'SR Platform')
        {
            ali.RecordTypeId = SRUtilities.getRecordTypeMap('Addendum_Line_Item__c').get('SR').getRecordTypeId();
        }
        else if(ali.Asset__c == null)
        {
            ali.RecordTypeId = SRUtilities.getRecordTypeMap('Addendum_Line_Item__c').get('ANY_ADD').getRecordTypeId();
        }
        else 
        {
        	ali.RecordTypeId = SRUtilities.getRecordTypeMap('Addendum_Line_Item__c').get('ANY').getRecordTypeId();
        }	
	}

	public void updateSnippets(Addendum_Line_Item__c ali, Addendum_Line_Item__c existingAli)
	{
		String recordTypeName = SRUtilities.getRecordTypeName('Addendum_Line_Item__c', ali.RecordTypeId);
		recordTypeName = recordTypeName == 'SR' ? recordTypeName : 'ANY';

		if(ali.Asset__c == null)
		{	
			ali.Header_Text__c = getSnippetText(recordTypeName + '_Header', ali).escapeJava().replace('\\n\\n','<br/>').replace('<br>','<br/>').unescapeJava();
			ali.Any_Add_Product_Text__c = getSnippetText(recordTypeName + '_Add_Product', ali).escapeJava().replace('\\n\\n','<br/>').replace('<br>','<br/>').unescapeJava();		
		}
		else
		{
			ali.Header_Text__c = getSnippetText(recordTypeName + '_Header', ali).escapeJava().replace('\\n\\n','<br/>').replace('<br>','<br/>').unescapeJava();		
			ali.Intro_Language_Text__c = getSnippetText(recordTypeName + '_Intro_Language', ali).escapeJava().replace('\\n\\n','<br/>').replace('<br>','<br/>').unescapeJava();
			ali.Confidentiality_Clause_Text__c = getSnippetText(recordTypeName + '_Confidentiality_Clause', ali).escapeJava().replace('\\n\\n','<br/>').replace('<br>','<br/>').unescapeJava();
			ali.Outro_Language_Text__c = getSnippetText(recordTypeName + '_Outro_Language', ali).escapeJava().replace('\\n\\n','<br/>').replace('<br>','<br/>').unescapeJava();		
			ali.Defer_Billing_Text__c = ali.Defer_Billing__c ? (ali.Deferred_Months__c == 0 ? getSnippetText(recordTypeName + '_Defer_Billing_Zero__c', ali).escapeJava().replace('\\n\\n','<br/>').replace('<br>','<br/>').unescapeJava() : getSnippetText(recordTypeName + '_Defer_Billing__c', ali).escapeJava().replace('\\n\\n','<br/>').replace('<br>','<br/>').unescapeJava()) : null;		
			ali.Waive_Billing_Text__c = ali.Waive_Billing__c && ali.Waived_Months__c != null ? getSnippetText(recordTypeName + '_Waive_Billing__c', ali).escapeJava().replace('\\n\\n','<br/>').replace('<br>','<br/>').unescapeJava() : null;
			ali.NewTerm_Text__c = ali.NewTerm__c && ali.NewTerm_Months__c != null ? getSnippetText(recordTypeName + '_Extend_Term__c', ali).escapeJava().replace('\\n\\n','<br/>').replace('<br>','<br/>').unescapeJava() : null;
			if(ali.Change_MSF__c && ali.New_MSF__c != null)
			{
				ali.Change_MSF_Text__c = ali.New_Price__c < ali.Current_Price__c ? getSnippetText(recordTypeName + '_Reduce_MSF__c', ali).escapeJava().replace('\\n\\n','<br/>').replace('<br>','<br/>').unescapeJava() : 
					getSnippetText(recordTypeName + '_Increase_MSF__c', ali).escapeJava().replace('\\n\\n','<br/>').replace('<br>','<br/>').unescapeJava();
			}	
			else 
			{
				ali.Change_MSF_Text__c = null;
			}
			ali.Extend_Satisfaction_Period_Text__c = ali.Extend_Satisfaction_Period__c && ali.Trial_End_Date__c != null ? getSnippetText(recordTypeName + '_Extend_Satisfaction_Period__c', ali).escapeJava().replace('\\n\\n','<br/>').replace('<br>','<br/>').unescapeJava() : null;		
		}
	}

	public String getSnippetText(String snipName, Addendum_Line_Item__c ali)
	{
		if(snipMap == null) snipMap = AddendumLineItemsSelector.newInstance().getSnippetMap();
		if(fieldMap == null)  fieldMap = Schema.SObjectType.Addendum_Line_Item__c.fields.getMap();
				
		String mergeText = snipMap.containsKey(snipName) ? snipMap.get(snipName) : '';

		while(mergeText.indexOf('{{') > 0)
		{
		    Schema.DisplayType dt = fieldMap.get(mergeText.substringBetween('{{','}}')).getDescribe().getType();

		    if(ali.get(mergeText.substringBetween('{{','}}')) != null)
		    {
		    	if(dt == DisplayType.DATE)
			    {
			    	mergeText = mergeText.replace('{{'+ mergeText.substringBetween('{{','}}')+'}}', Datetime.newInstance((Date) Date.valueOf(ali.get(mergeText.substringBetween('{{','}}'))),Time.newInstance(0, 0, 0, 0)).format('MMMM d, YYYY'));
			    }
			    else if(dt == DisplayType.CURRENCY)
			    {
					mergeText = mergeText.replace('{{'+ mergeText.substringBetween('{{','}}')+'}}', '$' + (Decimal) Decimal.valueOf(String.valueOf(ali.get(mergeText.substringBetween('{{','}}')))));
				}
			    else
			    {		
			    	mergeText = mergeText.replace('{{'+ mergeText.substringBetween('{{','}}')+'}}', (String) String.valueOf(ali.get(mergeText.substringBetween('{{','}}'))));
			    }
		    }
		    else
		    {
		    	mergeText = mergeText.replace('{{'+ mergeText.substringBetween('{{','}}')+'}}', '');
		    }
		}

		return mergeText;
	}
		    
	public void setNewNextInvoiceDate(Addendum_Line_Item__c ali, Addendum_Line_Item__c existingAli)
	{		 		
		if (existingAli != null && 
			existingAli.NewTerm_Months__c == ali.NewTerm_Months__c &&
			existingAli.Deferred_Months__c == ali.Deferred_Months__c &&
			existingAli.Waived_Months__c == ali.Waived_Months__c) return;

        if (ali.NewTerm__c == false && ali.Defer_Billing__c == false && ali.Waive_Billing__c == false)
		{						
			ali.New_Next_Invoice_Date__c = ali.Current_Next_Invoice_Date__c;			
		}
		if (ali.NewTerm__c == false && ali.Defer_Billing__c == false && ali.Waive_Billing__c == true && ali.Current_Next_Invoice_Date__c != null)
		{						
			ali.New_Next_Invoice_Date__c = ali.Current_Next_Invoice_Date__c.addMonths(Integer.valueOf(ali.Waived_Months__c));			
		}
		if (ali.NewTerm__c == false && ali.Defer_Billing__c == true && ali.Waive_Billing__c == false && ali.Current_Next_Invoice_Date__c != null)
		{
			ali.New_Next_Invoice_Date__c = ali.Current_Next_Invoice_Date__c.addMonths(Integer.valueOf(ali.Deferred_Months__c));			
		}			
		if (ali.NewTerm__c == true && ali.Defer_Billing__c == false && ali.Waive_Billing__c == false)
		{
			ali.New_Next_Invoice_Date__c = Date.today();			
		}  
		if (ali.NewTerm__c == true && ali.Defer_Billing__c == true && ali.Waive_Billing__c == false)
		{
			ali.New_Next_Invoice_Date__c = Date.today().addMonths(Integer.valueOf(ali.Deferred_Months__c));			
		}  
		if (ali.NewTerm__c == true && ali.Defer_Billing__c == false && ali.Waive_Billing__c == true)
		{
			ali.New_Next_Invoice_Date__c = Date.today().addMonths(Integer.valueOf(ali.Waived_Months__c));			
		}     
	}

	public void setNewRenewalDate(Addendum_Line_Item__c ali, Addendum_Line_Item__c existingAli)
	{		 		
		if (existingAli != null && 
			existingAli.NewTerm_Months__c == ali.NewTerm_Months__c &&
			existingAli.Deferred_Months__c == ali.Deferred_Months__c &&
			existingAli.Waived_Months__c == ali.Waived_Months__c) return;

        if (ali.NewTerm__c == false && ali.Defer_Billing__c == false && ali.Waive_Billing__c == false)
		{						
			ali.New_Renewal_Date__c = ali.Current_Renewal_Date__c;		
		}
		if (ali.NewTerm__c == false && ali.Defer_Billing__c == false && ali.Waive_Billing__c == true )
		{						
			ali.New_Renewal_Date__c = ali.Current_Renewal_Date__c;			
		}
		if (ali.NewTerm__c == false && ali.Defer_Billing__c == true && ali.Waive_Billing__c == false && ali.Current_Renewal_Date__c != null)
		{
			ali.New_Renewal_Date__c = ali.Current_Renewal_Date__c.addMonths(Integer.valueOf(ali.Deferred_Months__c));			
		}			
		if (ali.NewTerm__c == true && ali.Defer_Billing__c == false && ali.Waive_Billing__c == false)
		{
			ali.New_Renewal_Date__c = Date.today().addMonths(Integer.valueOf(ali.NewTerm_Months__c)).addDays(-1);			
		}  
		if (ali.NewTerm__c == true && ali.Defer_Billing__c == true && ali.Waive_Billing__c == false)
		{
			ali.New_Renewal_Date__c = Date.today().addMonths(Integer.valueOf(ali.Deferred_Months__c)).addMonths(Integer.valueOf(ali.NewTerm_Months__c)).addDays(-1);			
		}  
		if (ali.NewTerm__c == true && ali.Defer_Billing__c == false && ali.Waive_Billing__c == true)
		{
			ali.New_Renewal_Date__c = Date.today().addMonths(Integer.valueOf(ali.NewTerm_Months__c)).addDays(-1);	
		}     
	}

	public void setNewContractStartDate(Addendum_Line_Item__c ali, Addendum_Line_Item__c existingAli)
	{
		if(existingAli != null &&
			existingAli.Original_Agreement_Date__c == ali.Original_Agreement_Date__c &&
			existingAli.NewTerm__c == ali.NewTerm__c) return;

		if(ali.Original_Agreement_Date__c != null && ali.NewTerm__c == false && ali.Current_Next_Invoice_Date__c != null)
    	{
    		ali.New_Contract_Start_Date__c = ali.Current_Next_Invoice_Date__c.addMonths(-1) > ali.Original_Agreement_Date__c ?
    	    	ali.Current_Next_Invoice_Date__c.addMonths(-1) : ali.Current_Next_Invoice_Date__c;
    	}
        if(ali.NewTerm__c == true)
        {
        	ali.New_Contract_Start_Date__c = Date.today();
        }
	}

	public void setNewPrice(Addendum_Line_Item__c ali, Addendum_Line_Item__c existingAli)
	{	
		if(existingAli != null &&
			existingAli.New_MSF__c == ali.New_MSF__c) return;	
		if(ali.Asset__c == null) return;

		ali.New_Price__c = ali.New_MSF__c == null ? ali.Current_Price__c : ali.New_MSF__c;
	}   

	public void setNewTrialEndDate(Addendum_Line_Item__c ali, Addendum_Line_Item__c existingAli)
	{		
		if(existingAli != null &&
			existingAli.Trial_End_Date__c == ali.Trial_End_Date__c) return;
        if(ali.Trial_End_Date__c != null)
        {
            ali.New_Trial_End_Date__c = ali.Trial_End_Date__c;
        }
        else if(ali.Waive_Satisfaction_and_Send_Promo__c)
        {
            ali.New_Trial_End_Date__c = ali.Original_Agreement_Date__c;
        }
        else
        {
            ali.New_Trial_End_Date__c = ali.Current_Trial_End_Date__c;
        }	        	    
	}      
	                  	        	
	public void setNewTrialPeriodDays(Addendum_Line_Item__c ali, Addendum_Line_Item__c existingAli)
	{		
        if(ali.New_Trial_End_Date__c > ali.Current_Trial_End_Date__c && ali.New_Contract_Start_Date__c != null)
        {
            ali.New_Trial_Period_Days__c = ali.New_Contract_Start_Date__c.daysBetween(ali.New_Trial_End_Date__c);
        }	        	    
	}        
	       
	public void setNewContractTermMonths(Addendum_Line_Item__c ali, Addendum_Line_Item__c existingAli)
	{			
        if(ali.Original_Agreement_Date__c != null && ali.New_Contract_Start_Date__c != null && ali.New_Renewal_Date__c != null)
    	{
    		ali.New_Contract_Term_Months__c = ali.New_Contract_Start_Date__c.monthsBetween(ali.New_Renewal_Date__c);
    	}
	}        

	public void setNewFreeMonths(Addendum_Line_Item__c ali, Addendum_Line_Item__c existingAli)
	{        
		ali.New_Free_Months__c = ali.Months_To_Add__c;
		ali.New_Free_Month_Setting__c = ali.New_Free_Months__c > 0 ? 'Include in Contract Period - At the Beginning' : null;	    
	}   	  
}