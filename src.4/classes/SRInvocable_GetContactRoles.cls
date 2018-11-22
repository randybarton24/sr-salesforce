public with sharing class SRInvocable_GetContactRoles 
{
	@InvocableMethod(label='getContactRoles' description='Get Opportunity Contact Roles')
	public static OutputData[] getContactRoles(InputData[] input)
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Map<String, OpportunityContactRole> ocrMap = OpportunityContactRolesSelector.newInstance().selectRoleMapByOpportunityIdWithContact(new Set<Id>{ input[0].opportunityId });
		Contact[] contacts = ContactsSelector.newInstance().selectByOpportunityContactRoles(ocrMap.values());
		for(Contact c : contacts)
		{
			if(c.Contact_Role_Multi__c != null) continue;
			c.Contact_Role_Multi__c = 'Unknown';
			uow.registerDirty(c);
		}
		uow.commitWork();
        OutputData output = new OutputData();
        output.contacts = contacts.size() > 0 ? contacts : null;
        System.debug('OutputData: ' + output);
        System.debug('Contacts: ' + contacts);
        return new List<OutputData>{ output };
	}

	public class InputData
	{
		@InvocableVariable(required=true)
		public String opportunityId;
	}

	public class OutputData
	{
		@InvocableVariable(required=false)
		public Contact[] contacts;
	}
}