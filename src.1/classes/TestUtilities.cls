@isTest
public class TestUtilities {
    
    public static Map<String, PricebookEntry> standardPricebookEntries = new Map<String, PricebookEntry>();

    public static Opportunity getOppData(Id oppId) {
        
        Opportunity results = 
        [SELECT Id, 
        AccountId, 
        Account.Subscriber_Id__c, 
        Account.RecurSoft__Billing_Email__c,
        Account.Name,
        Account.Practice_Management_Software__r.Limelight_Available__c,
        RecurSoft__Billing_Contact__r.Email, 
        RecordTypeId, 
        RecordType.Name, 
        Contract_Signed__c,
        Number_of_Providers__c, 
        RecurSoft__Contract_Signed_Date__c, 
        RecurSoft__Contract_Term_Start_Date__c, 
        RecurSoft__Contract_Term_End_Date__c, 
        RecurSoft__Trial_End_Date1__c, 
        Name, 
        RecurSoft__Initial_Contract_Term__c, 
        RecurSoft__Number_of_Free_Months__c, 
        RecurSoft__Free_Months_Setting__c,
        RecurSoft__Trial__c, 
        HasOpportunityLineItem, 
        IsLegacy__c,
        CampaignId,
            Campaign.Product_1_Name1__c,
            Campaign.Product_2_Name_2__c,
            Campaign.Name,
            Campaign.Type,
            Campaign.Trial_Period__c,
            Campaign.Free_Months__c,
            Campaign.Free_Months_Setting__c,
            Campaign.Promo_Product1__c,
            Campaign.Product_1_Sales_Price__c,
            Campaign.Product_2_Sale_Price__c, 
        Pricebook2Id,
            Pricebook2.Name,
            Pricebook2.IsStandard,
        (SELECT Id,
            Is_Promo_Item__c,
            ListPrice,
            UnitPrice,
            TotalPrice,
            Quantity,
            OpportunityId, 
            Opportunity.RecordType.Name,
            Opportunity.AccountId,
            Override_Modified_Subscription__c,
            Modified_Subscription__c,
            Base_Contract_Term__c, 
            RecurSoft__Renewal_Rule__c,
            RecurSoft__Product_Subscription__c,
            Trial__c,
            Co_Terminate__c,
            Provider__c, 
            Provider__r.NPI__c, 
            Provider__r.Healthgrades_Id__c, 
            PricebookEntryId,
            PriceBookEntry.Name,
            PriceBookEntry.UnitPrice,
            PricebookEntry.Product2Id, 
            PricebookEntry.Product2.Name,
            PricebookEntry.Product2.ProductCode,
            PricebookEntry.Product2.Family, 
            PriceBookEntry.Product2.Default_Co_Terminate__c,
            PricebookEntry.Product2.Default_Renewal_Rule__c,
            PricebookEntry.Product2.Default_Contract_Term__c,
            PricebookEntry.Product2.RecurSoft__Billing_Frequency__c,
            PricebookEntry.Pricebook2Id
            FROM OpportunityLineItems)
        FROM Opportunity 
        WHERE Id = :oppId];

        return results;
    }

