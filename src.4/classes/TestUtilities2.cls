/*
fflib_AnswerTest
fflib_AnyOrderTest
fflib_ApexMocksTest
fflib_ApexMocksUtilsTest
fflib_ApplicationTest
fflib_ArgumentCaptorTest
fflib_IDGeneratorTest
fflib_InheritorTest
fflib_InOrderTest
fflib_MatcherDefinitionsTest
fflib_MatchTest
fflib_MethodArgValuesTest
fflib_QualifiedMethodAndArgValuesTest
fflib_QualifiedMethodTest
fflib_QueryFactoryTest
fflib_SecurityUtilsTest
fflib_SObjectDescribeTest
fflib_SObjectDomainTest
fflib_SObjectSelectorTest
fflib_SObjectUnitOfWorkTest
fflib_StringBuilderTest
fflib_SystemTest

sfab_ChildRelationshipNodeTest
sfab_FabricatedSObjectTest
sfab_FieldValuePairNodeTest
sfab_ParentRelationshipNodeTest
*/

@isTest
public class TestUtilities2 
{
	public static sfab_FabricatedSObject newAccount()
	{
		return new sfab_FabricatedSObject(Account.class)
            .setField(Account.Id, fflib_IDGenerator.generate(Account.SObjectType));
	}	

	public static sfab_FabricatedSObject newAsset()
	{
		return new sfab_FabricatedSObject(Asset.class)
            .setField(Asset.Id, fflib_IDGenerator.generate(Asset.SObjectType));
	}

	public static sfab_FabricatedSObject newAddendum()
	{
		return new sfab_FabricatedSObject(Addendum__c.class)
            .setField(Addendum__c.Id, fflib_IDGenerator.generate(Addendum__c.SObjectType));
	}

	public static sfab_FabricatedSObject newAddendumLineItems()
	{
		return new sfab_FabricatedSObject(Addendum_Line_Item__c.class)
            .setField(Addendum_Line_Item__c.Id, fflib_IDGenerator.generate(Addendum_Line_Item__c.SObjectType));
	}

	public static sfab_FabricatedSObject newOpportunity()
	{
		return new sfab_FabricatedSObject(Opportunity.class)
            .setField(Opportunity.Id, fflib_IDGenerator.generate(Opportunity.SObjectType));
	}

	public static sfab_FabricatedSObject newOpportunityLineItem()
	{
		return new sfab_FabricatedSObject(OpportunityLineItem.class)
            .setField(OpportunityLineItem.Id, fflib_IDGenerator.generate(OpportunityLineItem.SObjectType));
	}
	
	public static sfab_FabricatedSObject newOpportunityContactRole()
	{
		return new sfab_FabricatedSObject(OpportunityContactRole.class)
            .setField(OpportunityContactRole.Id, fflib_IDGenerator.generate(OpportunityContactRole.SObjectType));
	}

	public static sfab_FabricatedSObject newCancelRequest()
	{
		return new sfab_FabricatedSObject(Cancel_Request__c.class)
            .setField(Cancel_Request__c.Id, fflib_IDGenerator.generate(Cancel_Request__c.SObjectType));
	}

	public static sfab_FabricatedSObject newContact()
	{
		return new sfab_FabricatedSObject(Contact.class)
            .setField(Contact.Id, fflib_IDGenerator.generate(Contact.SObjectType));
	}

	public static sfab_FabricatedSObject newCases()
	{
		return new sfab_FabricatedSObject(Case.class)
            .setField(Case.Id, fflib_IDGenerator.generate(Case.SObjectType))
			.setField(Case.OwnerId, fflib_IDGenerator.generate(User.SObjectType));
	}

	public static sfab_FabricatedSObject newParentChildMapping()
	{
		return new sfab_FabricatedSObject(Parent_Child_Mapping__c.class)
            .setField(Parent_Child_Mapping__c.Id, fflib_IDGenerator.generate(Parent_Child_Mapping__c.SObjectType));
	}

	public static sfab_FabricatedSObject newProduct()
	{
		return new sfab_FabricatedSObject(Product2.class)
            .setField(Product2.Id, fflib_IDGenerator.generate(Product2.SObjectType));
	}
	public static sfab_FabricatedSObject newUser()
	{
		return new sfab_FabricatedSObject(User.class)
            .setField(User.Id, fflib_IDGenerator.generate(User.SObjectType));
	}
	public static sfab_FabricatedSObject newCampaign()
	{
		return new sfab_FabricatedSObject(Campaign.class)
            .setField(Campaign.Id, fflib_IDGenerator.generate(Campaign.SObjectType));
	}

