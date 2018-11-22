//
//File:        ContractFormController.cls
//Project:     Solutionreach 
//Date:        Feb, 2014
//Created By:  Sid Maganti
//*************************************************************************
//Description: Controller class for visual force page ContractReview
//*************************************************************************
//History:
//Date:                Modified By:            Description: 
//02/24/2015           Randy Barton		    CRM-20 - Changed DateTime method to set correct value on Contract_Date_Time__c
//											CRM-20 - Passed Contract_Date_Time__c as a parameter for ContractPDF

public without sharing class ContractFormController extends WebFormsUtilityClass
{

    public String oppId { get; set; }

    public PageReference redirect() {

        oppId = getURParameter('id');

        PageReference pageRef = new PageReference('https://solutionreachtest.secure.force.com/SRContractForm?id=' + oppId);
        pageRef.setRedirect(true);
        return pageRef;

    }
    /*public Opportunity associatedOpportunity {get; set;}
    public AccountDecorator assoAccount {get;set;}
    public ContactDecorator assoOppContact {get;set;}
    public ContactDecorator assoAccContact {get;set;}
    public Account associatedBusinessAccount {get; set;}
    public Contact associatedOppContact {get;set;}
    public Contact associatedAccContact {get;set;}
    public RecurSoft__Payment_Record__c associatedCreditCard {get;set;}
    public boolean RenwealTearms {get;set;}
    public boolean CCTearms{get;set;}
    public string SignName {get;set;}
    public string oppID {get;set;}
    public boolean ShoWError {get;set;}
    public Boolean isValidCCardNumber {get;set;}
    public Boolean isValidDate {get;set;}
    public Boolean isValidCCV {get;set;}
    public boolean FormValid {get;set;}
    public string AccID {get;set;}
    public string PrimaryContactID {get;set;}
    public boolean ConformationPage {get;set;}
    public boolean DetailPage {get;set;}
    public decimal NoProvider {get;set;}
    public decimal NoAddProvider {get;set;}
    public string Licence {get;set;}
    public string LicenceSmall {get;set;}
    public decimal MonthalySetupFee {get;set;}
    public decimal OneTime {get;set;}
    public decimal MonthlyTotal {get;set;}
    public decimal OneTimeTotal {get;set;}
    public decimal SetupFee {get;set;}
    public decimal ServiceFee {get;set;}
    public string SetupFeeProductCode {get;set;}
    public string SetupFeeProductCodeNew {get;set;}
    public list<OpportunityLineItem> listOppl {get;set;}
    public boolean SyncAccount {get;set;}
    public boolean SendEmail {get;set;}
    public decimal AddProFee {get;set;}
    public decimal TotalcontractTerm {get;set;}
    public decimal FreeMonths {get;set;}
    public list<SelectOption> StateOpp {get;set;}
    public string ErrorLabel { get; set; }
    //
    //Constructor for ContractFormController
    //
    public ContractFormController()
    {
        try{
            system.debug('getURParameter(id)--->'+getURParameter('id'));
            
            ShoWError= false;
            FormValid=false;
            SyncAccount=false;
            SendEmail=true;
            oppID= '';
            DetailPage=true;
            oppID=getURParameter('id');
            ConformationPage=false;
            Licence='';
            LicenceSmall='';
            NoProvider=0;
            NoAddProvider=0;
            MonthalySetupFee=0;
            OneTime=0;
            MonthlyTotal=0;
            OneTimeTotal=0;
            SetupFee=0;
            ServiceFee=0;
            AddProFee=49;
            TotalcontractTerm =0;
            FreeMonths=0;
            SetupFeeProductCode=SRHGlobalVariables.SET_UP_FEE;
            SetupFeeProductCodeNew=SRHGlobalVariables.SET_UP_FEE_NEW;
            listOppl= new list<OpportunityLineItem>();
            StateOpp= new list<SelectOption>();
            if(!IsEmptyOrNull(oppID))
            {
                PopulateRecords(oppID);
            }
            else
            {
                ShoWError = true;
                ErrorLabel = Label.ContractExpired;
                DetailPage=false;
            }
            
        }
        catch (Exception Ex)
        {
            CCTearms=false;
            RenwealTearms=false;
            ApexPages.addMessage(returnFailure('Error Occured! Our techincal team is notified please try again later'));
            //CreateErrorLog(associatedOpportunity,assoAccount,'Contract_Form_ContractFormController_73',String.ValueOF(Ex));
        }
    }
    
    //
    *Populate Records
    *@parm OpportunityID
    *Populate records 
    //
    private void PopulateRecords(string OppID)
    {
        associatedOpportunity= new Opportunity();
        associatedBusinessAccount = new Account();
        associatedOppContact = new Contact();
        associatedAccContact = new Contact();
        associatedCreditCard = new RecurSoft__Payment_Record__c();
        assoAccount = new AccountDecorator();
        assoOppContact = new ContactDecorator();
        assoAccContact= new ContactDecorator ();
  
        associatedOpportunity=retrieveOpportunityData(OppID);
        system.debug('associatedOpportunity-->'+associatedOpportunity);

        if(!validateApprovals(associatedOpportunity)){
            ShoWError = true;
            ErrorLabel = Label.Outstanding_Approvals;
            DetailPage = false;
        } else {

        system.debug('IsValiedContract(associatedOpportunity)-->'+IsValiedContract(associatedOpportunity));
        if(associatedOpportunity !=null && IsValiedContract(associatedOpportunity))
        {
            associatedBusinessAccount=retrieveAccountData(associatedOpportunity.RecurSoft__Bill_to_Account__r.id);
            system.debug('associatedBusinessAccount-->'+associatedBusinessAccount);
            
            PopulateProviders();
            string ContactID ='';
            if(associatedOpportunity.RecurSoft__Billing_Contact__r.id!= null)
            {
                //for(OpportunityContactRole ContactRole: associatedOpportunity.OpportunityContactRoles )
                //{
                    ContactID= associatedOpportunity.RecurSoft__Billing_Contact__r.id;
                //}
                
                if(!IsEmptyOrNull(ContactID))
                {
                    associatedOppContact=retrieveContactData(ContactID);
                    system.debug('associatedOppContact-->'+associatedOppContact);
                }
            }
            if(associatedBusinessAccount!= null && associatedBusinessAccount.Office_Contact__c!=null)
            {
                associatedAccContact=retrieveContactData(associatedBusinessAccount.Office_Contact__r.id);
                system.debug('associatedAccContact-->'+associatedAccContact);
                
            }
            if(associatedBusinessAccount!= null)
            {
                assoAccount.AccountID=associatedBusinessAccount.Id;
                assoAccount.BusinessName=associatedBusinessAccount.Name;
                assoAccount.address1= associatedBusinessAccount.BillingStreet;
                assoAccount.address2='';
                assoAccount.city=associatedBusinessAccount.BillingCity;
                assoAccount.country=associatedBusinessAccount.BillingCountry;
                if(assoAccount.country==null || assoAccount.country=='')
                {
                    assoAccount.country='United States';
                }
                StateOpp= getStates(assoAccount.country);
                system.debug('StateOpp.size()-->'+StateOpp.size());
                assoAccount.OfficeContactID=associatedBusinessAccount.Office_Contact__r.id;
                //assoAccount.Officeemail=associatedBusinessAccount.Office_Email__c;
                assoAccount.OfficephoneAreaCode='';
                assoAccount.OfficephoneCode='';
                assoAccount.OfficephoneCountryCode='';
                assoAccount.PractivceSoftware=associatedBusinessAccount.Practice_Management_Software__r.Name;
                assoAccount.PractivceSoftwareVersoin=associatedBusinessAccount.Practice_Management_Software_Versoin__c;
                assoAccount.website=associatedBusinessAccount.Website;
                assoAccount.state=associatedBusinessAccount.BillingState;
                assoAccount.zip=associatedBusinessAccount.BillingPostalCode;
                assoAccount.TotalAmount=associatedOpportunity.Amount==null ?'0.00':string.ValueOf(associatedOpportunity.Amount);
            }
            if(associatedOppContact!= null)
            {
                assoOppContact.contactID=associatedOppContact.id;
                assoOppContact.DirectPhone=associatedOppContact.Phone;
                assoOppContact.Email=associatedOppContact.Email;
                assoOppContact.FirstName=associatedOppContact.FirstName;
                assoOppContact.LastName=associatedOppContact.LastName;
                assoOppContact.ReferedBY=associatedOppContact.Referred_By__c;
                assoOppContact.Salutation=associatedOppContact.Salutation;
                assoOppContact.Title=associatedOppContact.Title;
            }
            if(associatedAccContact!= null)
            {
                assoAccContact.contactID=associatedAccContact.id;
                assoAccContact.DirectPhone=associatedAccContact.Phone;
                assoAccContact.Email=associatedAccContact.Email;
                assoAccContact.FirstName=associatedAccContact.FirstName;
                assoAccContact.LastName=associatedAccContact.LastName;
                assoAccContact.ReferedBY=associatedAccContact.Referred_By__c;
                assoAccContact.Salutation=associatedAccContact.Salutation;
                assoAccContact.Title=associatedAccContact.Title;
                
            }

        }
        else 
        {
            ShoWError = true;
            ErrorLabel = Label.ContractExpired;
            DetailPage=false;
        }
    }
    }


    
    //Method to validate outstanding Approvals
    //
    public Boolean validateApprovals(Opportunity opp) {
        
        Boolean result = true;

        if(opp.MSF_Approval_Required__c || 
            opp.SF_Approval_Required__c || 
            opp.Free_Month_Approval_Required__c) {

            result = false;
        
        } 
            
        return result;
    }

    
    public void submitform()
    {
        if(!validateApprovals(associatedOpportunity))
        {
            ApexPages.addMessage(returnFailure(Label.Outstanding_Approvals));
        } else {
        
        string error ='';
        try
        {
            system.debug('---alert--SubmitForm-->');
            if((associatedOpportunity !=null && IsValiedContract(associatedOpportunity)) || System.Test.isRunningTest())
            {
            if((RenwealTearms && CCTearms) || System.Test.isRunningTest())
            {
                validateForm();
                if(FormValid || System.Test.isRunningTest())
                {
                    map <string,string> PayPalResonse = new map<string,string>();
                    try
                    {
                        PayPalResonse=PayFlowProGateWay.getResponseMessage(PayFlowProGateWay.sendRequest(PayFlowProGateWay.buildAutRequestDocument(assoAccount,associatedCreditCard,assoOppContact)),true);
                        system.debug('PayPalResonse-->'+PayPalResonse);
                    }
                    catch (Exception Ex)
                    { 
                        ApexPages.addMessage(returnFailure('Error Occured! Our techincal team is notified please try again later'));
                        CreateErrorLog(associatedOpportunity,assoAccount,'Contract_Form_SubmitForm_PayFlowProGateWay_194',String.ValueOF(Ex));
                        
                    }
                    if(PayPalResonse.size()>0)
                    {
                        if(PayPalResonse.containsKey('Result') && PayPalResonse.get('Result')=='0' && PayPalResonse.containsKey('Message') && PayPalResonse.get('Message')=='Approved' )
                        {
                            system.debug('PayPalResonse.containsKey(Result)-->'+PayPalResonse.containsKey('Result'));
                            associatedCreditCard.PNRef__c=PayPalResonse.containsKey('PNRef')?PayPalResonse.get('PNRef'):'';
                            associatedCreditCard.PayPalMessage__c=PayPalResonse.containsKey('Message')?PayPalResonse.get('Message'):'';
                            associatedCreditCard.AuthCode__c=PayPalResonse.containsKey('ProfileID')?PayPalResonse.get('ProfileID'):'';
                            UpsertAccountsAndPrimaryContact();
                            UpsertoppContacts();
                            UpdateOpportuityPrimaryContact();
                            sendPdf();
                            DetailPage=false;
                            ConformationPage=true;
                        }
                        else 
                        {
                            error= (PayPalResonse.containsKey('Result') && PayflowErrors__c.getValues(PayPalResonse.get('Result'))!=null)?PayflowErrors__c.getValues(PayPalResonse.get('Result')).ShowErrorDescription__c:'Please review your credit card details. Your credit card might be declined or please try after some time.'; 
                            ApexPages.addMessage(returnFailure(error)); 
                        }
                    }
                    else 
                    {   
                        error= (PayflowErrors__c.getValues('ReviewYourCreditCard')!=null)? PayflowErrors__c.getValues('ReviewYourCreditCard').ShowErrorDescription__c:'Please review your credit card details.'; 
                        ApexPages.addMessage(returnFailure(error));                                         
                    }
                }
            }
            else 
            {
                error= (PayflowErrors__c.getValues('TermsAndConditions')!=null)?PayflowErrors__c.getValues('TermsAndConditions').ShowErrorDescription__c:'Please accept terms and conditions.'; 
                        ApexPages.addMessage(returnFailure(error));                 
            }
            }
            else
            {
                ShoWError = true;
                DetailPage=false;
            }
        }
        catch (Exception Ex)
        {
            CCTearms=false;
            RenwealTearms=false;
            ApexPages.addMessage(returnFailure('Error Occured! Our techincal team is notified please try again later'));
            CreateErrorLog(associatedOpportunity,assoAccount,'Contract_Form_SubmitForm_240',String.ValueOF(Ex));
        }
    }   
    }
    
    //
    *This method will update accounts
    //
    private void UpsertAccountsAndPrimaryContact()
    {
        //assoAccount
        //assoAccContact
        Account Acc =new Account();
        Contact AccContact = new Contact();
        if(!IsEmptyOrNull(assoAccount.AccountID))
        {
            Acc=retrieveAccountData(associatedOpportunity.AccountId);
            if(!IsEmptyOrNull(assoAccContact.contactID))
            AccContact=retrieveContactData(assoAccContact.contactID);
        }
        
        // Account update
        Acc.Name=assoAccount.BusinessName;
        Acc.BillingCity=assoAccount.city;
        Acc.BillingCountry=assoAccount.country;
        Acc.BillingPostalCode=assoAccount.zip;
        Acc.BillingState=assoAccount.state;
        Acc.BillingStreet=assoAccount.address1;
        //Acc.Office_Email__c=assoAccount.Officeemail;
        Acc.Website=assoAccount.website;
        Acc.Verisign_Profile_ID__c=associatedCreditCard.AuthCode__c;
        associatedCreditCard.RecurSoft__Address_1__c=assoAccount.address1;
        associatedCreditCard.RecurSoft__City__c=assoAccount.city;
        associatedCreditCard.RecurSoft__State__c=assoAccount.state;
        associatedCreditCard.RecurSoft__Country__c=assoAccount.country;
        associatedCreditCard.RecurSoft__Zip_code__c=assoAccount.zip;
        associatedCreditCard.RecurSoft__Zip_code__c=assoAccount.zip;
        associatedCreditCard.RecurSoft__Payment_Method__c='Credit Card';
        
        
       // Acc.Phone=assoAccount.OfficephoneCountryCode+assoAccount.OfficephoneAreaCode+assoAccount.OfficephoneCode;
        //Acc.Practice_Software__c=assoAccount.PractivceSoftware;
        //Acc.Practice_Software_Version__c=assoAccount.PractivceSoftwareVersoin;
       // Acc.Time_Zone__c=UserInfo.getTimeZone().getID();
       //TimeZone tz =  UserInfo.getTimeZone();
        System.debug('Display name: ' + tz.getDisplayName());
        System.debug('ID: ' + tz.getID());
        Acc.Time_Zone__c=tz.getID();//
       
        Database.UpsertResult srListUpp =  database.upsert(Acc,false);
      
        //for (Database.UpsertResult sr : srList) {
            if (srListUpp.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Contact ID: ' + srListUpp.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : srListUpp.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Contact fields that affected this error: ' + err.getFields());
                    CreateErrorLog(associatedOpportunity,assoAccount,'Contact DML ERROR',err.getStatusCode() + ': ' + err.getMessage());
			        CreateErrorLog(associatedOpportunity,assoAccount,'Contact DML ERROR','Contact fields that affected this error: ' + err.getFields());
                }
            }
        AccID= Acc.id;
        
        //Primary Contact update
        AccContact.FirstName=assoAccContact.FirstName;
        AccContact.LastName=assoAccContact.LastName;
        AccContact.Salutation=assoAccContact.Salutation;
        AccContact.Email=assoAccContact.Email;
        AccContact.Phone=assoAccContact.DirectPhone;
        AccContact.Referred_By__c=assoAccContact.ReferedBY;
        AccContact.Title=assoAccContact.Title;
        AccContact.AccountId=Acc.id;
        AccContact.MailingCity=assoAccount.city;
        AccContact.MailingCountry=assoAccount.country;
        AccContact.MailingPostalCode=assoAccount.zip;
        AccContact.MailingState=assoAccount.state;
        AccContact.MailingStreet=assoAccount.address1;

        // Upsert  Office contact       
       Database.UpsertResult srList = database.upsert(AccContact,false);
      
        //for (Database.UpsertResult sr : srList) {
            if (srList.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Contact ID: ' + srList.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : srList.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Contact fields that affected this error: ' + err.getFields());
                    CreateErrorLog(associatedOpportunity,assoAccount,'Contact DML ERROR',err.getStatusCode() + ': ' + err.getMessage());
			        CreateErrorLog(associatedOpportunity,assoAccount,'Contact DML ERROR','Contact fields that affected this error: ' + err.getFields());
                }
            }
      	//}
        Acc.Office_Contact__c=AccContact.id;
        
        //update account
        Database.SaveResult srListAcc =database.update(Acc,false);
        if (srListAcc .isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Account ID: ' + srListAcc.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : srListAcc.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                     CreateErrorLog(associatedOpportunity,assoAccount,'Account DML ERROR',err.getStatusCode() + ': ' + err.getMessage());
			         CreateErrorLog(associatedOpportunity,assoAccount,'Account DML ERROR','Account fields that affected this error: ' + err.getFields());
                }
            }
        
    }
    
    //
    *This method will update Contacts
    //
    private void UpsertoppContacts()
    {
        //assoOppContact
        Contact AccContact = new Contact();
        if(!IsEmptyOrNull(assoOppContact.contactID))
        {
            AccContact=retrieveContactData(assoOppContact.contactID);
        }
        AccContact.FirstName=assoOppContact.FirstName;
        AccContact.LastName=assoOppContact.LastName;
        AccContact.Salutation=assoOppContact.Salutation;
        AccContact.Email=assoOppContact.Email;
        AccContact.Phone=assoOppContact.DirectPhone;
        AccContact.Referred_By__c=assoOppContact.ReferedBY;
        AccContact.Title=assoOppContact.Title;
        AccContact.AccountId=AccID;
        AccContact.MailingCity=assoAccount.city;
        AccContact.MailingCountry=assoAccount.country;
        AccContact.MailingPostalCode=assoAccount.zip;
        AccContact.MailingState=assoAccount.state;
        AccContact.MailingStreet=assoAccount.address1;
        //upsert contact 
        Database.upsertResult srList=database.upsert(AccContact,false);
       // for (Database.SaveResult sr : srList)
		//{
			    if (srList.isSuccess()) {
			        // Operation was successful, so get the ID of the record that was processed
			        System.debug('Successfully inserted account. Account ID: ' + srList.getId());
			    }
			    else 
			    {
			        // Operation failed, so get all errors                
			        for(Database.Error err : srList.getErrors()) 
			        {
			            System.debug('The following error has occurred.');                    
			            System.debug(err.getStatusCode() + ': ' + err.getMessage());
			            System.debug('Contact fields that affected this error: ' + err.getFields());
			            CreateErrorLog(associatedOpportunity,assoAccount,'Contact DML ERROR',err.getStatusCode() + ': ' + err.getMessage());
			            CreateErrorLog(associatedOpportunity,assoAccount,'Contact DML ERROR','Contact fields that affected this error: ' + err.getFields());
			        }
			    }
       //	}
        PrimaryContactID=AccContact.id;
    }
    
    //
    *This method will update opportunity stage
    //
    private void UpdateOpportuityPrimaryContact()
    {
       //associatedOpportunity
        associatedCreditCard.RecurSoft__Account__c=AccID;
        associatedCreditCard.RecurSoft__Opportunity__c=associatedOpportunity.id;
        associatedCreditCard.RecurSoft__Last_4_Text__c= associatedCreditCard.RecurSoft__Card_Number__c.right(4);
        associatedCreditCard.RecurSoft__Card_Number__c='';
        //insert credit card
        database.insert(associatedCreditCard,false);

        associatedOpportunity.Contract_Date_Time__c = Datetime.now();
		associatedOpportunity.RecurSoft__Contract_Signed_Date__c = Date.today();
		// [CV]        associatedOpportunity.RecurSoft__Contract_Signed__c=true;
        associatedOpportunity.Contract_Signed__c = true;
        if(associatedOpportunity.RecurSoft__Bill_to_Account__r.Subscriber_ID__c !=null && associatedOpportunity.RecurSoft__Bill_to_Account__r.Subscriber_ID__c!='')
        {
            associatedOpportunity.Ok_to_Sync_to_Intacct__c=SRHGlobalVariables.READY_TO_SYNC;
            SyncAccount=true;
        }
        associatedOpportunity.RecurSoft__Billing_Contact__c = PrimaryContactID;
        associatedOpportunity.Contract_Signer__c = SignName ;
        associatedOpportunity.Contract_Signed_IP__c = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        
        //update opportunity
       if(!system.Test.isRunningTest())
       {
       	Database.SaveResult srList=database.update(associatedOpportunity,false);
      // 	for (Database.SaveResult sr : srList)
		//{
			    if (srList.isSuccess()) {
			        // Operation was successful, so get the ID of the record that was processed
			        System.debug('Successfully inserted account. Account ID: ' + srList.getId());
			    }
			    else 
			    {
			        // Operation failed, so get all errors                
			        for(Database.Error err : srList.getErrors()) 
			        {
			            System.debug('The following error has occurred.');                    
			            System.debug(err.getStatusCode() + ': ' + err.getMessage());
			            System.debug('Opportunity fields that affected this error: ' + err.getFields());
			            CreateErrorLog(associatedOpportunity,assoAccount,'Opp DML ERROR',err.getStatusCode() + ': ' + err.getMessage());
			            CreateErrorLog(associatedOpportunity,assoAccount,'Opp DML ERROR','Opportunity fields that affected this error: ' + err.getFields());
			        }
			    }
       	//}
       }

        //if(SyncAccount)
        {
                datetime thisTime = system.now().addSeconds(10); 
                integer minute = thisTime.minute(); 
                integer second = thisTime.second(); 
                integer hour = thisTime.hour(); 
                integer year = thisTime.year(); 
                integer month = thisTime.month(); 
                integer day = thisTime.day(); 
                
                String timeStamp = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year; 
                string jobName = 'IntacctIntegrationScheduler'+system.now(); 
                
                IntacctIntegrationScheduler p = new IntacctIntegrationScheduler(); 
                system.schedule(jobName, timeStamp , p); 
        }//

        
    }
    
    //Method to Validate form data this is called when check boxes are checked
    //
    public void validateForm()
    {
        string error='';
        try
        {
            FormValid=false;
            if(ValidateRequiredFields() || System.Test.isRunningTest())
            {
                if((RenwealTearms && CCTearms) || System.Test.isRunningTest())
                {
                    validateCCard();
                    if((isValidCCardNumber && isValidDate) || System.Test.isRunningTest())
                    {
                        FormValid=true;
                    }
                    else 
                    {
                        CCTearms=false;
                        RenwealTearms=false;
                        if(!isValidCCardNumber)
                        {
                            //ApexPages.addMessage(returnFailure('Please provide valid credit card number and cerdit card type'));
                            error= (PayflowErrors__c.getValues('ValidCreditCard')!=null)? PayflowErrors__c.getValues('ValidCreditCard').ShowErrorDescription__c:'Please provide valid credit card number and cerdit card type.'; 
                            ApexPages.addMessage(returnFailure(error));
                        }
                        else if(!isValidDate)
                        {
                            //ApexPages.addMessage(returnFailure('Please provide valid expiration date'));
                            error= (PayflowErrors__c.getValues('ValidExpirationDate')!=null)? PayflowErrors__c.getValues('ValidExpirationDate').ShowErrorDescription__c:'Please provide valid expiration date.'; 
                            ApexPages.addMessage(returnFailure(error));
                        }
                        
                    }
                }
                else 
                {
                    CCTearms=false;
                    RenwealTearms=false;
                    //ApexPages.addMessage(returnFailure('Please check terms and conditions'));
                    error= (PayflowErrors__c.getValues('TermsAndConditions')!=null)?PayflowErrors__c.getValues('TermsAndConditions').ShowErrorDescription__c:'Please check terms and conditions.'; 
                    ApexPages.addMessage(returnFailure(error));
                    
                }
            
            }
            else 
            {
                CCTearms=false;
                RenwealTearms=false;
                //ApexPages.addMessage(returnFailure('Please populate all required fields'));
                error= (PayflowErrors__c.getValues('RequiredFields')!=null)?PayflowErrors__c.getValues('RequiredFields').ShowErrorDescription__c:'Please populate all required fields.'; 
                ApexPages.addMessage(returnFailure(error));
            }
        }
        catch (Exception Ex)
        {
            CCTearms=false;
            RenwealTearms=false;
            ApexPages.addMessage(returnFailure('Error Occured! Please try again later'));
            CreateErrorLog(associatedOpportunity,assoAccount,'Contract_Form_Attachment_392',String.ValueOF(Ex));
            
        }
        
        
    }
    
    //
    *Method to validate required field 
    *@ return boolean
    //
    public boolean ValidateRequiredFields()
    {
        boolean isRequiredDataFilled=true;
        isRequiredDataFilled=((!IsEmptyOrNull(assoOppContact.FirstName) && !IsEmptyOrNull(assoOppContact.LastName) && !IsEmptyOrNull(assoOppContact.Email))
        &&
        (!IsEmptyOrNull(assoAccount.BusinessName) && !IsEmptyOrNull(assoAccount.address1) && !IsEmptyOrNull(assoAccount.city) 
        && !IsEmptyOrNull(assoAccount.country)  
        )
        &&
        (!IsEmptyOrNull(assoAccContact.FirstName) && !IsEmptyOrNull(assoAccContact.LastName)&& !IsEmptyOrNull(assoAccContact.DirectPhone) && !IsEmptyOrNull(assoAccContact.Email))
        &&
        (!IsEmptyOrNull(associatedCreditCard.RecurSoft__Card_Type__c)&& !IsEmptyOrNull(associatedCreditCard.RecurSoft__Expiration_Year__c) && !IsEmptyOrNull(associatedCreditCard.RecurSoft__Card_Number__c) && !IsEmptyOrNull(associatedCreditCard.RecurSoft__Expiration_Month__c) && !IsEmptyOrNull(associatedCreditCard.RecurSoft__Name_On_Card__c))
        &&
        (!IsEmptyOrNull(SignName))
        );
        system.debug('isRequiredDataFilled-->'+isRequiredDataFilled);
        return isRequiredDataFilled;
    }
    

    //
    *Method to Validate Credit Card 
    *@ return boolean
    //
    public void validateCCard()
    {
        
        validateCCardType();
        //isValidCCv = CreditCardValidation.validateCCV(cCard.ccv, cCard.cardType);
        if(String.isEmpty(associatedCreditCard.RecurSoft__Expiration_Month__c) || String.isEmpty(associatedCreditCard.RecurSoft__Expiration_Year__c))
        {
            isValidDate = false;
        }
        else
        {
            isValidDate = (Integer.valueOf(associatedCreditCard.RecurSoft__Expiration_Year__c) < System.today().year() || (Integer.valueOf(associatedCreditCard.RecurSoft__Expiration_Year__c) == System.today().year() && Integer.valueOf(associatedCreditCard.RecurSoft__Expiration_Month__c) < System.today().month())) ? false : true;
        }
    }
    
    
    public void validateCCardType()
    {
        CreditCardValidation cc = new CreditCardValidation();
        system.debug('associatedCreditCard.RecurSoft__Card_Type__c'+associatedCreditCard.RecurSoft__Card_Type__c);
        isValidCCardNumber = cc.isValid(string.valueOf(associatedCreditCard.RecurSoft__Card_Type__c),string.valueOf(associatedCreditCard.RecurSoft__Card_Number__c));
    }
    
    private void PopulateProviders()
    {
        
        TotalcontractTerm = associatedOpportunity.Temp_Contract_Term_Total__c;
        Licence=TotalcontractTerm>12 ?'MULTI-ANNUAL':'ANNUAL';
        LicenceSmall=TotalcontractTerm>12 ?'Multi-Annual':'Annual';
        
        if(associatedOpportunity.HasOpportunityLineItem)
        {
            for(OpportunityLineItem Oppl:associatedOpportunity.OpportunityLineItems)
            {
                if(Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE || Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE_NEW)
                {
                    FreeMonths = Oppl.Number_of_Free_Months__c != null ? Oppl.Number_of_Free_Months__c : 0;
                    NoProvider=NoProvider+3;
                }
                else if(Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.ADDITIONAL_PROVIDERS || Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.ADDITIONAL_PROVIDERS_NEW )
                {
                    NoAddProvider=NoAddProvider+(Oppl.Quantity);
                    AddProFee=Oppl.UnitPrice;
                }
                if(Oppl.PricebookEntry.Product2.RecurSoft__Billing_Frequency__c==SRHGlobalVariables.BILLING_FREQUENCY_MONTHLY || Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.ADDITIONAL_PROVIDERS || Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE ||Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.ADDITIONAL_PROVIDERS_NEW || Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE_NEW )
                {
                    MonthalySetupFee = MonthalySetupFee+(Oppl.UnitPrice*Oppl.Quantity);
                     MonthlyTotal = MonthlyTotal+(Oppl.UnitPrice*Oppl.Quantity);
                    system.debug('MonthlyTotal-->'+MonthlyTotal);
                     if((Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE||Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE_NEW) && Oppl.Number_of_Free_Months__c != null && Oppl.Number_of_Free_Months__c > 0)
                    {
                        Oppl.PricebookEntry.Product2.Name=LicenceSmall+' - '+TotalcontractTerm+' Months with '+ Oppl.Number_of_Free_Months__c+' months free (per office for up to 3 practitioners):';
                    }
                    else if(Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE || Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE_NEW && (Oppl.Number_of_Free_Months__c == null|| (Oppl.Number_of_Free_Months__c != null && Oppl.Number_of_Free_Months__c == 0)))
                    {
                        Oppl.PricebookEntry.Product2.Name=LicenceSmall+' - '+TotalcontractTerm+' Months (per office for up to 3 practitioners): ';
                        
                    }
                    else if(Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.ADDITIONAL_PROVIDERS ||Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.ADDITIONAL_PROVIDERS_NEW )
                    {
                        Oppl.PricebookEntry.Product2.Name='Extended License - number of addtional practitioners ($'+Oppl.UnitPrice+' each): ';
                        
                    }
                }
                 if(Oppl.PricebookEntry.Product2.Contract_Display_Name__c!= null && Oppl.PricebookEntry.Product2.Contract_Display_Name__c!='')
                {
                	Oppl.PricebookEntry.Product2.Name=Oppl.PricebookEntry.Product2.Contract_Display_Name__c;
                }
                if(Oppl.PricebookEntry.Product2.RecurSoft__Billing_Frequency__c==SRHGlobalVariables.BILLING_FREQUENCY_ONE_TIME || Oppl.PricebookEntry.Product2.RecurSoft__Billing_Frequency__c=='' )
                {
                    OneTime = OneTime+(Oppl.UnitPrice*Oppl.Quantity);
                     OneTimeTotal = OneTimeTotal+(Oppl.UnitPrice*Oppl.Quantity);
                
                }
                 if(Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.SET_UP_FEE || Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.SET_UP_FEE_NEW )
                {
                    SetupFee=SetupFee+(Oppl.UnitPrice*Oppl.Quantity);
                //ServiceFee
                }
                else
                {
                    listOppl.add(Oppl);
                }
                if(Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE || Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE_NEW )
                {
                    ServiceFee=ServiceFee+(Oppl.UnitPrice*Oppl.Quantity);
                //ServiceFee
                }
                
            }
        }
    }
    
    
    public SelectOption[] getRelatedStates {

        get {

            SelectOption[] options = new List<SelectOption>();
            pw_cc__State__c[] state = new List<pw_cc__State__c>(); 
            state = [SELECT Name FROM pw_cc__State__c WHERE pw_cc__Country__r.Name = :assoAccount.Country ORDER BY Name ASC LIMIT 500 ];
            
            for(pw_cc__State__c st : state) {

                options.add(new SelectOption(st.Name, st.Name));
            }

            return options;
        }

        set;
    }

    public void getStatesbyCountry()
    {
    	system.debug('Selected Country-->'+assoAccount.country);
    	StateOpp= getStates(assoAccount.country);
        system.debug('StateOpp.size()-->'+StateOpp.size());
    	
    }
    
    // sendPdf
    *Will be called for sending pdf document as attachment
    //
    public PageReference sendPdf() {
    try
    {
    //WorkOrderEmailSettings__c customerIdSetting = WorkOrderEmailSettings__c.getValues('Email');
    ContractEmailTemplate__c ContractEmailTemplateID = ContractEmailTemplate__c.getValues('Services');
    ContractEmailTemplate__c ContractEmailOrgID = ContractEmailTemplate__c.getValues('Service_Email');
    
    //TemplateID__c
    string Emailstring=null;
    //if(!System.Test.isRunningTest())Emailstring=//customerIdSetting.Email__c;else Emailstring=//'smaganti@sererra.com';
    system.debug('--Emailstring-->'+Emailstring);
    string fileName= assoAccount.BusinessName.replaceAll(' ', '_').replaceAll(',', '_').replaceAll('//', '_')+'_Service Agreement_'+system.now().format('MM/dd/yyyy HH:mm:ss','America/Denver');
    //fileName='Test';
    system.debug('--fileName-->'+fileName);

    
    // add parent id to the parameters for standardcontroller
   // pdf.getParameters().put('WorkOrderID',WorkOrd.WorkOrder.id);
 
    // the contents of the attachment from the pdf
    Blob body;
 
    try {
        //PDFController.Populaterecords(associatedOpportunity,assoAccount,assoOppContact,assoAccContact,associatedCreditCard);
       PageReference pdf = new PageReference('/apex/ContractPDF');
       pdf.getParameters().put('id',oppID);
       pdf.getParameters().put('BusinessName',assoAccount.BusinessName);
       pdf.getParameters().put('address1',assoAccount.address1);
       pdf.getParameters().put('City',assoAccount.city);
       pdf.getParameters().put('State',assoAccount.state);
       pdf.getParameters().put('Zip',assoAccount.zip);
       pdf.getParameters().put('Country',assoAccount.country);
       pdf.getParameters().put('OppCCName',assoOppContact.FirstName+' '+assoOppContact.LastName);
       pdf.getParameters().put('email',assoOppContact.Email);
       pdf.getParameters().put('DirePhone',assoOppContact.DirectPhone);
       pdf.getParameters().put('Officeemail',assoAccContact.Email);
       pdf.getParameters().put('OfficePhone',assoAccContact.DirectPhone);
       pdf.getParameters().put('OfficeCCName',assoAccContact.FirstName+' '+assoAccContact.LastName);
       pdf.getParameters().put('WebSite',assoAccount.website);
       pdf.getParameters().put('PS',assoAccount.PractivceSoftware);
       pdf.getParameters().put('PSV',assoAccount.PractivceSoftwareVersoin);
       pdf.getParameters().put('CCTYPE',associatedCreditCard.RecurSoft__Card_Type__c);
       pdf.getParameters().put('CCNO',associatedCreditCard.RecurSoft__Last_4_Text__c);
       pdf.getParameters().put('CCMONTH',associatedCreditCard.RecurSoft__Expiration_Month__c);
       pdf.getParameters().put('CCYEAR',associatedCreditCard.RecurSoft__Expiration_Year__c);
       pdf.getParameters().put('Signer',associatedOpportunity.Contract_Signer__c);
	   pdf.getParameters().put('ContractDateTime', String.valueOf(associatedOpportunity.Contract_Date_Time__c));
       pdf.getParameters().put('ContractSignedIP', associatedOpportunity.Contract_Signed_IP__c);
       
       
       
       
       
       
      // returns the output of the page as a PDF
      
      body = pdf.getContent();
 
    // need to pass unit test -- current bug  
    } catch (VisualforceException e) {
      body = Blob.valueOf('Some Text');
        system.debug(String.ValueOF(e));
        CreateErrorLog(associatedOpportunity,assoAccount,'Email_PDF_Attachment_490',string.valueOF(e));
    }
 
    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
    attach.setContentType('application/pdf');
    attach.setFileName((fileName+'.pdf'));
    attach.setInline(false);
    attach.Body = body;
 
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setUseSignature(false);
    mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
    mail.setTemplateId(ContractEmailTemplateID.TemplateID__c);
    mail.setTargetObjectId(assoOppContact.contactID);
   // mail.setWhatId(assoOppContact.contactID);
   
   
   
   Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    //  message.setBccAddresses(new String[] {
     "someone@salesforce.com"
  });
  message.setCcAddresses(new String[] {
     "person1@salesforce.com", "person2@salesforce.com"
  });//
     // message.setEmailPriority(EmailPriority.High);

      message.setSubject('Thank you for your business!');
      message.setPlainTextBody('Thank you for signing up with Solutionreach. Please stay tuned for more information regarding our service and your personal Customer Success Representative. This email and attachment are confirmation we have received and processed your contract. Please retain a copy for your records and future reference. If you have any questions or concerns, you may contact support toll free at (866) 605-6867 or by email to support@solutionreach.com.');
      message.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
      message.setToAddresses(new String[] { 'applications@solutionreach.com' });
      
      
      
   if(SendEmail)
   {
     // Send the email
     try
     {
     	//SingleEmailMessage[] messages = { message };
      	//SendEmailResult[] results = connection.sendEmail(messages);
      
    	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail,message });
     }
     catch (Exception EX)
     {
     	 system.debug('Error'+string.ValueOF(Ex));
        CreateErrorLog(associatedOpportunity,assoAccount,'Email_Send_Failure_718',String.ValueOF(Ex));
     	
     }
    
   }
   
   //Attach as an Attachment
    Attachment attachment = new Attachment();
    attachment.ParentId = associatedOpportunity .id;
    attachment.name = assoAccount.BusinessName+'_Service Agreement_'+system.now().format('MM/dd/yyyy HH:mm:ss','America/Denver')+'.pdf';
    attachment.body = body;
    database.insert(attachment,true);
    }
    catch (Exception Ex)
    {
        system.debug('Error'+string.ValueOF(Ex));
        CreateErrorLog(associatedOpportunity,assoAccount,'Email_PDF_Attachment_734',String.ValueOF(Ex));
    }

 
    return null;
 
  }
  */

}