global class SandboxRefresh implements SandboxPostCopy 
{
	/*
	SandboxRefresh.insertBasicManagementSystem();
	SandboxRefresh.insertBasicIntacctEntity();
	SandboxRefresh.defaultRenewal = SandboxRefresh.insertBasicRenewalRule();
	SandboxRefresh.updateProductDefaultRenewal();
	SandboxRefresh.updateIsProduction();
	*/

/*Healthgrades_Contract_URL custom setting 
sso settings
Intacct Integration custom setting Company ID = Solutionreach-copy
*/

	public static RecurSoft__Renewal_Rule__c defaultRenewal;

	global void runApexClass(SandboxContext context) 
    {
    	insertBasicManagementSystem();
    	insertBasicIntacctEntity();
    	defaultRenewal = insertBasicRenewalRule();
    	updateProductDefaultRenewal();
    	updateIsProduction();
        createQAProfiles(context.sandboxName());
        insertQAAccounts();
        insertAreaCodes();
    }

    public static void insertBasicManagementSystem() 
    {
        Management_System__c pm = new Management_System__c(Name = 'Dentrix',
        	DB_Type__c = 'Database',
        	Production_ID__c = 'a00i000000Mq9oB',
        	SYNC_Availability__c = 'SYNC Complete');
        insert pm;
    }

    public static void insertBasicIntacctEntity() 
    {
        RecurSoft__Intacct_Entity__c entity = new RecurSoft__Intacct_Entity__c(Name = 'SR001');
        insert entity;
    }

    public static RecurSoft__Renewal_Rule__c insertBasicRenewalRule() 
    {
        RecurSoft__Renewal_Rule__c rr = new RecurSoft__Renewal_Rule__c(RecurSoft__Renewal_Rule_Firendly_Name__c = 'Default Recurring Rule',
        	RecurSoft__End_of_Term_Action__c = 'Repeating fixed term',
        	RecurSoft__Number_of_Months__c = 12,
        	RecurSoft__Renewal_Pricing_Option__c = 'Opportunity price');
        insert rr;
        return rr;
    }

    public static void updateProductDefaultRenewal() 
    {
    	Product2[] productList = [SELECT Id, Default_Renewal_Rule__c FROM Product2 WHERE RecurSoft__Billing_Frequency__c = 'Monthly' AND Default_Contract_Term__c = null];

    	for(Product2 p : productList) 
        {
    		p.Default_Renewal_Rule__c = defaultRenewal.Id;
    	}

    	update productList;
    }

    public static void updateIsProduction() 
    {
    	AppAdminAPI_Settings__c apiSettings = AppAdminAPI_Settings__c.getValues('APISettings');
    	AppAdminAPI_Settings__c assetSettings = AppAdminAPI_Settings__c.getValues('AssetSettings');
    	AppAdminAPI_Settings__c hgSettings = AppAdminAPI_Settings__c.getValues('HealthgradesSettings');
    	AppAdminAPI_Settings__c pwrdSettings = AppAdminAPI_Settings__c.getValues('PasswordReset');
    	AppAdminAPI_Settings__c userNameSettings = AppAdminAPI_Settings__c.getValues('SubscriberUserName');
        SR_Default_Values__c currentEnvironment = SR_Default_Values__c.getValues('Current Environment');
        SR_Default_Values__c sandboxContractURL = SR_Default_Values__c.getValues('Sandbox Contract URL');

    	apiSettings.isProduction__c = false;
    	update apiSettings;

    	assetSettings.isProduction__c = false;
    	update assetSettings;

    	hgSettings.isProduction__c = false;
    	update hgSettings;

    	pwrdSettings.isProduction__c = false;
    	update pwrdSettings;

    	userNameSettings.isProduction__c = false;
    	update userNameSettings;

        currentEnvironment.Value__c = 'Sandbox';
        update currentEnvironment;

        sandboxContractURL.Value__c = [SELECT Domain FROM Domain].Domain;
        update sandboxContractURL;


    }

    //TODO Lookup Rollup Summaries
    
    public static void insertQAAccounts()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Map<String, PricebookEntry> productToPricebookEntry = new Map<String, PricebookEntry>();

        Pricebook2[] pBook = PricebooksSelector.newInstance().selectByNameWithPricebookEntries(new Set<String>{'Standard Price Book'});
        PricebookEntry[] pBookEntries = pBook[0].PricebookEntries;
        Id pm = [SELECT Id FROM Management_System__c LIMIT 1].Id;
        Id intacctEntity = [SELECT Id FROM RecurSoft__Intacct_Entity__c LIMIT 1].Id;

        for(PricebookEntry pbEntry : pBookEntries)
        {
            productToPricebookEntry.put(pbEntry.ProductCode, pbEntry);
        }

        Account a1 = new Account(Name = 'Beachfront Medical',
            Industry = 'Dental',
            RecurSoft__Billing_Email__c = 'rgamett+ssandmanMain@solutionreach.com',
            BillingStreet = '1500 N 2350 E',
            BillingCity = 'Hot Springs',
            BillingState = 'South Dakota',
            BillingPostalCode = '57747',
            Subscriber_Id__c = '80',
            Admin_UserName__c = 'ssandman',
            Practice_Management_Software__c = pm,
            RecurSoft__Intacct_Entity__c = intacctEntity,
            RecurSoft__Synced_with_Intacct__c = true,
            RecurSoft__Synced_with_Intacct_Date__c = Date.today());

        uow.registerNew(a1);

        Contact c1 = new Contact(FirstName = 'Ryan',
            LastName = 'Gamett',
            Email = 'rgamett+ssandmanMain@solutionreach.com',
            Phone = '8013317100',
            MailingStreet = '1500 N 2350 E',
            MailingCity = 'Hot Springs',
            MailingState = 'South Dakota',
            MailingPostalCode = '57747',
            RecurSoft__Synced_with_Intacct__c = true,
            RecurSoft__Synced_with_Intacct_Date__c = Date.today(),
            RecurSoft__Intacct_Contact_Id__c = 'FakeIDc1');

        uow.registerNew(c1, Contact.AccountId, a1);

        Opportunity o1 = new Opportunity(Name = 'QA Setup',
            StageName = 'Qualified',
            Pricebook2Id = pBook[0].Id,
            RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get('New Practice Business').getRecordTypeId(),
            RecurSoft__Trial__c = 'None',
            CloseDate = Date.today(),
            RecurSoft__Initial_Contract_Term__c = 24,
            RecurSoft__Intacct_Entity__c = intacctEntity,
            RecurSoft__Contract_Signed_Date__c = Date.today());
        uow.registerNew(o1, Opportunity.AccountId, a1);
        uow.registerRelationship(o1, Opportunity.RecurSoft__Bill_to_Account__c, a1);
        uow.registerRelationship(o1, Opportunity.RecurSoft__Billing_Contact__c, c1);
        uow.registerRelationship(o1, Opportunity.RecurSoft__Shipping_Contact__c, c1);

        OpportunityLineItem oppLi1 = new OpportunityLineItem(Quantity = 1, 
            UnitPrice = productToPricebookEntry.get('3000').UnitPrice,
            PricebookEntryId = productToPricebookEntry.get('3000').Id);
        uow.registerNew(oppLi1, OpportunityLineItem.OpportunityId, o1);

        Account a2 = new Account(Name = 'Cache Valley Dental',
            Industry = 'Dental',
            RecurSoft__Billing_Email__c = 'emaughan@solutionreach.com',
            BillingStreet = '3365 N 2400 W',
            BillingCity = 'Amalga',
            BillingState = 'Utah',
            BillingPostalCode = '84335',
            Subscriber_Id__c = '7',
            Admin_UserName__c = 'cvalleydental',
            Practice_Management_Software__c = pm,
            RecurSoft__Intacct_Entity__c = intacctEntity,
            RecurSoft__Synced_with_Intacct__c = true,
            RecurSoft__Synced_with_Intacct_Date__c = Date.today());

        uow.registerNew(a2);

        Contact c2 = new Contact(FirstName = 'Ethan',
            LastName = 'Maughan',
            Email = 'emaughan@solutionreach.com',
            Phone = '8013317100',
            MailingStreet = '3365 N 2400 W',
            MailingCity = 'Amalga',
            MailingState = 'Utah',
            MailingPostalCode = '84335',
            RecurSoft__Synced_with_Intacct__c = true,
            RecurSoft__Synced_with_Intacct_Date__c = Date.today(),
            RecurSoft__Intacct_Contact_Id__c = 'FakeIDc2');

        uow.registerNew(c2, Contact.AccountId, a2);

        Opportunity o2 = new Opportunity(Name = 'QA Setup',
            StageName = 'Qualified',
            Pricebook2Id = pBook[0].Id,
            RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get('New Practice Business').getRecordTypeId(),
            RecurSoft__Trial__c = 'None',
            CloseDate = Date.today(),
            RecurSoft__Initial_Contract_Term__c = 24,
            RecurSoft__Intacct_Entity__c = intacctEntity,
            RecurSoft__Contract_Signed_Date__c = Date.today());
        uow.registerNew(o2, Opportunity.AccountId, a2);
        uow.registerRelationship(o2, Opportunity.RecurSoft__Bill_to_Account__c, a2);
        uow.registerRelationship(o2, Opportunity.RecurSoft__Billing_Contact__c, c2);
        uow.registerRelationship(o2, Opportunity.RecurSoft__Shipping_Contact__c, c2);

        OpportunityLineItem oppLi2 = new OpportunityLineItem(Quantity = 1, 
            UnitPrice = productToPricebookEntry.get('3000').UnitPrice,
            PricebookEntryId = productToPricebookEntry.get('3000').Id);
        uow.registerNew(oppLi2, OpportunityLineItem.OpportunityId, o2);

        Account a3 = new Account(Name = 'Balboa Veterinary',
            Industry = 'Dental',
            RecurSoft__Billing_Email__c = 'ssorensen@solutionreach.com',
            BillingStreet = '9150 S 170 E',
            BillingCity = 'Sandy',
            BillingState = 'Utah',
            BillingPostalCode = '84070',
            Subscriber_Id__c = '17',
            Admin_UserName__c = 'bvet',
            Practice_Management_Software__c = pm,
            RecurSoft__Intacct_Entity__c = intacctEntity,
            RecurSoft__Synced_with_Intacct__c = true,
            RecurSoft__Synced_with_Intacct_Date__c = Date.today());

        uow.registerNew(a3);

        Contact c3 = new Contact(FirstName = 'Sam',
            LastName = 'Sorensen',
            Email = 'ssorensen@solutionreach.com',
            Phone = '8013317100',
            MailingStreet = '9150 S 170 E',
            MailingCity = 'Sandy',
            MailingState = 'Utah',
            MailingPostalCode = '84070',
            RecurSoft__Synced_with_Intacct__c = true,
            RecurSoft__Synced_with_Intacct_Date__c = Date.today(),
            RecurSoft__Intacct_Contact_Id__c = 'FakeIDc3');

        uow.registerNew(c3, Contact.AccountId, a3);

        Opportunity o3 = new Opportunity(Name = 'QA Setup',
            StageName = 'Qualified',
            Pricebook2Id = pBook[0].Id,
            RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get('New Practice Business').getRecordTypeId(),
            RecurSoft__Trial__c = 'None',
            CloseDate = Date.today(),
            RecurSoft__Initial_Contract_Term__c = 24,
            RecurSoft__Intacct_Entity__c = intacctEntity,
            RecurSoft__Contract_Signed_Date__c = Date.today());
        uow.registerNew(o3, Opportunity.AccountId, a3);
        uow.registerRelationship(o3, Opportunity.RecurSoft__Bill_to_Account__c, a3);
        uow.registerRelationship(o3, Opportunity.RecurSoft__Billing_Contact__c, c3);
        uow.registerRelationship(o3, Opportunity.RecurSoft__Shipping_Contact__c, c3);

        OpportunityLineItem oppLi3 = new OpportunityLineItem(Quantity = 1, 
            UnitPrice = productToPricebookEntry.get('3000').UnitPrice,
            PricebookEntryId = productToPricebookEntry.get('3000').Id);
        uow.registerNew(oppLi3, OpportunityLineItem.OpportunityId, o3);

        Account a4 = new Account(Name = 'Lepidstadt University',
            Industry = 'Dental',
            RecurSoft__Billing_Email__c = 'jonathan+lorrimor@solutionreach.com',
            BillingStreet = '2912 Executive Pkwy #300',
            BillingCity = 'Lehi',
            BillingState = 'Utah',
            BillingPostalCode = '84043',
            Subscriber_Id__c = '64',
            Admin_UserName__c = 'plorrimor',
            Practice_Management_Software__c = pm,
            RecurSoft__Intacct_Entity__c = intacctEntity,
            RecurSoft__Synced_with_Intacct__c = true,
            RecurSoft__Synced_with_Intacct_Date__c = Date.today());

        uow.registerNew(a4);

        Contact c4 = new Contact(FirstName = 'Jonathan',
            LastName = 'Doty',
            Email = 'jonathan+lorrimor@solutionreach.com',
            Phone = '8013317100',
            MailingStreet = '2912 Executive Pkwy #300',
            MailingCity = 'Lehi',
            MailingState = 'Utah',
            MailingPostalCode = '84043',
            RecurSoft__Synced_with_Intacct__c = true,
            RecurSoft__Synced_with_Intacct_Date__c = Date.today(),
            RecurSoft__Intacct_Contact_Id__c = 'FakeIDc4');

        uow.registerNew(c4, Contact.AccountId, a4);

        Opportunity o4 = new Opportunity(Name = 'QA Setup',
            StageName = 'Qualified',
            Pricebook2Id = pBook[0].Id,
            RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get('New Practice Business').getRecordTypeId(),
            RecurSoft__Trial__c = 'None',
            CloseDate = Date.today(),
            RecurSoft__Initial_Contract_Term__c = 24,
            RecurSoft__Intacct_Entity__c = intacctEntity,
            RecurSoft__Contract_Signed_Date__c = Date.today());
        uow.registerNew(o4, Opportunity.AccountId, a4);
        uow.registerRelationship(o4, Opportunity.RecurSoft__Bill_to_Account__c, a4);
        uow.registerRelationship(o4, Opportunity.RecurSoft__Billing_Contact__c, c4);
        uow.registerRelationship(o4, Opportunity.RecurSoft__Shipping_Contact__c, c4);

        OpportunityLineItem oppLi4 = new OpportunityLineItem(Quantity = 1, 
            UnitPrice = productToPricebookEntry.get('3000').UnitPrice,
            PricebookEntryId = productToPricebookEntry.get('3000').Id);
        uow.registerNew(oppLi4, OpportunityLineItem.OpportunityId, o4);

        Account a5 = new Account(Name = 'Raccoon City Dental',
            Industry = 'Dental',
            RecurSoft__Billing_Email__c = 'charles+rcdlagunan@solutionreach.com',
            BillingStreet = '1234 Raccoon Blvd',
            BillingCity = 'Raccoon',
            BillingState = 'Kentucky',
            BillingPostalCode = '41557',
            Subscriber_Id__c = '31',
            Admin_UserName__c = 'rcdental',
            Practice_Management_Software__c = pm,
            RecurSoft__Intacct_Entity__c = intacctEntity,
            RecurSoft__Synced_with_Intacct__c = true,
            RecurSoft__Synced_with_Intacct_Date__c = Date.today());

        uow.registerNew(a5);

        Contact c5 = new Contact(FirstName = 'Charles',
            LastName = 'Thornton',
            Email = 'charles+rcdlagunan@solutionreach.com',
            Phone = '8013317100',
            MailingStreet = '1234 Raccoon Blvd',
            MailingCity = 'Raccoon',
            MailingState = 'Kentucky',
            MailingPostalCode = '41557',
            RecurSoft__Synced_with_Intacct__c = true,
            RecurSoft__Synced_with_Intacct_Date__c = Date.today(),
            RecurSoft__Intacct_Contact_Id__c = 'FakeIDc5');

        uow.registerNew(c5, Contact.AccountId, a5);

        Opportunity o5 = new Opportunity(Name = 'QA Setup',
            StageName = 'Qualified',
            Pricebook2Id = pBook[0].Id,
            RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get('New Practice Business').getRecordTypeId(),
            RecurSoft__Trial__c = 'None',
            CloseDate = Date.today(),
            RecurSoft__Initial_Contract_Term__c = 24,
            RecurSoft__Intacct_Entity__c = intacctEntity,
            RecurSoft__Contract_Signed_Date__c = Date.today());
        uow.registerNew(o5, Opportunity.AccountId, a5);
        uow.registerRelationship(o5, Opportunity.RecurSoft__Bill_to_Account__c, a5);
        uow.registerRelationship(o5, Opportunity.RecurSoft__Billing_Contact__c, c5);
        uow.registerRelationship(o5, Opportunity.RecurSoft__Shipping_Contact__c, c5);

        OpportunityLineItem oppLi5 = new OpportunityLineItem(Quantity = 1, 
            UnitPrice = productToPricebookEntry.get('3000').UnitPrice,
            PricebookEntryId = productToPricebookEntry.get('3000').Id);
        uow.registerNew(oppLi5, OpportunityLineItem.OpportunityId, o5);

        uow.commitWork();

        SandboxRefresh.closeQAOpps();
        SandboxRefresh.updateOfficeContacts();
    }

    @future
    public static void closeQAOpps()
    {
        Opportunity[] newOpps = [SELECT Id, StageName FROM Opportunity WHERE Name = 'QA Setup'];
        for(Opportunity o : newOpps)
        {
            o.StageName = 'Closed Won';
        }

        update newOpps;
    }

    @future
    public static void updateOfficeContacts()
    {
        Account[] newAccts = [SELECT Id, Office_Contact__c, (SELECT Id FROM Contacts LIMIT 1) FROM Account WHERE Name IN ('Beachfront Medical','Cache Valley Dental','Balboa Veterinary','Lepidstadt University','Raccoon City Dental')];
        for(Account a : newAccts)
        {
            a.Office_Contact__c = a.Contacts[0].Id;
        }

        update newAccts;
    }

    public static void createQAProfiles(String sandboxName)
    {
        Id sysProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        Id sysRoleId = [SELECT Id FROM UserRole WHERE Name = 'System Administrator' LIMIT 1].Id;

        User gamett = new User(FirstName = 'Ryan',
            LastName = 'Gamett',
            Alias = 'rgame',
            Email = 'rgamett+ssandmanMain@solutionreach.com',
            Username = 'rgamett+ssandmanMain@solutionreach.com.' + sandboxName,
            CommunityNickname = 'rgamett+ssandmanMain',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Denver',
            ProfileId = sysProfileId,
            UserRoleId = sysRoleId);
        insert gamett;

        User sorensen = new User(FirstName = 'Sam',
            LastName = 'Sorensen',
            Alias = 'ssore',
            Email = 'ssorensen@solutionreach.com',
            Username = 'ssorensen@solutionreach.com.' + sandboxName,
            CommunityNickname = 'ssorensen',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Denver',
            ProfileId = sysProfileId,
            UserRoleId = sysRoleId);
        insert sorensen;

        User doty = new User(FirstName = 'Jonathan',
            LastName = 'Doty',
            Alias = 'jdoty',
            Email = 'jonathan+lorrimor@solutionreach.com',
            Username = 'jonathan+lorrimor@solutionreach.com.' + sandboxName,
            CommunityNickname = 'jonathan+lorrimor',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Denver',
            ProfileId = sysProfileId,
            UserRoleId = sysRoleId);
        insert doty;

        User thornton = new User(FirstName = 'Charles',
            LastName = 'Thornton',
            Alias = 'cthor',
            Email = 'charles+rcdlagunan@solutionreach.com',
            Username = 'charles+rcdlagunan@solutionreach.com.' + sandboxName,
            CommunityNickname = 'charles+rcdlagunan',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Denver',
            ProfileId = sysProfileId,
            UserRoleId = sysRoleId);
        insert thornton;
    }

    public static void insertAreaCodes()
    {
        Area_Code__c[] newList = new List<Area_Code__c>();

        newList.add(new Area_Code__c(Name = '201', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '202', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '203', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '204', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '205', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '206', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '207', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '208', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '209', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '210', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '212', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '213', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '214', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '215', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '216', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '217', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '218', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '219', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '224', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '225', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '228', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '229', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '231', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '234', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '239', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '240', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '248', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '250', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '251', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '252', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '253', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '254', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '256', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '260', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '262', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '267', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '269', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '270', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '276', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '281', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '289', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '301', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '302', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '303', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '304', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '305', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '306', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '307', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '308', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '309', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '310', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '312', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '313', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '314', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '315', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '316', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '317', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '318', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '319', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '320', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '321', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '323', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '325', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '330', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '334', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '336', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '337', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '339', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '347', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '351', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '352', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '360', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '361', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '386', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '401', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '402', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '403', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '404', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '405', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '406', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '407', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '408', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '409', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '410', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '412', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '413', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '414', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '415', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '416', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '417', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '418', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '419', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '423', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '424', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '425', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '430', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '432', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '434', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '435', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '440', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '443', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '450', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '469', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '478', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '479', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '480', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '484', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '501', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '502', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '503', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '504', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '505', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '506', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '507', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '508', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '509', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '510', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '512', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '513', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '514', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '515', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '516', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '517', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '518', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '519', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '520', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '530', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '540', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '541', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '551', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '559', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '561', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '562', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '563', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '567', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '570', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '571', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '573', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '574', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '580', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '585', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '586', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '601', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '602', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '603', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '604', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '605', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '606', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '607', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '608', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '609', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '610', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '612', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '613', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '614', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '615', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '616', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '617', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '618', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '619', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '620', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '623', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '626', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '630', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '631', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '636', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '641', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '646', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '647', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '650', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '651', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '660', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '661', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '662', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '678', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '682', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '689', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '701', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '702', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '703', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '704', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '705', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '706', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '707', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '708', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '709', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '712', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '713', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '714', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '715', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '716', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '717', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '718', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '719', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '720', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '724', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '727', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '730', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '731', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '732', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '734', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '740', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '754', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '757', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '760', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '762', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '763', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '765', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '769', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '770', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '772', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '773', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '774', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '775', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '778', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '779', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '780', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '781', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '785', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '786', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '801', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '802', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '803', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '804', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '805', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '806', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '807', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '808', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '810', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '812', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '813', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '814', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '815', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '816', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '817', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '818', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '819', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '828', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '830', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '831', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '832', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '843', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '845', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '847', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '848', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '850', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '856', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '857', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '858', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '859', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '860', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '862', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '863', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '864', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '865', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '867', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '870', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '878', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '901', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '902', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '903', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '904', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '905', Country__c = 'CA'));
        newList.add(new Area_Code__c(Name = '906', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '907', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '908', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '909', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '910', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '912', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '913', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '914', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '915', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '916', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '917', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '918', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '919', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '920', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '925', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '928', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '931', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '936', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '937', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '940', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '941', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '947', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '949', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '951', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '952', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '954', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '956', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '970', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '971', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '972', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '973', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '978', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '979', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '980', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '985', Country__c = 'US'));
        newList.add(new Area_Code__c(Name = '989', Country__c = 'US'));

        insert newList;
    }
    
	
}