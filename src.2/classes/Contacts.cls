public class Contacts extends fflib_SObjectDomain 
{
    public Set<String> contactsDistGroup;
    public Set<String> createCI;
    public Set<Id> clearDemoTaskDate;

    public Contacts(Contact[] contacts) 
    {
        super(contacts);    
        Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Contacts(sObjectList);
        }
    }

    public override void onBeforeInsert()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Contact c : (Contact[]) Records) 
        {
            this.validateCountryByAreaCode(c, null);
            this.createNewAccount(c, uow);
        }

        uow.commitWork();
    }

    public override void onAfterInsert()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Contact c : (Contact[]) Records) 
        {
            this.createCampaignInfluence(c, null);
            this.processDistributionGroup(c, null);
            this.createDemoTask(c, null, uow);
        }

        if(contactsDistGroup != null && 
            !contactsDistGroup.isEmpty()) SRUtilities.scheduleAsync(contactsDistGroup, 'Process_Dist_Group', uow);

        if(createCI != null && 
            !createCI.isEmpty()) SRUtilities.scheduleAsync(createCI, 'Create_CI', uow);
        
        if(clearDemoTaskDate != null && 
            !clearDemoTaskDate.isEmpty()) ContactsService.clearDemoTaskDate(clearDemoTaskDate);

        uow.commitWork();
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Contact c : (Contact[]) Records) 
        {
            Contact existingContact = (Contact) existingRecords.get(c.Id);

            this.validateContactOwnerChange(c, existingContact);
            this.validateCountryByAreaCode(c, existingContact);
            this.createNewAccount(c, uow);
            this.createDemoTask(c, existingContact, uow);
            this.createCampaignInfluence(c, existingContact);
            this.processDistributionGroup(c, existingContact);
        }

        if(contactsDistGroup != null && 
            !contactsDistGroup.isEmpty()) SRUtilities.scheduleAsync(contactsDistGroup, 'Process_Dist_Group', uow);

        if(createCI != null && 
            !createCI.isEmpty()) SRUtilities.scheduleAsync(createCI, 'Create_CI', uow);

        uow.commitWork();
    }

    public void createCampaignInfluence(Contact c, Contact existingContact)
    {
        if(c.CampaignId__c == null) return;
        if(existingContact != null &&
            existingContact.CampaignId__c == c.CampaignId__c) return;

        Id campaignId = c.CampaignId__c InstanceOf Id ? c.CampaignId__c : null;
        if(createCI == null) createCI = new Set<String>();
        if(campaignId != null) createCI.add(c.Id + '::' + campaignId + ':' + UserInfo.getUserId());
    }

    public void createNewAccount(Contact c, fflib_SObjectUnitOfWork uow)
    {
        if(c.AccountId != null) return;

        Account account = new Account(Name = c.FirstName + ' ' + c.LastName,
            RecordTypeId = SRUtilities.getRecordTypeMap('Account').get('Account').getRecordTypeId(),
            Phone = c.Phone,
            BillingStreet = c.MailingStreet,
            BillingCity = c.MailingCity,
            //BillingState = c.MailingState, removed because it was failing validations
            BillingPostalCode = c.MailingPostalCode,
            BillingCountry = c.MailingCountry,
            Description = 'Account Auto-Created',
            Industry = c.Vertical__c == null ? 'Dental' : c.Vertical__c,
            //Sub_Vertical__c = c.Sub_Vertical__c == null ? null : c.Sub_Vertical__c, removed because it was failing validations
            Number_of_Locations__c = c.Number_of_Locations__c,
            Number_of_Providers__c = c.Number_of_Providers__c);
        uow.registerNew(account);
        uow.registerRelationship(c, Schema.Contact.AccountId, account);
    }

    public void createDemoTask(Contact c, Contact existingContact, fflib_SObjectUnitOfWork uow)
    {
        if(existingContact != null &&
            existingContact.Demo_Scheduled_Date_Text__c == c.Demo_Scheduled_Date_Text__c &&
            existingContact.Demo_Scheduled_Date__c == c.Demo_Scheduled_Date__c) return;
        if(c.Demo_Scheduled_Date__c == null &&
            c.Demo_Scheduled_Date_Text__c == null) return;

        //Boolean is workaround for Datetime parse not working correctly
        Boolean isText = c.Demo_Scheduled_Date_Text__c == null ? false : true;
        String subject = isText ? Datetime.valueOfGmt(c.Demo_Scheduled_Date_Text__c).format('MM/dd/yyyy h:mm a','America/Denver') : c.Demo_Scheduled_Date__c.format('MM/dd/yyyy h:mm a','America/Denver');

        Task t = new Task(Subject = 'Demo Scheduled with ' + c.FirstName + ' - ' + subject,
            ADR_Set__c = true,
            ActivityDate = Date.valueOf(isText ? Datetime.valueOfGmt(c.Demo_Scheduled_Date_Text__c) : c.Demo_Scheduled_Date__c),
            Activity_Type__c = 'Phone Demo',
            Activity_Results__c = 'Future Event',
            Status = 'Scheduled',
            Due_Time__c = isText ? Datetime.valueOfGmt(c.Demo_Scheduled_Date_Text__c) : c.Demo_Scheduled_Date__c,
            WhoId = c.Id,
            WhatId = c.AccountId);
        uow.registerNew(t);
    }

    public void processDistributionGroup(Contact c, Contact existingContact)
    {
        if(c.DistGroup__c == null && c.Distribution_Group__c == null) return;
        if(existingContact != null &&
            existingContact.DistGroup__c == c.DistGroup__c && 
            existingContact.Distribution_Group__c == c.Distribution_Group__c) return;

        Id distGroupId = c.Distribution_Group__c != null ? c.Distribution_Group__c : c.DistGroup__c InstanceOf Id ? c.DistGroup__c : null;
        if(contactsDistGroup == null) contactsDistGroup = new Set<String>(); 
        if(distGroupId != null) contactsDistGroup.add(c.Id + '::' + distGroupId + ':' + UserInfo.getUserId());
    }

    public void validateCountryByAreaCode(Contact c, Contact existingContact)
    {
        if(existingContact != null &&
            existingContact.Phone == c.Phone && 
            existingContact.MailingCountryCode == c.MailingCountryCode) return;

        AreaCodes areaCodes = new AreaCodes();
        String msg = 'The phone area code does not belong to the selected country. Please confirm that this is correct.';

        Boolean requiresValidation = areaCodes.validateCountryByAreaCode(c.Phone, c.MailingCountryCode);

        if(requiresValidation)
        {
            c.rrpu__Alert_Message__c = c.rrpu__Alert_Message__c != null && !c.rrpu__Alert_Message__c.contains(msg) ? 
                c.rrpu__Alert_Message__c + '\n' + msg : 
                c.rrpu__Alert_Message__c == null ?
                    msg : c.rrpu__Alert_Message__c;
        }
        else
        {
            c.rrpu__Alert_Message__c = c.rrpu__Alert_Message__c != null && c.rrpu__Alert_Message__c.contains(msg) ? 
                c.rrpu__Alert_Message__c.replace(msg,'') : c.rrpu__Alert_Message__c;
        }
    }

    public void validateContactOwnerChange(Contact c, Contact existingContact)
    {
        if(System.isBatch()) return;
        if(existingContact == null) return;
        if(existingContact.OwnerId == c.OwnerId ||
                existingContact.OwnerId == SR_Default_Values__c.getInstance('jennyPoolUserId').Value__c) return;

        if (SR_Default_Values__c.getInstance('noStealingProfiles').Value__c.contains(String.valueOf(UserInfo.getProfileId()) ) )
            c.addError(SR_Default_Values__c.getInstance('contactChangeOwnerErrorMessage').Value__c);
    }
}