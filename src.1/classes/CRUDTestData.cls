/*********************CRUDTestData***************************************
* Sid Maganti   Feb 2014        Initial 
*
* Global class to create methods for CRUD records used by all test classes
*/
global class CRUDTestData 
{
     /**
     * Create a new account record (optional insert)
     * @params doInsert
     * @return testAccount
    */
    public static Account createAccount(Boolean doInsert)
    {
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        testAccount.Description = 'Test';
        testAccount.Website = 'Test';
        testAccount.Industry = 'Medical';
        testAccount.Phone='222232222';
        testAccount.BillingStreet='122 st';
        testAccount.BillingCity='Irvine';
        testAccount.Description='test';
        testAccount.BillingCountry='United States';
        testAccount.BillingState='California';
        testAccount.Time_Zone__c='PST';
        testAccount.BillingPostalCode='92612';
        testAccount.RecurSoft__Channel__c = 'Direct';
        testAccount.RecurSoft__Payment_Term__c = 'Due Upon Receipt';
        if(doInsert)
        {
            insert testAccount;
        }
        return testAccount; 
    }
    
    /**
     * Create a new opportunity record (optional insert)
     * @params doInsert, partnerId, contactId, accountId
     * @return testOpportunity
    */
    public static Opportunity createOpportunity(ID accountId, ID partnerId, ID contactId, Boolean doInsert)
    {
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.AccountId = accountId;
        testOpportunity.Name = 'Test';
        testOpportunity.StageName = 'Demo Complete';
        testOpportunity.CloseDate = System.today()+4;
        testOpportunity.RecurSoft__Initial_Contract_Term__c = 12;
        testOpportunity.RecurSoft__Expected_Contract_Start_Date__c=  System.today()+4;
        testOpportunity.RecurSoft__Trial__c= '30' ;
        if(doInsert)
        {
            insert testOpportunity;
        }
        return testOpportunity; 
    } 
    
    /**
     * Create a new OpportunityLineItem record (optional insert)
     * @params doInsert, opportunityId, pricebookEntryId
     * @return testOpportunityLineItem
    */
    public static OpportunityLineItem createOpportunityLineItem(ID opportunityId, ID pricebookEntryId, Boolean doInsert)
    {
        OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem();
        testOpportunityLineItem.OpportunityId = opportunityId;
        testOpportunityLineItem.PricebookEntryId = pricebookEntryId;
        testOpportunityLineItem.UnitPrice = 100;
        testOpportunityLineItem.Quantity = 1;
       // testOpportunityLineItem.Run_Date__c = Date.today();
        //testOpportunityLineItem.ServiceEndDate__c = Date.today();
        
        if(doInsert)
        {
            insert testOpportunityLineItem;
        }
        return testOpportunityLineItem; 
    } 

    /**
     * Create a Contact record
     * @return cont
    */
    public static Contact createContact(Account acc, Boolean doInsert)
    {
        Contact cont = new Contact(
            AccountId = acc.Id,
            Email = 'testcontact@test.com',
            Phone = acc.phone,
            //Fax = acc.fax,
            MailingStreet = acc.BillingStreet,
            MailingCity = acc.BillingCity,
            MailingPostalCode = acc.BillingPostalCode,
            MailingState = acc.BillingState,
            MailingCountry = acc.BillingCountry,
            LastName = 'testa',
            FirstName = 'contacta',
            Fax='5655665668'
            
        );
        if(doInsert)
        {
           insert cont;
        }
        return cont;
    }
    
    /**
     * Create a Product2 record (optional insert)
     * @params doInsert
     * @return testProduct
    */
    public static Product2 createProduct2(Boolean doInsert)
    {
        Product2 testProduct = new Product2();
        testProduct.Name = 'TEST_VALUE';
        testProduct.IsActive = true;
        testProduct.RecurSoft__Billing_Frequency__c='One-Time';
        testProduct.ProductCode='ONE';
        testProduct.RecurSoft__Rev_Installments_Period__c='Test';
       // testProduct.Duration_Months__c=12;
        
        if(doInsert)
        {
           insert testProduct;
        }
        return testProduct;
    }
    
    /**
     * Create a PriceBookEntry record
     * params pricebookId, productId, doInsert
     * @return testPricebookeEntry
    */
    public static PricebookEntry createPricebookEntry(String pricebookId, String productId, Boolean doInsert)
    {
        PricebookEntry testPricebookeEntry = new PRicebookEntry();
        testPricebookeEntry.Product2Id = productId;
        testPricebookeEntry.Pricebook2Id = pricebookId;
        testPricebookeEntry.UnitPrice = 100;
        testPricebookeEntry.IsActive = true;
        testPricebookeEntry.UseStandardPrice = false;
        
        if(doInsert)
        {
           insert testPricebookeEntry;
        }
        return testPricebookeEntry;
    }
 
 
    /**
     * Create an Intacct_Entity__c record
     * @return entity
    */
  public static RecurSoft__Intacct_Entity__c createIntacctEntity(String name, Boolean doInsert)
    {
        RecurSoft__Intacct_Entity__c entity = new RecurSoft__Intacct_Entity__c(
            Name = name
        );
        if(doInsert)
        {
           insert entity;
        }
        return entity;
    }
    
    /**
     * Create a Credit_Card__c record
     * @return cCard
    */
   /* public static Credit_Card__c createCreditCard(Account acc, String cardNumber, String cardType, Boolean doInsert)
    {
        Credit_Card__c cCard = new Credit_Card__c(
            Account__c = acc.Id,
            Credit_Card_Number__c = cardNumber,
            Address_1__c = acc.BillingStreet,
            Address_2__c = (!String.isEmpty(acc.ShippingStreet)) ? acc.ShippingStreet : '',
            City__c = acc.BillingCity,
            Expiration_Month__c = 'January', 
            Expiration_Year__c = '2014', 
            Card_Type__c = cardType, 
            State__c = acc.BillingState, 
            Zip_Code__c = acc.BillingPostalCode,
            Last_4_Digits__c = '1111',
            Is_Valid__c = true
        );
        if(doInsert)
        {
           insert cCard;
        }
        return cCard;
    }*/
    
    
    /**
     * Create an OpportunityLineItem record
     * @return oli
    */
    public static OpportunityLineItem createOpportunityLineItem(String serviceAccountId, String priceBookEntryId, String opportunityId, String productId, Boolean doInsert)
    {
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opportunityId,
            PricebookEntryId = priceBookEntryId,
            Quantity = 1,
            UnitPrice = 100
            //Service_Account__c = serviceAccountId
        );
        if(doInsert)
        {
           insert oli;
        }
        return oli;
    }

  
    
}