public class Opportunities extends fflib_SObjectDomain 
{
    //Related Data
    public Map<Id, Pricebook2> allPricebooksMap;
    public Map<Id, Decimal> stagingMap;
    public Map<Id, Decimal> pipelineMap;
    public static Map<Id, Opportunity> approvalStatements = new Map<Id, Opportunity>{};
    public Map<Id, Opportunity> withAccountsAndProducts;
    public String defaultPricebookId;
    public String defaultPricebookStage;
    public Map<String, Integer> stageOrderMap = new Map<String, Integer> {
            'Pre-Qualified' => 1,
            'Qualified' => 2,
            'Demo Scheduled' => 3,
            'Demo Completed' => 4,
            'Negotiation Review' => 5,
            'Proposal' => 5,
            'Legal' => 6,
            'Signatures' => 7,
            'Awaiting Account Info' => 8,
            'Awaiting Billing' => 9,
            'Closed Won' => 10,
            'Not Qualified' => 0,
            'Closed Lost' => 0
        };
    public String oppLimitErrorMessage = 'You have reached your limit for open Opportunities. Please review your pipeline and close an Opportunity ' +
        'before creating a new one. Also, please be aware that you are currently ineligible to receive Marketing and SDR demo requests.';

    //Async processing
    public Set<Id> accountBillingEmail;
    public Set<Id> addRevenueToADRSetTask;
    public Set<Id> createAssetForClosedOpps;
    public Set<String> createCI;
    public Set<Id> closeAddendum;
    public Map<String, Id> leadSourceToCampaignIdMap;
    public Set<Id> linkOppCI;
    public Set<Id> newActivationCase;
    public Stamp_Field_Mapping__c[] stampMappings;
    public Set<String> stampUpdates;
    public Set<Id> ambassadorCommissionCreate;
    public Set<Id> ambassadorCommissionComplete;
    public Set<String> syncOwnersGeneralPool;
    public Set<String> syncOwners;   
    public Set<Id> updateAllOppLisOnOpp;
    public Set<Id> resetApprovals;
    public Set<Id> setApprovals;
    public Set<Id> updateAllOpplisOnOppContractDates;
    public Set<Id> updateAllOpplisOnOppModifiedSubscriptions;
    public Set<Id> userLimits;
    public Set<Id> getSubscriberId;
    
    //Recursion control
    public static Boolean oppLisProcessed = false;

