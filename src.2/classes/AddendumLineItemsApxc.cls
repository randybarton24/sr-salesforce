public  without sharing class AddendumLineItemsApxc 
{            
    @AuraEnabled
    public static Asset[] listAssets { get; set; }      
    @AuraEnabled
    public static Addendum_Line_Item__c[] listAddmItems { get; set; }
    @AuraEnabled
    public static Addendum__c addendum { get; set; }
    @AuraEnabled
    public static WrappedAsset[] wrapAssetOptions { get; set; }
    @AuraEnabled
    public static WrappedAsset[] wrapAssetSelections { get; set; }
    @AuraEnabled
    public static WrappedAddendumItem[] wrapAddmItemOptions { get; set; }
    @AuraEnabled
    public static WrappedAddendumItem[] wrapAddmItemSelections { get; set; }        
    @AuraEnabled
    public static Set<Id> assetIds  { get; set; }   

    public class WrappedAsset 
    {
        @AuraEnabled
        public Asset asset { get; set; }
        @AuraEnabled
        public Boolean isChecked { get; set; }        
        public WrappedAsset(Asset ast) 
        {            
            asset = ast;    
            isChecked = false;
        }
    }    
    
    public class WrappedAddendumItem
    {
        @AuraEnabled
        public Addendum_Line_Item__c addendumLineItem { get; set; }
        @AuraEnabled
        public Boolean isChecked { get; set; }        
        public WrappedAddendumItem(Addendum_Line_Item__c ali) 
        {            
            addendumLineItem = ali; 
            isChecked = false;
        }
    }      

    @AuraEnabled
    public static Addendum_Line_Item__c[] getAllAddendumLineItems(Id addendumId) 
    {                        
        Addendum_Line_Item__c[] listAddmItems = AddendumlineItemsSelector.newInstance().selectByAddendumIds(new Set<Id>{ addendumId });        
        return listAddmItems;
    }
    
    @AuraEnabled
    public static Asset[] getAllAssets(Id addendumId) 
    {        
        Addendum__c[] addList = AddendaSelector.newInstance().selectByIdWithAddendumLineItems(new Set<Id>{ addendumId });      
        listAssets = AssetsSelector.newInstance().selectActiveAssetsByAddendum(addList);
        return listAssets;
    }                   
     
    @AuraEnabled
    public static void fillLists(Id addendumId)
    {
        addendum = ((Addendum__c[]) AddendaSelector.newInstance().selectSObjectsById(new Set<Id>{ addendumId }))[0]; 
	    listAssets = AssetsSelector.newInstance().selectActiveAssetsByAddendum(new List<Addendum__c>{ addendum });	    
		listAddmItems = AddendumLineItemsSelector.newInstance().selectByAddendumIds(new Set<Id>{ addendumId });	
        
        if(assetIds == null) assetIds = new Set<Id>();
        for(Addendum_Line_Item__c ali : listAddmItems) 
        {
			assetIds.add(ali.Asset__c);
		}       
    }
        
    @AuraEnabled
    public static  WrappedAsset[] getAssetOptions() 
    {
		wrapAssetOptions = new List<WrappedAsset>();		
        for(Asset ast : listAssets) 
        {
			if(assetIds.contains(ast.Id)) continue;
			wrapAssetOptions.add(new WrappedAsset(ast));
		}				
        return wrapAssetOptions;
	}

	@AuraEnabled
	public static WrappedAddendumItem[] getAddmItemOptions() 
    {
		wrapAddmItemOptions = new List<WrappedAddendumItem>();
		for(Addendum_Line_Item__c ali : listAddmItems) 
        {
			wrapAddmItemOptions.add(new WrappedAddendumItem(ali));
		}				
        return wrapAddmItemOptions;
	}    
    
    @AuraEnabled
	public static PricebookEntry[] getProductOptions(Id pricebookId) 
	{                          
        Pricebook2[] pricebooks = PricebooksSelector.newInstance().selectByIdWithPricebookEntries(new Set<Id>{ pricebookId });
        System.debug(pricebooks[0].PricebookEntries[0].Product2.Contract_Display_Name__c);
	    return pricebooks[0].PricebookEntries;
	}

    @AuraEnabled
    public static Pricebook2[] getPricebookOptions() 
    {            
        Pricebook2[] pBook = PricebooksSelector.newInstance().selectAllActiveWithPricebookEntries();//.selectByTypeWithPricebookEntries(new Set<String>{'Add Product'});        
        return pBook;
    }         
    
    @AuraEnabled
    public static Boolean getSaveItems(Id addendumId, List<Id> assetList, List<Id> aliList) 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        Set<Id> aliSelectionIds = new Set<Id>(aliList);
        Set<Id> assetSelectionIds = new Set<Id>(assetList);        
		
        try 
        {
            Set<Id> ids = new Set<Id>{ addendumId };
            
            Addendum_Line_Item__c[] aliSelections = !aliSelectionIds.isEmpty() ? (Addendum_Line_Item__c[]) AddendumLineItemsSelector.newInstance().selectSObjectsById(aliSelectionIds) : new Addendum_Line_Item__c[]{};        
            Asset[] assetSelections = !assetSelectionIds.isEmpty() ? (Asset[]) AssetsSelector.newInstance().selectSObjectsById(assetSelectionIds) : new Asset[]{};            

            if(!assetSelections.isEmpty()) 
            {
                for(Asset a : assetSelections) 
                {
                    Addendum_Line_Item__c ali = new Addendum_Line_Item__c(Asset__c = a.Id,
                        Addendum__c = addendumId);
                    uow.registerNew(ali);
                }
            }

            if(!aliSelections.isEmpty()) 
            {
                for(Addendum_Line_Item__c ali : aliSelections) 
                {
                    uow.registerDeleted(ali);
                }
            }        

            uow.commitWork();
            return true;			
        }
		catch(Exception ex)
        {            
            return false;
        }
	}

    @AuraEnabled
    public static Boolean saveItemsAddProduct(Id addendumId, Id pricebookId, Addendum_Line_Item__c ali)// Id pricebookEntryId, String pricebookEntryName, Integer quantity, Decimal price, , String family, String contractName) 
    {    
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        try 
        {                                                  
            Addendum__c newAdd = new Addendum__c (Id = addendumId,
                                                Price_Book__c = pricebookId);          
            uow.registerDirty(newAdd);                                        
            uow.registerNew(ali);            
            uow.commitWork();                
            return true;
        }
        catch(Exception ex)
        {
            System.debug(ex.getStackTraceString());
            return false;
        }
    } 
}