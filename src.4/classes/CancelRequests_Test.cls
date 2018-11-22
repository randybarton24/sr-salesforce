@IsTest
private class CancelRequests_Test {
  
    @testSetup static void testData()
    {
        Account a = TestUtilities.insertBasicAccount(true);
        a.Do_Not_Support_Sync__c = true;
        a.Do_Not_Support_Reason__c = 'Billing Issues';

        update a;
    }

    @isTest static void test_onBeforeInsert() 
    {       
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

        Cancel_Request__c cro = (Cancel_Request__c) TestUtilities2.newCancelRequest()
            .setField(Cancel_Request__c.Override_Modified_Subscription__c, true)
            .setField(Cancel_Request__c.Override_Current_SR_Subscription__c, true)
            .toSObject();
     
        CancelRequests cancelRequest = new CancelRequests(new List<Cancel_Request__c>{ cro });         
        cancelRequest.onBeforeInsert();          
    }

    @isTest static void test_onAfterUpdate() 
    {       
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

        Cancel_Request__c cro = (Cancel_Request__c) TestUtilities2.newCancelRequest()
            .setField(Cancel_Request__c.Override_Modified_Subscription__c, true)
            .setField(Cancel_Request__c.Override_Current_SR_Subscription__c, true)
            .setField(Cancel_Request__c.Stage__c, 'Sale')
            .toSObject();
     
        CancelRequests cancelRequest = new CancelRequests(new List<Cancel_Request__c>{ cro });                 
        cancelRequest.onAfterUpdate(new Map<Id, SObject>{cro.Id => cro});          
    }

    @isTest static void test_onAfterInsert() 
    {       
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

        Cancel_Request__c cro = (Cancel_Request__c) TestUtilities2.newCancelRequest()
            .setField(Cancel_Request__c.Override_Modified_Subscription__c, true)
            .setField(Cancel_Request__c.Override_Current_SR_Subscription__c, true)
            .toSObject();
     
        CancelRequests cancelRequest = new CancelRequests(new List<Cancel_Request__c>{ cro });         
        cancelRequest.onAfterInsert();          
    }

    @isTest static void test_setModifiedSubscriptions()
    {         
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

         fflib_ApexMocks mocks2 = new fflib_ApexMocks();

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
                         
        sfab_FabricatedSObject croFab = TestUtilities2.newCancelRequest()
            .setField(Cancel_Request__c.Override_Modified_Subscription__c, false)
            .setField(Cancel_Request__c.Asset__c, ast.Id)
            .setField(Cancel_Request__c.Override_Current_SR_Subscription__c, false);

        Cancel_Request__c cro = (Cancel_Request__c) croFab.toSObject();

        Cancel_Request__c existingCro = (Cancel_Request__c) croFab.toSObject();  

        AssetsSelector mockSelector1 = (AssetsSelector) mocks2.mock(AssetsSelector.class);

        mocks2.startStubbing();
        mocks2.when(mockSelector1.getSObjectType2())
            .thenReturn(Asset.SObjectType);
        mocks2.when(mockSelector1.selectCurrentSubscriptionsByCancelRequests(new List<Cancel_Request__c> {cro}))
            .thenReturn(new Map<String, Id> {String.valueOf(ast.AccountId) + ast.Product2.Family + ast.Provider__c => ast.Current_Product_Subscription__c});
        mocks2.stopStubbing();

        Application.Selector.setMock(mockSelector1); 

        AssetsSelector mockSelector2 = (AssetsSelector) mocks2.mock(AssetsSelector.class);

        mocks2.startStubbing();
        mocks2.when(mockSelector2.getSObjectType2())
            .thenReturn(Asset.SObjectType);
        mocks2.when(mockSelector2.selectByCancelRequestsWithAccountAndProduct(new List<Cancel_Request__c> {cro}))
            .thenReturn(new List<Asset> {ast});
        mocks2.stopStubbing();

        Application.Selector.setMock(mockSelector2);     

        CancelRequests cancelRequest = new CancelRequests(new List<Cancel_Request__c>{ cro });         
        cancelRequest.setModifiedSubscriptions(cro, existingCro, uow);
       
        System.assertEquals(1, uow.m_dirtyMapByType.get('Cancel_Request__c').size());         
    }

