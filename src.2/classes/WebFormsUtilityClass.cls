/**
 * File:        WebFormsUtilityClass.cls
 * Project:     Solutionreach 
 * Date:        Feb, 2014
 * Created By:  Sid Maganti
 * *************************************************************************
 * Description: Web Form utitlity class contains Querys and utility methods
 * *************************************************************************
 * History:
 */
public virtual class WebFormsUtilityClass 
{
    /**
     * Validates Email address
     * @param email address
     * @return Boolean
    */
    public Boolean validateEmail(String email)
    {
        if(!(Pattern.matches('^([a-zA-Z0-9_.-])+@(([a-zA-Z0-9-])+.)+([a-zA-Z0-9]{2,4})+$', email)||Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}+.[a-zA-Z]{2,4}', email)||Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+-[a-zA-Z]{2,4}+.[a-zA-Z]{2,4}', email)|| Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+.[a-zA-Z]{2,4}', email)))
        {
            return false;
        }
        return true;
    }
    
    /**
     * getMonths()
     * @return list<SelectOption>
    */
    public List<SelectOption> getMonths()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--'));
        options.add(new SelectOption('01','01'));options.add(new SelectOption('02','02'));
        options.add(new SelectOption('03','03'));options.add(new SelectOption('04','04'));
        options.add(new SelectOption('05','05'));options.add(new SelectOption('06','06'));
        options.add(new SelectOption('07','07'));options.add(new SelectOption('08','08'));
        options.add(new SelectOption('09','09'));options.add(new SelectOption('10','10'));
        options.add(new SelectOption('11','11'));options.add(new SelectOption('12','12'));
        return options;
    }
    
    /**
     * getYear()
     * @return list of Years
    */
    public List<SelectOption> getYear()
    {
        integer years= date.today().year();
        integer i=1;
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','----'));
        while(i<=10)
        {
            options.add(new SelectOption(String.valueOf(years),String.valueOf(years)));
            i++;
            years++;
        }
        
        return options;
    }
    
    /**GetPrefix
     * @return list of Prefix
    */
    public List<SelectOption> getPreFix()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Prefix'));
        options.add(new SelectOption('Mr.','Mr.'));
        options.add(new SelectOption('Ms.','Ms.'));
        options.add(new SelectOption('Mrs.','Mrs.'));
        options.add(new SelectOption('Dr.','Dr.'));
        options.add(new SelectOption('Prof.','Prof.'));
        return options;
    }
    
    /**Credit Card Type
     * @return list of type Of Credit Cards
    */
    public List<SelectOption> getCardType()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Please select one'));
        options.add(new SelectOption('American Express','American Express'));
        options.add(new SelectOption('Discover','Discover'));
        options.add(new SelectOption('MasterCard','MasterCard'));
        options.add(new SelectOption('VISA','VISA'));
        return options;
    }
    
    /**
     * Get UR Parameter
     * @param parameter name
     * @return parameter value
    */
    
    public String getURParameter(String pname)
    {   
        PageReference pageRef = ApexPages.currentPage();
        Map<string,string> pageParameters = pageRef.getParameters();
        string p = pageParameters.get(pname);
        return p;
    }
    
    
    /**
     * Will check Empty or null
     * @param string value
     * @return boolean empty or null returns true
    */
    public Boolean IsEmptyOrNull(String strValue){
        return (strValue == null || strValue.trim().equals('')) ? true : false;
    }
    
    
    /**
     * Insert Error Log
    */
    public void CreateErrorLog(Opportunity associatedOpportunity,AccountDecorator assoAccount,String ErrorType, String Error)
    {
        Error_Log__c ErrorLog = new Error_Log__c();
        ErrorLog.Error__c=Error;
        ErrorLog.Error_Type__c=ErrorType;
        if(assoAccount!=null && assoAccount.AccountID!=null)
        ErrorLog.Account__c=assoAccount.AccountID;
        if(associatedOpportunity!=null)
        ErrorLog.Opportunity__c=associatedOpportunity.Id;
        Database.insert(ErrorLog,false);
    }
    
    public Provider__c retrieveProviderData(String id)
    {
        Provider__c providerData;
        String providerQuery = 'SELECT Id, NPI__c, Healthgrades_ID__c, Premium_Member__c, Bill_to_Account__r.Id, Related_Contact__r.Id ' +
        'FROM Provider__c  WHERE id = \'' + id +'\'';
        
        try{
            providerData = Database.query(providerQuery);
        } catch(QUERYException queryEx) {
            System.debug(queryEx.getMessage());
        }
        return providerData;
    }

    public PricebookEntry[] retrievePricebookData() {

        String pricebookQuery = 'SELECT Id, ' +
            'Pricebook2Id, ' +
            'Product2Id, ' +
            'Product2.Name, ' +
            'Product2.ProductCode, ' +
            'Product2.Family, ' +
            'Product2.Default_Co_Terminate__c, ' +
            'Product2.Default_Contract_Term__c, ' +
            'Product2.RecurSoft__Billing_Frequency__c, ' +
            'UnitPrice, ' +
            'ProductCode ' +
            'FROM PricebookEntry ' +
            'WHERE Pricebook2.Name = \'8. Add Product\'' +
            'AND Product2.Family != \'Healthgrades\' ' +
            'ORDER BY Product2.ProductCode ASC';

        PricebookEntry[] STANDARD_PRICEBOOK = Database.query(pricebookQuery);

        return STANDARD_PRICEBOOK;
    }

    public Asset[] retrieveAssetData(String accId) {

        Asset[] assetData;

        String assetQuery = 'SELECT Id, Product2.Family, Active__c, Next_Invoice_Date__c, Contract_End_Date__c ' +
        'FROM Asset WHERE AccountId = \'' + accId + '\' AND Active__c = true';

        assetData = Database.query(assetQuery);

        return assetData;
    }

    public RecurSoft__Product_Subscription__c retrieveSubscriptionData(String accId) {

        RecurSoft__Product_Subscription__c prodSubscriptionData;

        String prodSubscriptionQuery = 'SELECT Id, RecurSoft__Account__c, RecurSoft__Billing_Status__c, RecurSoft__Product__r.Name, ' +
        'RecurSoft__Contract_Term_End_Date__c, RecurSoft__Contract_Term_Start_Date__c, RecurSoft__Related_Opportunity__c, ' + 
        'RecurSoft__Bill_to_Account__c, RecurSoft__Bill_to_Contact__c, RecurSoft__Ship_to_Contact__c ' +
        'FROM RecurSoft__Product_Subscription__c WHERE RecurSoft__Account__c = \'' + accId + '\' AND RecurSoft__Product__r.Family = \'SR Platform\' ' +
        'AND RecurSoft__Billing_Status__c != \'Terminated\'ORDER BY RecurSoft__Contract_Term_End_Date__c DESC LIMIT 1';

        prodSubscriptionData = Database.query(prodSubscriptionQuery);

        return prodSubscriptionData;
    }