	public static sfab_FabricatedSObject newCampaignMember()
	{
		return new sfab_FabricatedSObject(CampaignMember.class)
            .setField(CampaignMember.Id, fflib_IDGenerator.generate(CampaignMember.SObjectType));
	}

	public static sfab_FabricatedSObject newCampaignInfluence()
	{
		return new sfab_FabricatedSObject(Campaign_Influence__c.class)
            .setField(Campaign_Influence__c.Id, fflib_IDGenerator.generate(Campaign_Influence__c.SObjectType));
	}

	public static sfab_FabricatedSObject newAsyncRequest()
	{
		return new sfab_FabricatedSObject(AsyncRequest__c.class)
            .setField(AsyncRequest__c.Id, fflib_IDGenerator.generate(AsyncRequest__c.SObjectType));
	}

	public static sfab_FabricatedSObject newDistributionGroup()
	{
		return new sfab_FabricatedSObject(Distribution_Group__c.class)
            .setField(Distribution_Group__c.Id, fflib_IDGenerator.generate(Distribution_Group__c.SObjectType));
	}

	public static sfab_FabricatedSObject newDistributionGroupMember()
	{
		return new sfab_FabricatedSObject(Distribution_Group_Member__c.class)
            .setField(Distribution_Group_Member__c.Id, fflib_IDGenerator.generate(Distribution_Group_Member__c.SObjectType));
	}

	public static sfab_FabricatedSObject newRecurSoftProductSubscription()
	{
		return new sfab_FabricatedSObject(RecurSoft__Product_Subscription__c.class)
            .setField(RecurSoft__Product_Subscription__c.Id, fflib_IDGenerator.generate(RecurSoft__Product_Subscription__c.SObjectType));
	}

	public static sfab_FabricatedSObject newProvider()
	{
		return new sfab_FabricatedSObject(Provider__c.class)
            .setField(Provider__c.Id, fflib_IDGenerator.generate(Provider__c.SObjectType));
	}

	public static sfab_FabricatedSObject newPricebook2()
	{
		return new sfab_FabricatedSObject(Pricebook2.class)
            .setField(Pricebook2.Id, fflib_IDGenerator.generate(Pricebook2.SObjectType));
	}

	public static sfab_FabricatedSObject newRecurSoftRenewalRule()
	{
		return new sfab_FabricatedSObject(RecurSoft__Renewal_Rule__c.class)
            .setField(RecurSoft__Renewal_Rule__c.Id, fflib_IDGenerator.generate(RecurSoft__Renewal_Rule__c.SObjectType));
	}

	public static sfab_FabricatedSObject newPricebookEntry()
	{
		return new sfab_FabricatedSObject(PricebookEntry.class)
            .setField(PricebookEntry.Id, fflib_IDGenerator.generate(PricebookEntry.SObjectType));
	}

	public static sfab_FabricatedSObject newSalesCredit()
	{
		return new sfab_FabricatedSObject(Sales_Credit__c.class)
            .setField(Sales_Credit__c.Id, fflib_IDGenerator.generate(Sales_Credit__c.SObjectType));
	}

	public static sfab_FabricatedSObject newSalesTarget()
	{
		return new sfab_FabricatedSObject(Sales_Target__c.class)
            .setField(Sales_Target__c.Id, fflib_IDGenerator.generate(Sales_Target__c.SObjectType));
	}

	public static sfab_FabricatedSObject newStampFieldMapping()
	{
		return new sfab_FabricatedSObject(Stamp_Field_Mapping__c.class)
            .setField(Stamp_Field_Mapping__c.Id, fflib_IDGenerator.generate(Stamp_Field_Mapping__c.SObjectType));
	}

	public static sfab_FabricatedSObject newSurvey()
	{
		return new sfab_FabricatedSObject(Survey__c.class)
            .setField(Survey__c.Id, fflib_IDGenerator.generate(Survey__c.SObjectType));
	}

	public static sfab_FabricatedSObject newTask()
	{
		return new sfab_FabricatedSObject(Task.class)
            .setField(Task.Id, fflib_IDGenerator.generate(Task.SObjectType));
	}

	public static sfab_FabricatedSObject existingAccount(sfab_FabricatedSObject existing)
	{
		return new sfab_FabricatedSObject(Account.class)
            .setField(Account.Id, existing.toSObject().Id);
	}

