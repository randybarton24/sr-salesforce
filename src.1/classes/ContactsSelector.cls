public class ContactsSelector extends fflib_SObjectSelector 
{
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Contact.Id,
			Contact.Ambassador__Short_Code__c,
			Contact.AccountId,
			Contact.Associated_Opp__c,
			Contact.Assign_to_Distribution_Group__c,
			Contact.Best_Day_to_Contact__c,
			Contact.Best_Time_to_Contact__c,
			Contact.CampaignId__c,
			Contact.Contact_Role__c,
			Contact.Contact_Role_Multi__c,
			Contact.Created_From_Lead_Convertion__c,
			Contact.Department,
			Contact.Distribution_Group__c,
			Contact.DistGroup__c,
			Contact.DoNotCall,
			Contact.Email,
			Contact.Fax,
			Contact.FirstName,
			Contact.HasOptedOutOfEmail,
			Contact.LastName,
			Contact.Lead__c,
			Contact.MailingStreet,
			Contact.MailingCity,
			Contact.MailingState,
			Contact.MailingStateCode,
			Contact.MailingPostalCode,
			Contact.MailingCountry,
			Contact.MailingCountryCode,
			Contact.MobilePhone,
			Contact.Name, 
			Contact.OwnerId,
			Contact.Phone,
			Contact.Powerstone__c,
			Contact.Primary_Contact__c,
			Contact.Purchase_Involvement__c,
			Contact.Survey_Opt_Out__c,
			Contact.Title 
			};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Contact.SObjectType;
	}

	public static ContactsSelector newInstance()
	{
		return (ContactsSelector) Application.Selector.newInstance(Contact.SObjectType);
	}

	public Contact[] selectContactsByAccountId(Set<Id> acctIds)
	{
		fflib_QueryFactory contactQueryFactory = newQueryFactory();

		return Database.query(
			contactQueryFactory
			.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
			.setCondition('AccountId IN :acctIds')
			.toSOQL());
	}

	public Contact[] selectByIdWithAccount(Set<Id> ids)
	{
		fflib_QueryFactory contactQueryFactory = newQueryFactory();

		new AccountsSelector().configureQueryFactoryFields(contactQueryFactory, 'Account');

		return Database.query(
			contactQueryFactory
			.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
			.setCondition('Id IN :ids')
			.toSOQL());
	}

	public Contact[] selectByIdWithAccountAndTasks(Set<Id> ids)
	{
		fflib_QueryFactory contactQueryFactory = newQueryFactory();

		new AccountsSelector().configureQueryFactoryFields(contactQueryFactory, 'Account');

		fflib_QueryFactory taskQueryFactory = contactQueryFactory.subselectQuery('Tasks')
        	.selectFields(new TasksSelector().getSObjectFieldList());

		return Database.query(
			contactQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}

	public Database.QueryLocator queryLocatorPowerstoneContactsWithAccount()
	{
		SR_Default_Values__c defaultValues = SR_Default_Values__c.getValues('Opportunity Closed Lost Days');
		Integer cutOffDays = Integer.valueOf(defaultValues.Value__c);
		Datetime cutOff = Datetime.now().addDays(-cutOffDays);

		fflib_QueryFactory contactQueryFactory = newQueryFactory();

		new AccountsSelector().configureQueryFactoryFields(contactQueryFactory, 'Account');

		return Database.getQueryLocator(
			contactQueryFactory
				.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList()))
				.setCondition('Powerstone__c = true AND Account.Last_ROE_Date__c != null AND Account.Last_ROE_Date__c > :cutOff')
				.toSOQL());
	}

	public Map<Id, Contact> selectContactsWithAccountsByTask(Task[] tasks)
	{
		Set<Id> ids = new Set<Id>();

		for(Task t : tasks)
		{
			if(t.WhoId != null && t.WhoId.getSObjectType().getDescribe().getName() == 'Contact') ids.add(t.WhoId);
		}

		fflib_QueryFactory contactQueryFactory = newQueryFactory();

		new AccountsSelector().configureQueryFactoryFields(contactQueryFactory, 'Account');

		return new Map<Id, Contact>((Contact[]) Database.query(
			contactQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('id IN :ids').toSOQL()));
	}

	public Contact[] selectByOpportunityContactRoles(OpportunityContactRole[] ocrs)
	{
		Set<Id> ids = new Set<Id>();

		for(OpportunityContactRole ocr : ocrs)
		{
			ids.add(ocr.ContactId);
		}

		fflib_QueryFactory contactQueryFactory = newQueryFactory();

		return Database.query(
			contactQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('id IN :ids').toSOQL());
	}
}