/**
 * Query and return the Contact Id for the 
 *
 *
 */
    public Id retrieveOpportunityContactRole(String id, String role)
    {
        OpportunityContactRole ocr;
        String ocrQuery = 'SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId = \'' + id + '\' AND Role = \'' + role + '\' LIMIT 1';

        try
        {
            ocr = Database.query(ocrQuery);
            System.debug('Opportunity Contact Role Query: ' + ocrQuery);
            System.debug('Opportunity Contact Role Data: ' + ocr);
        }
        catch(QUERYException queryEx)
        {
            System.debug(queryEx.getMessage());
        }

        return ocr.ContactId;
    }

    /**
     * Query and return the opportunity for the given signup code
     * @param Opportunity ID
     * @return opportunityData
    */
    public Opportunity retrieveOpportunityData(String id)
    {
        Opportunity opportunityData;
        String opportunityQuery = 'SELECT Id, RecurSoft__Initial_Contract_Term__c, Approval_Level_Required__C, RecordType.Name, Pricebook2.Contract_Start_Date_Offset__c, ' + 
            'HGFreeMonths__c, Pricebook2.Name, Account.Sales_Engineer_Call_Completed__c, Account.Practice_Management_Software__r.Sales_Engineer_Call_Needed__c, ' +
            'Name,RecurSoft__Trial__c,Contract_Signer__c,Temp_Contract_Term__c,Temp_Contract_Term_Total__c,Contract_Signed_IP__c,RecurSoft__Billing_Contact__c,RecurSoft__Billing_Contact__r.id,' + 
            'RecurSoft__Bill_to_Account__c,RecurSoft__Bill_to_Account__r.id,RecurSoft__Contract_Signed_Date__c,Contract_Date_Time__c,Contract_Signed__c,' + 
            'Opportunity_Owner__c, OwnerId, Type, Amount, Pricebook2Id, StageName, CloseDate, AccountId, Account.Name, Owner.Name, HasOpportunityLineItem,' + 
            'Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, Account.BillingStreet,RecurSoft__Total_Contract_Term__c,' +
            'RecurSoft__Number_of_Free_Months__c, RecurSoft__Bill_to_Account__r.Name, RecurSoft__Bill_to_Account__r.BillingCity, ' +
            'RecurSoft__Bill_to_Account__r.BillingState,RecurSoft__Bill_to_Account__r.Office_Contact__r.Email,RecurSoft__Bill_to_Account__r.Subscriber_ID__c,' +
            'RecurSoft__Bill_to_Account__r.BillingPostalCode, RecurSoft__Bill_to_Account__r.BillingCountry, RecurSoft__Bill_to_Account__r.BillingStreet,' +
            '(SELECT Id FROM RecurSoft__RecurSoft_Payment_Records__r), ' +
            '(SELECT Id, Contact.Id, Contact.Name, Contact.Email FROM OpportunityContactRoles WHERE isPrimary = true),RecurSoft__Total_Contract_Term_Text__c, ' + 
            '(SELECT Id, UnitPrice, Quantity,TotalPrice, PricebookEntryId, PricebookEntry.UnitPrice, PricebookEntry.ProductCode, PricebookEntry.Product2Id, PricebookEntry.Product2.Name,' +
            'PricebookEntry.Product2.Contract_Display_Name__c,PricebookEntry.Product2.RecurSoft__Billing_Frequency__c, Number_of_Free_Months__c, Trial__c, List_Price_Override__c, ' +
            'RecurSoft__Contract_Term_Start_Date_New__c, RecurSoft__Contract_Term_End_Date_Editable__c, PricebookEntry.Pricebook2.Number_of_Providers_Included__c, SR_Conversations_Phone_Number__c,' +
            'PricebookEntry.Product2.Family, PricebookEntry.Product2.ProductCode, Promotional_Price__c, Total_Contract_Term__c FROM OpportunityLineItems ORDER BY TotalPrice DESC) ' +
            'FROM Opportunity WHERE id = \'' + id +'\'';
        
        try
        {
            opportunityData = Database.query(opportunityQuery);
            system.debug('OPPORTUNITY QUERY: ' + opportunityQuery);
            system.debug('OPPORTUNITY DATA: ' + opportunityData);
        }
        catch(QUERYException queryEx)
        {
            System.debug(queryEx.getMessage());
        }
        return opportunityData;
    }
    