	public static sfab_FabricatedSObject existingOpportunity(sfab_FabricatedSObject existing)
	{
		return new sfab_FabricatedSObject(Opportunity.class)
            .setField(Opportunity.Id, existing.toSObject().Id);
	}

	public static sfab_FabricatedSObject existingOpportunityLineItem(sfab_FabricatedSObject existing)
	{
		return new sfab_FabricatedSObject(OpportunityLineItem.class)
            .setField(OpportunityLineItem.Id, existing.toSObject().Id);
	}

	public static sfab_FabricatedSObject existingContact(sfab_FabricatedSObject existing)
	{
		return new sfab_FabricatedSObject(Contact.class)
            .setField(Contact.Id, existing.toSObject().Id);
	}
	public static sfab_FabricatedSObject existingUser(sfab_FabricatedSObject existing)
	{
		return new sfab_FabricatedSObject(User.class)
            .setField(User.Id, existing.toSObject().Id);
    }

	public static sfab_FabricatedSObject existingCampaign(sfab_FabricatedSObject existing)
	{
		return new sfab_FabricatedSObject(Campaign.class)
            .setField(Campaign.Id, existing.toSObject().Id);
	}

	public static sfab_FabricatedSObject existingCampaignMember(sfab_FabricatedSObject existing)
	{
		return new sfab_FabricatedSObject(CampaignMember.class)
            .setField(CampaignMember.Id, existing.toSObject().Id);
	}

	public static sfab_FabricatedSObject existingCampaignInfluence(sfab_FabricatedSObject existing)
	{
		return new sfab_FabricatedSObject(Campaign_Influence__c.class)
            .setField(Campaign_Influence__c.Id, existing.toSObject().Id);
	}

	public static sfab_FabricatedSObject existingAsyncRequest(sfab_FabricatedSObject existing)
	{
		return new sfab_FabricatedSObject(AsyncRequest__c.class)
            .setField(AsyncRequest__c.Id, existing.toSObject().Id);
	}

	public static sfab_FabricatedSObject existingAccount(Account existing)
	{
		return new sfab_FabricatedSObject(Account.class)
            .setField(Account.Id, existing.Id);
	}

	public static sfab_FabricatedSObject existingOpportunity(Opportunity existing)
	{
		return new sfab_FabricatedSObject(Opportunity.class)
            .setField(Opportunity.Id, existing.Id);
	}

	public static sfab_FabricatedSObject existingOpportunityLineItem(OpportunityLineItem existing)
	{
		return new sfab_FabricatedSObject(OpportunityLineItem.class)
            .setField(OpportunityLineItem.Id, existing.Id);
	}

	public static sfab_FabricatedSObject existingAddendumLineItem(Addendum_Line_Item__c existing)
	{
		return new sfab_FabricatedSObject(Addendum_Line_Item__c.class)
            .setField(Addendum_Line_Item__c.Id, existing.Id);
	}

	public static sfab_FabricatedSObject existingProduct(Product2 existing)
	{
		return new sfab_FabricatedSObject(Product2.class)
            .setField(Product2.Id, existing.Id);
	}

	public static sfab_FabricatedSObject existingSurvey(sfab_FabricatedSObject existing)
	{
		return new sfab_FabricatedSObject(Survey__c.class)
            .setField(Survey__c.Id, existing.toSObject().Id);
	}

	public static sfab_FabricatedSObject existingContact(Contact existing)
	{
		return new sfab_FabricatedSObject(Contact.class)
            .setField(Contact.Id, existing.Id);
	}

	public static sfab_FabricatedSObject existingCampaign(Campaign existing)
	{
		return new sfab_FabricatedSObject(Campaign.class)
            .setField(Campaign.Id, existing.Id);
	}

	public static sfab_FabricatedSObject existingCampaignInfluence(CampaignMember existing)
	{
		return new sfab_FabricatedSObject(CampaignMember.class)
            .setField(CampaignMember.Id, existing.Id);
	}

	public static sfab_FabricatedSObject existingCampaignInfluence(Campaign_Influence__c existing)
	{
		return new sfab_FabricatedSObject(Campaign_Influence__c.class)
            .setField(Campaign_Influence__c.Id, existing.Id);
	}

	public static sfab_FabricatedSObject existingCase(sfab_FabricatedSObject existing)
	{
		return new sfab_FabricatedSObject(Case.class)
				.setField(Case.Id, existing.toSObject().Id);
	}

	public static sfab_FabricatedSObject existingCase(Case existing)
	{
		return new sfab_FabricatedSObject(Case.class)
				.setField(Case.Id, existing.Id);
	}
}