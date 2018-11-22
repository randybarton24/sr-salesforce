public class ProvidersSelector extends fflib_SObjectSelector 
{
	
	public Schema.SObjectField[] getSObjectFieldList() 
	{
		return new List<Schema.SObjectField> {
			Provider__c.Id,
			Provider__c.Accepting_New_Patients__c,
			Provider__c.Addiction_Psychology_Conditions__c,
			Provider__c.Addiction_Psychology_Procedures__c,
			Provider__c.Allergists_Conditions__c,
			Provider__c.Allergists_Procedures__c,
			Provider__c.Bill_to_Account__c,
			Provider__c.Care_Philosophy__c,
			Provider__c.Chiropractic_Conditions__c,
			Provider__c.Chiropractic_Procedures__c,
			Provider__c.Cosmetic_Dentistry_Conditions__c,
			Provider__c.Cosmetic_Dentistry_Procedures__c,
			Provider__c.Date_of_Birth__c,
			Provider__c.Degree__c,
			Provider__c.Dental_Hygiene_Conditions__c,
			Provider__c.Dental_Hygiene_Procedures__c,
			Provider__c.Dentistry_Conditions__c,
			Provider__c.Dentistry_Practicing_Specialties__c,
			Provider__c.Dentistry_Procedures__c,
			Provider__c.Primary_Dentistry_Practicing_Specialty__c,
			Provider__c.Primary_Dermatology_Practicing_Specialty__c,
			Provider__c.Primary_OphthalmologyPracticingSpecialty__c,
			Provider__c.Primary_Optometry_Practicing_Specialty__c,
			Provider__c.Primary_Orthodontics_Practicing_Specialt__c,
			Provider__c.Primary_Plastic_Surgery_Practicing_Speci__c,
			Provider__c.Dermatology_Conditions__c,
			Provider__c.Dermatology_Practicing_Specialties__c,
			Provider__c.Dermatology_Procedure__c,
			Provider__c.Email__c,
			Provider__c.Gender__c,
			Provider__c.Healthgrades_ID__c,
			Provider__c.Insurance_Accepted__c,
			Provider__c.Languages_Spoken__c,
			Provider__c.Laser_Dentistry_Conditions__c,
			Provider__c.Laser_Dentistry_Procedures__c,
			Provider__c.Last_Profile_Update_Date__c,
			Provider__c.Last_Reported_Date__c,
			Provider__c.Last_Scorecard_Date__c,
			Provider__c.Licensing_State__c,
			Provider__c.Medical_Dental_School__c,
			Provider__c.Name,
			Provider__c.Neuromuscular_Dentistry_Conditions__c,
			Provider__c.Neuromuscular_Dentistry_Procedures__c,
			Provider__c.NPI__c,
			Provider__c.Ophthalmology_Conditions__c,
			Provider__c.Ophthalmology_Practicing_Specialties__c,
			Provider__c.Ophthalmology_Procedures__c,
			Provider__c.Optometry_Conditions__c,
			Provider__c.Optometry_Practicing_Specialties__c,
			Provider__c.Optometry_Procedures__c,
			Provider__c.Orthodontics_Conditions__c,
			Provider__c.Orthodontics_Practicing_Specialties__c,
			Provider__c.Orthodontics_Procedures__c,
			Provider__c.Pediatric_Dentistry_Conditions__c,
			Provider__c.Pediatric_Dentistry_Procedures__c,
			Provider__c.Pediatric_Dermatology_Conditions__c,
			Provider__c.Pediatric_Dermatology_Procedures__c,
			Provider__c.Pediatric_Ophthalmology_Conditions__c,
			Provider__c.Pediatric_Ophthalmology_Procedures__c,
			Provider__c.Physical_Therapy_Conditions__c,
			Provider__c.Physical_Therapy_Procedures__c,
			Provider__c.Plastic_Surgery_Additional_Conditions__c,
			Provider__c.Plastic_Surgery_Additional_Procedures__c,
			Provider__c.Plastic_Surgery_Conditions__c,
			Provider__c.Plastic_Surgery_Practicing_Specialties__c,
			Provider__c.Plastic_Surgery_Procedures__c,
			Provider__c.Practice_Image_Link__c,
			Provider__c.Practice_Name__c,
			Provider__c.Practice_Video_Link__c,
			Provider__c.Practice_URL__c,
			Provider__c.Premium_Member__c,
			Provider__c.Provider_Photo_Link__c,
			Provider__c.Psychiatry_Conditions__c,
			Provider__c.Psychiatry_Procedures__c,
			Provider__c.Psychology_Conditions__c,
			Provider__c.Psychology_Procedures__c,
			Provider__c.PUID__c,
			Provider__c.Reconstructive_Dentistry_Conditions__c,
			Provider__c.Reconstructive_Dentistry_Procedures__c,
			Provider__c.RecordTypeId,
			Provider__c.Related_Contact__c,
			Provider__c.Sports_Dentistry_Conditions__c,
			Provider__c.Sports_Dentistry_Procedures__c,
			Provider__c.State_License__c,
			Provider__c.Year_Graduated__c };
	}

	public Schema.SObjectType getSObjectType()
	{
		return Provider__c.SObjectType;
	}

	public static ProvidersSelector newInstance()
	{
		return (ProvidersSelector) Application.Selector.newInstance(Provider__c.SObjectType);
	}

	public override String getOrderBy()
	{
		return 'Premium_Member__c DESC, Last_Profile_Update_Date__c DESC';
	}

	public Provider__c[] selectByPuidWithBillingAccount(Set<String> puids)
	{
		//assertIsAccessible();

		AccountsSelector accountsSelector = new AccountsSelector();
		accountsSelector.assertIsAccessible();

		return Database.query(
			String.format(
				'SELECT {0}, {1} ' +
				'FROM {2} WHERE PUID__c IN :puids ORDER BY {3}', 
				new List<String>{ 
					getFieldListString(),
					accountsSelector.getRelatedFieldListString('Bill_to_Account__r'),
					getSObjectName(),
					getOrderBy()}));
	}

	public Provider__c[] selectByIdWithCases(Set<Id> ids)
	{
		//assertIsAccessible();

		fflib_QueryFactory providerQueryFactory = newQueryFactory();

		fflib_QueryFactory caseQueryFactory = new CasesSelector().addQueryFactorySubselect(providerQueryFactory);

		new AccountsSelector().configureQueryFactoryFields(providerQueryFactory, 'Bill_to_Account__r');

		return (Provider__c[]) Database.query(
			providerQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
	}

	public Database.QueryLocator queryLocatorDailyReport(Boolean allRecords)
	{
		fflib_QueryFactory providerQueryFactory = newQueryFactory();
		
		fflib_QueryFactory opportunityQueryFactory = providerQueryFactory.subselectQuery('Opportunities__r')
        	.selectFields(new OpportunitiesSelector().getSObjectFieldList());

        fflib_QueryFactory assetQueryFactory = providerQueryFactory.subselectQuery('Assets__r')
        	.selectFields(new AssetsSelector().getSObjectFieldList())
        	.addOrdering('Active__c', fflib_QueryFactory.SortOrder.DESCENDING, true)
        	.addOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING, true);
		
		new AccountsSelector().configureQueryFactoryFields(providerQueryFactory, 'Bill_to_Account__r');
		
		new ContactsSelector().configureQueryFactoryFields(providerQueryFactory, 'Related_Contact__r');
		
		Date dt = Date.today();
		Datetime dt1 = Datetime.newInstance(Date.today().year(), Date.today().month(), Date.today().addDays(-1).day(), 0, 0, 0);
		Datetime dt2 = Datetime.newInstance(Date.today().year(), Date.today().month(), Date.today().day(), 0, 0, 0);

		if(allRecords)
		{
			return Database.getQueryLocator(
				providerQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).
					setCondition('Id IN (SELECT Provider__c FROM Asset) AND Last_Reported_Date__c != :dt').
					addOrdering('Premium_Member__c', fflib_QueryFactory.SortOrder.DESCENDING, true).
					addOrdering('Last_Profile_Update_Date__c', fflib_QueryFactory.SortOrder.DESCENDING, true).
					setLimit(3500).
					toSOQL());
		}
		else
		{
			return Database.getQueryLocator(
				providerQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).
					setCondition('Id IN (SELECT Provider__c FROM Asset) AND Last_Profile_Update_Date__c > :dt1 AND Last_Profile_Update_Date__c < :dt2').
					addOrdering('Premium_Member__c', fflib_QueryFactory.SortOrder.DESCENDING, true).
					addOrdering('Last_Profile_Update_Date__c', fflib_QueryFactory.SortOrder.DESCENDING, true).
					setLimit(3500).
					toSOQL());
		}
	}
}