    @isTest static void test_setModifiedSubscriptions2()
    {       
        String fieldName = 'Current_SR_Subscription__c';

        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

         fflib_ApexMocks mocks2 = new fflib_ApexMocks();

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
                         
        sfab_FabricatedSObject croFab = TestUtilities2.newCancelRequest()
            .setField(Cancel_Request__c.Override_Modified_Subscription__c, false)
            .setField(Cancel_Request__c.Asset__c, ast.Id)
            .setField(Cancel_Request__c.Override_Current_SR_Subscription__c, false);

        Cancel_Request__c cro = (Cancel_Request__c) croFab.toSObject();

        AssetsSelector mockSelector1 = (AssetsSelector) mocks2.mock(AssetsSelector.class);

        mocks2.startStubbing();
        mocks2.when(mockSelector1.getSObjectType2())
            .thenReturn(Asset.SObjectType);
        mocks2.when(mockSelector1.selectCurrentSubscriptionsByCancelRequests(new List<Cancel_Request__c> {cro}))
            .thenReturn(new Map<String, Id> {String.valueOf(ast.AccountId) + ast.Product2.Family + ast.Provider__c => ast.Current_Product_Subscription__c});
        mocks2.stopStubbing();

        Application.Selector.setMock(mockSelector1); 

        AssetsSelector mockSelector2 = (AssetsSelector) mocks2.mock(AssetsSelector.class);

        mocks2.startStubbing();
        mocks2.when(mockSelector2.getSObjectType2())
            .thenReturn(Asset.SObjectType);
        mocks2.when(mockSelector2.selectByCancelRequestsWithAccountAndProduct(new List<Cancel_Request__c> {cro}))
            .thenReturn(new List<Asset> {ast});
        mocks2.stopStubbing();

        Application.Selector.setMock(mockSelector2);     

        CancelRequests cancelRequest = new CancelRequests(new List<Cancel_Request__c>{ cro });         
        cancelRequest.setModifiedSubscriptions(fieldName, cro, uow);
       
        System.assertEquals(1, uow.m_dirtyMapByType.get('Cancel_Request__c').size());         
    }

    @isTest static void test_createAddendumOpp()
    {       
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        fflib_ApexMocks mocks2 = new fflib_ApexMocks();

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
                         
        sfab_FabricatedSObject croFab = TestUtilities2.newCancelRequest()
            .setField(Cancel_Request__c.Override_Modified_Subscription__c, false)
            .setField(Cancel_Request__c.Asset__c, ast.Id)
            .setField(Cancel_Request__c.Stage__c, 'Save')
            .setField(Cancel_Request__c.Override_Current_SR_Subscription__c, false);

        Cancel_Request__c cro = (Cancel_Request__c) croFab.toSObject();

        Cancel_Request__c existingCro = (Cancel_Request__c) croFab
			.setField(Cancel_Request__c.Stage__c, 'New')
        	.toSObject();  
        
        AssetsSelector mockSelector2 = (AssetsSelector) mocks2.mock(AssetsSelector.class);

        mocks2.startStubbing();
        mocks2.when(mockSelector2.getSObjectType2())
            .thenReturn(Asset.SObjectType);
        mocks2.when(mockSelector2.selectByCancelRequestsWithAccountAndProduct(new List<Cancel_Request__c> {cro}))
            .thenReturn(new List<Asset> {ast});
        mocks2.stopStubbing();

        Application.Selector.setMock(mockSelector2);     

        CancelRequests cancelRequest = new CancelRequests(new List<Cancel_Request__c>{ cro });         
        cancelRequest.createAddendumOpp(cro, existingCro, uow);
       
        System.assertEquals(1, uow.m_newListByType.get('Opportunity').size());         
    }

    @isTest static void test_createCancelCase()
    {       
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        fflib_ApexMocks mocks2 = new fflib_ApexMocks();

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

        Opportunity opp = (Opportunity) TestUtilities2.newOpportunity().toSObject();
                         
        sfab_FabricatedSObject croFab = TestUtilities2.newCancelRequest()
            .setField(Cancel_Request__c.Override_Modified_Subscription__c, false)
            .setField(Cancel_Request__c.Asset__c, ast.Id)
            .setField(Cancel_Request__c.Stage__c, 'Cancelled')
            .setField(Cancel_Request__c.Cancel_Request_Type__c, 'Annual')
            .setField(Cancel_Request__c.Override_Current_SR_Subscription__c, false)
            .setField(Cancel_Request__c.Opportunity__c, opp.Id);

        Cancel_Request__c cro = (Cancel_Request__c) croFab.toSObject();

        Cancel_Request__c existingCro = (Cancel_Request__c) croFab
			.setField(Cancel_Request__c.Stage__c, 'No Sale')
        	.toSObject();  
        
        AssetsSelector mockSelector2 = (AssetsSelector) mocks2.mock(AssetsSelector.class);

        mocks2.startStubbing();
        mocks2.when(mockSelector2.getSObjectType2())
            .thenReturn(Asset.SObjectType);
        mocks2.when(mockSelector2.selectByCancelRequestsWithAccountAndProduct(new List<Cancel_Request__c> {cro}))
            .thenReturn(new List<Asset> {ast});
        mocks2.stopStubbing();

        Application.Selector.setMock(mockSelector2);     

        CancelRequests cancelRequest = new CancelRequests(new List<Cancel_Request__c>{ cro });         
        cancelRequest.createCancelCase(cro, existingCro, uow);
       
        System.assertEquals(1, uow.m_newListByType.get('Case').size());         
    }

