public class UsersService 
{	
	public static void updateUserLimits(Set<Id> ids, fflib_SObjectUnitOfWork uow) 
	{		
        Map<Id, Decimal> stagingMap;
        Map<Id, Decimal> pipelineMap;
        User[] users = UsersSelector.newInstance().selectSObjectsById(ids);
        
        for(User u : users)
        {
            Open_Opp_Limit__c oppLimit = Open_Opp_Limit__c.getInstance(u.Id);

            if(stagingMap == null) stagingMap = OpportunitiesSelector.newInstance().selectOwnerStagingOpps(ids);
        	if(pipelineMap == null) pipelineMap = OpportunitiesSelector.newInstance().selectOwnerPipelineOpps(ids);
            
            Decimal stagingActual = stagingMap.get(u.Id) == null ? 0 : stagingMap.get(u.Id);
            Decimal pipelineActual = pipelineMap.get(u.Id) == null ? 0 : pipelineMap.get(u.Id);

            if(stagingActual >= oppLimit.Staging__c && !u.AtStagingLimit__c) u.AtStagingLimit__c = true;
            if(pipelineActual >= oppLimit.Pipeline__c && !u.AtPipelineLimit__c) u.AtPipelineLimit__c = true;  
            if(stagingActual < oppLimit.Staging__c && u.AtStagingLimit__c) u.AtStagingLimit__c = false;
            if(pipelineActual < oppLimit.Pipeline__c && u.AtPipelineLimit__c) u.AtPipelineLimit__c = false; 
            u.Limit_Staging_Opps__c = oppLimit.Staging__c;
            u.Limit_Pipeline_Opps__c = oppLimit.Pipeline__c;
            u.Number_of_Staging_Opps__c = stagingActual;
        	u.Number_of_Pipeline_Opps__c = pipelineActual;
            uow.registerDirty(u);
        }
	}

	public static void checkUserLimits(Id userId) 
	{		
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();        
        User[] users = UsersSelector.newInstance().selectSObjectsById(new Set<Id> {userId});
        
        for(User u : users)
        {
            if (u.AtPipelineLimit__c) 
            {
            	List<Distribution_Group_Member__c> usersNextUp = new List<Distribution_Group_Member__c> ([SELECT Id, Name, User__c, User__r.Name, User__r.FirstName, User__r.LastName, Available__c, 
				Next_Up__c, Distribution_Group__c 
				FROM Distribution_Group_Member__c 
				WHERE User__r.Id = :userId AND Next_Up__c = true]);			

				//if (usersNextUp != null && !usersNextUp.isEmpty()) DistributionGroupsService.getNextUser(usersNextUp, uow);
            }            
        }
	}
}