global class AsyncMain implements Database.Batchable<sObject>, Database.AllowsCallouts 
{	
	global static final String TYPE_ACCOUNT_BILLING_EMAIL = 'Account_Billing_Email';
	global static final String TYPE_ACTIVATION_CASE = 'Activation_Case';
	global static final String TYPE_ADR_TASK_REVENUE = 'ADR_Task_Revenue';
	global static final String TYPE_APPADMIN_ASSETSYNC = 'AppAdmin_AssetSync';
	global static final String TYPE_APPADMIN_HGSYNC = 'AppAdmin_HGSync';
	global static final String TYPE_APPADMIN_OPPSYNC = 'AppAdmin_OppSync';
	global static final String TYPE_CLOSE_ADDENDUM = 'Close_Addendum';
	global static final String TYPE_CONTRACT_EMAIL = 'Contract_Email';
	global static final String TYPE_CREATE_ASSET = 'Create_Asset';
	global static final String TYPE_CREATE_CI = 'Create_CI';
	global static final String TYPE_DEMO_REQUEST_REASON = 'Demo_Request_Reason';
	global static final String TYPE_LINK_OPP_CI = 'Link_Opp_CI';
	global static final String TYPE_PROCESS_DIST_GROUP = 'Process_Dist_Group';
	global static final String TYPE_CASE_PROCESS_DIST_GROUP = 'Case_Process_Dist_Group';
	global static final String TYPE_PRODSUB_AFTERINSERT = 'ProdSub_AfterInsert';
	global static final String TYPE_PRODUCT_TERMS_ROLLUP = 'Product_Terms_Rollup';
	global static final String TYPE_RESET_APPROVALS = 'Reset_Approvals';
	global static final String TYPE_SET_APPROVALS = 'Set_Approvals';
	global static final String TYPE_STAMP_UPDATES = 'Stamp_Updates';
	global static final String TYPE_SYNC_RECORD_OWNERS = 'Sync_Owners';
	global static final String TYPE_AMBASSADOR_CREATE = 'Ambassador_Create';
	global static final String TYPE_AMBASSADOR_COMPLETE = 'Ambassador_Complete';
	global static final String TYPE_USER_LIMITS = 'User_Limits';
	private static Boolean batchRequested = false;
	private static Boolean schedulerRequested = false;

	global Database.Querylocator Start(Database.BatchableContext bc) 
	{
		return Database.getQueryLocator('SELECT Id, CreatedDate, AsyncType__c, Params__c, Number_of_Attempts__c, Error__c, Attachment_Id__c, RequestedEmail__c ' +
			'FROM AsyncRequest__c WHERE Number_of_Attempts__c <= 5 ORDER BY Priority__c, Number_of_Attempts__c LIMIT 50');
	}

	global void Execute(Database.BatchableContext BC, AsyncRequest__c[] scope) 
	{
		Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();
      	fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
      	SRUtilities.SRUnitOfWork sruow = new SRUtilities.SRUnitOfWork();
      	Map<AsyncRequest__c, Exception> errorMap = new Map<AsyncRequest__c, Exception>();

		for(AsyncRequest__c ar: scope) 
		{
			if(ar.Number_of_Attempts__c > 5) continue;

			try
			{
				if(ar.AsyncType__c == TYPE_ACCOUNT_BILLING_EMAIL)
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					OpportunitiesService.setAccountBillingEmailFromBillToContact(new Set<Id>(idsToProcess), uow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);	
				}

				if(ar.AsyncType__c == TYPE_ACTIVATION_CASE)
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					OpportunitiesService.newActivationCase(new Set<Id>(idsToProcess), uow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);	
				}

				if(ar.AsyncType__c == TYPE_ADR_TASK_REVENUE)
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					OpportunitiesService.addRevenueToADRSetTask(new Set<Id>(idsToProcess), uow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);	
				}

				if(ar.AsyncType__c == TYPE_APPADMIN_ASSETSYNC) 
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					AppAdminAPIClass.postAssetStatus(new Set<Id>(idsToProcess));
					mapDeleteSObject.put(ar.Id, ar);
				} 

				if(ar.AsyncType__c == TYPE_APPADMIN_HGSYNC) 
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					AppAdminAPIClass.postHealthgradesStatus(new Set<Id>(idsToProcess));
					mapDeleteSObject.put(ar.Id, ar);
				}

				if(ar.AsyncType__c == TYPE_APPADMIN_OPPSYNC) 
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					AppAdminAPIClass.syncOpportunityAppAdmin(new Set<Id>(idsToProcess));
					mapDeleteSObject.put(ar.Id, ar);
				} 

				if(ar.AsyncType__c == TYPE_CLOSE_ADDENDUM)
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					OpportunitiesService.closeAddendum(new Set<Id>(idsToProcess), uow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);	
				}

				if(ar.AsyncType__c == TYPE_CONTRACT_EMAIL)
				{
					OpportunitiesService.sendContractEmail(ar);
					mapDeleteSObject.put(ar.Id, ar);	
				}

				if(ar.AsyncType__c == TYPE_CREATE_ASSET)
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					OpportunitiesService.createAssetForClosedOpps(new Set<Id>(idsToProcess), uow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);	
				}

				if(ar.AsyncType__c == TYPE_CREATE_CI)
				{
					Map<Id, Id> idToCampaignId = new Map<Id, Id>();
					Map<Id, Id> idToUserId = new Map<Id, Id>();
					String[] idsToProcess = ar.Params__c.split(',');
					for(String s : idsToProcess)
					{
						String[] split = s.split('::');
						String[] split1 = split[1].split(':');
						idToCampaignId.put(split[0], split1[0]);
						if(split1.size() > 1) idToUserId.put(split[0], split1[1]);
					}

					if(new List<Id>(idToCampaignId.keySet())[0].getSObjectType().getDescribe().getName() == 'Contact') CampaignInfluencesService.createCIs(idToCampaignId, idToUserId, ar, uow);
					if(new List<Id>(idToCampaignId.keySet())[0].getSObjectType().getDescribe().getName() == 'Opportunity') CampaignInfluencesService.createCIsFromOpps(idToCampaignId, idToUserId, ar, uow);

					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);	
				} 	

				if(ar.AsyncType__c == TYPE_LINK_OPP_CI) 
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					CampaignInfluencesService.linkOppOnCIs(new Set<Id>(idsToProcess), uow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);
				} 

				if(ar.AsyncType__c == TYPE_PROCESS_DIST_GROUP)
				{
					Map<Id, Id> idToDistGroupId = new Map<Id, Id>();
					Map<Id, Id> idToUserId = new Map<Id, Id>();
					String[] idsToProcess = ar.Params__c.split(',');
					for(String s : idsToProcess)
					{
						String[] split = s.split('::');
						String[] split1 = split[1].split(':');
						idToDistGroupId.put(split[0], split1[0]);
						if(split1.size() > 1) idToUserId.put(split[0], split1[1]);
					}

					ContactsService.processDistributionGroup(idToDistGroupId, idToUserId, uow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);	
				}

				if(ar.AsyncType__c == TYPE_CASE_PROCESS_DIST_GROUP)
				{
					Map<Id, Id> idToDistGroupId = new Map<Id, Id>();
					Map<Id, Id> idToUserId = new Map<Id, Id>();
					String[] idsToProcess = ar.Params__c.split(',');
					for(String s : idsToProcess)
					{
						String[] split = s.split('::');
						String[] split1 = split[1].split(':');
						idToDistGroupId.put(split[0], split1[0]);
						if(split1.size() > 1) idToUserId.put(split[0], split1[1]);
					}

					CasesService.processDistributionGroup(idToDistGroupId, uow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);
				} 

				if(ar.AsyncType__c == TYPE_PRODSUB_AFTERINSERT) 
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					Set<Id> ids = new Set<Id>(idsToProcess);
					ProductSubscriptionsService.processRevSchedules(ids, uow, sruow);
					ProductSubscriptionsService.syncSubscriptionWithAsset(ids, uow, sruow);
					uow.registerWork(sruow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);	
				}

				if(ar.AsyncType__c == TYPE_DEMO_REQUEST_REASON) 
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					CampaignInfluencesService.setDemoRequestReason(new Set<Id>(idsToProcess), uow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);
				} 

				if(ar.AsyncType__c == TYPE_PRODUCT_TERMS_ROLLUP) 
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					OpportunityLineItemsService.updateProductTermsRollup(new Set<Id>(idsToProcess), uow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);
				} 

				if(ar.AsyncType__c == TYPE_RESET_APPROVALS) 
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					OpportunityLineItemsService.resetApprovals(new Set<Id>(idsToProcess), uow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);
				} 

				if(ar.AsyncType__c == TYPE_SET_APPROVALS) 
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					OpportunityLineItemsService.setApprovals(new Set<Id>(idsToProcess), uow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);
				} 

				if(ar.AsyncType__c == TYPE_STAMP_UPDATES)
				{
					SObject[] objectList;
					Map<Id, Set<String>> idToStampIds = new Map<Id, Set<String>>();
					String[] idsToProcess = ar.Params__c.split(',');
					for(String s : idsToProcess)
					{
						String[] split = s.split('::');
						String[] split1 = split[1].split(':');
						idToStampIds.put(split[0], new Set<String>(split1));
					}

					if(new List<Id>(idToStampIds.keySet())[0].getSObjectType().getDescribe().getName() == 'Account')
					{
						objectList = AccountsSelector.newInstance().selectByIdWithManagerAndVP(idToStampIds.keySet());
					}

					if(new List<Id>(idToStampIds.keySet())[0].getSObjectType().getDescribe().getName() == 'Opportunity')
					{
						objectList = OpportunitiesSelector.newInstance().selectByIdWithManagerAndVP(idToStampIds.keySet());
					}

					if(new List<Id>(idToStampIds.keySet())[0].getSObjectType().getDescribe().getName() == 'Campaign_Influence__c')
					{
						objectList = CampaignInfluencesSelector.newInstance().selectByIdWithManagerAndVP(idToStampIds.keySet());
					}

					if(objectList != null) SRUtilities.processStampUpdates(idToStampIds, objectList, uow);

					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);	
				} 	

				if(ar.AsyncType__c == TYPE_SYNC_RECORD_OWNERS)
				{
					Map<Id, Id> accountIdToOwnerId = new Map<Id, Id>();
					String[] idsToProcess = ar.Params__c.split(',');
					for(String s : idsToProcess)
					{
						String[] split = s.split(':');
						accountIdToOwnerId.put(split[0], split[1]);
					}					
					AccountsService.syncRecordOwners(accountIdToOwnerId, uow);
					uow.commitWork();                   
					mapDeleteSObject.put(ar.Id, ar);	
				} 

				if(ar.AsyncType__c == TYPE_AMBASSADOR_CREATE)
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					OpportunitiesService.createAmbassadorCommission(new Set<Id>(idsToProcess), uow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);
				} 

				if(ar.AsyncType__c == TYPE_AMBASSADOR_COMPLETE)
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					OpportunitiesService.completeAmbassadorCommission(new Set<Id>(idsToProcess), uow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);
				} 

				if(ar.AsyncType__c == TYPE_USER_LIMITS)
				{
					Id[] idsToProcess = ar.Params__c.split(',');
					UsersService.updateUserLimits(new Set<Id>(idsToProcess), uow);
					uow.commitWork();
					mapDeleteSObject.put(ar.Id, ar);
				} 
			}
			
			catch(Exception e) 
			{
				errorMap.put(ar, e);
			}
		}

		if(errorMap.size() > 0)
		{
			fflib_SObjectUnitOfWork uow1 = Application.UnitOfWork.newInstance();

			for(AsyncRequest__c ar : errorMap.keySet())
			{
				Exception e = errorMap.get(ar);
				ar.Number_of_Attempts__c += 1;
				ar.Error__c = e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' Stack Trace: ' + e.getStackTraceString();
				uow1.registerDirty(ar);
			}

			uow1.commitWork();
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'AsyncMain.Execute');
		if(mapDeleteSObject.size() > 0) Database.emptyRecycleBin(mapDeleteSObject.values());
	}

	global void Finish(Database.BatchableContext BC) 
	{
		AsyncRequest__c[] ars = [SELECT Id, Number_of_Attempts__c FROM AsyncRequest__c WHERE Number_of_Attempts__c <= 5 LIMIT 1];
		
		if(ars.size() > 0 && !Test.isRunningTest()) 
		{
			AsyncRequestEvent__e asyncRequestEvent = new AsyncRequestEvent__e();
			Database.SaveResult sr = EventBus.publish(asyncRequestEvent);

			if(!sr.isSuccess())
			{
				for(Database.Error err : sr.getErrors())
				{
					Error_Log__c log = new Error_Log__c(
			            Error_Message__c = 'Status Code: ' + err.getStatusCode() + '\nMessage: ' + err.getMessage() + '\nFields: ' + err.getFields(),
			            Error_Type__c = 'AsyncRequestEvent Error');
					insert log;
				}
			}
		}
	}

	public class ScheduleHandler implements ScheduledDispatcher.IScheduleDispatched 
	{
        public void execute(SchedulableContext sc) 
        {
        	startBatch();
            System.abortJob(sc.getTriggerID());	// Always abort the job on completion
        } 
    }

	public static void startBatch() 
	{
		if(batchRequested) return;
		if(isAsyncMainRunning()) return;
		AsyncMain am = new AsyncMain();
		Database.executeBatch(am, 1);
		batchRequested = true;
	}
        
    public static void startScheduler() 
    {
    	if(schedulerRequested) return;
        
        // Is the job already running?
        CronTrigger[] jobs = [SELECT Id, 
        	CronJobDetail.Name, 
        	State, 
        	NextFireTime 
        	FROM CronTrigger 
        	WHERE CronJobDetail.Name LIKE 'AsyncMain_Job%'];

    	if(jobs.size() > 0 && 
    		jobs[0].State != 'COMPLETED' && 
    		jobs[0].State != 'ERROR' && 
    		jobs[0].State != 'DELETED') 
    	{
            // It's already running - Is the batch running?
            if(isAsyncMainRunning()) return;  // The batch is running
            
            if(Datetime.now().addSeconds(60) > jobs[0].NextFireTime) return;  // If we're going to run soon, exit 
        }

        // If the job exists, it needs to be deleted
        if(jobs.size() > 0) System.abortJob(jobs[0].id);

        try 
        {
	        System.schedule('AsyncMain_Job' + Datetime.now().getTime(), 
	                        getSchedulerExpression(Datetime.now().addSeconds(10)), 
	                        new ScheduledDispatcher());

	        schedulerRequested = true;
        } 

        catch(Exception ex)
        {

        }
    }

    public static Boolean isAsyncMainRunning()
    {
    	Boolean results = false;
    	Set<String> activeJobStates = new Set<String>{'Holding','Queued','Processing','Preparing'};
        List<AsyncApexJob> apexJobs = [SELECT Id, 
        	ApexClass.Name 
        	FROM AsyncApexJob 
        	WHERE ApexClass.Name = 'AsyncMain' 
        	AND Status IN :activeJobStates];

		if(apexJobs.size() > 0) results = true;
		return results; 
    }

    public static String getSchedulerExpression(Datetime dt) 
    {
        return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }
}