public with sharing class SyncWithIntacctAndClose_Controller 
{    
	private final Id opportunityId;
    public Opportunity opp { get; set; }
    public Account billingAccount { get; set; }
    public Contact billingContact { get; set; }
    public Contact shippingContact { get; set; }
    public Boolean isEligible { get; set; }
    private static final String STAGE_CLOSED_WON = 'Closed Won';

    public SyncWithIntacctAndClose_Controller(ApexPages.StandardController stdController) 
    {
        this.opportunityId = stdController.getId();
        
        opp = ((Opportunity[]) OpportunitiesSelector.newInstance().selectSObjectsById(new Set<Id>{ this.opportunityId }))[0];
        
        if(opp.RecurSoft__Bill_to_Account__c != null)
        {
            billingAccount = ((Account[]) AccountsSelector.newInstance().selectByIdWithParentAccount(new Set<Id>{ opp.RecurSoft__Bill_to_Account__c }))[0];
        }
        else
        {
            billingAccount = new Account();
        }
    
        if(opp.RecurSoft__Billing_Contact__c != null)
        {
            billingContact = ((Contact[]) ContactsSelector.newInstance().selectSObjectsById(new Set<Id>{ opp.RecurSoft__Billing_Contact__c }))[0];
        }
        else 
        {
            billingContact = new Contact();
        }
        
        if(opp.RecurSoft__Shipping_Contact__c != null)
        {
            shippingContact = ((Contact[]) ContactsSelector.newInstance().selectSObjectsById(new Set<Id>{ opp.RecurSoft__Shipping_Contact__c }))[0];
        }
        else 
        {
            shippingContact = new Contact();
        }            
    }

    public PageReference updateAccountAndContactData()
    {
        try 
        {
            fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            
            if(opp.RecurSoft__Bill_to_Account__c == null) 
            {
                uow.registerNew(billingAccount);
                uow.registerRelationship(opp, Schema.Opportunity.RecurSoft__Bill_to_Account__c, billingAccount);
            }
            else 
            {
                uow.registerDirty(billingAccount);
            }
            
            if(opp.RecurSoft__Billing_Contact__c == null)
            {                                
                uow.registerNew(billingContact); 
                uow.registerRelationship(opp, Opportunity.RecurSoft__Billing_Contact__c, billingContact);                               
            } 
            else 
            {
                uow.registerDirty(billingContact);
            }

            if(opp.RecurSoft__Shipping_Contact__c == null) 
            {
                uow.registerNew(shippingContact);  
                uow.registerRelationship(opp, Opportunity.RecurSoft__Shipping_Contact__c, shippingContact);               
            }            
            else 
            {
                uow.registerDirty(shippingContact);
            }

            uow.registerDirty(opp);
            uow.commitWork();

            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'Account and Contacts Updated Successfully.');
            ApexPages.addMessage(errorMessage); 
            return null;            
        }
        catch (Exception e) 
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'The following error occurred: ' + e);
            ApexPages.addMessage(errorMessage); 
            return null;                                  
        } 
    }

    public PageReference syncWithIntacctAndClose() 
    {
        try 
        {
            if(validateRequiredData())
            {
                IntacctIntegrationSyncHandler intacctSyncHandler = new IntacctIntegrationSyncHandler(new Set<Id>{ opportunityId });
                intacctSyncHandler.startIntegrationSR();    

                PageReference pageRef = new PageReference('/' + opportunityId);
                pageRef.setRedirect(true);
                return pageRef;           
            }
            else
            {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Required information is missing on the Account or Contacts.');
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
        if((billingAccount.Name != null && 
                billingAccount.BillingStreet != null && 
                billingAccount.BillingCity != null && 
                billingAccount.BillingStateCode != null && 
                billingAccount.BillingCountryCode != null && 
                billingAccount.BillingPostalCode != null &&
                billingAccount.ShippingStreet != null && 
                billingAccount.ShippingCity != null && 
                billingAccount.ShippingStateCode != null &&
                billingAccount.ShippingCountryCode != null && 
                billingAccount.ShippingPostalCode != null) &&
            (billingContact.Name != null && 
                billingContact.Email != null && 
                billingContact.Phone != null && 
                billingContact.MailingStreet != null && 
                billingContact.MailingCity != null && 
                billingContact.MailingStateCode != null &&
                billingContact.MailingCountryCode != null && 
                billingContact.MailingPostalCode != null) &&
            (shippingContact.Name != null && 
                shippingContact.Email != null && 
                shippingContact.Phone != null && 
                shippingContact.MailingStreet != null && 
                shippingContact.MailingCity != null && 
                shippingContact.MailingStateCode != null &&
                shippingContact.MailingCountryCode != null && 
                shippingContact.MailingPostalCode != null)) return true;

        return false;
    }

    public PageReference validateIsEligible() 
    {        
        isEligible = true;
        if(opp.StageName == STAGE_CLOSED_WON)
        {                
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.WARNING, 'This Opportunity has already been closed.');
            ApexPages.addMessage(errorMessage);  
            isEligible = false;
            return null;                    
        }  

        if(billingAccount.Subscriber_ID__c == null || billingAccount.Subscriber_ID__c == '')
        {                
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.WARNING, 'The Bill to Account needs a Subscriber Id first.');
            ApexPages.addMessage(errorMessage);  
            isEligible = false;
            return null;                    
        }

        if(billingAccount.ParentId != null && (billingAccount.Parent.Subscriber_ID__c == null || billingAccount.Parent.Subscriber_ID__c == ''))
        {                
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.WARNING, 'The parent Account needs a Subscriber Id first.');
            ApexPages.addMessage(errorMessage);  
            isEligible = false;
            return null;                    
        }  

        return null;
    }

    public PageReference cancel()
    {
        PageReference pageRef = new PageReference('/' + opportunityId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}