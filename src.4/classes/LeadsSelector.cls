public class LeadsSelector 
{
	/*
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Lead.Id,
			Lead.Company,
			Lead.ConvertedAccountId, 
	        Lead.ConvertedContactId, 
	        Lead.ConvertedOpportunityId,
	        Lead.Country,
	        Lead.Email,
	        Lead.FirstName,
	        Lead.Industry,
	        Lead.IsConverted,
			Lead.LastName,
			Lead.Last_ROE_Task_Date__c,
			Lead.LeadSource,
			Lead.Lead_Type__c,
			Lead.Micro_Vertical__c,
			Lead.Name, 
			Lead.Number_of_Active_CI__c,
			Lead.OwnerId,
			Lead.Phone,
			Lead.Practice_Software__c,
			Lead.Status,
			Lead.Sub_Industry__c
	    };
	}

	public Schema.SObjectType getSObjectType()
	{
		return Lead.SObjectType;
	}

	public static LeadsSelector newInstance()
	{
		return (LeadsSelector) Application.Selector.newInstance(Lead.SObjectType);
	}

	public Lead[] selectByIdWithCustomRelationships(Set<Id> ids)
	{
		assertIsAccessible();

		CampaignInfluencesSelector campaignInfluencesSelector = new CampaignInfluencesSelector();
		campaignInfluencesSelector.assertIsAccessible();

		ContactsSelector contactsSelector = new ContactsSelector();
		contactsSelector.assertIsAccessible();

		return Database.query(
			String.format(
				'SELECT {0}, ' +
				'(SELECT {1},{2} FROM Campaign_Influence__r ORDER BY {3}), ' +
				'(SELECT {4},{5} FROM Contacts__r ORDER BY {6}) ' +
				'FROM {7} WHERE Id IN :ids ORDER BY {8}', 
				new List<String>{ 
					getFieldListString(),
					campaignInfluencesSelector.getFieldListString(),
					getRelatedFieldListString('Lead__r'),
					campaignInfluencesSelector.getOrderBy(),
					contactsSelector.getFieldListString(),
					getRelatedFieldListString('Lead__r'),
					contactsSelector.getOrderBy(),
					getSObjectName(),
					getOrderBy()}));
	}*/
}