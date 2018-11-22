public class OpportunitiesService 
{
    public static void createAmbassadorCommission(Set<Id> ids, fflib_SObjectUnitOfWork uow)
    {
        Opportunity[] opps = OpportunitiesSelector.newInstance().selectByIdWithAmbassadorContacts(ids);
        
        for(Opportunity o : opps)
        {
            JSONGenerator gen = JSON.createGenerator(true);    
            gen.writeStartObject();      
            gen.writeStringField('email', o.Referred_Contact__r.Email);
            gen.writeStringField('first_name', o.Referred_Contact__r.FirstName);
            gen.writeStringField('last_name', o.Referred_Contact__r.LastName);
            gen.writeNumberField('campaign_uid', 33710);
            gen.writeStringField('transaction_uid', o.Id);
            gen.writeStringField('short_code', o.Referred_Contact__r.Ambassador__Short_Code__c); 
            gen.writeStringField('auto_create', '1');
            gen.writeStringField('email_new_ambassador', '0');
            gen.writeStringField('add_to_group_id', '1');
            gen.writeEndObject();    
            String jsonString = gen.getAsString();
            
            Http http = new Http();
            HTTPResponse response = new HTTPResponse();
            HttpRequest req = new HttpRequest();            
            req.setEndpoint('https://getambassador.com/api/v2/solutionreach/03dae48d3d78060be224d6ff48c5d447/json/event/record/');
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');
            req.setBody(jsonString);
            req.setTimeout(12000);

            response = http.send(req);
            
            if(String.valueOf(response.getStatusCode()) == '200')
            {
                o.Ambassador_Commission_Created__c = true;
                uow.registerDirty(o);
            }            
        }          
    }

    public static void completeAmbassadorCommission(Set<Id> ids, fflib_SObjectUnitOfWork uow)
    {
        Opportunity[] opps = OpportunitiesSelector.newInstance().selectByIdWithAmbassadorContacts(ids);
        
        for(Opportunity o : opps)
        {
            JSONGenerator gen = JSON.createGenerator(true);    
            gen.writeStartObject();      
            gen.writeStringField('is_approved', '1');
            gen.writeStringField('transaction_uid', o.Id);
            gen.writeEndObject();    
            String jsonString = gen.getAsString();
            
            Http http = new Http();
            HTTPResponse response = new HTTPResponse();
            HttpRequest req = new HttpRequest();            
            req.setEndpoint('https://getambassador.com/api/v2/solutionreach/03dae48d3d78060be224d6ff48c5d447/json/commission/update/');
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');
            req.setBody(jsonString);
            req.setTimeout(12000);

            response = http.send(req);
            
            if(String.valueOf(response.getStatusCode()) == '200')
            {
                o.Ambassador_Commission_Paid__c = true;
                uow.registerDirty(o);
            }            
        }           
    }

    public static void addRevenueToADRSetTask(Set<Id> ids, fflib_SObjectUnitOfWork uow)
    {
        Opportunity[] opps = OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(ids);
        Map<Id, Task> accountToTaskMap = TasksSelector.newInstance().selectByOpportunityAccountId(opps);

        for(Opportunity o : opps)
        {
            if(!accountToTaskMap.containsKey(o.AccountId)) continue;
            addRevenueToADRSetTask(o, accountToTaskMap.get(o.AccountId), uow);
        } 
    }
    public static void addRevenueToADRSetTask(Opportunity o, Task t, fflib_SObjectUnitOfWork uow)
    {
        if(o.RecurSoft__Contract_Signed_Date__c.addDays(-60) < t.CreatedDate &&
            t.ADR_Set__c == true &&
            t.Activity_Results__c == 'Spoke with-')
        {
            t.ADR_Set_SR_Revenue__c = o.RecurSoft__Contract_Signed_Date__c < Date.newInstance(2017,7,1) ? o.SR_Monthly_Revenue__c : o.Monthly_Revenue__c;
            uow.registerDirty(t);
        }
    }

    public static void closeAddendum(Set<Id> ids, fflib_SObjectUnitOfWork uow)
    {
        Opportunity[] opps = OpportunitiesSelector.newInstance().selectByIdWithAddenda(ids);

        for(Opportunity o : opps)
        {
            if(o.Addenda__r.size() == 0 || o.Addenda__r == null) continue;
            closeAddendum(o, uow);
        } 
    }

    public static void closeAddendum(Opportunity o, fflib_SObjectUnitOfWork uow)
    {   
        for(Addendum__c a : o.Addenda__r)
        {
            a.Status__c = 'Closed';
            uow.registerDirty(a);
        }
    }

    public static void createAssetForClosedOpps(Set<Id> ids, fflib_SObjectUnitOfWork uow)
    {
        Opportunity[] opps = OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(ids);
        Map<Id, Account> acctMap = new Map<Id, Account>(AccountsSelector.newInstance().selectAccountByOpportunityWithAssets(opps));

        for(Opportunity o : opps)
        {
            createAssetForClosedOpps(o, acctMap.get(o.AccountId), uow);
        } 
    }

    public static void createAssetForClosedOpps(Opportunity o, Account acct, fflib_SObjectUnitOfWork uow) 
    {   
        Set<String> currentAssets = new Set<String>();
        Set<String> eligibleAssets = new Set<String>{'SR Platform','SR Reminders','Healthgrades','SR Schedule','SR Conversations','SR Smart Reviews','Provider'};
        String currentAssetName = '';
        String assetFamilyName = '';

        currentAssets.clear();

        if(acct.Assets.size() > 0) 
        {
            for(Asset a2 : acct.Assets) 
            {
                currentAssetName = a2.Product2.Family == 'Healthgrades' ? 'Healthgrades - ' + 
                    a2.Provider__r.Healthgrades_Id__c.replaceAll('(https?:\\/\\/)?(www\\.healthgrades\\.com\\/(\\w)+\\/)', '') : 
                    a2.Product2.Family;
                currentAssets.add(currentAssetName);
            }
        }

        for(OpportunityLineItem oppLi : o.OpportunityLineItems) 
        {
            if(oppLi.PricebookEntry.Product2.Family == null || !eligibleAssets.contains(oppLi.PricebookEntry.Product2.Family)) continue;

            assetFamilyName = oppLi.PricebookEntry.Product2.Family == 'Healthgrades' ? 'Healthgrades - ' + 
                oppLi.Provider__r.Healthgrades_Id__c.replaceAll('(https?:\\/\\/)?(www\\.healthgrades\\.com\\/(\\w)+\\/)', '') : 
                oppLi.PricebookEntry.Product2.Family;

            if(!currentAssets.contains(assetFamilyName)) 
            {
                Asset a = new Asset(AccountId = o.AccountId,
                    Name = o.Account.Subscriber_Id__c + ': ' + assetFamilyName,
                    Most_Recent_Pricebook__c = o.Pricebook2Id,
                    Price = oppLi.UnitPrice,
                    Product2Id = oppLi.PricebookEntry.Product2Id,
                    Quantity = oppLi.Quantity,
                    Original_Contract_Signed_Date__c = o.RecurSoft__Contract_Signed_Date__c,
                    Trial_End_Date__c = oppLi.Trial_End_Date__c,
                    Status = 'Active',
                    Provider__c = oppLi.Provider__c == null ? null : oppLi.Provider__c);

                uow.registerNew(a);

                //if(accountIdsToSyncToAppAdmin == null) accountIdsToSyncToAppAdmin = new Set<Id>();
                //accountIdsToSyncToAppAdmin.add(o.AccountId);
            }
        }
    }

    public static void newActivationCase(Set<Id> ids, fflib_SObjectUnitOfWork uow) 
    {
        Opportunity[] opps = OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(ids);
        Map<Id, Account> accountWithCasesMap = new Map<Id, Account>(AccountsSelector.newInstance().selectByOpportunityWithCases(opps));

        for(Opportunity o : opps)
        {
            newActivationCase(o, accountWithCasesMap.get(o.AccountId), uow);
        } 
    }

    public static void newActivationCase(Opportunity o, Account account, fflib_SObjectUnitOfWork uow) 
    {
        if(!o.Contract_Signed__c) return;

        String SRC_QUEUE_ID = SR_Default_Values__c.getValues('SRC Onboarding Queue').Value__c;
        String SRSR_QUEUE_ID = SR_Default_Values__c.getValues('SRSR Onboarding Queue').Value__c;
        String SRS_QUEUE_ID = SR_Default_Values__c.getValues('SRS Onboarding Queue').Value__c;
        String ROUND_ROBIN_ID = SR_Default_Values__c.getValues('Case Round Robin Owner ID').Value__c;
        Boolean hasSR = false;
        Boolean hasSRR = false;
        Boolean hasSRS = false;
        Boolean hasSRC = false;
        Boolean hasSRSR = false;
        Boolean hasSRcase = false;
        Boolean hasSRRcase = false;
        Boolean hasSRScase = false;
        Boolean hasSRCcase = false;
        Boolean hasSRSRcase = false;
        Boolean hasHG = false;
        Set<Id> providerIds = new Set<Id>();

        Boolean isMajorMultiAccount = o.Account.RecordTypeId == SRUtilities.getRecordTypeId('Account', 'Major Account') ||
            o.Account.RecordTypeId == SRUtilities.getRecordTypeId('Account', 'Child Major Account') ||
            o.Account.RecordTypeId == SRUtilities.getRecordTypeId('Account', 'Multi-Location Account') ||
            o.Account.RecordTypeId == SRUtilities.getRecordTypeId('Account', 'Child Multi-Location Account');
                
        for(OpportunityLineItem oppLi : o.OpportunityLineItems) 
        {
            if(oppLi.PricebookEntry.Product2.Family == 'SR Platform') hasSR = true;
            if(oppLi.PricebookEntry.Product2.Family == 'SR Reminders') hasSRR = true;
            if(oppLi.PricebookEntry.Product2.Family == 'SR Schedule') hasSRS = true;
            if(oppLi.PricebookEntry.Product2.Family == 'SR Conversations') hasSRC = true;
            if(oppLi.PricebookEntry.Product2.Family == 'SR Smart Reviews') hasSRSR = true;
            if(oppLi.PricebookEntry.Product2.Family == 'Healthgrades') 
            {
                hasHG = true;
                providerIds.add(oppLi.Provider__c);
            }
        }

        for(Case c : account.Cases)
        {
            if(c.Subject == null) continue;
            if(c.Subject == 'Activation case for ' + o.Account.Name &&
                c.RecordTypeId == SRUtilities.getRecordTypeId('Case','Activation') &&
                c.Status == 'New') hasSRcase = true;
            if(c.Subject == 'SRC + Reminders Implementation' &&
                c.RecordTypeId == SRUtilities.getRecordTypeId('Case','Activation') &&
                c.Status == 'New') hasSRRcase = true;
            if(c.Subject == 'SR Schedule Implementation' &&
                c.RecordTypeId == SRUtilities.getRecordTypeId('Case','Support') &&
                c.Status == 'New') hasSRScase = true;
            if(c.Subject == 'SR Conversations Implementation' &&
                c.RecordTypeId == SRUtilities.getRecordTypeId('Case','Support') &&
                c.Status == 'New') hasSRCcase = true;
            if(c.Subject == 'SR Smart Reviews Implementation' &&
                c.RecordTypeId == SRUtilities.getRecordTypeId('Case','Support') &&
                c.Status == 'New') hasSRSRcase = true;
            if(c.Subject.startsWith('Healthgrades Implementation') &&
                c.RecordTypeId == SRUtilities.getRecordTypeId('Case','Support') &&
                c.Status == 'New' &&
                c.Provider__c != null) providerIds.remove(c.Provider__c);
        }
            
        if(hasSR && !hasSRcase) 
        {
            uow.registerNew(OpportunitiesService.newCase(o, 'SR Platform', ROUND_ROBIN_ID));    
        } 

        if(hasSRR && !hasSRRcase) 
        {
            uow.registerNew(OpportunitiesService.newCase(o, 'SRC + Reminders', o.OwnerId));   
        } 

        if(hasSRS && !hasSRScase) 
        {
           uow.registerNew(OpportunitiesService.newCase(o, 'SR Schedule', hasSR ? ROUND_ROBIN_ID : isMajorMultiAccount ? o.Account.OwnerId : SRS_QUEUE_ID));
        }

        if(hasSRC && !hasSRCcase)
        {
            uow.registerNew(OpportunitiesService.newCase(o, 'SR Conversations', hasSR ? ROUND_ROBIN_ID : isMajorMultiAccount ? o.Account.OwnerId : SRC_QUEUE_ID));
        }

        if(hasSRSR && !hasSRSRcase)
        {
            uow.registerNew(OpportunitiesService.newCase(o, 'SR Smart Reviews', hasSR ? ROUND_ROBIN_ID : isMajorMultiAccount ? o.Account.OwnerId : SRSR_QUEUE_ID));
        }

        if(hasHG && providerIds.size() > 0)
        {
            ProvidersService.newHealthgradesCase(providerIds, uow);
        }
    }

    public static void setAccountBillingEmailFromBillToContact(Set<Id> ids, fflib_SObjectUnitOfWork uow)
    {
        Opportunity[] opps = OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(ids);

        for(Opportunity o : opps)
        {
            setAccountBillingEmailFromBillToContact(o, uow);
        } 
    }
    public static void setAccountBillingEmailFromBillToContact(Opportunity o, fflib_SObjectUnitOfWork uow)
    {
        if(o.RecurSoft__Billing_Contact__c == null) return;
        if(o.RecurSoft__Billing_Contact__r.Email == null) return;
        
        Account a = new Account(Id = o.AccountId,
            RecurSoft__Billing_Email__c = o.RecurSoft__Billing_Contact__r.Email);
        uow.registerDirty(a); 
    }

    public static void syncOpportunityOwners(Id ownerId, Opportunity[] opportunities, fflib_SObjectUnitOfWork uow)
    {
        for(Opportunity o : opportunities)
        {
            if(o.IsClosed) continue;
            if(o.OwnerId == ownerId) continue;
            
            o.OwnerId = ownerId;
            //uow.registerDirty(o);
        }
    }

    public static Case newCase(Opportunity o, String productName, Id ownerId)
    {
        return new Case(Subject = productName == 'SR Platform' ? 'Activation case for ' + o.Account.Name : productName + ' Implementation',
            AccountId = o.AccountId,
            Related_Opportunity__c = o.Id,
            ContactId = o.RecurSoft__Billing_Contact__c,
            RecordTypeId = SRUtilities.getRecordTypeId('Case','Activation'),
            Product__c = productName,
            Origin = 'Web',
            Status = 'New',
            Priority = 'Medium',
            Category__c = 'Training',
            Topics__c = 'General Training',
            OwnerId = ownerId);
    }

    public static void sendContractEmail(AsyncRequest__c ar)
    {
        Opportunity[] opps = OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(new Set<Id>{ar.Params__c});
        SR_Default_Values__c contractEmailTemplateID = SR_Default_Values__c.getValues('New Customer Contract Email Template');
        SR_Default_Values__c contractEmailTemplateIDNoSubId = SR_Default_Values__c.getValues('Contract Email Template No Sub ID');
        ContractEmailTemplate__c contractEmailTemplateID_Old = ContractEmailTemplate__c.getValues('Services');
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support@solutionreach.com'];
        String templateId = contractEmailTemplateID.Value__c;

        for(Opportunity o : opps)
        {
            if(o.RecordTypeId == SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business'))
            {
                templateId = contractEmailTemplateID.Value__c;

                if(o.Account.Subscriber_Id__c == null) 
                {
                    if(ar.Number_of_Attempts__c < 5) 
                    {
                        throw new SRUtilities.SRException('Account doesn\'t have a Subscriber ID');
                    }
                    else
                    {
                        templateId = contractEmailTemplateIDNoSubId.Value__c;
                    }
                }
            }
            else
            {
                templateId = contractEmailTemplateID_Old.TemplateID__c;
            }
            

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setEntityAttachments(new List<String>{ar.Attachment_Id__c});
            mail.setBccAddresses(new List<String>{'randy@solutionreach.com','applications@solutionreach.com'});
            mail.setUseSignature(false);
            mail.setTemplateId(templateId);
            mail.setOrgWideEmailAddressId(owea[0].Id);
            mail.setWhatId(o.AccountId);
            mail.setTargetObjectId(o.RecurSoft__Billing_Contact__c);
            if(!ar.RequestedEmail__c) mail.setTreatTargetObjectAsRecipient(false);
         
            if(!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    @future(callout=true)
    public static void generateAndAttachContractPdf(Id oppId, Boolean source, Boolean requestedEmail)
    {
        Opportunity[] opps = OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(new Set<Id>{ oppId });

        for(Opportunity o : opps)
        {
            Blob body;
            String fileName = o.Account.Name.replaceAll(' ', '_').replaceAll(',', '_').replaceAll('//', '_').replaceAll('/', '_') + 
                + '_Service_Agreement_' 
                + System.now().format('MM/dd/yyyy HH:mm:ss','America/Denver')
                + '.pdf';
        
            PageReference pdf = new PageReference('/apex/SRContractPDF');
            pdf.getParameters().put('id', o.Id);
            pdf.getParameters().put('source', source == true ? 'api' : '');
                    
            body = Test.isRunningTest() ? Blob.valueOf('Test') : pdf.getContent();

            Attachment attachment = new Attachment();
            attachment.ParentId = o.Id;
            attachment.Name = fileName;
            attachment.Body = body;
            Database.SaveResult sr = Database.insert(attachment, false);

            if(sr.isSuccess()) 
            {               
                AsyncRequest__c asyncRequest = new AsyncRequest__c(AsyncType__c = 'Contract_Email', 
                   Params__c = o.Id,
                   RequestedEmail__c = requestedEmail, 
                   Attachment_ID__c = sr.getId());
                insert asyncRequest; 
            } 
            else
            {
                throw new SRUtilities.SRException(sr.getErrors()[0].getMessage());
            }
        }
    }

    public static OpportunityLineItem addOpportunityLineItem(Opportunity o, PriceBookEntry pbEntry, Decimal q) 
    {
        OpportunityLineItem results = new OpportunityLineItem(OpportunityId = o.Id,
                                                                PricebookEntryId = pbEntry.Id,
                                                                Quantity = q,
                                                                UnitPrice = pbEntry.UnitPrice);

        return results;
    }
}