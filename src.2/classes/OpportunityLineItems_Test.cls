@isTest
private class OpportunityLineItems_Test 
{
    @testSetup static void testData() 
    {
        TestUtilities.insertCustomSettings();
    }

    /*@isTest static void test_beforeInsert() 
    {       
        sfab_FabricatedSObject oppLiFab = TestUtilities2.newOpportunityLineItem();            
        
        OpportunityLineItem oppLi = (OpportunityLineItem) oppLiFab.toSObject();

        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem> {oppLi});       
        opportunityLineItems.onBeforeInsert();
    }

    @isTest static void test_afterInsert() 
    {       
        sfab_FabricatedSObject oppLiFab = TestUtilities2.newOpportunityLineItem();            
        
        OpportunityLineItem oppLi = (OpportunityLineItem) oppLiFab.toSObject();
        
        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem> {oppLi});       
        opportunityLineItems.onAfterInsert();
    }*/

    @isTest static void test_beforeUpdate() 
    {       
        sfab_FabricatedSObject oppLiFab = TestUtilities2.newOpportunityLineItem();            
        
        OpportunityLineItem oppLi = (OpportunityLineItem) oppLiFab.toSObject();
        
        OpportunityLineItem existingOppLi = (OpportunityLineItem) TestUtilities2.existingOpportunityLineItem(oppLiFab)
            .toSObject();

        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem> {oppLi});       
        opportunityLineItems.onBeforeUpdate(new Map<Id, SObject>(new List<OpportunityLineItem> {existingOppLi}));   
    }

    @isTest static void test_afterUpdate() 
    {       
       sfab_FabricatedSObject oppLiFab = TestUtilities2.newOpportunityLineItem();            
        
        OpportunityLineItem oppLi = (OpportunityLineItem) oppLiFab.toSObject();
        
        OpportunityLineItem existingOppLi = (OpportunityLineItem) TestUtilities2.existingOpportunityLineItem(oppLiFab)
            .toSObject();

        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem> {oppLi});       
        opportunityLineItems.onAfterUpdate(new Map<Id, SObject>(new List<OpportunityLineItem> {existingOppLi}));   
    }

    @isTest static void test_checkForContractDatesUpdateNeeded()
	{
        OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem()
        	.setField(OpportunityLineItem.Number_of_Free_Months__c, 0)
        	.setField(OpportunityLineItem.Free_Month_Setting__c, 'SettingNew')
        	.setField(OpportunityLineItem.RecurSoft__Contract_Term_Start_Date_New__c, Date.today().addDays(-10))
        	.toSObject();

        OpportunityLineItem existingOppLi = (OpportunityLineItem) TestUtilities2.existingOpportunityLineItem(oppLi)
            .setField(OpportunityLineItem.Number_of_Free_Months__c, 1)
        	.setField(OpportunityLineItem.Free_Month_Setting__c, 'SettingOld')
        	.setField(OpportunityLineItem.RecurSoft__Contract_Term_Start_Date_New__c, Date.today().addDays(-5))
        	.toSObject();

        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem>{ oppLi });
        opportunityLineItems.checkForContractDatesUpdateNeeded(oppLi, existingOppLi);

        System.assertEquals(1, opportunityLineItems.updateAllOppLisOnOpp.size());
        System.assertEquals(1, opportunityLineItems.updateAllOpplisOnOppContractDates.size());
	}

    @isTest static void test_getContractTerm()
    {           
        Account ac = (Account) TestUtilities2.newAccount().toSObject(); 

        sfab_FabricatedSObject pr = TestUtilities2.newProduct();         

        sfab_FabricatedSObject opp = TestUtilities2.newOpportunity()
            .setField(Opportunity.AccountId, ac.Id)
            .setField(Opportunity.RecurSoft__Initial_Contract_Term__c, 5)
            .setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeMap('Opportunity').get('Renewal').getRecordTypeId());

        Date createdDate = Date.newInstance(2018, 01, 20);
        OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem()
            .setField(OpportunityLineItem.OpportunityId, ((Opportunity) opp.toSObject()).Id)
            .setField(OpportunityLineItem.Product2Id, ((Product2) pr.toSObject()).Id)
            .setField(OpportunityLineItem.Number_of_Free_Months__c, 2)
            .setField(OpportunityLineItem.RecurSoft__Contract_Term_Start_Date_New__c, createdDate)
            .setParent('Product', pr)
            .setParent('Opportunity', opp)
            .toSObject();
       
        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem>{ oppLi });        
        Integer contractTerm = opportunityLineItems.getContractTerm(oppLi);

        System.assertEquals(5, contractTerm);        
    } 

    /*@isTest static void test_resetApprovals()
    {           
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
       
        sfab_FabricatedSObject user = TestUtilities2.newUser()
            .setField(User.Approval_Exempt__c, true);

        sfab_FabricatedSObject pr = TestUtilities2.newProduct();      

        sfab_FabricatedSObject pbe = TestUtilities2.newPricebookEntry();          

        sfab_FabricatedSObject opp = TestUtilities2.newOpportunity()
            .setField(Opportunity.OwnerId, ((User) user.toSObject()).Id)
            .setParent('Owner', user);          

        OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem()
            .setField(OpportunityLineItem.OpportunityId, ((Opportunity) opp.toSObject()).Id)  
            .setField(OpportunityLineItem.Approval_Level_Required_Price_Discount__c, 2)
            .setField(OpportunityLineItem.Approval_Level_Required__c, 3) 
            .setField(OpportunityLineItem.Approval_Level_Required_Free_Months__c, 4) 
            .setField(OpportunityLineItem.Approval_Level_Required_Term__c, 5) 
            .setField(OpportunityLineItem.Approval_Level_Required_Trial__c, 6) 
            .setField(OpportunityLineItem.PricebookEntryId, ((PricebookEntry) pbe.toSObject()).Id) 
            .setField(OpportunityLineItem.Product2Id, ((Product2) pr.toSObject()).Id)                                       
            .setParent('Opportunity', opp)
            .toSObject();
       
        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem>{ oppLi });        
        opportunityLineItems.updateAllOpplisOnOppResetApprovals = new Set<Id>();
        opportunityLineItems.updateAllOpplisOnOppResetApprovals.Add(oppLi.OpportunityId);
        opportunityLineItems.resetApprovals(new List<OpportunityLineItem> {oppLi}, uow);

        System.assertEquals(1, uow.m_dirtyMapByType.get('OpportunityLineItem').size()); 
        System.assertEquals(0, oppLi.Approved_Free_Months__c);  
        System.assertEquals(0, oppLi.Approved_Price_Discount__c);   
        System.assertEquals(24, oppLi.Approved_Term__c);    
        System.assertEquals(0, oppLi.Approved_Trial__c);    
    } 

    @isTest static void test_setApprovals()
    {           
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
       
        sfab_FabricatedSObject pbe = TestUtilities2.newPricebookEntry()
            .setField(PricebookEntry.UnitPrice, 100);

        sfab_FabricatedSObject opp = TestUtilities2.newOpportunity()
            .setField(Opportunity.RecurSoft__Initial_Contract_Term__c, 20);     

        OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem()
            .setField(OpportunityLineItem.OpportunityId, ((Opportunity) opp.toSObject()).Id)  
            .setField(OpportunityLineItem.Number_of_Free_Months__c, 2)
            .setField(OpportunityLineItem.Trial__c, 3)
            .setField(OpportunityLineItem.UnitPrice, 50)
            .setField(OpportunityLineItem.PricebookEntryId, ((PricebookEntry) pbe.toSObject()).Id)          
            .setParent('Opportunity', opp)
            .setParent('PricebookEntry', pbe)
            .toSObject();
       
        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem>{ oppLi });        
        opportunityLineItems.updateAllOpplisOnOppSetApprovals = new Set<Id>();
        opportunityLineItems.updateAllOpplisOnOppSetApprovals.Add(oppLi.OpportunityId);
        opportunityLineItems.setApprovals(new List<OpportunityLineItem> {oppLi}, uow, suow);

        System.assertEquals(oppLi.Number_of_Free_Months__c, oppLi.Approved_Free_Months__c); 
        System.assertEquals((oppLi.PricebookEntry.UnitPrice == 0 ? 0 : (((oppLi.PricebookEntry.UnitPrice - oppLi.UnitPrice) / oppLi.PricebookEntry.UnitPrice) + 0.00001) * 100), oppLi.Approved_Price_Discount__c); 
        System.assertEquals(oppLi.Opportunity.RecurSoft__Initial_Contract_Term__c, oppLi.Approved_Term__c); 
        System.assertEquals(oppLi.Trial__c == null ? 0 : Decimal.valueOf(oppLi.Trial__c), oppLi.Approved_Trial__c); 
        System.assertEquals(Datetime.now(), oppLi.Last_Approved_Date__c);                           
    } */

    @isTest static void test_setContractEndDate()
    {                      
        sfab_FabricatedSObject pr = TestUtilities2.newProduct() 
            .setField(Product2.Default_Contract_Term__c, 1);  

        Account ac = (Account) TestUtilities2.newAccount().toSObject();              

        sfab_FabricatedSObject opp = TestUtilities2.newOpportunity()
            .setField(Opportunity.RecurSoft__Initial_Contract_Term__c, 5)
            .setField(Opportunity.AccountId, ac.Id)
            .setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeMap('Opportunity').get('Renewal').getRecordTypeId());
        
        OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem()
            .setField(OpportunityLineItem.OpportunityId, ((Opportunity) opp.toSObject()).Id)  
            .setField(OpportunityLineItem.RecurSoft__Contract_Term_Start_Date_New__c, Date.today())
            .setField(OpportunityLineItem.Product2Id, ((Product2) pr.toSObject()).Id)
            .setField(OpportunityLineItem.Number_of_Free_Months__c, 2)  
            .setField(OpportunityLineItem.Product2Id, ((Product2) pr.toSObject()).Id)                              
            .setParent('Product2', pr)
            .setParent('Opportunity', opp)
            .toSObject();
           
        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem>{ oppLi });         
        opportunityLineItems.setContractEndDate(oppLi);

        System.assertEquals(Date.today().addMonths(opportunityLineItems.getContractTerm(oppLi)).addDays(-1), oppLi.RecurSoft__Contract_Term_End_Date_Editable__c);                      
    }     

    @isTest static void test_setContractStartDate()
    {                   
        sfab_FabricatedSObject pr = TestUtilities2.newProduct() 
            .setField(Product2.Default_Contract_Term__c, 1);  

        Account ac = (Account) TestUtilities2.newAccount().toSObject();  

        sfab_FabricatedSObject pb = TestUtilities2.newPricebook2()
            .setField(Pricebook2.Contract_Start_Date_Offset__c, 3);

        sfab_FabricatedSObject pbe = TestUtilities2.newPricebookEntry()
            .setField(PricebookEntry.Pricebook2Id,((Pricebook2) pb.toSObject()).Id)
            .setParent('Pricebook2', pb);                   

        sfab_FabricatedSObject opp = TestUtilities2.newOpportunity()
            .setField(Opportunity.RecurSoft__Contract_Signed_Date__c, Date.today())
            .setField(Opportunity.AccountId, ac.Id)
            .setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeMap('Opportunity').get('Add Product').getRecordTypeId());
    
        OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem()
            .setField(OpportunityLineItem.OpportunityId, ((Opportunity) opp.toSObject()).Id)  
            .setField(OpportunityLineItem.RecurSoft__Contract_Term_Start_Date_New__c, Date.today())
            .setField(OpportunityLineItem.Product2Id, ((Product2) pr.toSObject()).Id)
            .setField(OpportunityLineItem.Number_of_Free_Months__c, 2)   
            .setField(OpportunityLineItem.RecurSoft__Contract_Term_Start_Date_New__c, Date.today())                            
            .setField(OpportunityLineItem.PricebookEntryId, ((PricebookEntry) pbe.toSObject()).Id) 
            .setParent('PricebookEntry', pbe)
            .setParent('Opportunity', opp)
            .toSObject();
       
        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem>{ oppLi });         
        opportunityLineItems.setContractStartDate(oppLi);

        System.assertEquals(Date.today().addDays(3), oppLi.RecurSoft__Contract_Term_Start_Date_New__c);        
    }

    @isTest static void test_setDefaultsFromProduct()
    {           
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        sfab_FabricatedSObject pr = TestUtilities2.newProduct() 
            .setField(Product2.RecurSoft__Billing_Frequency__c, 'Monthly')
            .setField(Product2.Default_Co_Terminate__c, true)
            .setField(Product2.ProductCode, '00123');       
                        
        sfab_FabricatedSObject opp = TestUtilities2.newOpportunity();

        sfab_FabricatedSObject re = TestUtilities2.newRecurSoftRenewalRule();
    
        OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem()
            .setField(OpportunityLineItem.OpportunityId, ((Opportunity) opp.toSObject()).Id)            
            .setField(OpportunityLineItem.Product2Id, ((Product2) pr.toSObject()).Id)                                                                         
            .setField(OpportunityLineItem.RecurSoft__Renewal_Rule__c, ((RecurSoft__Renewal_Rule__c) re.toSObject()).Id)   
            .setParent('Opportunity', opp)
            .setParent('Product2', pr)
            .toSObject();

        ProductsSelector mockSelector = (ProductsSelector) mocks.mock(ProductsSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
            .thenReturn(Product2.SObjectType);
        mocks.when(mockSelector.selectByOpportunityLineItems(new List<OpportunityLineItem> {oppLi}))
            .thenReturn(new List<Product2> {(Product2) pr.toSObject()});
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);
       
        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem>{ oppLi });         
        opportunityLineItems.setDefaultsFromProduct(oppLi);

        System.assertEquals('Months', oppLi.RecurSoft__Contract_Term_Setting__c);        
        System.assertEquals('00123', oppLi.Product_Code_Formula__c);  
        System.assertEquals(true, oppLi.Is_Monthly__c);       
    }

    @isTest static void test_setMonthlyRevenue()
    {       
        fflib_ApexMocks mocks = new fflib_ApexMocks();       

        sfab_FabricatedSObject pr = TestUtilities2.newProduct()     
            .setField(Product2.Family, 'SR Platform')
            .setField(Product2.RecurSoft__Billing_Frequency__c, 'Monthly');   

        sfab_FabricatedSObject opp = TestUtilities2.newOpportunity();       

        sfab_FabricatedSObject oppLi = TestUtilities2.newOpportunityLineItem()
            .setField(OpportunityLineItem.OpportunityId, ((Opportunity) opp.toSObject()).Id) 
            .setField(OpportunityLineItem.UnitPrice, 100)    
            .setField(OpportunityLineItem.Invoiced_Price__c, 0)    
            .setField(OpportunityLineItem.Quantity, 10)  
            .setField(OpportunityLineItem.Product2Id, ((Product2) pr.toSObject()).Id)           
            .setParent('Opportunity', opp)          
            .setParent('Product2', pr);

        OpportunityLineItem oppLis = (OpportunityLineItem) oppLi.toSObject();

        OpportunityLineItem existingOppLi = (OpportunityLineItem) TestUtilities2.existingOpportunityLineItem(oppLi)
            .setField(OpportunityLineItem.OpportunityId, ((Opportunity) opp.toSObject()).Id)            
            .setField(OpportunityLineItem.UnitPrice, 200)   
            .setField(OpportunityLineItem.Invoiced_Price__c, 0)    
            .setField(OpportunityLineItem.Quantity, 20)   
            .setParent('Opportunity', opp)          
            .toSObject();               
       
        ProductsSelector mockSelector = (ProductsSelector) mocks.mock(ProductsSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
            .thenReturn(Product2.SObjectType);
        mocks.when(mockSelector.selectByOpportunityLineItems(new List<OpportunityLineItem> { oppLis }))
            .thenReturn(new List<Product2> { ((Product2) pr.toSObject()) });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);
       
        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem>{ oppLis });         
        opportunityLineItems.setMonthlyRevenue(oppLis, existingOppLi);

        System.assertEquals(1000, oppLis.SR_Monthly_Revenue__c);     
    }

    @isTest static void test_updateAllOppLisOnOppList()
    {       
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        sfab_FabricatedSObject pbe = TestUtilities2.newPricebookEntry()
            .setField(PricebookEntry.UnitPrice, 0);
    
        sfab_FabricatedSObject opp = TestUtilities2.newOpportunity()
            .setField(Opportunity.IsClosed, false)
            .setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeMap('Opportunity').get('Add-On Business').getRecordTypeId())
            .setField(Opportunity.RecurSoft__Initial_Contract_Term__c, 5)
            .setField(Opportunity.RecurSoft__Contract_Signed_Date__c, Date.today());      

        OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem()
            .setField(OpportunityLineItem.OpportunityId, ((Opportunity) opp.toSObject()).Id) 
            .setField(OpportunityLineItem.Approval_Level_Required_Price_Discount__c, 1)    
            .setField(OpportunityLineItem.Approval_Level_Required_Free_Months__c, 2)    
            .setField(OpportunityLineItem.Approval_Level_Required_Term__c, 3)  
            .setField(OpportunityLineItem.Approval_Level_Required_Trial__c, 4)              
            .setField(OpportunityLineItem.Number_of_Free_Months__c, 10)             
            .setField(OpportunityLineItem.Trial__c, 4) 
            .setField(OpportunityLineItem.RecurSoft__Contract_Term_Start_Date_New__c, Date.newInstance(2018, 01, 20)) 
            .setField(OpportunityLineItem.RecurSoft__Contract_Term_End_Date_Editable__c, Date.today())          
            .setField(OpportunityLineItem.PricebookEntryId, ((PricebookEntry) pbe.toSObject()).Id)
            .setField(OpportunityLineItem.Override_Modified_Subscription__c, true) 
            .setField(OpportunityLineItem.Override_Current_SR_Subscription__c, true) 
            .setParent('Opportunity', opp)          
            .setParent('PricebookEntry', pbe)  
            .toSObject();  
        
        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem>{ oppLi });         
        opportunityLineItems.updateAllOpplisOnOppContractDates = new Set<Id>();       
        opportunityLineItems.updateAllOpplisOnOppContractDates.Add(oppLi.OpportunityId);        
        opportunityLineItems.updateAllOpplisOnOppModifiedSubscriptions = new Set<Id>();       
        opportunityLineItems.updateAllOpplisOnOppModifiedSubscriptions.Add(oppLi.OpportunityId);                
        opportunityLineItems.updateAllOppLisOnOpp(new List<OpportunityLineItem> {oppLi}, uow);
        String recursofContractTerm = String.valueOf(oppLi.RecurSoft__Contract_Term_Start_Date_New__c.monthsBetween(oppLi.RecurSoft__Contract_Term_End_Date_Editable__c));
        
        System.assertEquals(1, uow.m_dirtyMapByType.get('OpportunityLineItem').size());  
        //System.assertEquals(10, oppLi.Approved_Free_Months__c);  
        System.assertEquals(recursofContractTerm, oppLi.RecurSoft__Contract_Term1__c); 
    }
    
    @isTest static void test_updateAllOppLisOnOpp()
    {       
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        sfab_FabricatedSObject pbe = TestUtilities2.newPricebookEntry()
            .setField(PricebookEntry.UnitPrice, 0);
    
        sfab_FabricatedSObject opp = TestUtilities2.newOpportunity()
            .setField(Opportunity.IsClosed, false)
            .setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeMap('Opportunity').get('Add-On Business').getRecordTypeId())
            .setField(Opportunity.RecurSoft__Initial_Contract_Term__c, 5)
            .setField(Opportunity.RecurSoft__Contract_Signed_Date__c, Date.today());      

        OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem()
            .setField(OpportunityLineItem.OpportunityId, ((Opportunity) opp.toSObject()).Id) 
            .setField(OpportunityLineItem.Approval_Level_Required_Price_Discount__c, 1)    
            .setField(OpportunityLineItem.Approval_Level_Required_Free_Months__c, 2)    
            .setField(OpportunityLineItem.Approval_Level_Required_Term__c, 3)  
            .setField(OpportunityLineItem.Approval_Level_Required_Trial__c, 4)              
            .setField(OpportunityLineItem.Number_of_Free_Months__c, 10)             
            .setField(OpportunityLineItem.Trial__c, 4) 
            .setField(OpportunityLineItem.RecurSoft__Contract_Term_Start_Date_New__c, Date.newInstance(2018, 01, 20)) 
            .setField(OpportunityLineItem.RecurSoft__Contract_Term_End_Date_Editable__c, Date.today())                      
            .setField(OpportunityLineItem.PricebookEntryId, ((PricebookEntry) pbe.toSObject()).Id)
            .setField(OpportunityLineItem.Override_Modified_Subscription__c, true) 
            .setField(OpportunityLineItem.Override_Current_SR_Subscription__c, true) 
            .setParent('Opportunity', opp)          
            .setParent('PricebookEntry', pbe)  
            .toSObject();  
        
        OpportunityLineItemsSelector mockSelector = (OpportunityLineItemsSelector) mocks.mock(OpportunityLineItemsSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
            .thenReturn(OpportunityLineItem.SObjectType);
        mocks.when(mockSelector.selectByOpportunityIdWithAccountOpportunityProductPricebookEntry(new Set<Id>{ oppLi.OpportunityId }))
            .thenReturn(new List<OpportunityLineItem>{ oppLi });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);
        
        Set<Id> ids = new Set<Id>();
        ids.Add(oppLi.OpportunityId);

        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem>{ oppLi });         
        opportunityLineItems.updateAllOpplisOnOppContractDates = new Set<Id>();       
        opportunityLineItems.updateAllOpplisOnOppContractDates.Add(oppLi.OpportunityId);        
        opportunityLineItems.updateAllOpplisOnOppModifiedSubscriptions = new Set<Id>();       
        opportunityLineItems.updateAllOpplisOnOppModifiedSubscriptions.Add(oppLi.OpportunityId);                
        opportunityLineItems.updateAllOppLisOnOpp(ids, uow);
        String recursofContractTerm = String.valueOf(oppLi.RecurSoft__Contract_Term_Start_Date_New__c.monthsBetween(oppLi.RecurSoft__Contract_Term_End_Date_Editable__c));        

        System.assertEquals(1, uow.m_dirtyMapByType.get('OpportunityLineItem').size()); 
        //System.assertEquals(10, oppLi.Approved_Free_Months__c);          
        System.assertEquals(recursofContractTerm, oppLi.RecurSoft__Contract_Term1__c);          
    }

    @isTest static void test_setModifiedSubscriptions()
    {  
        String fieldName = 'Current_SR_Subscription__c';        
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ApexMocks mocks2 = new fflib_ApexMocks();

        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        Account ac = (Account) TestUtilities2.newAccount().toSObject(); 

        sfab_FabricatedSObject pv =  TestUtilities2.newProvider(); 

        RecurSoft__Renewal_Rule__c re = (RecurSoft__Renewal_Rule__c) TestUtilities2.newRecurSoftRenewalRule().toSObject(); 

        sfab_FabricatedSObject ps = TestUtilities2.newRecurSoftProductSubscription();       

        RecurSoft__Product_Subscription__c ps2 = (RecurSoft__Product_Subscription__c) TestUtilities2.newRecurSoftProductSubscription().toSObject(); 

        sfab_FabricatedSObject pr = TestUtilities2.newProduct() 
            .setField(Product2.Family, 'SR Platform')
            .setField(Product2.Default_Co_Terminate__c, true)
            .setField(Product2.ProductCode, '00123');    

        sfab_FabricatedSObject a = TestUtilities2.newAsset()
            .setField(Asset.Product2Id, ((Product2) pr.toSObject()).Id)
            .setField(Asset.AccountId, ac.Id)
            .setField(Asset.Provider__c, ((Provider__c) pv.toSObject()).Id)
            .setField(Asset.Current_Product_Subscription__c, ps2.Id)            
            .setParent('Product2', pr);

        Asset ast = (Asset) a.toSObject();
                    
        sfab_FabricatedSObject opp = TestUtilities2.newOpportunity()
            .setField(Opportunity.AccountId, ac.Id)
            .setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeMap('Opportunity').get('Add-On Business').getRecordTypeId());

        OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem()
            .setField(OpportunityLineItem.OpportunityId, ((Opportunity) opp.toSObject()).Id)            
            .setField(OpportunityLineItem.Override_Modified_Subscription__c, false)                                                                       
            .setField(OpportunityLineItem.Override_Current_SR_Subscription__c, false)                                                                         
            .setField(OpportunityLineItem.RecurSoft__Renewal_Rule__c, re.Id)   
            .setField(OpportunityLineItem.Modified_Subscription__c, ((RecurSoft__Product_Subscription__c) ps.toSObject()).Id) 
            .setField(OpportunityLineItem.Current_SR_Subscription__c, null) 
            .setField(OpportunityLineItem.Provider__c, ((Provider__c) pv.toSObject()).Id)
            .setField(OpportunityLineItem.Product2Id, ((Product2) pr.toSObject()).Id)
            .setParent('Opportunity', opp)
            .setParent('Product2', pr)
            .setParent('RecurSoft__Product_Subscription__r', ps)
            .toSObject();           

        AssetsSelector mockSelector2 = (AssetsSelector) mocks2.mock(AssetsSelector.class);

        mocks2.startStubbing();
        mocks2.when(mockSelector2.getSObjectType2())
            .thenReturn(Asset.SObjectType);
        mocks2.when(mockSelector2.selectCurrentSubscriptionsByOpportunityLineItems(new List<OpportunityLineItem> {oppLi}))
            .thenReturn(new Map<String,Id> {String.valueOf(ast.AccountId) + (((Product2) pr.toSObject()).Family) + ast.Provider__c => ast.Current_Product_Subscription__c});
        mocks2.stopStubbing();

        Application.Selector.setMock(mockSelector2);

        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem>{ oppLi });             
        opportunityLineItems.setModifiedSubscriptions(oppLi, fieldName, uow);
       
        System.assertEquals(1, uow.m_dirtyMapByType.get('OpportunityLineItem').size()); 
        System.assertEquals(ps2.Id, oppLi.Current_SR_Subscription__c);      
    }

    @isTest static void test_setModifiedSubscriptionsList()
    {       
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ApexMocks mocks2 = new fflib_ApexMocks();

        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        Account ac = (Account) TestUtilities2.newAccount().toSObject(); 

        sfab_FabricatedSObject pv =  TestUtilities2.newProvider(); 

        RecurSoft__Renewal_Rule__c re = (RecurSoft__Renewal_Rule__c) TestUtilities2.newRecurSoftRenewalRule().toSObject(); 

        sfab_FabricatedSObject ps = TestUtilities2.newRecurSoftProductSubscription();       

        RecurSoft__Product_Subscription__c ps2 = (RecurSoft__Product_Subscription__c) TestUtilities2.newRecurSoftProductSubscription().toSObject(); 

        sfab_FabricatedSObject pr = TestUtilities2.newProduct() 
            .setField(Product2.Family, 'SR Platform')
            .setField(Product2.Default_Co_Terminate__c, true)
            .setField(Product2.ProductCode, '00123');    

        sfab_FabricatedSObject a = TestUtilities2.newAsset()
            .setField(Asset.Product2Id, ((Product2) pr.toSObject()).Id)
            .setField(Asset.AccountId, ac.Id)
            .setField(Asset.Provider__c, ((Provider__c) pv.toSObject()).Id)
            .setField(Asset.Current_Product_Subscription__c, ps2.Id)            
            .setParent('Product2', pr);

        Asset ast = (Asset) a.toSObject();
                    
        sfab_FabricatedSObject opp = TestUtilities2.newOpportunity()
            .setField(Opportunity.AccountId, ac.Id)
            .setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeMap('Opportunity').get('Add-On Business').getRecordTypeId());

        OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem()
            .setField(OpportunityLineItem.OpportunityId, ((Opportunity) opp.toSObject()).Id)            
            .setField(OpportunityLineItem.Override_Modified_Subscription__c, false)                                                                       
            .setField(OpportunityLineItem.Override_Current_SR_Subscription__c, false)                                                                         
            .setField(OpportunityLineItem.RecurSoft__Renewal_Rule__c, re.Id)   
            .setField(OpportunityLineItem.Modified_Subscription__c, null) 
            .setField(OpportunityLineItem.Current_SR_Subscription__c, null) 
            .setField(OpportunityLineItem.Provider__c, ((Provider__c) pv.toSObject()).Id)
            .setField(OpportunityLineItem.Product2Id, ((Product2) pr.toSObject()).Id)
            .setParent('Opportunity', opp)
            .setParent('Product2', pr)
            .setParent('RecurSoft__Product_Subscription__r', ps)
            .toSObject();           

        AssetsSelector mockSelector2 = (AssetsSelector) mocks2.mock(AssetsSelector.class);

        mocks2.startStubbing();
        mocks2.when(mockSelector2.getSObjectType2())
            .thenReturn(Asset.SObjectType);
        mocks2.when(mockSelector2.selectCurrentSubscriptionsByOpportunityLineItems(new List<OpportunityLineItem> {oppLi}))
            .thenReturn(new Map<String,Id> {String.valueOf(ast.AccountId) + (((Product2) pr.toSObject()).Family) + ast.Provider__c => ast.Current_Product_Subscription__c});
        mocks2.stopStubbing();

        Application.Selector.setMock(mockSelector2);

        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem>{ oppLi });         
        opportunityLineItems.updateAllOpplisOnOppModifiedSubscriptions = new Set<Id>();        
        opportunityLineItems.updateAllOpplisOnOppModifiedSubscriptions.Add(oppLi.OpportunityId); 
        opportunityLineItems.setModifiedSubscriptions(new List<OpportunityLineItem> {oppLi}, uow);
       
        System.assertEquals(1, uow.m_dirtyMapByType.get('OpportunityLineItem').size()); 
        System.assertEquals(ps2.Id, oppLi.Current_SR_Subscription__c); 
        System.assertEquals(ps2.Id, oppLi.Modified_Subscription__c);      
    }

    @isTest static void test_updateApprovalLevelRequired() 
    {       
        fflib_ApexMocks mocks = new fflib_ApexMocks();  

        sfab_FabricatedSObject pbe = TestUtilities2.newPricebookEntry();   

        sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity();            
        
        Opportunity opp = (Opportunity) oppFab.toSObject();
        
        sfab_FabricatedSObject oppLiFab = TestUtilities2.newOpportunityLineItem()
            .setField(OpportunityLineItem.OpportunityId, opp.Id) 
            .setField(OpportunityLineItem.UnitPrice, 100) 
            .setField(OpportunityLineItem.Approval_Level_Required_Price_Discount__c, 1) 
            .setField(OpportunityLineItem.Approval_Level_Required_Free_Months__c, 2) 
            .setField(OpportunityLineItem.Approval_Level_Required_Term__c, 3) 
            .setField(OpportunityLineItem.Approval_Level_Required_Trial__c, 4) 
            .setField(OpportunityLineItem.PricebookEntryId, ((PricebookEntry) pbe.toSObject()).Id)
            .setParent('Opportunity', oppFab)       
            .setParent('PricebookEntry', pbe); 

        OpportunityLineItem oppLi = (OpportunityLineItem) oppLiFab.toSObject();

        OpportunityLineItem existingOppLi = (OpportunityLineItem) TestUtilities2.existingOpportunityLineItem(oppLiFab)
            .setField(OpportunityLineItem.OpportunityId, opp.Id)            
            .setField(OpportunityLineItem.UnitPrice, 200)    
            .setField(OpportunityLineItem.PricebookEntryId, ((PricebookEntry) pbe.toSObject()).Id)
            .setParent('Opportunity', oppFab) 
            .setParent('PricebookEntry', pbe)           
            .toSObject();       

        PricebookEntriesSelector mockSelector = (PricebookEntriesSelector) mocks.mock(PricebookEntriesSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
            .thenReturn(PricebookEntry.SObjectType);
        mocks.when(mockSelector.selectByOpportunityLineItems(new List<OpportunityLineItem>{ oppLi }))
            .thenReturn(new List<PricebookEntry> { (PricebookEntry) pbe.toSObject() });
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);

        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem>{ oppLi });               
        opportunityLineItems.updateApprovalLevelRequired(oppLi, existingOppLi);
        
        System.assertEquals(oppLi.Approval_Level_Required_Trial__c, oppLi.Approval_Level_Required__c);      
    }

    @isTest static void test_validateProductFamily()
    {
        try{
            fflib_ApexMocks mocks = new fflib_ApexMocks();

            Account ac = (Account) TestUtilities2.newAccount().toSObject(); 

            Provider__c pv = (Provider__c) TestUtilities2.newProvider().toSObject(); 

            sfab_FabricatedSObject pr = TestUtilities2.newProduct()
                .setField(Product2.Family, 'SR Platform');
            
            sfab_FabricatedSObject opp = TestUtilities2.newOpportunity()
                .setField(Opportunity.AccountId, ac.Id);
                   
            OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem()
                .setField(OpportunityLineItem.OpportunityId, ((Opportunity) opp.toSObject()).Id)
                .setField(OpportunityLineItem.Product2Id, ((Product2) pr.toSObject()).Id)
                .setField(OpportunityLineItem.Provider__c, pv.Id)
                .setParent('Product2', pr)
                .setParent('Opportunity', opp)
                .toSObject();
            
            Map<Id, OpportunityLineItem>  mp = new Map<Id, OpportunityLineItem>(new List<OpportunityLineItem> { oppLi });

            OpportunityLineItemsSelector mockSelector = (OpportunityLineItemsSelector) mocks.mock(OpportunityLineItemsSelector.class);
           
            mocks.startStubbing();
            mocks.when(mockSelector.getSObjectType2())
               .thenReturn(OpportunityLineItem.SObjectType);
            mocks.when(mockSelector.selectByIdWithAccountOpportunityProductPricebookEntry(mp.keySet()))
               .thenReturn(new List<OpportunityLineItem> { oppLi });
            mocks.stopStubbing();
            
            Application.Selector.setMock(mockSelector);
            
            String result = oppLi.Opportunity.AccountId + oppLi.Product2.Family + oppLi.Provider__c;
            
            AssetsSelector mockSelector2 = (AssetsSelector) mocks.mock(AssetsSelector.class);
            
            mocks.startStubbing();
            mocks.when(mockSelector2.getSObjectType2())
               .thenReturn(Asset.SObjectType);
            mocks.when(mockSelector2.selectCurrentSubscriptionsByOpportunityLineItems(new List<OpportunityLineItem> { oppLi }))
               .thenReturn(new  Map<String,Id> { result => oppLi.Id });           
            mocks.stopStubbing();

           Application.Selector.setMock(mockSelector2);

           OpportunityLineItems opportunityLineItems = new  OpportunityLineItems (new List<OpportunityLineItem> { oppLi });
           opportunityLineItems.validateProductFamily(oppLi);  
           System.assert(false);        
       }
       catch(Exception e){
            System.assert(e.getMessage().contains('There is already an active subscription for this product family'));              
       }       
    }

    @isTest static void test_updateContractDates()
    {   
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
                
        sfab_FabricatedSObject oppFab = TestUtilities2.newOpportunity()
            .setField(Opportunity.IsClosed, false)
            .setField(Opportunity.RecordTypeId, SRUtilities.getRecordTypeMap('Opportunity').get('Add-On Business').getRecordTypeId())
            .setField(Opportunity.RecurSoft__Contract_Signed_Date__c, Date.today())
            .setField(Opportunity.RecurSoft__Initial_Contract_Term__c, 1);            
        
        Opportunity opp = (Opportunity) oppFab.toSObject();
       
        sfab_FabricatedSObject pr = TestUtilities2.newProduct()
            .setField(Product2.Default_Contract_Term__c, 2);
        
        OpportunityLineItem oppLi = (OpportunityLineItem) TestUtilities2.newOpportunityLineItem()
            .setField(OpportunityLineItem.OpportunityId, opp.Id)
            .setField(OpportunityLineItem.RecurSoft__Contract_Term_Start_Date_New__c, Date.newInstance(2018, 04, 27))
            .setField(OpportunityLineItem.RecurSoft__Contract_Term_End_Date_Editable__c, Date.today())
            .setParent('Product2', pr)
            .setParent('Opportunity', oppFab)
            .toSObject();
        
        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(new List<OpportunityLineItem> { oppLi });
        opportunityLineItems.updateAllOpplisOnOppContractDates = new Set<Id>();
        opportunityLineItems.updateAllOpplisOnOppContractDates.Add(oppLi.OpportunityId);
        opportunityLineItems.opportunityIdToContractEndDateMap = new Map<Id, Date>();
        opportunityLineItems.opportunityIdToContractEndDateMap.put(oppLi.OpportunityId, Date.today());
        opportunityLineItems.updateContractDates(new List<OpportunityLineItem> { oppLi }, uow);
        String recursoftContractTerm = String.valueOf(oppLi.RecurSoft__Contract_Term_Start_Date_New__c.monthsBetween(oppLi.RecurSoft__Contract_Term_End_Date_Editable__c));

        System.assertEquals(1, uow.m_dirtyMapByType.get('OpportunityLineItem').size());
        System.assertEquals(recursoftContractTerm, oppLi.RecurSoft__Contract_Term1__c);       
    }
}