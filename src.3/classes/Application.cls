public class Application 
{
	// Configure and create the UnitOfWorkFactory for this Application
	public static final UnitOfWorkFactory UnitOfWork = 
		new UnitOfWorkFactory(
				new List<SObjectType> { 
					User.SObjectType,
					Lead.SObjectType,
					Account.SObjectType,
					Contact.SObjectType,
					Asset.SObjectType,
					Case.SObjectType,
					Opportunity.SObjectType,
					Product2.SObjectType,
					Pricebook2.SObjectType,
					PricebookEntry.SObjectType,
					OpportunityLineItem.SObjectType,
					Addendum__c.SObjectType,
					Addendum_Line_Item__c.SObjectType,
					RecurSoft__Product_Subscription__c.SObjectType,
					RecurSoft__Revenue_Schedule__c.SObjectType,
					Provider__c.SObjectType,
					Playbook__c.SObjectType,
					Task.SObjectType,
					Campaign_Influence__c.SObjectType,
					Distribution_Group__c.SObjectType,
					Distribution_Group_Member__c.SObjectType,
					Distribution_Group_History__c.SObjectType,
					Comp_Plan__c.SObjectType,
					Comp_Plan_Rule__c.SObjectType,
					Sales_Target__c.SObjectType,
					Sales_Credit__c.SObjectType,
					Task_History__c.SObjectType,
					AsyncRequest__c.SObjectType,
					Attachment.SObjectType,
					RecurSoft__Payment_Record__c.SObjectType,
					Error_Log__c.SObjectType,
					Cancel_Request__c.SObjectType,
					OpportunityContactRole.SObjectType,
					Survey__c.SObjectType
					});

	// Configure and create the SelectorFactory for this Application
	public static final SelectorFactory Selector = 
		new SelectorFactory(
			new Map<SObjectType, Type> {
					User.SObjectType => UsersSelector.class,
					Account.SObjectType => AccountsSelector.class,
					Playbook__c.SObjectType => PlaybooksSelector.class,
					Opportunity.SObjectType => OpportunitiesSelector.class,
					Sales_Target__c.SObjectType => SalesTargetsSelector.class,
					Management_System__c.SObjectType => ManagementSystemsSelector.class,
					Product2.SObjectType => ProductsSelector.class,
					Pricebook2.SObjectType => PricebooksSelector.class,
					PricebookEntry.SObjectType => PricebookEntriesSelector.class,
					OpportunityLineItem.SObjectType => OpportunityLineItemsSelector.class,
					Contact.SObjectType => ContactsSelector.class,
					Asset.SObjectType => AssetsSelector.class,
					Addendum__c.SObjectType => AddendaSelector.class,
					Addendum_Line_Item__c.SObjectType => AddendumLineItemsSelector.class,
					RecurSoft__Product_Subscription__c.SObjectType => ProductSubscriptionsSelector.class,
					RecurSoft__Revenue_Schedule__c.SObjectType => RevenueSchedulesSelector.class,
					Provider__c.SObjectType => ProvidersSelector.class,
					Case.SObjectType => CasesSelector.class,
					Distribution_Group__c.SObjectType => DistributionGroupsSelector.class,
					Distribution_Group_Member__c.SObjectType => DistributionGroupMembersSelector.class,
					Task.SObjectType => TasksSelector.class,
					CampaignMember.SObjectType => CampaignMembersSelector.class,
					Campaign.SObjectType => CampaignsSelector.class,
					OpportunityContactRole.SObjectType => OpportunityContactRolesSelector.class,
					Campaign_Influence__c.SObjectType => CampaignInfluencesSelector.class,
					RecurSoft__Payment_Record__c.SObjectType => PaymentRecordsSelector.class,
                    Cancel_Request__c.SobjectType => CancelRequestsSelector.class,
					OpportunityContactRole.SObjectType => OpportunityContactRolesSelector.class
					});

	// Configure and create the DomainFactory for this Application
	public static final DomainFactory Domain = 
		new DomainFactory(
			new Map<SObjectType, Type> {
					Account.SObjectType => Accounts.Constructor.class,
					Opportunity.SObjectType => Opportunities.Constructor.class,
					OpportunityLineItem.SObjectType => OpportunityLineItems.Constructor.class,
					Addendum__c.SObjectType => Addenda.Constructor.class,
					Addendum_Line_Item__c.SObjectType => AddendumLineItems.Constructor.class,
					RecurSoft__Product_Subscription__c.SObjectType => ProductSubscriptions.Constructor.class,
					Contact.SObjectType => Contacts.Constructor.class,
					Sales_Target__c.SObjectType => SalesTargets.Constructor.class,
					Sales_Credit__c.SObjectType => SalesCredits.Constructor.class,
					Campaign_Influence__c.SObjectType => CampaignInfluences.Constructor.class,
					Cancel_Request__c.SObjectType => CancelRequests.Constructor.class,
					Payment__c.SObjectType => Payments.Constructor.class,
					Survey__c.SObjectType => Surveys.Constructor.class,
					User.SObjectType => Users.Constructor.class,
					Case.SObjectType => Cases.Constructor.class
					});

	/**
	 * Class implements a Unit of Work factory
	 **/
	/*public class UnitOfWorkFactory
	{
		private List<SObjectType> objectTypes;

		private UnitOfWorkFactory(List<SObjectType> objectTypes)
		{
			this.objectTypes = objectTypes;
		}

		public fflib_SObjectUnitOfWork newInstance()
		{
			return new fflib_SObjectUnitOfWork(objectTypes);
		}
	}*/

	public class UnitOfWorkFactory
	{
		private List<SObjectType> m_objectTypes;
		private fflib_SObjectUnitOfWork m_mockUow;

		/**
		 * Constructs a Unit Of Work factory
		 *
		 * @param objectTypes List of SObjectTypes in dependency order
		 **/
		public UnitOfWorkFactory(List<SObjectType> objectTypes)
		{
			m_objectTypes = objectTypes.clone();
		}

		/**
		 * Returns a new fflib_SObjectUnitOfWork configured with the 
		 *   SObjectType list provided in the constructor, returns a Mock implementation
		 *   if set via the setMock method
		 **/
		public fflib_SObjectUnitOfWork newInstance()
		{
			// Mock?
			if(m_mockUow!=null)
				return m_mockUow;
			return new fflib_SObjectUnitOfWork(m_objectTypes);
		}

		/**
		 * Returns a new fflib_SObjectUnitOfWork configured with the 
		 *   SObjectType list specified, returns a Mock implementation
		 *   if set via the setMock method
		 *
		 * @remark If mock is set, the list of SObjectType in the mock could be different
		 *         then the list of SObjectType specified in this method call
		 **/
		public fflib_SObjectUnitOfWork newInstance(List<SObjectType> objectTypes)
		{
			// Mock?
			if(m_mockUow!=null)
				return m_mockUow;
			return new fflib_SObjectUnitOfWork(objectTypes);
		}		

		@TestVisible
		private void setMock(fflib_SObjectUnitOfWork mockUow)
		{
			m_mockUow = mockUow;
		}
	}

	/**
	 * Class implements a Selector class factory
	 **/
	public class SelectorFactory
	{
		private Map<SObjectType, Type> sObjectBySelectorType;
		private Map<SObjectType, fflib_SObjectSelector> sObjectByMockSelector;

		private SelectorFactory(Map<SObjectType, Type> sObjectBySelectorType)
		{
			this.sObjectBySelectorType = sObjectBySelectorType;	
			this.sObjectByMockSelector = new Map<SObjectType, fflib_SObjectSelector>();		
		}

		public fflib_SObjectSelector newInstance(SObjectType sObjectType)
		{
			System.debug(sObjectByMockSelector);
			System.debug(sObjectType);

			// Mock implementation?
			System.debug(Test.isRunningTest());
			System.debug(Test.isRunningTest() && sObjectByMockSelector.containsKey(sObjectType));
			if(Test.isRunningTest() && sObjectByMockSelector.containsKey(sObjectType))
			{
				System.debug('mockselector');
				return sObjectByMockSelector.get(sObjectType);
			}

			// Determine Apex class for Selector class			
			Type selectorClass = sObjectBySelectorType.get(sObjectType);
			if(selectorClass==null)
				throw new ApplicationException('Selector class not found for SObjectType ' + sObjectType);

			// Construct Selector class and query by Id for the records
			return (fflib_SObjectSelector) selectorClass.newInstance();			
		}

		public List<SObject> selectById(Set<Id> recordIds)
		{
			// Determine SObjectType
			SObjectType domainSObjectType = new List<Id>(recordIds)[0].getSObjectType();

			// Construct Selector class and query by Id for the records
			return newInstance(domainSObjectType).selectSObjectsById(recordIds);
		}

		public List<SObject> selectByRelationship(List<SObject> relatedRecords, SObjectField relationshipField)
		{
			Set<Id> relatedIds = new Set<Id>();
			for(SObject relatedRecord : relatedRecords)
				relatedIds.add((Id) relatedRecord.get(relationshipField));
			return selectById(relatedIds);
		}

		@TestVisible
		private void setMock(fflib_SObjectSelector selectorInstance)
		{
			System.debug('setmock');
			System.debug(selectorInstance.getSObjectType2());
			System.debug(selectorInstance);
			sObjectByMockSelector.put(selectorInstance.getSObjectType2(), selectorInstance);
		} 
	}

	/**
	 * Class implements a Domain class factory
	 **/
	public class DomainFactory 
	{
		private Map<SObjectType, Type> sObjectByDomainConstructorType;

		private DomainFactory(
			Map<SObjectType, Type> sObjectByDomainConstructorType)
		{
			this.sObjectByDomainConstructorType = sObjectByDomainConstructorType;
		}			

		/**
		 * Dynamically constructs an instance of a Domain class for the given record Ids
		 **/
		public fflib_SObjectDomain newInstance(Set<Id> recordIds)
		{
			// No point creating an empty Domain class
			if(recordIds.size()==0)
				return null;

			List<SObject> records = Application.Selector.selectById(recordIds);

			// Determine SObjectType and Apex classes for Domain class
			SObjectType domainSObjectType = new List<Id>(recordIds)[0].getSObjectType();
			Type domainConstructorClass = sObjectByDomainConstructorType.get(domainSObjectType);
			if(domainConstructorClass==null)
				throw new ApplicationException('Domain constructor class not found for SObjectType ' + domainSObjectType);

			// Construct Domain class passing in the queried records
			fflib_SObjectDomain.IConstructable domainConstructor = 
				(fflib_SObjectDomain.IConstructable) domainConstructorClass.newInstance();		
			return domainConstructor.construct(records);
		}		
	}

	public enum ExceptionCode
	{
		NotImplemented,
		ComplianceFailure,
		UnableToVerifyCompliance
	}		

	public virtual class ApplicationException extends Exception 
	{
		public ExceptionCode ExceptionCode {get; private set;}

		public ApplicationException(ExceptionCode exceptionCode, String message)
		{
			this(message);
			this.exceptionCode = exceptionCode;
		}
	}
}