/**
 * File:        ContractPDFController.cls
 * Project:     Solutionreach 
 * Date:        Feb, 2014
 * Created By:  Sid Maganti
 * *************************************************************************
 * Description: This is Controller for  ContractPDF Document
 * *************************************************************************
 * History:
 * Date:                Modified By:            Description: 
 * 02/24/2015           Randy Barton		    CRM-20 - Added ContractDateTime parameter
 * 02/24/2015			Randy Barton			Corrected spelling in class name from ContactPDFController to ContractPDFController
 */

public class ContractPDFController extends WebFormsUtilityClass
{
    /*public Opportunity associatedOpportunity {get;set;}
    public AccountDecorator assoAccount {get;set;}
    public ContactDecorator assoOppContact {get; set;}
    public ContactDecorator assoAccContact {get;set;}
    //
    public string BusinessName {get;set;}
    public string address1 {get;set;}
    public string City {get;set;}
    public string State {get;set;}
    public string Zip {get;set;}
    public string Country {get;set;}
    public string OppCCName {get;set;}
    public string email {get;set;}
    public string DirePhone {get;set;}
    public string Officeemail {get;set;}
    public string OfficePhone {get;set;}
    public string OfficeCCName {get;set;}
    public string WebSite {get;set;}
    public string PS {get;set;}
    public string PSV {get;set;}
    public string CCTYPE {get;set;}
    public string CCNO {get;set;}
    public string CCMONTH {get;set;}
    public string CCYEAR {get;set;}
    public string Signer {get;set;}
    //
    public decimal NoProvider {get;set;}
    public decimal NoAddProvider {get;set;}
    public string Licence {get;set;}
    public string LicenceSmall {get;set;}
    public decimal MonthlyTotal {get;set;}
    public decimal OneTimeTotal {get;set;}
    public string ContractSignedIP {get;set;}
    
    public decimal SetupFee {get;set;}
    public decimal AddProFee {get;set;}
    public decimal ServiceFee {get;set;}
    public string SetupFeeProductCode {get;set;}
    public string SetupFeeProductCodeNew {get;set;}
    public list<OpportunityLineItem> listOppl {get;set;}
     public decimal TotalcontractTerm {get;set;}
	 public String ContractDateTime { get; set; }
    /*
    *Constructor for ContactPDFController
    */ 
    /* public ContractPDFController()
     {
        try
        {
           associatedOpportunity = new Opportunity();
            assoAccount = new AccountDecorator();
            assoOppContact = new  ContactDecorator();
            assoAccContact = new  ContactDecorator();
            MonthlyTotal=0;
            Licence='';
            LicenceSmall='';
            NoAddProvider=0;
            NoProvider=0;
            OneTimeTotal=0;
            TotalcontractTerm=0;
            SetupFee=0;
            ServiceFee=0;
            AddProFee=0;
            SetupFeeProductCode=SRHGlobalVariables.SET_UP_FEE;
            SetupFeeProductCodeNew=SRHGlobalVariables.SET_UP_FEE_NEW;
            listOppl= new list<OpportunityLineItem>();
            
            ContractSignedIP = getURParameter('ContractSignedIP') == null ? '' : getURParameter('ContractSignedIP');  
            string oppID=getURParameter('id');
            BusinessName=getURParameter('BusinessName')==null? '':getURParameter('BusinessName');
            address1=getURParameter('address1')==null? '':getURParameter('address1');
            City=getURParameter('City')==null? '':getURParameter('City');
            State=getURParameter('State')==null? '':getURParameter('State');
            Zip=getURParameter('Zip')==null? '':getURParameter('Zip');
            Country=getURParameter('Country')==null? '':getURParameter('Country');
            OppCCName=getURParameter('OppCCName')==null? '':getURParameter('OppCCName');
            email=getURParameter('email')==null? '':getURParameter('email');
            DirePhone=getURParameter('DirePhone')==null? '':getURParameter('DirePhone');
            Officeemail=getURParameter('Officeemail')==null? '':getURParameter('Officeemail');
            OfficePhone=getURParameter('OfficePhone')==null? '':getURParameter('OfficePhone');
            OfficeCCName=getURParameter('OfficeCCName')==null? '':getURParameter('OfficeCCName');
            WebSite=getURParameter('WebSite')==null? '':getURParameter('WebSite');
            PS=getURParameter('PS')==null? '':getURParameter('PS');
            PSV=getURParameter('PSV')==null? '':getURParameter('PSV');
            CCTYPE=getURParameter('CCTYPE')==null? '':getURParameter('CCTYPE');
            CCNO=getURParameter('CCNO')==null? '':getURParameter('CCNO');
            CCMONTH=getURParameter('CCMONTH')==null? '':getURParameter('CCMONTH'); 
            CCYEAR=getURParameter('CCYEAR')==null? '':getURParameter('CCYEAR');
            Signer=getURParameter('Signer')==null? '':getURParameter('Signer');
            Datetime Dt = system.now();
            ContractDateTime = Dt.format('MM/dd/yyyy HH:mm:ss', 'America/Denver');
            
            if(!IsEmptyOrNull(oppID))
            {
                PopulateRecords(oppID);
            }
        }
        catch (Exception Ex)
        {
            system.debug('Error ContactPDFController : '+String.ValueOF(Ex) );
            CreateErrorLog(associatedOpportunity,assoAccount,'Contract_Form_ContactPDFController_54',String.ValueOF(Ex));
        }
     }
     
  
    /*
    *Populate Records
    *@parm OpportunityID
    *Populate records 
    */
    /*public void PopulateRecords(string OppID)
    {
        associatedOpportunity= new Opportunity();
        Account associatedBusinessAccount = new Account();
        Contact associatedOppContact = new Contact();
        Contact associatedAccContact = new Contact();
        assoAccount = new AccountDecorator();
        assoOppContact = new ContactDecorator();
        assoAccContact= new ContactDecorator ();
  
        associatedOpportunity=retrieveOpportunityData(OppID);
        system.debug('associatedOpportunity-->'+associatedOpportunity);

        //system.debug('IsValiedContract(associatedOpportunity)-->'+IsValiedContract(associatedOpportunity));
        if(associatedOpportunity !=null )
        {
            associatedBusinessAccount=retrieveAccountData(associatedOpportunity.RecurSoft__Bill_to_Account__r.id);
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
                }
            }
            if(associatedBusinessAccount!= null && associatedBusinessAccount.Office_Contact__c!=null)
            {
                associatedAccContact=retrieveContactData(associatedBusinessAccount.Office_Contact__r.id);
            }
            if(associatedBusinessAccount!= null)
            {
                assoAccount.AccountID=associatedBusinessAccount.Id;
                assoAccount.BusinessName=associatedBusinessAccount.Name;
                assoAccount.address1= associatedBusinessAccount.BillingStreet;
                assoAccount.address2='';
                assoAccount.city=associatedBusinessAccount.BillingCity;
                assoAccount.country=associatedBusinessAccount.BillingCountry;
                assoAccount.OfficeContactID=associatedBusinessAccount.Office_Contact__r.id;
                assoAccount.Officeemail=associatedBusinessAccount.Office_Contact__r.Email;
                assoAccount.OfficephoneAreaCode='';
                assoAccount.OfficephoneCode='';
                assoAccount.OfficephoneCountryCode='';
                assoAccount.PractivceSoftware=associatedBusinessAccount.Practice_Management_Software__r.Name;
                assoAccount.PractivceSoftwareVersoin=associatedBusinessAccount.Practice_Management_Software_Versoin__c;         
                assoAccount.website=associatedBusinessAccount.Website==null?'':associatedBusinessAccount.Website;
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
                assoAccContact.ReferedBY=associatedAccContact.Referred_By__c==null?'':associatedAccContact.Referred_By__c;
                assoAccContact.Salutation=associatedAccContact.Salutation;
                assoAccContact.Title=associatedAccContact.Title;
                
            }

        }
        else 
        {
            //ShoWError = true;
            //DetailPage=false;
        }
   }
    
    
    /*Will Populate Providers*/
    /*private void PopulateProviders()
    {
        
        TotalcontractTerm = associatedOpportunity.Temp_Contract_Term_Total__c;
        Licence=TotalcontractTerm>12 ?'MULTI-ANNUAL':'ANNUAL';
        LicenceSmall=TotalcontractTerm>12 ?'Multi-Annual':'Annual';
      system.debug('associatedOpportunity.HasOpportunityLineItem-->'+associatedOpportunity.HasOpportunityLineItem);
        if(associatedOpportunity.HasOpportunityLineItem)
        {
            for(OpportunityLineItem Oppl:associatedOpportunity.OpportunityLineItems)
            {
                if(Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE || Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE_NEW)
                {
                    NoProvider=NoProvider+3;
                }
                else if(Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.ADDITIONAL_PROVIDERS || Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.ADDITIONAL_PROVIDERS_NEW )
                {
                    NoAddProvider=NoAddProvider+(Oppl.Quantity);
                    AddProFee=Oppl.UnitPrice;
                }
                if(Oppl.PricebookEntry.Product2.RecurSoft__Billing_Frequency__c==SRHGlobalVariables.BILLING_FREQUENCY_MONTHLY || Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.ADDITIONAL_PROVIDERS || Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE ||Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.ADDITIONAL_PROVIDERS_NEW || Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE_NEW )
                {
                   // MonthalySetupFee = MonthalySetupFee+(Oppl.UnitPrice*Oppl.Quantity);
                     MonthlyTotal = MonthlyTotal+(Oppl.UnitPrice*Oppl.Quantity);
                    system.debug('MonthlyTotal-->'+MonthlyTotal);
                   if((Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE||Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE_NEW) && Oppl.Number_of_Free_Months__c != null && Oppl.Number_of_Free_Months__c > 0)
                    {
                        Oppl.PricebookEntry.Product2.Name=LicenceSmall+' - '+TotalcontractTerm+' Months with '+ Oppl.Number_of_Free_Months__c+' months free (per office for up to 3 practitioners):';
                    }
                    else if(Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE || Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.MONTHLY_SERVICE_FEE_NEW && (Oppl.Number_of_Free_Months__c == null || (Oppl.Number_of_Free_Months__c != null && Oppl.Number_of_Free_Months__c == 0)))
                    {
                        Oppl.PricebookEntry.Product2.Name=LicenceSmall+' - '+TotalcontractTerm+' Months (per office for up to 3 practitioners): ';
                        
                    }
                    else if(Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.ADDITIONAL_PROVIDERS ||Oppl.PricebookEntry.ProductCode==SRHGlobalVariables.ADDITIONAL_PROVIDERS_NEW )
                    {
                        Oppl.PricebookEntry.Product2.Name='Extended License - number of addtional practitioners ($'+Oppl.UnitPrice+' each): ';
                        
                    }
                }
                if(Oppl.PricebookEntry.Product2.RecurSoft__Billing_Frequency__c==SRHGlobalVariables.BILLING_FREQUENCY_ONE_TIME || Oppl.PricebookEntry.Product2.RecurSoft__Billing_Frequency__c=='' )
                {
                    //OneTime = OneTime+(Oppl.UnitPrice*Oppl.Quantity);
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
                
                system.debug('Oppl.PricebookEntry.Product2.Name-->'+Oppl.PricebookEntry.Product2.Name);
            }
        }
    }*/
}