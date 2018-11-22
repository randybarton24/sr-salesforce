public class ContactsService 
{
	public static void processDistributionGroup(Map<Id, Id> contactIdToDistGroupId, Map<Id, Id> contactIdToUserId, fflib_SObjectUnitOfWork uow) 
	{
		Contact[] contacts = ContactsSelector.newInstance().selectByIdWithAccount(contactIdToDistGroupId.keySet());
		Set<String> contactToCampaign = new Set<String>();
		Map<Id, Account> accountMap = AccountsSelector.newInstance().selectAccountByContactWithParentAccount(contacts);
		Map<Id, Account> parentAccountMap = AccountsSelector.newInstance().selectParentAccountByAccount(accountMap.values());
		Map<Id, Task[]> accountTaskMap = TasksSelector.newInstance().selectADRSetsByAccountId(contacts);
		OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'srreplies@solutionreach.com'];
		Id jennyPoolUserId = SR_Default_Values__c.getValues('jennyPoolUserId').Value__c;

		Map<Id, Distribution_Group__c> distGroupMap = new Map<Id, Distribution_Group__c>([SELECT Id, 
			Name, Open_Opportunity_Setting__c, CampaignId__c, Customer_Setting__c, Timed_Distribution_Group_Hours__c, Major_Accounts__c, Price_Book__c,
			(SELECT Id, Name, User__c, User__r.Name, User__r.FirstName, User__r.LastName, Available__c, 
			Next_Up__c, Distribution_Group__c, User__r.AtPipelineLimit__c
				FROM Distribution_Group_Members__r
				WHERE Available__c = true 
				AND User__r.AtPipelineLimit__c = false
				AND User__r.IsActive = true
				ORDER BY User__r.LastName ASC)
			FROM Distribution_Group__c WHERE Id IN :contactIdToDistGroupId.values()]);
		Distribution_Group_Member__c[] distGroupMembers = new List<Distribution_Group_Member__c>();

		for(Contact contact : contacts) 
		{
			if(!contactIdToDistGroupId.keySet().contains(contact.Id)) return;
			Id distGroupId = contactIdToDistGroupId.get(contact.Id);
			Account account = accountMap.get(contact.AccountId);
			Account parentAccount = account.ParentId != null && parentAccountMap.containsKey(account.ParentId) ? parentAccountMap.get(account.ParentId) : null;
			Opportunity opp = parentAccount != null && parentAccount.Opportunities.size() > 0 ? parentAccount.Opportunities[0] : account.Opportunities.size() > 0 ?
				account.Opportunities[0] : null;
			Distribution_Group__c distGroup = distGroupMap.get(distGroupId);
			Boolean isNewOwner = false;
			Id demoTaskId;

			contact.DistGroup__c = null;
			contact.Distribution_Group__c = null;
			uow.registerDirty(contact);

			if(distGroup.CampaignId__c != null) contactToCampaign.add(contact.Id + '::' + distGroup.CampaignId__c + ':' + contactIdToUserId.get(contact.Id));

			if(skipCustomerStatus(account, parentAccount, contact, distGroup, uow)) continue;
			if(skipTimedDistGroup(account, parentAccount, contact, distGroup, uow)) continue;

			User user = getUser(account, parentAccount, opp, distGroup, uow);

			if(opp == null &&
				user.Id != jennyPoolUserId) uow.registerNew(createNewOpp(user.Id, contactIdToUserId.get(contact.Id), distGroup, parentAccount != null ? parentAccount : account, contact.Ambassador__Short_Code__c != null && contact.Ambassador__Short_Code__c != '' ? contact.Id : null));

			if(contact.OwnerId != user.Id)
			{
				isNewOwner = true;
				contact.OwnerId = user.Id;
				uow.registerDirty(contact);
			}

			if(opp != null && 
				distGroup.Open_Opportunity_Setting__c == 'Reassign Opportunity' && 
				opp.OwnerId != user.Id)
			{
				isNewOwner = true;
				opp.OwnerId = user.Id;
				uow.registerDirty(opp);
			}

			if(account.OwnerId != user.Id)
			{
				isNewOwner = true;
				account.OwnerId = user.Id;
				uow.registerDirty(account);
			}

			if(parentAccount != null && parentAccount.OwnerId != user.Id)
			{
				isNewOwner = true;
				parentAccount.OwnerId = user.Id;
				uow.registerDirty(parentAccount);
			}

			if(account.Id != null && accountTaskMap != null && accountTaskMap.containsKey(account.Id) && accountTaskMap.get(account.Id).size() > 0)
			{				
				for(Task t : accountTaskMap.get(account.Id))
				{
					demoTaskId = t.Id;
					t.OwnerId = user.Id;
					t.ADR_Set_Received__c = true;
					uow.registerDirty(t);
				}
			}

			if(user.Id != jennyPoolUserId) uow.registerEmail(buildMessage(owea, account, contact, user.Id, isNewOwner, demoTaskId));
			createHistory(distGroup, user, contact, account, parentAccount, uow);
		}

		if(contactToCampaign != null && 
            !contactToCampaign.isEmpty()) SRUtilities.scheduleAsync(contactToCampaign, 'Create_CI', uow);
	}

	public static Messaging.SingleEmailMessage buildMessage(OrgWideEmailAddress[] owea, Account account, Contact contact, Id userId, Boolean isNewOwner, Id demoTaskId)
	{
		String subject = demoTaskId != null ? '*DEMO REQUEST* ' : '';
		subject += isNewOwner ? 'New Lead Assigned' : 'New Lead Activity';
		String intro = isNewOwner ? 'have been assigned to you: ' : 'need your attention: ';
		String acctName = account != null ? account.ParentId == null ? account.Name : account.Parent.Name : null;
		String acctId = account != null ? account.ParentId == null ? account.Id : account.ParentId : null;
		String acctLink = account != null ? acctName + '\n' + 'https://solutionreach.lightning.force.com/lightning/r/Account/' + acctId + '/view\n\n' : 'Please link to an existing Account or create a new Account.' + '\n\n';
		String demoLink = demoTaskId != null ? '*LINK TO DEMO*: https://solutionreach.lightning.force.com/lightning/r/Task/' + demoTaskId + '/view\n\n' : '';	

		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSubject(subject);
        message.setPlainTextBody(demoLink +
        'The following Account and Contact ' + intro + '\n\n' +
        'Account: ' + acctLink +
        'Contact: ' + contact.FirstName + ' ' + contact.LastName + '\n' + 'https://solutionreach.lightning.force.com/lightning/r/Contact/' + contact.Id + '/view');
	    message.setSaveAsActivity(false);
	    message.setTargetObjectId(userId);
	    //message.setBccAddresses(new String[] { '005i0000002fU4O' });
          
        if(owea.size() > 0) 
        {
        	message.setOrgWideEmailAddressId(owea.get(0).Id);
        }

        return message;
	}

	public static void createHistory(Distribution_Group__c distGroup, User user, Contact contact, Account account, Account parentAccount, fflib_SObjectUnitOfWork uow)
	{
		Distribution_Group_History__c history = new Distribution_Group_History__c(Name = distGroup.Name + String.valueOf(Datetime.now()),
			Description__c = user.AboutMe,
			Contact__c = contact.Id,
			Account__c = parentAccount != null ? parentAccount.Id : account.Id,
			Distribution_Group__c = distGroup.Id,
			User__c = user.Id);
		uow.registerNew(history);
	}

	public static Opportunity createNewOpp(Id ownerId, Id sourceUser, Distribution_Group__c distGroup, Account a, Id contactId)
	{
		Opportunity o = new Opportunity(Name = a.Name + '-',
			AccountId = a.Id,
			OwnerId = ownerId,
			Source_User__c = sourceUser,
            StageName = 'Demo Scheduled',
            RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get(a.RecurSoft__Status__c == 'Active'  ? 'Add Product' : distGroup.Major_Accounts__c  ? 'Enterprise New Business' : 'New Practice Business').getRecordTypeId(),
            Pricebook2Id = distGroup.Price_Book__c == null ? null : distGroup.Price_Book__c,
            RecurSoft__Trial__c = 'None',
            Apex_Override_Validation__c = true,
            CloseDate = Date.today().addDays(30),
            RecurSoft__Initial_Contract_Term__c = 24,
            Referred_Contact__c = contactId,
            RecurSoft__Bill_to_Account__c = a.Id);
		return o;
	}

	public static Id getDistGroup(Contact c)
	{
		if(c.DistGroup__c == null && c.Distribution_Group__c == null) return null;

		Id distGroupId = c.Distribution_Group__c != null ? c.Distribution_Group__c : c.DistGroup__c InstanceOf Id ? c.DistGroup__c : null;
		return distGroupId;
	}

	public static User getUser(Account account, Account parentAccount, Opportunity opportunity, Distribution_Group__c distGroup, fflib_SObjectUnitOfWork uow)
	{
		if(opportunity != null && distGroup.Open_Opportunity_Setting__c != 'Reassign Opportunity') return new User(Id = parentAccount != null ? parentAccount.OwnerId : account.OwnerId, 
				AboutMe = 'Stayed with owner because of open Opportunity');
		else return DistributionGroupsService.getNextUserId(distGroup.Distribution_Group_Members__r, distGroup.Id, uow);
	}

	public static Boolean skipCustomerStatus(Account account, Account parentAccount, Contact contact, Distribution_Group__c distGroup, fflib_SObjectUnitOfWork uow)
	{
		if(((account.RecurSoft__Status__c == 'Active' || 
					(parentAccount != null && parentAccount.RecurSoft__Status__c == 'Active')) 
					&& distGroup.Customer_Setting__c == 'Prospects Only') ||
				((parentAccount == null && account.RecurSoft__Status__c != 'Active' || 
					(parentAccount != null && parentAccount.RecurSoft__Status__c != 'Active')) 
					&& distGroup.Customer_Setting__c == 'Customers Only') ||
				((account.RecurSoft__Status__c == 'Ineligible' || 
				(parentAccount != null && parentAccount.RecurSoft__Status__c == 'Ineligible'))))
		{
			User user = new User(Id = parentAccount != null ? parentAccount.OwnerId : account.OwnerId, AboutMe = 'Skipped because of customer status');
			createHistory(distGroup, user, contact, account, parentAccount, uow);
			return true;
		}
		return false;
	}

	public static Boolean skipTimedDistGroup(Account account, Account parentAccount, Contact contact, Distribution_Group__c distGroup, fflib_SObjectUnitOfWork uow)
	{
		if(distGroup.Timed_Distribution_Group_Hours__c == null) return false;

		if((account.Timed_Distribution_Group_Date__c != null &&
				account.Timed_Distribution_Group_Date__c.addHours(Integer.valueOf(distGroup.Timed_Distribution_Group_Hours__c)) > Datetime.now()) ||
			(parentAccount != null &&
				parentAccount.Timed_Distribution_Group_Date__c != null &&
				parentAccount.Timed_Distribution_Group_Date__c.addHours(Integer.valueOf(distGroup.Timed_Distribution_Group_Hours__c)) > Datetime.now()))
		{
			User user = new User(Id = parentAccount != null ? parentAccount.OwnerId : account.OwnerId, AboutMe = 'Skipped because of timed Distribution Group');
			createHistory(distGroup, user, contact, account, parentAccount, uow);
			return true;
		}
		else
		{
			account.Timed_Distribution_Group_Date__c = Datetime.now();
			uow.registerDirty(account);
			if(parentAccount != null)
			{
				parentAccount.Timed_Distribution_Group_Date__c = Datetime.now();
				uow.registerDirty(parentAccount);
			} 
			return false;
		}
	}

	public static void syncContactOwners(Map<Id, Id> accountIdToOwnerId, Contact[] contacts, fflib_SObjectUnitOfWork uow)
	{
		for(Contact c : contacts)
		{
			Id ownerId = accountIdToOwnerId.get(c.AccountId);
			if(c.OwnerId == ownerId) continue;					
			c.OwnerId = ownerId;
			uow.registerDirty(c);
		}
	}

	@future
    public static void clearDemoTaskDate(Set<Id> ids)
    {
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	Contact[] contacts = ContactsSelector.newInstance().selectByIdWithAccount(ids);

    	for(Contact c : contacts)
    	{
    		c.Demo_Scheduled_Date__c = null;
    		c.Demo_Scheduled_Date_Text__c = null;
    		uow.registerDirty(c);
    	}

    	uow.commitWork();
    }
}