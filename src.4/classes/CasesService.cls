/**
 * Created by mschetselaar on 8/21/2018.
 */
/*
  __  __       _   _   _                      _____      _          _            _
 |  \/  |     | | | | | |                    / ____|    | |        | |          | |
 | \  / | __ _| |_| |_| |__   _____      __ | (___   ___| |__   ___| |_ ___  ___| | __ _  __ _ _ __
 | |\/| |/ _` | __| __| '_ \ / _ \ \ /\ / /  \___ \ / __| '_ \ / _ \ __/ __|/ _ \ |/ _` |/ _` | '__|
 | |  | | (_| | |_| |_| | | |  __/\ V  V /   ____) | (__| | | |  __/ |_\__ \  __/ | (_| | (_| | |
 |_|  |_|\__,_|\__|\__|_| |_|\___| \_/\_/   |_____/ \___|_| |_|\___|\__|___/\___|_|\__,_|\__,_|_|

                                                                                                     
*/
public with sharing class CasesService
{
    public static void closeCancelledAccountsCases(List<Cancel_Request__c> cros, fflib_SObjectUnitOfWork uow)
    {
        Set<Id> acctIDs = new Set<Id>();
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        for(Cancel_Request__c cro : cros)
        {
            if(cro.Cancel_Month__c < cro.Asset__r.Current_Product_Subscription__r.RecurSoft__Contract_Term_Start_Date__c) continue;
            acctIds.add(cro.Opportunity__r.AccountId);
        }

        for(Case c : [SELECT Id, Status, Resolution__c, OwnerId FROM Case WHERE AccountId IN : acctIDs AND IsClosed = false AND RecordType.Name != 'Accounting' AND RecordType.Name != 'Cancel Request'])
        {
            if(c.OwnerId.getSObjectType() != User.SObjectType) continue;
            c.Status = 'Closed';
            c.Resolution__c = 'Wont Fix';
            uow.registerDirty(c);
            
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.subjectId = c.id;
            
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
            body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = 'Case closed because the Account has Cancelled';
    
            body.messageSegments.add(textSegment);
            input.body = body;
    
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
            batchInputs.add(batchInput);
        }
        
        if(!test.isRunningTest()) ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
    }

    public static void autoCloseSyncCases(List<Case> scope, fflib_SObjectUnitOfWork uow)
    {
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        
        for(Case c : scope) {
            if(c.OwnerId.getSObjectType() != User.SObjectType) continue;
            
            if(c.Sync_Case_Account__r.Admin_Last_Sync_Date__c != Date.today().addDays(-1)) continue;
            if(c.Sync_Case_Account__r.Admin_Sync_Received__c == false ) continue;
            
            c.Status = 'Closed';
            c.Resolution__c = 'Resumed';

            uow.registerDirty(c);
    
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.subjectId = c.id;
    
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
            body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = 'Case closed because the sync ran the previous day';
    
            body.messageSegments.add(textSegment);
            input.body = body;
    
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
            batchInputs.add(batchInput);
        }
    
        if(!test.isRunningTest()) ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);   
    }

    public static void processDistributionGroup(Map<Id, Id> caseIdToDistGroupId, fflib_SObjectUnitOfWork uow)
    {
        Case[] cases = (Case[]) CasesSelector.newInstance().selectSObjectsById(caseIdToDistGroupId.keySet());   
        
        Map<Id, Distribution_Group__c> distGroupMap = new Map<Id, Distribution_Group__c>(DistributionGroupsSelector.newInstance().selectById(new Set<Id>(caseIdToDistGroupId.values())));

        for(Case c : cases)
        {
            if(!caseIdToDistGroupId.keySet().contains(c.Id)) return;
            Id distGroupId = caseIdToDistGroupId.get(c.Id);
            
            Distribution_Group__c distGroup = distGroupMap.get(distGroupId);            
            c.Distribution_Group__c = null;
            uow.registerDirty(c);

            User user = DistributionGroupsService.getNextUserId(distGroup.Distribution_Group_Members__r, distGroup.Id, uow);

            if(c.OwnerId != user.Id)
            {               
                c.OwnerId = user.Id;
                uow.registerDirty(c);
            }

            createHistory(distGroup, user, c, uow);
        }
    }

    public static void createHistory(Distribution_Group__c distGroup, User user, Case c, fflib_SObjectUnitOfWork uow)
    {
        Distribution_Group_History__c history = new Distribution_Group_History__c(Name = distGroup.Name + String.valueOf(Datetime.now()),
            Description__c = user.AboutMe,
            Case__c = c.Id,         
            Distribution_Group__c = distGroup.Id,
            User__c = user.Id);
        uow.registerNew(history);
    }
    public static void chatCaseQueue(Map <Id, Case> cases, fflib_SObjectUnitOfWork uow)
    {
        Id csSupporQueue  = (Id) SR_Default_Values__c.getValues('CS Support Queue').Value__c;
        for(case c : cases.values())
        {
            c.OwnerId = csSupporQueue;
            uow.registerDirty(c);
        }

    }
}