    @IsTest
    static void testDoNotSupportSyncCROSaved()
    {
        Account a = [SELECT Id, Do_Not_Support_Sync__c, Do_Not_Support_Reason__c FROM Account LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];

        Asset ast = new Asset(Name = 'Test Asset',
                AccountId = a.Id,
                Product2Id = p.Id,
                Active__c = false);

        insert ast;

        Opportunity o = TestUtilities.insertRecordTypeOpportunity(a.Id, 'Retention');

        Cancel_Request__c cr = new Cancel_Request__c(Asset__c = ast.Id,
                Opportunity__c = o.Id,
                Stage__c = 'New');

        insert cr;

        Test.startTest();

        cr.Stage__c = 'Save';
        cr.Original_Setup_Fee__c = 399;
        cr.Current_MSF__c = 379;
        cr.Most_Recent_Contract_Date__c = Date.today().addDays(-30);
        cr.Cancellation_Reasons__c = 'Not interested';
        cr.Cancel_Request_Type__c = 'Trial';
        cr.Save_MSF__c = 359;
        cr.Months_Gained__c = 2;
        cr.Description__c = 'Description';
        cr.Projected_Contract_Expiration_Renewal__c = Date.today().addDays(5);
        cr.Months_Paid_Trial__c = 1;
        Database.SaveResult result = Database.update(cr);

        Test.stopTest();

        Account acct = [SELECT Id, Do_Not_Support_Sync__c, Do_Not_Support_Reason__c FROM Account WHERE Id =: a.Id LIMIT 1];
        System.assert(result.isSuccess());
        System.assertEquals(false, acct.Do_Not_Support_Sync__c, 'Did not uncheck \'Do Not Support Sync\' Checkbox');
        System.assertEquals(null, acct.Do_Not_Support_Reason__c, 'Did not Clear \'Do Not Support Reason\'');
    }

    @IsTest
    static void testDoNotSupportSyncCRONotClosed()
    {
        Account a = [SELECT Id, Do_Not_Support_Sync__c, Do_Not_Support_Reason__c FROM Account LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];

        Asset ast = new Asset(Name = 'Test Asset',
                AccountId = a.Id,
                Product2Id = p.Id,
                Active__c = false);

        insert ast;

        Opportunity o = TestUtilities.insertRecordTypeOpportunity(a.Id, 'Retention');

        Cancel_Request__c cr = new Cancel_Request__c(Asset__c = ast.Id,
                Opportunity__c = o.Id,
                Stage__c = 'New');

        insert cr;

        Test.startTest();

        cr.Stage__c = 'Actively Working';
        cr.Original_Setup_Fee__c = 399;
        cr.Current_MSF__c = 379;
        cr.Most_Recent_Contract_Date__c = Date.today().addDays(-30);
        cr.Cancellation_Reasons__c = 'Not interested';
        cr.Cancel_Request_Type__c = 'Trial';
        cr.Description__c = 'Description';
        cr.Projected_Contract_Expiration_Renewal__c = Date.today().addDays(5);
        cr.Months_Paid_Trial__c = 1;
        Database.SaveResult result = Database.update(cr);

        Test.stopTest();

        Account acct = [SELECT Id, Do_Not_Support_Sync__c, Do_Not_Support_Reason__c FROM Account WHERE Id =: a.Id LIMIT 1];
        System.assert(result.isSuccess());
        System.assertEquals(true, acct.Do_Not_Support_Sync__c, 'Did uncheck \'Do Not Support Sync\' Checkbox and it wasn\'t suppose to');
        System.assertEquals('Billing Issues', acct.Do_Not_Support_Reason__c, 'Did Clear \'Do Not Support Reason\' and it wasn\'t suppose to');
    }

    @IsTest
    static void testDoNotSupportSyncCROCancelled()
    {
        Account a = [SELECT Id, Do_Not_Support_Sync__c, Do_Not_Support_Reason__c FROM Account LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];

        Asset ast = new Asset(Name = 'Test Asset',
                AccountId = a.Id,
                Product2Id = p.Id,
                Active__c = false);

        insert ast;

        Opportunity o = TestUtilities.insertRecordTypeOpportunity(a.Id, 'Retention');

        Cancel_Request__c cr = new Cancel_Request__c(Asset__c = ast.Id,
                Opportunity__c = o.Id,
                Stage__c = 'New');

        insert cr;

        Test.startTest();

        cr.Stage__c = 'Cancelled';
        cr.Original_Setup_Fee__c = 399;
        cr.Current_MSF__c = 379;
        cr.Most_Recent_Contract_Date__c = Date.today().addDays(-30);
        cr.Cancel_Month__c = Date.today().addMonths(1).toStartOfMonth();
        cr.Cancellation_Reasons__c = 'Not interested';
        cr.Cancellation_Details__c = 'Really Not interested';
        cr.Cancel_Request_Type__c = 'Trial';
        cr.Description__c = 'Description';
        cr.Projected_Contract_Expiration_Renewal__c = Date.today().addDays(5);
        cr.Months_Paid_Trial__c = 1;
        Database.SaveResult result = Database.update(cr);

        Test.stopTest();

        Account acct = [SELECT Id, Do_Not_Support_Sync__c, Do_Not_Support_Reason__c FROM Account WHERE Id =: a.Id LIMIT 1];
        System.assert(result.isSuccess());
        System.assertEquals(false, acct.Do_Not_Support_Sync__c, 'Did not uncheck \'Do Not Support Sync\' Checkbox');
        System.assertEquals(null, acct.Do_Not_Support_Reason__c, 'Did not Clear \'Do Not Support Reason\'');
    }
}