    public static void newInit()
    {
        TestUtilities.insertCustomSettings();
        SObject[] stdPricebookEntry = new List<SObject>();
        SObject[] managementSystems = Test.loadData(Management_System__c.sObjectType, 'TestData_ManagementSystem');
        SObject[] intacctEntity = Test.loadData(RecurSoft__Intacct_Entity__c.sObjectType, 'TestData_IntacctEntity');
        SObject[] renewalRules = Test.loadData(RecurSoft__Renewal_Rule__c.sObjectType, 'TestData_RenewalRule');
        SObject[] products = Test.loadData(Product2.sObjectType, 'TestData_Product2');
        SObject[] pricebooks = Test.loadData(Pricebook2.sObjectType, 'TestData_Pricebook2');

        for(Product2 product : (Product2[]) products)
        {
            PricebookEntry pbEntryStdUSD = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                                    Product2Id = product.Id,
                                                    UnitPrice = 1,
                                                    CurrencyIsoCode = 'USD',
                                                    IsActive = false);
            stdPricebookEntry.add(pbEntryStdUSD);

            PricebookEntry pbEntryStdCAD = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                                    Product2Id = product.Id,
                                                    UnitPrice = 1,
                                                    CurrencyIsoCode = 'CAD',
                                                    IsActive = false);
            stdPricebookEntry.add(pbEntryStdCAD);
        }
        insert stdPricebookEntry;

        SObject[] pricebookentries = Test.loadData(PricebookEntry.sObjectType, 'TestData_PricebookEntry');
        SObject[] appAdminAPISettings = Test.loadData(AppAdminAPI_Settings__c.sObjectType, 'TestData_AppAdminAPISettings');
        SObject[] srDefaultValues = Test.loadData(SR_Default_Values__c.sObjectType, 'TestData_SRDefaultValues');
        SObject[] contractEmailTemplateSettings = Test.loadData(ContractEmailTemplate__c.sObjectType, 'TestData_ContractEmailTemplateSettings');
        SObject[] accounts = Test.loadData(Account.sObjectType, 'TestData_Accounts');
        SObject[] opportunities = Test.loadData(Opportunity.sObjectType, 'TestData_Opportunities');
        SObject[] productSubscriptions = Test.loadData(RecurSoft__Product_Subscription__c.sObjectType, 'TestData_ProductSubscriptions');
        SObject[] assets = Test.loadData(Asset.sObjectType, 'TestData_Assets');
        SObject[] cancelRequests = Test.loadData(Cancel_Request__c.sObjectType, 'TestData_CancelRequests');
    }

    public static void init() {
        Management_System__c pm = insertBasicManagementSystem();
        RecurSoft__Intacct_Entity__c entity = insertBasicIntacctEntity();
        RecurSoft__Renewal_Rule__c rr = insertBasicRenewalRule();
        TestUtilities.insertStandardProducts();
        TestUtilities.insertCustomSettings();
    }
    
    public static void init(fflib_SObjectUnitOfWork uow) 
    {
        TestUtilities.createBasicManagementSystem(uow);
        TestUtilities.createBasicIntacctEntity(uow);
        TestUtilities.createBasicRenewalRule(uow);
        TestUtilities.createStandardProducts(uow);
        TestUtilities.createCustomSettings(uow);
    }

    public static Management_System__c insertBasicManagementSystem() {
        Management_System__c pm = new Management_System__c(Name = 'Test Management System');
        insert pm;
        return pm;
    }

    public static RecurSoft__Intacct_Entity__c insertBasicIntacctEntity() {
        RecurSoft__Intacct_Entity__c entity = new RecurSoft__Intacct_Entity__c(Name = 'SR001');
        insert entity;
        return entity;
    }

    public static RecurSoft__Renewal_Rule__c insertBasicRenewalRule() {
        RecurSoft__Renewal_Rule__c rr = new RecurSoft__Renewal_Rule__c(RecurSoft__Renewal_Rule_Firendly_Name__c = 'Default Recurring Rule');
        insert rr;
        return rr;
    }

    public static void createBasicManagementSystem(fflib_SObjectUnitOfWork uow) 
    {
        Management_System__c pm = new Management_System__c(Name = 'Test Management System');
        uow.registerNew(pm);
    }

    public static void createBasicIntacctEntity(fflib_SObjectUnitOfWork uow) 
    {
        RecurSoft__Intacct_Entity__c entity = new RecurSoft__Intacct_Entity__c(Name = 'SR001');
        uow.registerNew(entity);
    }

    public static void createBasicRenewalRule(fflib_SObjectUnitOfWork uow) 
    {
        RecurSoft__Renewal_Rule__c rr = new RecurSoft__Renewal_Rule__c(RecurSoft__Renewal_Rule_Firendly_Name__c = 'Default Recurring Rule');
        uow.registerNew(rr);
    }

    public static RecurSoft__Product_Subscription__c insertProductSubscription(Account a, Opportunity o, OpportunityLineItem oppLi) {
        RecurSoft__Product_Subscription__c prodSubscription = new RecurSoft__Product_Subscription__c(RecurSoft__Related_Opportunity__c = o.Id,
            RecurSoft__Account__c = a.Id,
            RecurSoft__Opportunity_Product_ID__c = oppLi.Id);
        insert prodSubscription;

        return prodSubscription;
    }
    

    public static void insertPricebookEntry(Id productId, Decimal price, String productName, Id pbookId, Boolean autoAdd) {
 
        PricebookEntry pbEntryStd = new PricebookEntry(Pricebook2Id = pbookId,
                                                    Product2Id = productId,
                                                    UnitPrice = price,
                                                    IsActive = true,
                                                    Auto_Add__c = autoAdd,
                                                    Auto_Add_Quantity__c = autoAdd ? 1 : null);

        insert pbEntryStd;
        if(pbookId == Test.getStandardPricebookId()) TestUtilities.standardPricebookEntries.put(productName, pbEntryStd);
        System.debug(TestUtilities.standardPricebookEntries);
    }

    public static PricebookEntry createPricebookEntry(Id productId, Decimal price, String productName, Id pbookId, Boolean autoAdd) 
    {
        PricebookEntry pbEntryStd = new PricebookEntry(Pricebook2Id = pbookId,
                                                    Product2Id = productId,
                                                    UnitPrice = price,
                                                    IsActive = true,
                                                    Auto_Add__c = autoAdd,
                                                    Auto_Add_Quantity__c = autoAdd ? 1 : null);

        if(pbookId == Test.getStandardPricebookId()) TestUtilities.standardPricebookEntries.put(productName, pbEntryStd);
        return pbEntryStd;
    }

    public static void insertCustomSettings() {
        
        insert new ContractEmailTemplate__c(Name = 'Services',
            TemplateID__c = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sales@solutionreach.com'].Id);
        insert new ContractEmailTemplate__c(Name = 'HealthgradesContract',
            TemplateID__c = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Healthgrades_Contract'].Id);
        insert new SR_Default_Values__c(Name = 'New Customer Contract Email Template',
            Description__c = 'New Customer Contract Email Template',
            Value__c = '7013D0000002bFy');
        insert new SR_Default_Values__c(Name = 'Contract Email Template No Sub ID',
            Description__c = 'Contract Email Template No Sub ID',
            Value__c = '7013D0000002bFy');
        insert new SR_Default_Values__c(Name = 'Services',
            Description__c = 'Services',
            Value__c = '7013D0000002bFy');
        insert new SR_Default_Values__c(Name = 'noCiCampaignIds',
            Description__c = 'noCiCampaignIds',
            Value__c = '1234');
        insert new SR_Default_Values__c(Name = 'sdrCampaignId',
            Description__c = 'sdrCampaignId',
            Value__c = '7013D0000002bFy');
        insert new SR_Default_Values__c(Name = 'coldCallCampaignId',
            Description__c = 'coldCallCampaignId',
            Value__c = '7013D0000002bFy');
        insert new SR_Default_Values__c(Name = 'defaultPricebookId',
            Description__c = 'defaultPricebookId',
            Value__c = Test.getStandardPricebookId());
        insert new SR_Default_Values__c(Name = 'defaultPricebookStage',
            Description__c = 'defaultPricebookStage',
            Value__c = 'Demo Scheduled');
        insert new SR_Default_Values__c(Name = 'jennyPoolUserId',
            Description__c = 'jennyPoolUserId',
            Value__c = '0050Z0000091cKSQAY');
        insert new SR_Default_Values__c(Name = 'salesTargetRolesProfiles',
            Description__c = 'salesTargetRolesProfiles',
            Value__c = 'Standard User');
        insert new SR_Default_Values__c(Name = 'noStealingProfiles',
            Description__c = 'noStealingProfiles',
            Value__c = '0050Z0000091cKSQAY');
        insert new SR_Default_Values__c(Name = 'leadSourceToCampaignId',
            Description__c='leadSourceToCampaignId',
            Value__c = 'ADR Set:70131000001lbcW::Cold Call:70131000001lbcR::Direct Mail:70131000001Nmcx::Email:70131000001Nmcd::Other Website:70131000001uCC2::PPC:7010Z000001vKi7::Referral Partner:70131000001uGlJ::SR Website:70131000001uCBx::Trade Show/Event:70131000001Nmci');
        insert new SR_Default_Values__c(Name = 'Campaign Influence Orphan Days',
            Description__c = 'Campaign Influence Orphan Days',
            Value__c = '30');
        insert new SR_Default_Values__c(Name = 'Opportunity Closed Lost Days',
            Description__c = 'Opportunity Closed Lost Days',
            Value__c = '30');
        insert new AppAdminAPI_Settings__c(Name = 'HealthgradesSettings',
            isProduction__c = false,
            successStatusCode__c = '201',
            practiceNameLength__c = 33,
            productionUsername__c = 'srsalesforce',
            sandboxUsername__c = 'srsalesforce',
            productionPassword__c = '>%p|8u/.K2E?Ji"Gc-]a',
            sandboxPassword__c = 'nottherealpassword',
            productionTargetUrl__c = 'https://sfapi.solutionreach.com/admin/healthgrades',
            sandboxTargetUrl__c = 'https://rlaw-d.communitect.com/admin/healthgrades',
            productionRequestUrl__c = '',
            sandboxRequestUrl__c = '',
            requestType__c = 'PUT');
        insert new AppAdminAPI_Settings__c(Name = 'APISettings',
            isProduction__c = false,
            successStatusCode__c = '201',
            practiceNameLength__c = 33,
            productionUsername__c = 'srsalesforce',
            sandboxUsername__c = 'srsalesforce',
            productionPassword__c = '>%p|8u/.K2E?Ji"Gc-]a',
            sandboxPassword__c = 'nottherealpassword',
            productionTargetUrl__c = 'https://sfapi.solutionreach.com/admin/applications',
            sandboxTargetUrl__c = 'https://salesforce.solutionreach.com/admin/applications',
            productionRequestUrl__c = 'https://sfapi.solutionreach.com/admin/subscribers/',
            sandboxRequestUrl__c = 'https://salesforce.solutionreach.com/admin/subscribers',
            requestType__c = 'POST');
        insert new AppAdminAPI_Settings__c(Name = 'SubscriberUserName',
            isProduction__c = false,
            successStatusCode__c = '201',
            productionUsername__c = 'srsalesforce',
            sandboxUsername__c = 'srsalesforce',
            productionPassword__c = '>%p|8u/.K2E?Ji"Gc-]a',
            sandboxPassword__c = 'nottherealpassword',
            productionTargetUrl__c = 'https://sfapi.solutionreach.com/admin/subscribers/{subscriberIdx}',
            sandboxTargetUrl__c = 'https://kings.communitect.com/admin/subscribers/{subscriberIdx}',
            productionRequestUrl__c = 'https://sfapi.solutionreach.com/admin/subscribers/',
            sandboxRequestUrl__c = 'https://salesforce.solutionreach.com/admin/subscribers',
            requestType__c = 'GET');
        insert new AppAdminAPI_Settings__c(Name = 'PasswordReset',
            isProduction__c = false,
            successStatusCode__c = '201',
            productionUsername__c = 'srsalesforce',
            sandboxUsername__c = 'srsalesforce',
            productionPassword__c = '>%p|8u/.K2E?Ji"Gc-]a',
            sandboxPassword__c = 'nottherealpassword',
            productionTargetUrl__c = 'https://sfapi.solutionreach.com/admin/subscribers/{subscriberIdx}/prr',
            sandboxTargetUrl__c = 'https://kings.communitect.com/admin/subscribers/{subscriberIdx}/prr',
            productionRequestUrl__c = 'https://sfapi.solutionreach.com/admin/subscribers/',
            sandboxRequestUrl__c = 'https://salesforce.solutionreach.com/admin/subscribers',
            requestType__c = 'POST');
    }

    public static void createCustomSettings(fflib_SObjectUnitOfWork uow) 
    {    
        uow.registerNew(new ContractEmailTemplate__c(Name = 'Services',
            TemplateID__c = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sales@solutionreach.com'].Id));
        uow.registerNew(new ContractEmailTemplate__c(Name = 'HealthgradesContract',
            TemplateID__c = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Healthgrades_Contract'].Id));
        uow.registerNew(new SR_Default_Values__c(Name = 'Campaign Influence Orphan Days',
            Description__c = 'Campaign Influence Orphan Days',
            Value__c = '30'));
        uow.registerNew(new SR_Default_Values__c(Name = 'Opportunity Closed Lost Days',
            Description__c = 'Opportunity Closed Lost Days',
            Value__c = '30'));
        uow.registerNew(new AppAdminAPI_Settings__c(Name = 'HealthgradesSettings',
            isProduction__c = false,
            successStatusCode__c = '201',
            practiceNameLength__c = 33,
            productionUsername__c = 'srsalesforce',
            sandboxUsername__c = 'srsalesforce',
            productionPassword__c = '>%p|8u/.K2E?Ji"Gc-]a',
            sandboxPassword__c = 'nottherealpassword',
            productionTargetUrl__c = 'https://sfapi.solutionreach.com/admin/healthgrades',
            sandboxTargetUrl__c = 'https://rlaw-d.communitect.com/admin/healthgrades',
            productionRequestUrl__c = '',
            sandboxRequestUrl__c = '',
            requestType__c = 'PUT'));
        uow.registerNew(new AppAdminAPI_Settings__c(Name = 'APISettings',
            isProduction__c = false,
            successStatusCode__c = '201',
            practiceNameLength__c = 33,
            productionUsername__c = 'srsalesforce',
            sandboxUsername__c = 'srsalesforce',
            productionPassword__c = '>%p|8u/.K2E?Ji"Gc-]a',
            sandboxPassword__c = 'nottherealpassword',
            productionTargetUrl__c = 'https://sfapi.solutionreach.com/admin/applications',
            sandboxTargetUrl__c = 'https://salesforce.solutionreach.com/admin/applications',
            productionRequestUrl__c = 'https://sfapi.solutionreach.com/admin/subscribers/',
            sandboxRequestUrl__c = 'https://salesforce.solutionreach.com/admin/subscribers',
            requestType__c = 'POST'));
        uow.registerNew(new AppAdminAPI_Settings__c(Name = 'SubscriberUserName',
            isProduction__c = false,
            successStatusCode__c = '201',
            productionUsername__c = 'srsalesforce',
            sandboxUsername__c = 'srsalesforce',
            productionPassword__c = '>%p|8u/.K2E?Ji"Gc-]a',
            sandboxPassword__c = 'nottherealpassword',
            productionTargetUrl__c = 'https://sfapi.solutionreach.com/admin/subscribers/{subscriberIdx}',
            sandboxTargetUrl__c = 'https://kings.communitect.com/admin/subscribers/{subscriberIdx}',
            productionRequestUrl__c = 'https://sfapi.solutionreach.com/admin/subscribers/',
            sandboxRequestUrl__c = 'https://salesforce.solutionreach.com/admin/subscribers',
            requestType__c = 'GET'));
        uow.registerNew(new AppAdminAPI_Settings__c(Name = 'PasswordReset',
            isProduction__c = false,
            successStatusCode__c = '201',
            productionUsername__c = 'srsalesforce',
            sandboxUsername__c = 'srsalesforce',
            productionPassword__c = '>%p|8u/.K2E?Ji"Gc-]a',
            sandboxPassword__c = 'nottherealpassword',
            productionTargetUrl__c = 'https://sfapi.solutionreach.com/admin/subscribers/{subscriberIdx}/prr',
            sandboxTargetUrl__c = 'https://kings.communitect.com/admin/subscribers/{subscriberIdx}/prr',
            productionRequestUrl__c = 'https://sfapi.solutionreach.com/admin/subscribers/',
            sandboxRequestUrl__c = 'https://salesforce.solutionreach.com/admin/subscribers',
            requestType__c = 'POST'));
    }

    public static Product2 createProduct(String frequency, String productCode, String name, String familyName, Boolean defaultRenewal) {
        Product2 newProduct = new Product2(Name = name,
                                            ProductCode = productCode,
                                            Family = familyName,
                                            Contract_Display_Name__c = familyName == null ? name : familyName,
                                            IsActive = true,
                                            Description = 'Test Description',
                                            RecurSoft__Item_Type__c = 'Non-Inventory (Sales only)',
                                            RecurSoft__Billing_Automation__c = 'Auto',
                                            RecurSoft__Billing_Frequency__c = frequency,
                                            RecurSoft__Revenue_Schedule_Type__c = 'Repeat Amount for Each Installment',
                                            RecurSoft__Product_Based_On__c = 'Each',
                                            RecurSoft__Intacct_UOM_dropdown__c = 'Each',
                                            RecurSoft__Invoicing_Date__c = 'Based on contract signed date',
                                            RecurSoft__Taxable__c = true,
                                            RecurSoft__Revenue_Recognition_Method__c = frequency == 'Monthly' ? 'Revenue Transaction' : 'Revenue Recognition Template',
                                            RecurSoft__Rev_Rec_Template_Name__c = 'Contract Term',
                                            RecurSoft__Rev_Rec_End_Based_On__c = frequency == 'Monthly' ? 'Contract Term End Date' : 'Revenue Schedule Entry',
                                            RecurSoft__Rev_Rec_Start__c = 0,
                                            RecurSoft__Rev_Installments_Period__c = frequency,
                                            Default_Renewal_Rule__c = defaultRenewal ? [SELECT Id FROM RecurSoft__Renewal_Rule__c LIMIT 1].Id : null,
                                            Default_Co_Terminate__c = true);
        return newProduct;
    }

    
    public static void insertStandardProducts() {
        
        Pricebook2 pbPremier = new Pricebook2(Name = '1.1 SR Platform',
            IsActive = true,
            Number_of_Providers_Included__c = 3);
        insert pbPremier;

        Pricebook2 pbElite = new Pricebook2(Name = '1.4 PRM Suite',
            IsActive = true,
            Number_of_Providers_Included__c = 10);
        insert pbElite;

        Pricebook2 pbAdd = new Pricebook2(Name = '8. Add Product',
            IsActive = true,
            Number_of_Providers_Included__c = 3);
        insert pbAdd;

        Product2 msfProduct = TestUtilities.createProduct('Monthly', '3000', 'SR Premier', 'SR Platform', true);
        insert msfProduct;
        TestUtilities.insertPricebookEntry(msfProduct.Id, 379, 'SR Premier', Test.getStandardPricebookId(), true);
        TestUtilities.insertPricebookEntry(msfProduct.Id, 379, 'SR Premier', pbPremier.Id, true);
        TestUtilities.insertPricebookEntry(msfProduct.Id, 379, 'SR Premier', pbElite.Id, true);
        Product2 sfProduct = TestUtilities.createProduct('One-Time', '4000', 'SR Platform Setup Fee', null, false);
        insert sfProduct;
        TestUtilities.insertPricebookEntry(sfProduct.Id, 399, 'SR Platform Setup Fee', Test.getStandardPricebookId(), true);
        TestUtilities.insertPricebookEntry(sfProduct.Id, 399, 'SR Platform Setup Fee', pbPremier.Id, true);
        TestUtilities.insertPricebookEntry(sfProduct.Id, 399, 'SR Platform Setup Fee', pbElite.Id, true);
        Product2 apProduct = TestUtilities.createProduct('Monthly', '3001', 'Additional Providers', null, true);
        insert apProduct;
        TestUtilities.insertPricebookEntry(apProduct.Id, 49, 'Additional Providers', Test.getStandardPricebookId(), false);
        TestUtilities.insertPricebookEntry(apProduct.Id, 49, 'Additional Providers', pbPremier.Id, false);
        TestUtilities.insertPricebookEntry(apProduct.Id, 49, 'Additional Providers', pbElite.Id, false);
        Product2 hgProduct = TestUtilities.createProduct('Monthly', '3005', 'Healthgrades Premium Profile', 'Healthgrades', true);
        insert hgProduct;
        TestUtilities.insertPricebookEntry(hgProduct.Id, 1, 'Healthgrades Premium Profile', Test.getStandardPricebookId(), false);
        TestUtilities.insertPricebookEntry(hgProduct.Id, 1, 'Healthgrades Premium Profile', pbPremier.Id, false);
        TestUtilities.insertPricebookEntry(hgProduct.Id, 1, 'Healthgrades Premium Profile', pbElite.Id, false);
        Product2 srScheduleProduct = TestUtilities.createProduct('Monthly', '3010', 'SR Schedule - Bundle', 'SR Schedule', true);
        insert srScheduleProduct;
        TestUtilities.insertPricebookEntry(srScheduleProduct.Id, 1, 'SR Schedule - Bundle', Test.getStandardPricebookId(), false);
        TestUtilities.insertPricebookEntry(srScheduleProduct.Id, 1, 'SR Schedule - Bundle', pbPremier.Id, false);
        TestUtilities.insertPricebookEntry(srScheduleProduct.Id, 1, 'SR Schedule - Bundle', pbElite.Id, false);
        TestUtilities.insertPricebookEntry(srScheduleProduct.Id, 1, 'SR Schedule - Bundle', pbAdd.Id, false);
        Product2 srScheduleMonthlyProduct = TestUtilities.createProduct('Monthly', '3011', 'SR Schedule - Monthly', 'SR Schedule', false);
        srScheduleMonthlyProduct.RecurSoft__Revenue_Recognition_Method__c = 'Revenue Recognition Template';
        srScheduleMonthlyProduct.Default_Contract_Term__c = 1;
        srScheduleMonthlyProduct.Default_Co_Terminate__c = false;
        insert srScheduleMonthlyProduct;
        TestUtilities.insertPricebookEntry(srScheduleMonthlyProduct.Id, 1, 'SR Schedule - Monthly', Test.getStandardPricebookId(), false);
        TestUtilities.insertPricebookEntry(srScheduleMonthlyProduct.Id, 1, 'SR Schedule - Monthly', pbPremier.Id, false);
        TestUtilities.insertPricebookEntry(srScheduleMonthlyProduct.Id, 1, 'SR Schedule - Monthly', pbElite.Id, false);
        TestUtilities.insertPricebookEntry(srScheduleMonthlyProduct.Id, 1, 'SR Schedule - Monthly', pbAdd.Id, false);
        Product2 promoProduct = TestUtilities.createProduct('One-Time', '5000', 'Promo Product', null, false);
        promoProduct.RecurSoft__Revenue_Recognition_Method__c = 'Revenue Transaction';
        promoProduct.RecurSoft__Rev_Rec_End_Based_On__c = 'Contract Term End Date';
        insert promoProduct;
        TestUtilities.insertPricebookEntry(promoProduct.Id, 0, 'Promo Product', Test.getStandardPricebookId(), false);
        TestUtilities.insertPricebookEntry(promoProduct.Id, 0, 'Promo Product', pbPremier.Id, false); 
        TestUtilities.insertPricebookEntry(promoProduct.Id, 0, 'Promo Product', pbElite.Id, false);
    }

    public static void createStandardProducts(fflib_SObjectUnitOfWork uow) 
    {    
        Pricebook2 pbPremier = new Pricebook2(Name = '1.1 SR Platform',
            IsActive = true,
            Number_of_Providers_Included__c = 3);
        uow.registerNew(pbPremier);

        Pricebook2 pbElite = new Pricebook2(Name = '1.4 PRM Suite',
            IsActive = true,
            Number_of_Providers_Included__c = 10);
        uow.registerNew(pbElite);

        Pricebook2 pbAdd = new Pricebook2(Name = '8. Add Product',
            IsActive = true,
            Number_of_Providers_Included__c = 3);
        uow.registerNew(pbAdd);

        Product2 msfProduct = TestUtilities.createProduct('Monthly', '3000', 'SR Premier', 'SR Platform', true);
        uow.registerNew(msfProduct);
        uow.registerNew(TestUtilities.createPricebookEntry(msfProduct.Id, 379, 'SR Premier', Test.getStandardPricebookId(), true));
        uow.registerNew(TestUtilities.createPricebookEntry(msfProduct.Id, 379, 'SR Premier', pbPremier.Id, true));
        uow.registerNew(TestUtilities.createPricebookEntry(msfProduct.Id, 379, 'SR Premier', pbElite.Id, true));
        Product2 sfProduct = TestUtilities.createProduct('One-Time', '4000', 'SR Platform Setup Fee', null, false);
        uow.registerNew(sfProduct);
        uow.registerNew(TestUtilities.createPricebookEntry(sfProduct.Id, 399, 'SR Platform Setup Fee', Test.getStandardPricebookId(), true));
        uow.registerNew(TestUtilities.createPricebookEntry(sfProduct.Id, 399, 'SR Platform Setup Fee', pbPremier.Id, true));
        uow.registerNew(TestUtilities.createPricebookEntry(sfProduct.Id, 399, 'SR Platform Setup Fee', pbElite.Id, true));
        Product2 apProduct = TestUtilities.createProduct('Monthly', '3001', 'Additional Providers', null, true);
        uow.registerNew(apProduct);
        uow.registerNew(TestUtilities.createPricebookEntry(apProduct.Id, 49, 'Additional Providers', Test.getStandardPricebookId(), false));
        uow.registerNew(TestUtilities.createPricebookEntry(apProduct.Id, 49, 'Additional Providers', pbPremier.Id, false));
        uow.registerNew(TestUtilities.createPricebookEntry(apProduct.Id, 49, 'Additional Providers', pbElite.Id, false));
        Product2 hgProduct = TestUtilities.createProduct('Monthly', '3005', 'Healthgrades Premium Profile', 'Healthgrades', true);
        uow.registerNew(hgProduct);
        uow.registerNew(TestUtilities.createPricebookEntry(hgProduct.Id, 1, 'Healthgrades Premium Profile', Test.getStandardPricebookId(), false));
        uow.registerNew(TestUtilities.createPricebookEntry(hgProduct.Id, 1, 'Healthgrades Premium Profile', pbPremier.Id, false));
        uow.registerNew(TestUtilities.createPricebookEntry(hgProduct.Id, 1, 'Healthgrades Premium Profile', pbElite.Id, false));
        Product2 srScheduleProduct = TestUtilities.createProduct('Monthly', '3010', 'SR Schedule - Bundle', 'SR Schedule', true);
        uow.registerNew(srScheduleProduct);
        uow.registerNew(TestUtilities.createPricebookEntry(srScheduleProduct.Id, 1, 'SR Schedule - Bundle', Test.getStandardPricebookId(), false));
        uow.registerNew(TestUtilities.createPricebookEntry(srScheduleProduct.Id, 1, 'SR Schedule - Bundle', pbPremier.Id, false));
        uow.registerNew(TestUtilities.createPricebookEntry(srScheduleProduct.Id, 1, 'SR Schedule - Bundle', pbElite.Id, false));
        uow.registerNew(TestUtilities.createPricebookEntry(srScheduleProduct.Id, 1, 'SR Schedule - Bundle', pbAdd.Id, false));
        Product2 srScheduleMonthlyProduct = TestUtilities.createProduct('Monthly', '3011', 'SR Schedule - Monthly', 'SR Schedule', false);
        srScheduleMonthlyProduct.RecurSoft__Revenue_Recognition_Method__c = 'Revenue Recognition Template';
        srScheduleMonthlyProduct.Default_Contract_Term__c = 1;
        srScheduleMonthlyProduct.Default_Co_Terminate__c = false;
        uow.registerNew(srScheduleMonthlyProduct);
        uow.registerNew(TestUtilities.createPricebookEntry(srScheduleMonthlyProduct.Id, 1, 'SR Schedule - Monthly', Test.getStandardPricebookId(), false));
        uow.registerNew(TestUtilities.createPricebookEntry(srScheduleMonthlyProduct.Id, 1, 'SR Schedule - Monthly', pbPremier.Id, false));
        uow.registerNew(TestUtilities.createPricebookEntry(srScheduleMonthlyProduct.Id, 1, 'SR Schedule - Monthly', pbElite.Id, false));
        uow.registerNew(TestUtilities.createPricebookEntry(srScheduleMonthlyProduct.Id, 1, 'SR Schedule - Monthly', pbAdd.Id, false));
        Product2 promoProduct = TestUtilities.createProduct('One-Time', '5000', 'Promo Product', null, false);
        promoProduct.RecurSoft__Revenue_Recognition_Method__c = 'Revenue Transaction';
        promoProduct.RecurSoft__Rev_Rec_End_Based_On__c = 'Contract Term End Date';
        uow.registerNew(promoProduct);
        uow.registerNew(TestUtilities.createPricebookEntry(promoProduct.Id, 0, 'Promo Product', Test.getStandardPricebookId(), false));
        uow.registerNew(TestUtilities.createPricebookEntry(promoProduct.Id, 0, 'Promo Product', pbPremier.Id, false));
        uow.registerNew(TestUtilities.createPricebookEntry(promoProduct.Id, 0, 'Promo Product', pbElite.Id, false));
    }

    public static Account insertBasicAccount(Boolean init) {
        if(init) {
            TestUtilities.init();
        }
        
        Account acc = new Account(Name = 'Test Company',
                                Practice_Management_Software__c = [SELECT Id FROM Management_System__c LIMIT 1].Id,
                                BillingCountry = 'United States',
                                Industry = 'Dental',
                                RecurSoft__Intacct_Entity__c = [SELECT Id FROM RecurSoft__Intacct_Entity__c LIMIT 1].Id);
        insert acc;
        return acc;
    }
    
    public static Opportunity insertBasicOpportunity(Id accId) {
        RecurSoft__Renewal_Rule__c rr = insertBasicRenewalRule();
        Opportunity opp = new Opportunity(Name = 'Test Opportunity',
                            Accountid = accId,
                            CloseDate = Date.today().addDays(30),
                            StageName = 'Qualified');
        insert opp;
        return opp;
    }

    public static Opportunity createOpportunity(Id accId, Id pricebookId, String recordType) 
    {
        RecurSoft__Renewal_Rule__c rr = insertBasicRenewalRule();
        Opportunity opp = new Opportunity(Name = 'Test Opportunity',
                            Accountid = accId,
                            Pricebook2Id = pricebookId,
                            RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get(recordType).getRecordTypeId(),
                            CloseDate = Date.today().addDays(5),
                            StageName = 'Qualified');
        return opp;
    }

    public static Opportunity createBasicOpportunity(Id accId) {
        RecurSoft__Renewal_Rule__c rr = insertBasicRenewalRule();
        Opportunity opp = new Opportunity(Name = 'Test Opportunity',
                            Accountid = accId,
                            CloseDate = Date.today().addDays(5),
                            StageName = 'Qualified');
        return opp;
    }

    public static Opportunity insertRecordTypeOpportunity(Id accId, String recordType) {
        RecurSoft__Renewal_Rule__c rr = insertBasicRenewalRule();
        Opportunity opp = new Opportunity(Name = 'Test Opportunity',
                            Accountid = accId,
                            CloseDate = Date.today().addDays(30),
                            StageName = 'Qualified',
                            Pricebook2Id = Test.getStandardPricebookId(),
                            RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get(recordType).getRecordTypeId());
        insert opp;
        return opp;
    }

    public static OpportunityLineItem createOpportunityLineItem(Opportunity o, PriceBookEntry pbEntry, Decimal q) {

        OpportunityLineItem results = new OpportunityLineItem(OpportunityId = o.Id,
                                                                PricebookEntryId = pbEntry.Id,
                                                                Quantity = q,
                                                                UnitPrice = pbEntry.UnitPrice);

        return results;
    }

    public static void prepForOpportunityClose(Account a, Contact c, Opportunity o) {
        
        o.RecurSoft__Billing_Contact__c = c.Id;
        o.RecurSoft__Shipping_Contact__c = c.Id;
        o.RecurSoft__Bill_to_Account__c = a.Id;
        o.RecurSoft__Initial_Contract_Term__c = 24;
        o.RecurSoft__Contract_Term_Start_Date__c = Date.today();
        o.RecurSoft__Intacct_Entity__c = a.RecurSoft__Intacct_Entity__c;
        a.RecurSoft__Synced_With_Intacct__c = true;
        a.RecurSoft__Synced_With_Intacct_Date__c = Date.today();
        a.RecurSoft__IntacctID__c = '12345';
        c.RecurSoft__Synced_With_Intacct__c = true;
        c.RecurSoft__Synced_With_Intacct_Date__c = Date.today();
        c.RecurSoft__Intacct_Contact_ID__c = '12345';
        update o;
        update a;
        update c;
    }

    public static Provider__c insertProvider(Id accId, Id contactId, String npiUnique) {
        Provider__c p = new Provider__c(Bill_to_Account__c = accId,
            Related_Contact__c = contactId,
            NPI__c = '111111111' + npiUnique,
            Healthgrades_ID__c = 'https://www.healthgrades.com/dentist/dr-first-last-abc12' + npiUnique);

        insert p;
        return p;
    }

    public static Contact insertBasicContact(Id accId) {
        Contact c = new Contact(FirstName = 'First',
            LastName = 'Last',
            Email = 'email@solutionreach.com',
            Phone = '8013317150',
            AccountId = accId);
        
        insert c;
        return c;
    }

    public static Lead insertBasicLead() {
        Lead l = new Lead(Company = 'Test Company',
                        LastName = 'Last Name',
                        LeadSource = 'Advertising',
                        Status = 'New');
        insert l;
        return l;
    }

    public static Lead insertLeadForConversion(Boolean init) {
        if(init) {
            TestUtilities.init();
        }

        Lead l = new Lead(Company = 'Test Company',
                        FirstName = 'First Name',
                        LastName = 'Last Name',
                        Phone = '8013317150',
                        Email = 'randytest@solutionreach.com',
                        Lead_Type__c = 'Practice',
                        Industry = 'Dental',
                        Sub_Industry__c = 'General Dentistry',
                        LeadSource = 'Advertising',
                        Status = 'New',
                        Practice_Software__c = [SELECT Id FROM Management_System__c LIMIT 1].Id,
                        State = 'Utah',
                        Country = 'United States');
        insert l;
        return l;
    }

    public static Map<String, Id> convertLead(Lead l) {
        Map<String, Id> convertedObjects = new Map<String, Id>();

        FlowControl.isLeadConvert = true;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        System.assert(lcr.isSuccess());
        
        convertedObjects.put('AccountId', lcr.getAccountId());
        convertedObjects.put('ContactId', lcr.getContactId());
        convertedObjects.put('OpportunityId', lcr.getOpportunityId());
        convertedObjects.put('LeadId', lcr.getLeadId());
        FlowControl.isLeadConvert = false;

        return convertedObjects;
    }

    public static Profile createProfile(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        return p;
    }

    public static UserRole createUserRole(String roleName) {
        UserRole r = [SELECT Id FROM UserRole WHERE Name = :roleName LIMIT 1];
        return r;
    }

    public static User createUser(String profileName, String roleName) {
        Profile p = createProfile(profileName);
        UserRole r = createUserRole(roleName);
        User u = new User(Username = profileName.deleteWhitespace() + '@solutionreach.com',
                        Alias = profileName.deleteWhitespace().substring(0,7),
                        LastName = 'TestUserLast',
                        Email = profileName.deleteWhitespace() + '@solutionreach.com',
                        EmailEncodingKey = 'UTF-8',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US',
                        TimeZoneSidKey = 'America/Denver',
                        ProfileId = p.Id,
                        UserRoleId = r.Id);
        return u;
    }

    public static Task createScheduledTask(Id whoid, Id whatid) {
        Task t = new Task (Subject = 'Test',
                        Status = 'Scheduled',
                        Activity_Type__c = 'Phone Demo',
                        Activity_Results__c = 'Future Event',
                        ActivityDate = Date.today().addDays(7),
                        Whoid = whoid,
                        Whatid = whatid);
        return t;
    }
    
    public static Task createCompletedTask(Id whoid, Id whatid) {
        Task t = new Task (Subject = 'Test',
                        Status = 'Completed',
                        Activity_Type__c = 'Phone Demo',
                        Activity_Results__c = 'Spoke with-',
                        Talked_to__c = 'John',
                        ActivityDate = Date.today(),
                        Whoid = whoid,
                        Whatid = whatid);
    return t;
    }

    public static Campaign insertBasicPricingCampaign(Decimal msfPrice, Decimal sfPrice, Boolean hasPromoProduct, Boolean hasFreeMonths) {
        Campaign c = new Campaign(Name = 'Test Pricing Campaign',
                                    IsActive = true,
                                    StartDate = Date.today().toStartOfMonth(),
                                    EndDate = Date.today().addDays(90),
                                    Type = 'Pricing',
                                    Status = 'In Progress',
                                    Free_Months__c = hasFreeMonths ? '2' : null,
                                    Free_Months_Setting__c = hasFreeMonths ? 'Extend Contract - At the Beginning' : null,
                                    Product_1_Name1__c = [select Id from Product2 where ProductCode = '4000'].Id,
                                    Product_1_Sales_Price__c = sfPrice,
                                    Product_2_Name_2__c = [select Id from Product2 where ProductCode = '3000'].Id,
                                    Product_2_Sale_Price__c = msfPrice,
                                    Promo_Product1__c = hasPromoProduct ? [select Id from Product2 where Name = 'Promo Product'].Id : null,
                                    Trial_Period__c = '90');
        insert c;
        return c;
    }

    public static Campaign insertBasicMarketingCampaign(String type, Boolean isList, Boolean isAdrNonSet, String name) {
        Campaign c = new Campaign(Name = name,
                                    IsActive = true,
                                    StartDate = Date.today().toStartOfMonth(),
                                    EndDate = Date.today().addMonths(1).toStartOfMonth().addDays(-1),
                                    Type = type,
                                    Status = 'In Progress',
                                    List__c = isList,
                                    Default_CI_Type__c = 'SR',
                                    ADR_Set__c = isAdrNonSet);
        insert c;
        return c;
    }

    public static Case insertBasicCase(Account a, String recordType) {
        a.Implementation_Rep__c = [SELECT Id FROM User LIMIT 1].Id;
        update a;
        Case c = new Case(AccountId = a.Id,
            RecordTypeId = SRUtilities.getRecordTypeMap('Case').get(recordType).getRecordTypeId());

        insert c;
        return c;
    }

    public static Campaign_Influence__c insertBasicCampaignInfluence(Id campaignId, Id contactId, Id leadId, Id oppId, Id acctId, Id userId, Integer dayOffset) {

        Campaign_Influence__c result = new Campaign_Influence__c(Campaign__c = campaignId,
            Contact__c = contactId,
            Lead__c = leadId,
            Opportunity__c = oppId,
            Account__c = acctId,
            Associated_Rep__c = userId);

        result.Campaign_Add_Date__c = dayOffset == null ? null : Datetime.now().addDays(dayOffset);

        insert result;
        return result;
    }

    public static Asset insertAsset(Account a, RecurSoft__Product_Subscription__c ps){

        Asset asset = new Asset(AccountId = a.Id, Current_Product_Subscription__c = ps.Id, Name = 'SR Platform Asset');

        insert asset;
        return asset;
    }

    public static Cancel_Request__c insertCancelRequest(Opportunity o, Asset asset, String recordType, String stage)
    {
        Cancel_Request__c cr = new Cancel_Request__c(Opportunity__c = o.Id, 
                Asset__c = asset.Id, 
                RecordTypeId = SRUtilities.getRecordTypeMap('Cancel_Request__c').get(recordType).getRecordTypeId(),
                Cancel_Request_Type__c = 'Annual',
                Cancel_Request_Date__c = Date.today().addDays(-5),
                Description__c = 'Was not interested',
                Most_Recent_Contract_Date__c = Date.today().addDays(-10),
                Original_Setup_Fee__c = 0.00,
                Current_MSF__c = 399.00,
                E_T_Reason__c = 'Technical Issues',
                Cancel_Meta_Theme__c = 'Sales',
                Cancel_Sub_Category__c = 'Expectations',
                Cancellation_Reasons__c = 'Contract/Billing',
                Stage__c = stage,
                Cancellation_Details__c = 'Test Cancel',
                Projected_Contract_Expiration_Renewal__c = Date.today().addDays(355)                                                    
                );
        if (stage == 'Cancelled'){
            cr.Cancel_Month__c = Date.today().toStartofMonth();
        }
        insert cr;
        return cr;
    }

    public static Opportunity insertRetentionOpportunity(Account accId){
        Opportunity opp = new Opportunity(Name = 'Test Save Opportunity',
                    Accountid = accId.Id,
                    CloseDate = Date.today().addDays(5),
                    StageName = 'Qualified',
                    RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get('Retention').getRecordTypeId());

        insert opp;
        return opp;
    }
}