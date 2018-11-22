public class Tasks extends fflib_SObjectDomain 
{
	private Five9_Disposition_Mapping__c[] allMappings;
	private Map<String, Five9_Disposition_Mapping__c> dispositionMap;
	private Map<Id, Contact> contactMap;
	private Task_Field_History__c[] fieldsToTrack;

	public Tasks(Task[] tasks) 
	{
		super(tasks);
		Configuration.disableTriggerCRUDSecurity();
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Tasks(sObjectList);
		}
	}

	public override void onBeforeInsert()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		for(Task t : (Task[]) Records) 
    	{
			this.mapFive9Dispositions(t, uow);
    	}

        uow.commitWork();
	}

	public override void onAfterUpdate(Map<Id, SObject> existingRecords)
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		for(Task t : (Task[]) Records) 
    	{
    		Task existingTask = (Task) existingRecords.get(t.Id);

    		this.createHistory(t, existingTask, uow);
    	}

        uow.commitWork();
	}

	public override void onBeforeDelete()
	{
		this.blockTaskDelete();
	}

	public void blockTaskDelete()
	{
		Map<Id, Profile> profileMap = new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE (Name LIKE '%sales%' OR Name LIKE '%Account Development%') AND Name != 'Sales Administrator']);

		for(Task t : (Task[]) Records) 
		{
			if(!profileMap.isEmpty() && profileMap.containsKey(UserInfo.getProfileId())) 
			{
				t.addError('Insufficient Priviledges to Delete a Task');
			}
		}
	}

	public void createHistory(Task t, Task existingTask, fflib_SObjectUnitOfWork uow)
	{
		if(fieldsToTrack == null) fieldsToTrack = Task_Field_History__c.getAll().values();

		for(Task_Field_History__c field : fieldsToTrack)
		{
			if(t.get(field.Name) != existingTask.get(field.Name))
			{
				Task_History__c th = new Task_History__c(Name = t.Id + String.valueOf(Datetime.now()),
					Field__c = (String) field.Name,
					Old_Value__c = (String) String.valueOf(existingTask.get(field.Name)) == null ? 'null' : (String) String.valueOf(existingTask.get(field.Name)),
					New_Value__c = (String) String.valueOf(t.get(field.Name)) == null ? 'null' : (String) String.valueOf(t.get(field.Name)),
					Task_ID__c = t.Id);

				uow.registerNew(th);
			}
		}
	}

	public void mapFive9Dispositions(Task t, fflib_SObjectUnitOfWork uow)
	{
		if(t.CallDisposition == null) return;
		if(allMappings == null) allMappings = [SELECT 
			Id, Five9_Disposition__c, Activity_Results__c, Activity_Type__c, Spoke_With__c, Active__c, Account_Sales_Status__c, Follow_Up_Days__c 
			FROM Five9_Disposition_Mapping__c WHERE Active__c = true];
		if(dispositionMap == null) dispositionMap = new Map<String, Five9_Disposition_Mapping__c>();
		if(contactMap == null) contactMap = ContactsSelector.newInstance().selectContactsWithAccountsByTask((Task[]) Records);

		if(dispositionMap.isEmpty())
		{
			for(Five9_Disposition_Mapping__c disposition : allMappings)
			{
				dispositionMap.put(disposition.Five9_Disposition__c, disposition);
			}
		}

		if(!dispositionMap.containsKey(t.CallDisposition)) return;

		Five9_Disposition_Mapping__c disposition = dispositionMap.get(t.CallDisposition);
		t.Activity_Type__c = disposition.Activity_Type__c;
		t.Activity_Results__c = disposition.Activity_Results__c;
		t.Talked_To__c = disposition.Spoke_With__c;

		if(disposition.Account_Sales_Status__c != null && contactMap != null && contactMap.containsKey(t.WhoId))
		{
			Account a = new Account();
			a.Id = contactMap.get(t.WhoId).AccountId;
			a.Account_Sales_Status__c = disposition.Account_Sales_Status__c;
			uow.registerDirty(a);
		}

		if(disposition.Follow_Up_Days__c != null)
		{
			Task tNew = t.clone(false);
			tNew.Subject = 'Five9 Follow-up';
			tNew.Status = 'Scheduled';
			tNew.CallDisposition = null;
			tNew.ActivityDate = Date.today().addDays(Integer.valueOf(disposition.Follow_Up_Days__c));
			tNew.Activity_Type__c = 'Outbound Call';
			tNew.Activity_Results__c = 'Future Event';
			tNew.Talked_To__c = null;
			uow.registerNew(tNew);
		}
	}
}