/**
     * Query and return the Account for the given id
     * @param Account ID
     * @return AccountData
    */
    public Account retrieveAccountData(String id)
    {
        Account AccountData;
        String AccountQuery = 'SELECT Id, Subscriber_ID__c, Verisign_Profile_ID__c, Name, OwnerId,Website, Type, Phone,Fax,Office_Contact__c,Office_Contact__r.Email, ' +
        'Office_Contact__r.id,Office_Contact__r.Phone, BillingCity, BillingState, RecurSoft__Billing_Email__c, Probable_Most_Recent_K_Date__c, Practice_Management_Software__r.Name, ' + 
        'Practice_Management_Software__r.Version__c, Office_Email__c, Practice_Management_Software_Versoin__c, BillingPostalCode, BillingCountry, BillingStreet, ' +
        'ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ' +
        'RecurSoft__Default_Payment_Type__c FROM Account WHERE id = \'' + id +'\'';
        try
        {
            AccountData = Database.query(AccountQuery);
            System.debug(AccountData.Practice_Management_Software__r.Name);
            system.debug('Account QUERY: ' + AccountQuery);
            system.debug('Account DATA: ' + AccountData);
        }
        catch(QUERYException queryEx)
        {
            System.debug(queryEx.getMessage());
        }
        return AccountData;
    }
    
    /**
     * Query and return the Contact for the given id
     * @param Contact ID
     * @return ContactData
    */
    public Contact retrieveContactData(String id)
    {
        Contact ContactData;
        String ContactQuery = 'Select Title,Salutation, Phone, OwnerId, Name, MobilePhone, MailingStreet, MailingState,'+
        'MailingPostalCode, MailingLongitude, MailingLatitude, MailingCountry, MailingCity,'+
        'LastName, Id, FirstName, Fax,Referred_By__c, Email, Department, AccountId From Contact WHERE id = \'' + id +'\'';
        try
        {
            ContactData= Database.query(ContactQuery);
            system.debug('Contact QUERY: ' + ContactQuery);
            system.debug('Contact DATA: ' + ContactData);
        }
        catch(QUERYException queryEx)
        {
            System.debug(queryEx.getMessage());
        }
        return ContactData;
    }

    public RecurSoft__Payment_Record__c retrieveCreditCardData(String id) {
        
        RecurSoft__Payment_Record__c CreditCardData;
        String CreditCardQuery = 'SELECT RecurSoft__Card_Type__c, RecurSoft__Expiration_Month__c, RecurSoft__Expiration_Year__c, RecurSoft__Name_On_Card__c, ' +
            'RecurSoft__Last_4_Text__c FROM RecurSoft__Payment_Record__c WHERE RecurSoft__Opportunity__c = \'' + id +'\'';
        
        try {

            CreditCardData = Database.query(CreditCardQuery);
        
        } catch(QUERYException queryEx) {
        
            System.debug(queryEx.getMessage());
        }

        return CreditCardData;
    }
    
    
       /**
     * Is Valied contract
     * @param Opportunity Object
     * @return boolean
    */
    public boolean IsValiedContract(Opportunity Opp)
    {
        boolean ISValied= true;
        if(Opp.StageName != SRHGlobalVariables.STAGE_CLOSED_WON 
        && ( Date.today()<=Opp.CloseDate) && Opp.StageName != SRHGlobalVariables.STAGE_CLOSED_LOST &&
         !Opp.Contract_Signed__c )
        {
            system.debug('ISValied-1->'+ISValied);
            return ISValied;
        }
        else
        {
            return false;
        }
    }
    
    // will return failure error message
    public ApexPages.Message returnFailure(string Message)
    {
         ApexPages.Message failureMessage = new ApexPages.Message(ApexPages.Severity.ERROR,Message);
         return    failureMessage;                   
    }
    
    //Will retrun sucess error message
    public ApexPages.Message returnSucess(string Message)
    {
        ApexPages.Message failureMessage = new ApexPages.Message(ApexPages.Severity.CONFIRM,Message);
        return    failureMessage;                       
    }
    
    /*getCountry Querys countrys from pw_cc__CountryObject__c 
    *@ return list<SelectOption>
    */
    public list<SelectOption> getCountrys 
    {
        get 
        {
            list<SelectOption> options = new List<SelectOption>();
            list<pw_cc__CountryObject__c> Country = new list<pw_cc__CountryObject__c>(); 
            Country=[SELECT Name FROM pw_cc__CountryObject__c order by Name asc limit 500 ];
            for (pw_cc__CountryObject__c S:Country )
            options.add(new SelectOption(s.Name,s.Name));
            return options;
        }
        set;
    }
    
   public list<SelectOption> getStates (string country)
    {
        if(country==null || country=='')
        country='United States';
    
        list<SelectOption> options = new List<SelectOption>();
        list<pw_cc__State__c> State = new list<pw_cc__State__c>(); 
        State=[SELECT Name FROM pw_cc__State__c where pw_cc__Country__r.Name=: country  limit 1000];
        for (pw_cc__State__c S:State )
        options.add(new SelectOption(s.Name,s.Name));
        return options;
        
    }
}