    public Opportunities(Opportunity[] opportunities) 
    {
        super(opportunities);
        Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Opportunities(sObjectList);
        }
    }

    public override void onBeforeInsert()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Opportunity o : (Opportunity[]) Records) 
        {
            this.setClosedDateOnClose(o, null);
            this.setContractDates(o, null);
            this.setDefaultPricebook(o, null);
            this.setPricebookDefaultValues(o, null);
            this.setSourceUser(o);
            this.setSRDateCreated(o);
            this.stampDemoScheduledStageDate(o, null);
            this.stampDemoCompletedStageDate(o, null);
        }

        uow.commitWork();
    }

    public override void onAfterInsert()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Opportunity o : (Opportunity[]) Records) 
        {
            //Synchronous processing
            this.validateOppLimit(o, null);
            this.addPackageProducts(o, null, uow);
            this.setActiveOpportunityOnAccount(o, null, uow);
            //Async processing
            this.createCampaignInfluence(o);
            this.processStampUpdates(o, null);            
            this.checkForSyncOwners(o, null);
            this.checkForAmbassadorCommissionCreate(o, null);
            this.checkForAmbassadorCommissionComplete(o, null);
            this.updateUserLimits(o, null, uow);
            if(linkOppCI == null) linkOppCI = new Set<Id>();
            linkOppCI.add(o.AccountId);
        }

        if(userLimits != null && 
            !userLimits.isEmpty()) SRUtilities.scheduleAsync(userLimits, 'User_Limits', uow);

        if(createCI != null && 
            !createCI.isEmpty()) SRUtilities.scheduleAsync(createCI, 'Create_CI', uow);

        if(stampUpdates != null && 
            !stampUpdates.isEmpty()) SRUtilities.scheduleAsync(stampUpdates, 'Stamp_Updates', uow);
        
        if(syncOwners != null && 
            !syncOwners.isEmpty()) SRUtilities.scheduleAsync(syncOwners, 'Sync_Owners', uow);

        if(ambassadorCommissionCreate != null && 
            !ambassadorCommissionCreate.isEmpty()) SRUtilities.scheduleAsync(ambassadorCommissionCreate, 'Ambassador_Create', uow);

        if(ambassadorCommissionComplete != null && 
            !ambassadorCommissionComplete.isEmpty()) SRUtilities.scheduleAsync(ambassadorCommissionComplete, 'Ambassador_Complete', uow);

        if(linkOppCI != null && 
            !linkOppCI.isEmpty()) SRUtilities.scheduleAsync(linkOppCI, 'Link_Opp_CI', uow);

        uow.commitWork();
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Opportunity o : (Opportunity[]) Records) 
        {
            Opportunity existingOpp = (Opportunity) existingRecords.get(o.Id);
            
            //Synchronous processing
            this.validateOppOwnerChange(o, existingOpp);
            this.setClosedDateOnClose(o, existingOpp);
            this.setContractDates(o, existingOpp);
            this.setDefaultPricebook(o, existingOpp);
            this.setPricebookDefaultValues(o, existingOpp); 
            this.stampDemoScheduledStageDate(o, existingOpp);
            this.stampDemoCompletedStageDate(o, existingOpp);
            this.stampStageBeforeClose(o, existingOpp); 
            //Async processing
            this.addRevenueToADRSetTask(o, existingOpp);
            this.checkApprovalCommentsRequired(o);
            this.checkForResetApprovals(o, existingOpp);
            this.checkForSetApprovals(o);            
            this.checkForSyncOwners(o, existingOpp);
            this.checkForOwnerToGeneralPool(o, existingOpp);
            this.closeAddendum(o, existingOpp); 
            this.createAssetForClosedOpps(o, existingOpp);
            this.newActivationCase(o, existingOpp);
            this.setAccountBillingEmailFromBillToContact(o, existingOpp);
            this.processStampUpdates(o, existingOpp);
        }

        if(addRevenueToADRSetTask != null && 
            !addRevenueToADRSetTask.isEmpty()) SRUtilities.scheduleAsync(addRevenueToADRSetTask, 'ADR_Task_Revenue', uow);

        if(!approvalStatements.isEmpty()) this.makeApprovalCommentsRequired();

        if(resetApprovals != null && 
            !resetApprovals.isEmpty()) SRUtilities.scheduleAsync(resetApprovals, 'Reset_Approvals', uow);

        if(setApprovals != null && 
            !setApprovals.isEmpty()) SRUtilities.scheduleAsync(setApprovals, 'Set_Approvals', uow);
        
        if(syncOwners != null && 
            !syncOwners.isEmpty()) SRUtilities.scheduleAsync(syncOwners, 'Sync_Owners', uow);

        if(syncOwnersGeneralPool != null && 
            !syncOwnersGeneralPool.isEmpty()) SRUtilities.scheduleAsync(syncOwnersGeneralPool, 'Sync_Owners', uow);
        
        if(closeAddendum != null && 
            !closeAddendum.isEmpty()) SRUtilities.scheduleAsync(closeAddendum, 'Close_Addendum', uow);

        if(createAssetForClosedOpps != null && 
            !createAssetForClosedOpps.isEmpty()) SRUtilities.scheduleAsync(createAssetForClosedOpps, 'Create_Asset', uow);

        if(newActivationCase != null && 
            !newActivationCase.isEmpty()) SRUtilities.scheduleAsync(newActivationCase, 'Activation_Case', uow);

        if(accountBillingEmail != null && 
            !accountBillingEmail.isEmpty()) SRUtilities.scheduleAsync(accountBillingEmail, 'Account_Billing_Email', uow);  

        if(stampUpdates != null && 
            !stampUpdates.isEmpty()) SRUtilities.scheduleAsync(stampUpdates, 'Stamp_Updates', uow);

        uow.commitWork();
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords)
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Opportunity o : (Opportunity[]) Records) 
        {
            Opportunity existingOpp = (Opportunity) existingRecords.get(o.Id);

            this.validateOppOwnerChange(o, existingOpp);
            this.validateOppLimit(o, existingOpp);
            this.addPackageProducts(o, existingOpp, uow);
            this.checkForOppLiUpdateNeededContractDates(o, existingOpp);
            this.checkForOppLiUpdateNeededModifiedSubscription(o, existingOpp);
            this.setActiveOpportunityOnAccount(o, existingOpp, uow);
            this.updateAPProductForNumberOfProviders(o, existingOpp, uow);
            this.updateUserLimits(o, existingOpp, uow);
            this.sendEmailChangeOwner(o, existingOpp, uow);
            this.checkForAmbassadorCommissionCreate(o, existingOpp);
            this.checkForAmbassadorCommissionComplete(o, existingOpp);
            this.getSubscriberId(o, existingOpp);
        }

        if(userLimits != null && 
            !userLimits.isEmpty()) SRUtilities.scheduleAsync(userLimits, 'User_Limits', uow);

        if(ambassadorCommissionComplete != null && 
            !ambassadorCommissionComplete.isEmpty()) SRUtilities.scheduleAsync(ambassadorCommissionComplete, 'Ambassador_Complete', uow);

        if(ambassadorCommissionCreate != null && 
            !ambassadorCommissionCreate.isEmpty()) SRUtilities.scheduleAsync(ambassadorCommissionCreate, 'Ambassador_Create', uow);

        if(getSubscriberId != null &&
            getSubscriberId.size() > 0 && 
            !System.isBatch() && 
            !System.isFuture() && 
            !FlowControl.opportunityAppAdminSyncRecursion) 
        {
            FlowControl.opportunityAppAdminSyncRecursion = true;
            AppAdminAPIClassNew.syncOpportunityAppAdmin(getSubscriberId, false);
        }

        if(updateAllOppLisOnOpp != null &&
            updateAllOppLisOnOpp.size() > 0 &&
            !oppLisProcessed) this.updateAllOppLisOnOpp(new Map<Id, Opportunity>((Opportunity[]) Records).keySet(), uow);

        uow.commitWork();
    }


    /*
        @What - Flags Opps to be sent for processing. Processing = Stamps the Opportunity revenue amount on any SDR set tasks.
        @Why - SDR reporting
        @When - Only process when a NPB Opp changes to Closed Won and the Monthly Revenue field is > 0
        @Tests - 
            1. NPB, Stage changed to Closed Won, Monthly Revenue > 0
            2. Not NPB, Stage changed to Closed Won, Monthly Revenue > 0
            3. NPB, Stage changed to Closed Won, Monthly Revenue = 0
            4. NPB, Stage NOT Closed Won, Monthly Revenue > 0
            5. NPB, Stage Closed Won, Monthly Revenue > 0, existingOpp = null
    */
    public void addRevenueToADRSetTask(Opportunity o, Opportunity existingOpp)
    {
        if(o.StageName != 'Closed Won') return;
        if(o.Monthly_Revenue__c <= 0) return;
        if(existingOpp != null && 
            existingOpp.StageName == o.StageName &&
            existingOpp.Monthly_Revenue__c == o.Monthly_Revenue__c) return;
        if(o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business')) return;

        if(addRevenueToADRSetTask == null) addRevenueToADRSetTask = new Set<Id>();
        addRevenueToADRSetTask.add(o.Id); 
    }
    
    public void addPackageProducts(Opportunity o, Opportunity existingOpp, fflib_SObjectUnitOfWork uow)
    {
        if(o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Enterprise New Business')) return;
        if(o.Pricebook2Id == null) return;
        if(existingOpp != null && existingOpp.Pricebook2Id == o.Pricebook2Id) return;

        if(withAccountsAndProducts == null) withAccountsAndProducts = new Map<Id, Opportunity>(OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(new Map<Id, Opportunity>((Opportunity[]) Records).keySet()));
        Opportunity oppWithAccountsAndProducts = withAccountsAndProducts.get(o.Id);
        if(oppWithAccountsAndProducts.HasOpportunityLineItem) return;
        
        if(allPricebooksMap == null) allPricebooksMap = new Map<Id, Pricebook2>(PricebooksSelector.newInstance().selectAllWithPricebookEntries());
        if(!allPricebooksMap.containsKey(o.Pricebook2Id)) return;
        Pricebook2 pricebook = allPricebooksMap.get(o.Pricebook2Id);

        for(PriceBookEntry pbEntry : pricebook.PriceBookEntries) 
        {
            if(pbEntry.Auto_Add__c) 
            {
                if(pbEntry.Product2.Family == 'SR Schedule' && 
                    !oppWithAccountsAndProducts.Account.Practice_Management_Software__r.Limelight_Available__c) continue;
                
                OpportunityLineItem newOppLi = OpportunitiesService.addOpportunityLineItem(o, pbEntry, pbEntry.Auto_Add_Quantity__c);

                if(pbEntry.Auto_Add_Free_Months__c > 0) 
                {
                    newOppLi.Number_of_Free_Months__c = pbEntry.Auto_Add_Free_Months__c;
                    newOppLi.Free_Month_Setting__c = pbEntry.Auto_Add_Free_Month_Setting__c;
                } 

                if(pbEntry.Auto_Add_Trial__c != null) newOppLi.Trial__c = pbEntry.Auto_Add_Trial__c;
                if(pbEntry.Auto_Add_Price__c != null) newOppLi.UnitPrice = pbEntry.Auto_Add_Price__c;
                uow.registerNew(newOppLi);  
            }
        }
    }
    
    public void checkApprovalCommentsRequired(Opportunity o)
    {
        if (o.Approval_Comment_Check__c == 'Requested')
        { 
          approvalStatements.put(o.Id, o);
          o.Approval_Comment_Check__c = null; 
        }
    }

    public void checkForResetApprovals(Opportunity o, Opportunity existingOpp)
    {
        if(existingOpp != null && 
            existingOpp.OwnerId == o.OwnerId) return;
        if(o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Add Product') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Enterprise New Business')) return;

        if(resetApprovals == null) resetApprovals = new Set<Id>();
        resetApprovals.add(o.Id);

        o.Approved_Term__c = 24;
    }

    public void checkForSetApprovals(Opportunity o)
    {
        if(!o.Set_Product_Approvals__c) return;

        if(setApprovals == null) setApprovals = new Set<Id>();
        setApprovals.add(o.Id);

        o.Set_Product_Approvals__c = false;
        o.Approved_Term__c = o.RecurSoft__Initial_Contract_Term__c;
    }

    public void checkForAmbassadorCommissionCreate(Opportunity o, Opportunity existingOpp)
    {
        if(existingOpp != null && 
            existingOpp.StageName == o.StageName && 
            existingOpp.Referred_Contact__c == o.Referred_Contact__c) return;
        if(o.Referred_Contact__c == null) return;         
        if(o.Ambassador_Commission_Created__c == true) return; 
        if(stageOrderMap.get(o.StageName) < stageOrderMap.get('Demo Scheduled')) return;
        if(ambassadorCommissionCreate == null) ambassadorCommissionCreate = new Set<Id>();        
        ambassadorCommissionCreate.add(o.Id);        
    }

    public void checkForAmbassadorCommissionComplete(Opportunity o, Opportunity existingOpp)
    {
        if(existingOpp != null && 
            existingOpp.StageName == o.StageName && 
            existingOpp.Referred_Contact__c == o.Referred_Contact__c) return;
        if(o.Referred_Contact__c == null) return;
        if(o.Ambassador_Commission_Paid__c == true) return; 
        if(stageOrderMap.get(o.StageName) < stageOrderMap.get('Demo Completed')) return;
        if(ambassadorCommissionComplete == null) ambassadorCommissionComplete = new Set<Id>();        
        ambassadorCommissionComplete.add(o.Id);        
    }
    

    public void checkForOwnerToGeneralPool(Opportunity o, Opportunity existingOpp)
    {           
        if(o.StageName != 'Closed Lost' && 
            o.StageName != 'Not Qualified') return;
        
        if(existingOpp != null && 
            existingOpp.StageName == o.StageName) return;
        
        if(o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Add Product') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Enterprise New Business')) return;

        if(withAccountsAndProducts == null) withAccountsAndProducts = new Map<Id, Opportunity>(OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(new Map<Id, Opportunity>((Opportunity[]) Records).keySet()));
        Opportunity oppWithAccountsAndProducts = withAccountsAndProducts.get(o.Id);
        if(oppWithAccountsAndProducts.Account.RecurSoft__Status__c == 'Active') return;

        if(syncOwnersGeneralPool == null) syncOwnersGeneralPool = new Set<String>();        
        syncOwnersGeneralPool.add(o.AccountId + ':' + SR_Default_Values__c.getInstance('jennyPoolUserId').Value__c);        
    }

    public void checkForSyncOwners(Opportunity o, Opportunity existingOpp)
    {
        if(o.IsClosed) return;
        if(existingOpp != null && 
            existingOpp.OwnerId == o.OwnerId) return;
        if(o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Add Product') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Enterprise New Business')) return;

        if(syncOwners == null) syncOwners = new Set<String>();
        syncOwners.add(o.AccountId + ':' + o.OwnerId);
    }

    public void checkForOppLiUpdateNeededContractDates(Opportunity o, Opportunity existingOpp)
    {
        if(existingOpp != null && 
            existingOpp.RecurSoft__Initial_Contract_Term__c == o.RecurSoft__Initial_Contract_Term__c &&
            existingOpp.RecurSoft__Contract_Signed_Date__c == o.RecurSoft__Contract_Signed_Date__c) return;

        if(o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Add Product') &&
            o.RecurSoft__Contract_Signed_Date__c == null) return;

        if(updateAllOppLisOnOpp == null) updateAllOppLisOnOpp = new Set<Id>();
        updateAllOppLisOnOpp.add(o.Id);

        if(updateAllOpplisOnOppContractDates == null) updateAllOpplisOnOppContractDates = new Set<Id>();
        updateAllOpplisOnOppContractDates.add(o.Id);
    }

    public void checkForOppLiUpdateNeededModifiedSubscription(Opportunity o, Opportunity existingOpp)
    {
        if(!o.IsClosed) return;
        if(existingOpp != null && 
            existingOpp.IsClosed) return;
        if(o.RecordTypeId != SRUtilities.getRecordTypeMap('Opportunity').get('Add-On Business').getRecordTypeId()) return;

        if(updateAllOppLisOnOpp == null) updateAllOppLisOnOpp = new Set<Id>();
        updateAllOppLisOnOpp.add(o.Id);

        if(updateAllOpplisOnOppModifiedSubscriptions == null) updateAllOpplisOnOppModifiedSubscriptions = new Set<Id>();
        updateAllOpplisOnOppModifiedSubscriptions.add(o.Id);
    }

    public void closeAddendum(Opportunity o, Opportunity existingOpp)
    {
        if(o.StageName != 'Closed Won') return;
        if(existingOpp != null && 
            existingOpp.StageName == o.StageName) return;
        if(o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Add-On Business')) return;
        
        if(closeAddendum == null) closeAddendum = new Set<Id>();
        closeAddendum.add(o.Id);
    }

    //Required by RecurSoft to Close Opp, actual subscription dates come from Opp Line Item
    public void setContractDates(Opportunity o, Opportunity existingOpp)
    {
        if(o.RecurSoft__Contract_Signed_Date__c == null) return;
        if(existingOpp != null && 
            existingOpp.RecurSoft__Initial_Contract_Term__c == o.RecurSoft__Initial_Contract_Term__c &&
            existingOpp.RecurSoft__Contract_Signed_Date__c == o.RecurSoft__Contract_Signed_Date__c) return;

        o.RecurSoft__Contract_Term_Start_Date__c = o.RecurSoft__Contract_Signed_Date__c;
        o.RecurSoft__Contract_Term_End_Date__c = o.RecurSoft__Contract_Signed_Date__c.addMonths(Integer.valueOf(o.RecurSoft__Initial_Contract_Term__c)).addDays(-1);
        o.RecurSoft__Total_Contract_Term_Text__c = String.valueOf(o.RecurSoft__Initial_Contract_Term__c);
    }

    public void createAssetForClosedOpps(Opportunity o, Opportunity existingOpp) 
    {   
        if(o.StageName != 'Closed Won') return;
        if(existingOpp != null && 
            existingOpp.StageName == o.StageName) return;
        if(o.RecordTypeId == SRUtilities.getRecordTypeMap('Opportunity').get('Renewal').getRecordTypeId() ||
            o.RecordTypeId == SRUtilities.getRecordTypeMap('Opportunity').get('Enterprise Renewal').getRecordTypeId() ||
            o.RecordTypeId == SRUtilities.getRecordTypeMap('Opportunity').get('Retention').getRecordTypeId() ||
            o.RecordTypeId == SRUtilities.getRecordTypeMap('Opportunity').get('Enterprise Retention').getRecordTypeId()) return;

        if(createAssetForClosedOpps == null) createAssetForClosedOpps = new Set<Id>();
        createAssetForClosedOpps.add(o.Id);
    }

    public void createCampaignInfluence(Opportunity o)
    {
        if(leadSourceToCampaignIdMap == null)
        {
            leadSourceToCampaignIdMap = new Map<String, Id>();
            String[] allMappings = SR_Default_Values__c.getValues('leadSourceToCampaignId').Value__c.split('::');
            for(String s : allMappings)
            {
                String[] split = s.split(':');
                if(split.size() > 1) leadSourceToCampaignIdMap.put(split[0], split[1]);
            }
        }

        if(!leadSourceToCampaignIdMap.containsKey(o.LeadSource)) return;
        if(leadSourceToCampaignIdMap.get(o.LeadSource) == null) return;
        if(o.RecordTypeId != SRUtilities.getRecordTypeMap('Opportunity').get('New Practice Business').getRecordTypeId() &&
            o.RecordTypeId != SRUtilities.getRecordTypeMap('Opportunity').get('Enterprise New Business').getRecordTypeId() &&
            o.RecordTypeId != SRUtilities.getRecordTypeMap('Opportunity').get('Add Product').getRecordTypeId() &&
            o.RecordTypeId != SRUtilities.getRecordTypeMap('Opportunity').get('Healthgrades').getRecordTypeId()) return;

        if(createCI == null) createCI = new Set<String>();
        createCI.add(o.Id + '::' + leadSourceToCampaignIdMap.get(o.LeadSource) + ':' + o.CreatedById);
    }  

    public void makeApprovalCommentsRequired()
    {
        Id[] processInstanceIds = new List<Id>{};
        
        for (Opportunity o : [SELECT 
                (SELECT ID
                    FROM ProcessInstances
                    ORDER BY CreatedDate DESC
                    LIMIT 1)
                FROM Opportunity
                WHERE ID IN :approvalStatements.keySet()])
        {
            processInstanceIds.add(o.ProcessInstances[0].Id);
        }
           
        for (ProcessInstance pi : [SELECT TargetObjectId,
                (SELECT Id, StepStatus, Comments 
                    FROM Steps
                    ORDER BY CreatedDate DESC
                    LIMIT 1 )
                FROM ProcessInstance
                WHERE Id IN :processInstanceIds
                ORDER BY CreatedDate DESC])
        {
            // If no comment exists, then prevent the object from saving.                 
            if((pi.Steps[0].Comments == null || 
               pi.Steps[0].Comments.trim().length() == 0))
            {
                approvalStatements.get(pi.TargetObjectId).addError(
                'Operation Cancelled: Please provide a reason for your approval / rejection');
            }
        }
    }

    public void newActivationCase(Opportunity o, Opportunity existingOpp) 
    {
        if(!o.Contract_Signed__c) return;
        if(existingOpp != null && 
            existingOpp.Contract_Signed__c) return;
        if(o.RecordTypeId != SRUtilities.getRecordTypeMap('Opportunity').get('New Practice Business').getRecordTypeId() &&
            o.RecordTypeId != SRUtilities.getRecordTypeMap('Opportunity').get('Enterprise New Business').getRecordTypeId() &&
            o.RecordTypeId != SRUtilities.getRecordTypeMap('Opportunity').get('Add Product').getRecordTypeId() &&
            o.RecordTypeId != SRUtilities.getRecordTypeMap('Opportunity').get('Healthgrades').getRecordTypeId()) return;

        if(newActivationCase == null) newActivationCase = new Set<Id>();
        newActivationCase.add(o.Id);
    }

    public void stampDemoScheduledStageDate(Opportunity o, Opportunity existingOpp)
    {
        if(o.Demo_Scheduled_Stage_Date__c != null) return;
        if(!stageOrderMap.containsKey(o.StageName)) return;
        if(stageOrderMap.get(o.StageName) < stageOrderMap.get('Demo Scheduled')) return;
        if(existingOpp != null && 
            existingOpp.StageName == o.StageName) return;
        o.Demo_Scheduled_Stage_Date__c = Datetime.now();
    }

    public void stampDemoCompletedStageDate(Opportunity o, Opportunity existingOpp)
    {
        if(o.Demo_Completed_Stage_Date__c != null) return;
        if(!stageOrderMap.containsKey(o.StageName)) return;
        if(stageOrderMap.get(o.StageName) < stageOrderMap.get('Demo Completed')) return;
        if(existingOpp != null && 
            existingOpp.StageName == o.StageName) return;
        o.Demo_Completed_Stage_Date__c = Datetime.now();
    }

    public void stampStageBeforeClose(Opportunity o, Opportunity existingOpp)
    {
        if(!o.IsClosed) return;
        if(existingOpp == null) return; 
        if(existingOpp.IsClosed) return;
        o.Stage_Before_Close__c = existingOpp.StageName;
    }

    public void processStampUpdates(Opportunity o, Opportunity existingOpp)
    {
        if(stampMappings == null) stampMappings = [SELECT Id, Field_Changed__c, Field_Changed_Value__c
            FROM Stamp_Field_Mapping__c 
            WHERE Stamp_To_Object__c = 'Opportunity'
            AND Active__c = true];
        
        String stampUpdateString = SRUtilities.processStampUpdates(o, existingOpp, stampMappings);

        if(stampUpdateString == null) return;
        if(stampUpdates == null) stampUpdates = new Set<String>(); 
        stampUpdates.add(stampUpdateString);
    }

    public void setAccountBillingEmailFromBillToContact(Opportunity o, Opportunity existingOpp)
    {
        if(o.RecurSoft__Billing_Contact__c == null) return;
        if(existingOpp != null && 
            existingOpp.RecurSoft__Billing_Contact__c == o.RecurSoft__Billing_Contact__c) return;

        if(accountBillingEmail == null) accountBillingEmail = new Set<Id>();
        accountBillingEmail.add(o.Id);
    }

    public void setActiveOpportunityOnAccount(Opportunity o, Opportunity existingOpp, fflib_SObjectUnitOfWork uow)
    {
        if(existingOpp == null && 
            o.IsClosed) return;
        if(existingOpp != null && 
            existingOpp.IsClosed == o.IsClosed) return;
        if(o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Enterprise New Business') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Add Product')) return;
        
        Account a = new Account(Id = o.AccountId,
            Active_Opportunity__c = o.IsClosed ? null : o.Id);
        uow.registerDirty(a); 
    }

    public void setClosedDateOnClose(Opportunity o, Opportunity existingOpp)
    {
        if(!o.IsClosed) return;
        if(existingOpp != null && 
            existingOpp.IsClosed) return;
        o.CloseDate = Date.today();
    }

    public void setDefaultPricebook(Opportunity o, Opportunity existingOpp)
    {
        if(o.Pricebook2Id != null) return;
        if(existingOpp != null && 
            existingOpp.StageName == o.StageName) return;
        if(defaultPricebookStage == null) defaultPricebookStage = SR_Default_Values__c.getValues('defaultPricebookStage').Value__c;
        if(stageOrderMap.get(o.StageName) < stageOrderMap.get(defaultPricebookStage)) return;
        if(o.RecordTypeId == SRUtilities.getRecordTypeId('Opportunity', 'Renewal')) return;
        if(defaultPricebookId == null) defaultPricebookId = SR_Default_Values__c.getValues('defaultPricebookId').Value__c;

        o.Pricebook2Id = defaultPriceBookId;
    }

    public void setPricebookDefaultValues(Opportunity o, Opportunity existingOpp)
    {
        if(o.Pricebook2Id == null) return;
        if(existingOpp != null && 
            existingOpp.Pricebook2Id == o.Pricebook2Id) return;
        if(o.RecordTypeId == SRUtilities.getRecordTypeId('Opportunity', 'Renewal') ||
            o.RecordTypeId == SRUtilities.getRecordTypeId('Opportunity', 'Add Product')) return;
        if(allPricebooksMap == null) allPricebooksMap = new Map<Id, Pricebook2>(PricebooksSelector.newInstance().selectAllWithPricebookEntries());
        if(!allPricebooksMap.containsKey(o.PriceBook2Id)) return;

        Pricebook2 pricebook = allPricebooksMap.get(o.Pricebook2Id);

        if(pricebook.Number_of_Providers_Included__c > 0) o.Number_of_Providers__c = pricebook.Number_of_Providers_Included__c;
        if(pricebook.Number_of_PRT_Included__c > 0) o.Number_of_PRT__c = pricebook.Number_of_PRT_Included__c;
        if(pricebook.Default_Term__c != null) o.RecurSoft__Initial_Contract_Term__c = pricebook.Default_Term__c;
    }

    public void setSRDateCreated(Opportunity o)
    {
        if(o.SR_Date_Created__c != null) return; 
        o.SR_Date_Created__c = Datetime.now();
    }  

    public void setSourceUser(Opportunity o)
    {
        if(System.isBatch() || System.isFuture()) return;
        if(o.Source_User__c != null) return; 
        o.Source_User__c = UserInfo.getUserId();
    }  

    public void updateAllOppLisOnOpp(Set<Id> ids, fflib_SObjectUnitOfWork uow)
    {
        oppLisProcessed = true;
        OpportunityLineItem[] oppLis = OpportunityLineItemsSelector.newInstance().selectByOpportunityIdWithAccountOpportunityProductPricebookEntry(ids);

        OpportunityLineItems opportunityLineItems = new OpportunityLineItems(oppLis);
        opportunityLineItems.updateAllOpplisOnOppContractDates = this.updateAllOpplisOnOppContractDates;
        opportunityLineItems.updateAllOpplisOnOppModifiedSubscriptions = this.updateAllOpplisOnOppModifiedSubscriptions;
        opportunityLineItems.updateAllOppLisOnOpp(oppLis, uow);
    }

    public void updateAPProductForNumberOfProviders(Opportunity o, Opportunity existingOpp, fflib_SObjectUnitOfWork uow) 
    {
        if(existingOpp != null && 
            existingOpp.Number_of_Providers__c == o.Number_of_Providers__c) return;
        if(o.RecordTypeId == SRUtilities.getRecordTypeId('Opportunity', 'Renewal')) return;
        
        if(allPricebooksMap == null) allPricebooksMap = new Map<Id, Pricebook2>(PricebooksSelector.newInstance().selectAllWithPricebookEntries());
        if(!allPricebooksMap.containsKey(o.PriceBook2Id)) return;
        if(allPricebooksMap.get(o.Pricebook2Id).PricebookEntries.isEmpty()) return;
        PriceBook2 pricebook = allPricebooksMap.get(o.Pricebook2Id);
        Decimal includedProviders = pricebook.Number_of_Providers_Included__c == null ? 0 : pricebook.Number_of_Providers_Included__c;
        if(o.Number_of_Providers__c == includedProviders) return;

        if(withAccountsAndProducts == null) withAccountsAndProducts = new Map<Id, Opportunity>(OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(new Map<Id, Opportunity>((Opportunity[]) Records).keySet()));
        Opportunity oppWithAccountsAndProducts = withAccountsAndProducts.get(o.Id);

        if(oppWithAccountsAndProducts.HasOpportunityLineItem) 
        {
            for(OpportunityLineItem oppLi : oppWithAccountsAndProducts.OpportunityLineItems) 
            {
                if(oppLi.PricebookEntry.Product2.ProductCode == '3052') uow.registerDeleted(oppLi);
            }
        } 

        if(o.Number_of_Providers__c > includedProviders) 
        {    
            for(PriceBookEntry pbEntry : pricebook.PricebookEntries) 
            {
                if(pbEntry.Product2.ProductCode == '3052') 
                {    
                    OpportunityLineItem newOppLi = OpportunitiesService.addOpportunityLineItem(o, pbEntry, o.Number_of_Providers__c - includedProviders);
                    uow.registerNew(newOppLi);
                }
            }
        } 
    }

    public void updatePRTProductForNumberOfPRT(Opportunity o, Opportunity existingOpp, fflib_SObjectUnitOfWork uow) 
    {
        if(existingOpp != null && 
            existingOpp.Number_of_PRT__c == o.Number_of_PRT__c) return;
        if(o.RecordTypeId == SRUtilities.getRecordTypeId('Opportunity', 'Renewal')) return;
        
        if(allPricebooksMap == null) allPricebooksMap = new Map<Id, Pricebook2>(PricebooksSelector.newInstance().selectAllWithPricebookEntries());
        if(!allPricebooksMap.containsKey(o.PriceBook2Id)) return;
        if(allPricebooksMap.get(o.Pricebook2Id).PricebookEntries.isEmpty()) return;
        PriceBook2 pricebook = allPricebooksMap.get(o.Pricebook2Id);
        Decimal includedPRT = pricebook.Number_of_PRT_Included__c == null ? 0 : pricebook.Number_of_PRT_Included__c;
        if(o.Number_of_PRT__c == includedPRT) return;

        if(withAccountsAndProducts == null) withAccountsAndProducts = new Map<Id, Opportunity>(OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(new Map<Id, Opportunity>((Opportunity[]) Records).keySet()));
        Opportunity oppWithAccountsAndProducts = withAccountsAndProducts.get(o.Id);

        if(o.HasOpportunityLineItem) 
        {
            for(OpportunityLineItem oppLi : o.OpportunityLineItems) 
            {
                if(oppLi.PricebookEntry.Product2.ProductCode == '3062') uow.registerDeleted(oppLi);
            }
        } 

        if(o.Number_of_PRT__c > includedPRT) 
        {    
            for(PriceBookEntry pbEntry : pricebook.PricebookEntries) 
            {
                if(pbEntry.Product2.ProductCode == '3062') 
                {    
                    OpportunityLineItem newOppLi = OpportunitiesService.addOpportunityLineItem(o, pbEntry, o.Number_of_PRT__c - includedPRT);
                    uow.registerNew(newOppLi);
                }
            }
        }  
    }

    public void validateOppLimitUpdate(Opportunity o, Opportunity existingOpp, fflib_SObjectUnitOfWork uow)
    {
        Boolean isPipelineChange = true;
        if(existingOpp != null && 
            existingOpp.OwnerId == o.OwnerId &&
            existingOpp.StageName == o.StageName &&
            o.IsClosed) isPipelineChange = false;
        System.debug(stageOrderMap);
        System.debug(o.StageName);
        System.debug(existingOpp);
        if(existingOpp != null &&
            (stageOrderMap.get(o.StageName) < stageOrderMap.get('Demo Scheduled') &&
            stageOrderMap.get(existingOpp.StageName) < stageOrderMap.get('Demo Scheduled'))) isPipelineChange = false;//||
            /*(stageOrderMap.get(o.StageName) >= stageOrderMap.get('Demo Scheduled') &&
            stageOrderMap.get(existingOpp.StageName) >= stageOrderMap.get('Demo Scheduled'))) isPipelineChange = false;*/
        if(o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Enterprise New Business') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Add Product')) return;

        Open_Opp_Limit__c oppLimit = Open_Opp_Limit__c.getInstance(o.OwnerId);

        if(stagingMap == null) stagingMap = OpportunitiesSelector.newInstance().selectOwnerStagingOpps((Opportunity[]) Records);
        if(pipelineMap == null) pipelineMap = OpportunitiesSelector.newInstance().selectOwnerPipelineOpps((Opportunity[]) Records);

        Decimal stagingOpps = stagingMap.containsKey(o.OwnerId) ? isPipelineChange ? stagingMap.get(o.OwnerId) + 1 : stagingMap.get(o.OwnerId) : 1;
        Decimal pipelineOpps = pipelineMap.containsKey(o.OwnerId) ? isPipelineChange ? pipelineMap.get(o.OwnerId) + 1 : pipelineMap.get(o.OwnerId) : 1;

        if(stagingOpps > oppLimit.Staging__c) o.addError(oppLimitErrorMessage);
        if(pipelineOpps > oppLimit.Pipeline__c) o.addError(oppLimitErrorMessage);

        if(stagingMap.get(o.OwnerId) == oppLimit.Staging__c && !o.Owner.AtStagingLimit__c) uow.registerDirty(new User(Id = o.OwnerId, AtStagingLimit__c = true));
        if(pipelineMap.get(o.OwnerId) == oppLimit.Pipeline__c && !o.Owner.AtPipelineLimit__c) uow.registerDirty(new User(Id = o.OwnerId, AtPipelineLimit__c = true));  
        if(stagingMap.get(o.OwnerId) < oppLimit.Staging__c && o.Owner.AtStagingLimit__c) uow.registerDirty(new User(Id = o.OwnerId, AtStagingLimit__c = false));
        if(pipelineMap.get(o.OwnerId) < oppLimit.Pipeline__c && o.Owner.AtPipelineLimit__c) uow.registerDirty(new User(Id = o.OwnerId, AtPipelineLimit__c = false));       
    }

    public void validateOppLimit(Opportunity o, Opportunity existingOpp)
    {
        if(o.IsClosed) return;
        if(existingOpp != null && 
            existingOpp.OwnerId == o.OwnerId &&
            existingOpp.StageName == o.StageName) return;

        if(existingOpp != null &&
            ((stageOrderMap.get(o.StageName) < stageOrderMap.get('Demo Scheduled') &&
            stageOrderMap.get(existingOpp.StageName) < stageOrderMap.get('Demo Scheduled')) ||
            (stageOrderMap.get(o.StageName) >= stageOrderMap.get('Demo Scheduled') &&
            stageOrderMap.get(existingOpp.StageName) >= stageOrderMap.get('Demo Scheduled')))) return;

        if(o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Enterprise New Business') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Add Product')) return;

        Open_Opp_Limit__c oppLimit = Open_Opp_Limit__c.getInstance(o.OwnerId);

        if(stagingMap == null) stagingMap = OpportunitiesSelector.newInstance().selectOwnerStagingOpps((Opportunity[]) Records);
        if(pipelineMap == null) pipelineMap = OpportunitiesSelector.newInstance().selectOwnerPipelineOpps((Opportunity[]) Records);

        if(stagingMap.containsKey(o.OwnerId) && 
            stagingMap.get(o.OwnerId) > oppLimit.Staging__c && 
            stageOrderMap.get(o.StageName) < stageOrderMap.get('Demo Scheduled')) o.addError(oppLimitErrorMessage);
        if(pipelineMap.containsKey(o.OwnerId) && 
            pipelineMap.get(o.OwnerId) > oppLimit.Pipeline__c &&
            stageOrderMap.get(o.StageName) >= stageOrderMap.get('Demo Scheduled')) o.addError(oppLimitErrorMessage);   
    }

    public void updateUserLimits(Opportunity o, Opportunity existingOpp, fflib_SObjectUnitOfWork uow)
    {         
        if(existingOpp != null && 
            existingOpp.OwnerId == o.OwnerId &&
            existingOpp.StageName == o.StageName) return;

        if(existingOpp != null &&
            ((stageOrderMap.get(o.StageName) < stageOrderMap.get('Demo Scheduled') &&
            stageOrderMap.get(existingOpp.StageName) < stageOrderMap.get('Demo Scheduled')) ||
            (stageOrderMap.get(o.StageName) >= stageOrderMap.get('Demo Scheduled') &&
            stageOrderMap.get(existingOpp.StageName) >= stageOrderMap.get('Demo Scheduled')))) return;
      
        if(o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Enterprise New Business') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Add Product')) return;

        if(userLimits == null) userLimits = new Set<Id>();
        userLimits.add(o.OwnerId);            
    }

    /*
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Map<Id, Decimal> stagingMap;
        Map<Id, Decimal> pipelineMap;
        User[] users = [SELECT Id, Name, AtStagingLimit__c, AtPipelineLimit__c, Profile.Name, IsActive FROM User WHERE UserType = 'Standard'];
        Map<Id, User> userIdMap = new Map<Id, User>(users);
        Set<Id> ids = userIdMap.keySet();

        for(User u : users)
        {
            Open_Opp_Limit__c oppLimit = Open_Opp_Limit__c.getInstance(u.Id);

            if(stagingMap == null)
            {
                stagingMap = new Map<Id, Decimal>();
                AggregateResult[] aggregateResults = Database.query('SELECT OwnerId, COUNT_DISTINCT(Id) staging ' +
                    'FROM Opportunity ' +
                    'WHERE IsClosed = false ' +
                    'AND StageName IN (\'Pre-Qualified\',\'Qualified\') ' +
                    'AND RecordType.Name IN (\'New Practice Business\',\'Add Product\',\'Enterprise New Business\') ' +
                    'AND OwnerId IN :ids ' +
                    'GROUP BY OwnerId');

                for(AggregateResult result :aggregateResults)
                {
                    stagingMap.put((Id) result.get('OwnerId'), (Decimal) result.get('staging'));
                }
            }

            if(pipelineMap == null) 
            {
                pipelineMap = new Map<Id, Decimal>();
                AggregateResult[] aggregateResults = Database.query('SELECT OwnerId, COUNT_DISTINCT(Id) pipeline ' +
                    'FROM Opportunity ' +
                    'WHERE IsClosed = false ' +
                    'AND StageName NOT IN (\'Pre-Qualified\',\'Qualified\') ' +
                    'AND RecordType.Name IN (\'New Practice Business\',\'Add Product\',\'Enterprise New Business\') ' +
                    'AND OwnerId IN :ids ' +
                    'GROUP BY OwnerId');

                for(AggregateResult result :aggregateResults)
                {
                    pipelineMap.put((Id) result.get('OwnerId'), (Decimal) result.get('pipeline'));
                }
            }

                System.debug('Name=>> ' + u.Name);
                System.debug('IsActive=>> ' + u.IsActive);
                System.debug('Profile=>> ' + u.Profile.Name);
                System.debug('StagingLimit=>> ' + oppLimit.Staging__c);
                System.debug('StagingActual=>> ' + stagingMap.get(u.Id));
                System.debug('AtStagingLimit=>> ' + u.AtStagingLimit__c);
                System.debug('PipelineLimit=>> ' + oppLimit.Pipeline__c);
                System.debug('PipelineActual=>> ' + pipelineMap.get(u.Id));
                System.debug('AtPipelineLimit=>> ' + u.AtPipelineLimit__c);
            
            Decimal stagingActual = stagingMap.get(u.Id) == null ? 0 : stagingMap.get(u.Id);
            Decimal pipelineActual = pipelineMap.get(u.Id) == null ? 0 : pipelineMap.get(u.Id);
            if(stagingActual >= oppLimit.Staging__c && !u.AtStagingLimit__c) System.debug('Update AtStagingLimit__c from false to true');
            if(pipelineActual >= oppLimit.Pipeline__c && !u.AtPipelineLimit__c) System.debug('Update AtPipelineLimit__c from false to true');
            if(stagingActual < oppLimit.Staging__c && u.AtStagingLimit__c) System.debug('Update AtStagingLimit__c from true to false');
            if(pipelineActual < oppLimit.Pipeline__c && u.AtPipelineLimit__c) System.debug('Update AtPipelineLimit__c from true to false');

            if(stagingActual >= oppLimit.Staging__c && !u.AtStagingLimit__c) u.AtStagingLimit__c = true;
            if(pipelineActual >= oppLimit.Pipeline__c && !u.AtPipelineLimit__c) u.AtPipelineLimit__c = true;  
            if(stagingActual < oppLimit.Staging__c && u.AtStagingLimit__c) u.AtStagingLimit__c = false;
            if(pipelineActual < oppLimit.Pipeline__c && u.AtPipelineLimit__c) u.AtPipelineLimit__c = false; 
            u.Limit_Staging_Opps__c = oppLimit.Staging__c;
            u.Limit_Pipeline_Opps__c = oppLimit.Pipeline__c;
            uow.registerDirty(u);
        }
        */
        

    public void validateOppOwnerChange(Opportunity o, Opportunity existingOpp)
    {
        if(System.isBatch()) return;
        if(existingOpp.IsClosed) return;
        if(existingOpp == null) return;
        if(existingOpp.OwnerId == UserInfo.getUserId() ||
                existingOpp.OwnerId == SR_Default_Values__c.getInstance('jennyPoolUserId').Value__c) return;

        if (SR_Default_Values__c.getInstance('noStealingProfiles').Value__c.contains(String.valueOf(UserInfo.getProfileId()) ) )
            o.addError(SR_Default_Values__c.getInstance('oppChangeOwnerErrorMessage').Value__c);
    }

    public void sendEmailChangeOwner(Opportunity o, Opportunity existingOpp, fflib_SObjectUnitOfWork uow)
    {
        if(existingOpp == null) return; 
        if(o.OwnerId == existingOpp.OwnerId) return;
        if(UserInfo.getUserId() == existingOpp.OwnerId) return;
        if(o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Enterprise New Business') &&
            o.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'Add Product')) return;

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSubject('Your Opportunity Was Reassigned');
        message.setPlainTextBody('The following Opportunity has been reassigned:\n' + o.Name + '\n' + 'https://solutionreach.lightning.force.com/lightning/r/Opportunity/' + o.Id + '\n' + 'Reassigned by: ' + UserInfo.getUserName());
        message.setSaveAsActivity(false);
        message.setTargetObjectId(existingOpp.OwnerId);
        message.setBccAddresses(new String[] { 'randy@solutionreach.com' }); 

        uow.registerEmail(message);
    }

    public void getSubscriberId(Opportunity o, Opportunity existingOpp)
    {
        if(existingOpp == null &&        
            existingOpp.StageName == o.StageName) return; 
        if(o.StageName != 'Closed Won - Pending Billing') return;
        
        if(getSubscriberId == null) getSubscriberId = new Set<Id>();
        getSubscriberId.add(o.Id);    
    }
}