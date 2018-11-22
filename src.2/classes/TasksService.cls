public class TasksService 
{
	public static void syncTaskOwners(Map<Id, Id> accountIdToOwnerId, Task[] tasks, fflib_SObjectUnitOfWork uow)
	{
		for(Task t : tasks)
		{
			Id ownerId = accountIdToOwnerId.get(t.AccountId);
			if(t.OwnerId == ownerId) continue;
			if(t.IsClosed == true) continue;			
			t.OwnerId = ownerId;
			uow.registerDirty(t);
		}
	}
}