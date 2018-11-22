public without sharing class GetSubscriberId_Controller 
{    
	private final Id opportunityId;
    public List<Contact> contacts { get; set; }
    public Account account { get; set; }
    public Opportunity opp { get; set; }
    public OpportunityContactRole businessContactRole { get; set; }
    public OpportunityContactRole billingContactRole { get; set; }
    public Contact billingContact { get; set; }
    public Contact businessContact { get; set; }
    public Contact newContact = new Contact();
    public Map<String, OpportunityContactRole> ocrMap { get; set;}
    public Boolean isEligible { get; set; }
    public Integer numberBillingContactSelected { get; set; }
    public Integer numberBusinessContactSelected { get; set; }
    public String blankSpace { get; set; }
    public Boolean sameAsBilling { get; set; }
    public String validationMessage { get; set; }

    public GetSubscriberId_Controller(ApexPages.StandardController stdController) 
    {
        this.opportunityId = stdController.getId();
        
        opp = ((Opportunity[]) OpportunitiesSelector.newInstance().selectSObjectsById(new Set<Id>{ this.opportunityId }))[0];
        
        account = ((Account[]) AccountsSelector.newInstance().selectByIdWithParentAccount(new Set<Id>{ opp.AccountId }))[0];        
        ocrMap = OpportunityContactRolesSelector.newInstance().selectRoleMapByOpportunityIdWithContact(new Set<Id>{ this.opportunityId });        
        if (!ocrMap.isEmpty()) businessContactRole = ocrMap.get('Business Contact');
        if (!ocrMap.isEmpty()) billingContactRole = ocrMap.get('Billing Contact');
     
        contacts = ContactsSelector.newInstance().selectContactsByAccountId(new Set<Id>{account.Id});                                                   
        for(Contact c : contacts)
        {
            if (c.Contact_Role_Multi__c != null && c.Contact_Role_Multi__c.contains('Business Contact')) businessContact = c;
            if (c.Contact_Role_Multi__c != null && c.Contact_Role_Multi__c.contains('Billing Contact')) billingContact = c;                
        }                
    }

    public PageReference cancel()
    {
        PageReference pageRef = new PageReference('/' + opportunityId);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference validateIsEligible() 
    {         
        isEligible = true;

        if(account.Subscriber_ID__c != null && account.Subscriber_ID__c != '')
        {                
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.WARNING, 'The Account already has a Subscriber ID');
            ApexPages.addMessage(errorMessage);  
            isEligible = false;
            return null;                    
        }

        if(account.ParentId != null && (account.Parent.Subscriber_ID__c == null || account.Parent.Subscriber_ID__c == ''))
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.WARNING, 'The parent Account needs to have a Subscriber ID before any child Accounts');
            ApexPages.addMessage(errorMessage);
            isEligible = false;
            return null;
        }
        return null;
    }

    public PageReference updateAccountAndContactData()
    {
        try 
        {            
            if (numberBusinessContactSelected == 1 && numberBillingContactSelected == 1)
            {
                fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
                billingContact = null;
                businessContact = null;                
                uow.registerDirty(account);   
                uow.registerDirty(opp);

                for(Contact c : contacts)
                {                    
                    if (c.Contact_Role_Multi__c != null && c.Contact_Role_Multi__c.contains('Business Contact'))
                    {                                        
                        if (businessContactRole != null) 
                        {
                            uow.registerDirty(businessContactRole);                        
                        }
                        else 
                        {
                            businessContactRole = new OpportunityContactRole();                                                                                        
                            businessContactRole.OpportunityId = this.opportunityId;                        
                            businessContactRole.Role = 'Business Contact';
                            uow.registerNew(businessContactRole);                                            
                        }
                        
                        if (c.Contact_Role_Multi__c.contains('Billing Contact'))
                        {
                            c.OtherStreet = account.ShippingStreet;
                            c.OtherCity = account.ShippingCity;
                            c.OtherStateCode = account.ShippingStateCode;
                            c.OtherCountryCode = account.ShippingCountryCode;
                            c.OtherPostalCode = account.ShippingPostalCode;    
                        }
                        else
                        {
                            c.MailingStreet = account.ShippingStreet;
                            c.MailingCity = account.ShippingCity;
                            c.MailingStateCode = account.ShippingStateCode;
                            c.MailingCountryCode = account.ShippingCountryCode;
                            c.MailingPostalCode = account.ShippingPostalCode;
                        }
                        uow.registerRelationship(businessContactRole, Schema.OpportunityContactRole.ContactId, c); 
                        businessContact = c;
                    }
                    
                    if (c.Contact_Role_Multi__c != null && c.Contact_Role_Multi__c.contains('Billing Contact'))
                    {                                                            
                        if (billingContactRole != null) 
                        {                           
                            uow.registerDirty(billingContactRole);
                        }
                        else 
                        {
                            billingContactRole = new OpportunityContactRole();                                                                                        
                            billingContactRole.OpportunityId = this.opportunityId;                        
                            billingContactRole.Role = 'Billing Contact';
                            uow.registerNew(billingContactRole);
                        }
                        c.MailingStreet = account.BillingStreet;
                        c.MailingCity = account.BillingCity;
                        c.MailingStateCode = account.BillingStateCode;
                        c.MailingCountryCode = account.BillingCountryCode;
                        c.MailingPostalCode = account.BillingPostalCode;                        
                        uow.registerRelationship(billingContactRole, Schema.OpportunityContactRole.ContactId, c); 
                        billingContact = c;                  
                    }    

                    if (c.Id == null) uow.registerNew(c); 
                    else uow.registerDirty(c);                                 

                }
                
                uow.commitWork();            

                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'Account and Contacts Updated Successfully.');
                ApexPages.addMessage(errorMessage); 
                return null; 
            }
            else
            {
                String message = '';
                if (numberBusinessContactSelected > 1) message = 'There can not be more than 1 Business Contact <br/>';
                if (numberBillingContactSelected > 1) message += 'There can not be more than 1 Billing Contact <br/>';                
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, message);
                ApexPages.addMessage(errorMessage);                 
                return null; 
            }
        } 
        catch (Exception e) 
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'The following error occurred: ' + e);
            ApexPages.addMessage(errorMessage);  
            return null;
        }
    }

    public PageReference getSubscriberId_PendingBilling()
    {
        try 
        { 
            return getSubscriberId(false, false);
        } 
        catch (Exception e) 
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'The following error occurred: ' + e);
            ApexPages.addMessage(errorMessage);  
            return null;
        }
    }

    public PageReference getSubscriberId_NonBilling()
    {
        try 
        { 
            return getSubscriberId(false, true);
        } 
        catch (Exception e) 
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'The following error occurred: ' + e);
            ApexPages.addMessage(errorMessage);  
            return null;
        }
    }

    public PageReference getSubscriberId_ClosedWon()
    {
        try 
        { 
            return getSubscriberId(true, true);
        } 
        catch (Exception e) 
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'The following error occurred: ' + e);
            ApexPages.addMessage(errorMessage);  
            return null;
        }
    }

    public PageReference getSubscriberId(Boolean closeOpp, Boolean syncIntacct) 
    {
        try 
        {     
            if(validateRequiredData() && numberBusinessContactSelected == 1 && numberBillingContactSelected == 1)
            {
                fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
                AppAdminAPIClassNew.syncOpportunityAppAdmin(new Set<Id>{ opportunityId }, closeOpp, syncIntacct, uow);
                uow.commitWork(); 

                account = ((Account[]) AccountsSelector.newInstance().selectByIdWithParentAccount(new Set<Id>{ opp.AccountId }))[0];        
                if (account.Subscriber_Id__c != null)
                {
                    opp.Contract_Signed__c = true;
                    if (!closeOpp && !syncIntacct) opp.StageName = 'Closed Won - Pending Billing';
                    update opp;

                    PageReference pageRef = new PageReference('/' + opportunityId);
                    pageRef.setRedirect(true);
                    return pageRef; 
                }
                else 
                {
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'The following error occurred:<br/> <br/><a href=\"/' + opportunityId +'#'+ opportunityId +'_00Ni000000DPQOv_target\" >View errors</a>');
                    ApexPages.addMessage(errorMessage);  
                    return null; 
                }                        
            }
            else
            {
                String message = '';
                if (numberBusinessContactSelected > 1) message = 'There can not be more than 1 Business Contact <br/>';
                if (numberBillingContactSelected > 1) message += 'There can not be more than 1 Billing Contact <br/>';
                
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Required information is missing on the Account or Contacts. <br/>' + message + (validationMessage != null ? validationMessage : ''));
                ApexPages.addMessage(errorMessage);  
                return null;
            }        
        } 
        catch (Exception e) 
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'The following error occurred: ' + e);
            ApexPages.addMessage(errorMessage);  
            return null;
        }
    }

    public Boolean validateRequiredData()
    {        
        if( opp.RecurSoft__Contract_Signed_Date__c != null &&
            (account.Industry != null && 
                account.BillingStreet != null && 
                account.BillingCity != null && 
                account.BillingStateCode != null && 
                account.BillingCountryCode != null && 
                account.BillingPostalCode != null) && 
                (businessContact != null && 
                    businessContact.FirstName != null && 
                    businessContact.LastName != null && 
                    businessContact.Email != null && 
                    businessContact.Phone != null) && 
                (billingContact != null && 
                    billingContact.FirstName != null && 
                    billingContact.LastName != null && 
                    billingContact.Email != null && 
                    billingContact.Phone != null)) return true;
        else
        {
            validationMessage = '';
            if (opp.RecurSoft__Contract_Signed_Date__c == null) validationMessage += 'Contract signed date required. <br/>';
            if (account.Industry == null) validationMessage += 'Vertical required. <br/>';
            if (account.BillingStreet == null) validationMessage += 'Account Billing Street required. <br/>';
            if (account.BillingCity == null) validationMessage += 'Account Billing City required. <br/>';
            if (account.BillingStateCode == null) validationMessage += 'Account Billing State required. <br/>';
            if (account.BillingCountryCode  == null) validationMessage += 'Account Billing Country required. <br/>';
            if (account.BillingPostalCode == null) validationMessage += 'Account Billing Postal Code required. <br/>';
            if (businessContact == null) validationMessage += 'Business Contact required. <br/>';
            if (businessContact != null && businessContact.FirstName == null) validationMessage += 'Business Contact First Name required. <br/>';
            if (businessContact != null && businessContact.LastName == null) validationMessage += 'Business Contact Last Name required. <br/>';
            if (businessContact != null && businessContact.Email == null) validationMessage += 'Business Contact Email required. <br/>';
            if (businessContact != null && businessContact.Phone == null) validationMessage += 'Business Contact Phone required. <br/>';
            if (billingContact == null) validationMessage += 'Business Contact required. <br/>';
            if (billingContact != null && billingContact.FirstName == null) validationMessage += 'Billing Contact First Name required. <br/>';
            if (billingContact != null && billingContact.LastName == null) validationMessage += 'Billing Contact Last Name required. <br/>';
            if (billingContact != null && billingContact.Email == null) validationMessage += 'Billing Contact Email required. <br/>';
            if (billingContact != null && billingContact.Phone == null) validationMessage += 'Billing Contact Phone required. <br/>';
            return false; 
        }
    }

    public void addContactRow()
    {
       Contact newContact1 = new Contact();
       newContact1.AccountId = account.Id;
       contacts.add(newContact1);       
    }
}