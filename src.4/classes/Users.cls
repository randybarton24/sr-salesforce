public class Users extends fflib_SObjectDomain 
{    
	public Set<Id> usersPipelineLimitNextUp;
    
    public Users(User[] users) 
    {
        super(users);    
        Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Users(sObjectList);
        }
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords)
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(User u : (User[]) Records) 
        {
        	User existingUser = (User) existingRecords.get(u.Id);

            this.checkUserPipelineLimitNextUp(u, existingUser, uow);
        }

        if(usersPipelineLimitNextUp != null && 
            !usersPipelineLimitNextUp.isEmpty()) DistributionGroupsService.resetNextUserAtLimit(uow);

     	uow.commitWork();
    }

    public void checkUserPipelineLimitNextUp(User u, User existingUser, fflib_SObjectUnitOfWork uow)
    {
        if(!u.AtPipelineLimit__c) return;
        if(existingUser != null &&
            u.AtPipelineLimit__c &&
            existingUser.AtPipelineLimit__c) return;

        if(usersPipelineLimitNextUp == null) usersPipelineLimitNextUp = new Set<Id>();
        usersPipelineLimitNextUp.add(u.Id);
    }
}