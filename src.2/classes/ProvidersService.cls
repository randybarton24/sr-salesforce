public class ProvidersService 
{
	public static void processNewScorecards(Set<String> pwid_list, fflib_SObjectUnitOfWork uow)
	{
		Provider__c[] providers = ProvidersSelector.newInstance().selectByPuidWithBillingAccount(pwid_list);
		Set<Id> acctIds = new Set<Id>();

		for(Provider__c p : providers)
		{
			acctIds.add(p.Bill_to_Account__r.Id);
			p.Last_Scorecard_Date__c = Datetime.now();
			uow.registerDirty(p);
		}

		AccountsService.processNewScorecards(acctIds, uow);
	}

	public static void newHealthgradesCase(Set<Id> ids, fflib_SObjectUnitOfWork uow) {

        Provider__c[] providers = ProvidersSelector.newInstance().selectSObjectsById(ids);
        String HG_QUEUE_ID = SR_Default_Values__c.getValues('HG Onboarding Queue').Value__c;

        for(Provider__c p : providers) 
        {
            Case newCase = new Case(Subject = 'Healthgrades Implementation: ' + p.Name,
                AccountId = p.Bill_to_Account__c,
                ContactId = p.Related_Contact__c,
                Provider__c = p.Id,
                RecordTypeId = SRUtilities.getRecordTypeMap('Case').get('Support').getRecordTypeId(),
                Product__c = 'Healthgrades',
                Origin = 'Web',
                Category__c = 'Training',
                Topics__c = 'General Training',
                Description = 'Healthgrades URL: ' + p.Healthgrades_ID__c + '\n' + 'Provider NPI: ' + p.NPI__c,
                OwnerId = HG_QUEUE_ID);
            uow.registerNew(newCase);
        }
    }

    public static String getPrimarySpecialty(Provider__c p)
    {
        String primaryProviderSpecialty = '';
        String recordTypeName = SRUtilities.getRecordTypeName('Provider__c', p.RecordTypeId);
        
        if(recordTypeName == 'Dentistry')
        {
            primaryProviderSpecialty = p.Primary_Dentistry_Practicing_Specialty__c;
        }
        else if(recordTypeName == 'Dermatology')
        {
            primaryProviderSpecialty = p.Primary_Dermatology_Practicing_Specialty__c;
        }
        else if(recordTypeName == 'Ophthalmology')
        {
            primaryProviderSpecialty = p.Primary_OphthalmologyPracticingSpecialty__c;
        }
        else if(recordTypeName == 'Optometry')
        {
            primaryProviderSpecialty = p.Primary_Optometry_Practicing_Specialty__c;
        }
        else if(recordTypeName == 'Orthodontics')
        {
            primaryProviderSpecialty = p.Primary_Orthodontics_Practicing_Specialt__c;
        }
        else if(recordTypeName == 'Plastic Surgery')
        {
            primaryProviderSpecialty = p.Primary_Plastic_Surgery_Practicing_Speci__c;
        }      
        else if(recordTypeName == 'Podiatry')
        {
            primaryProviderSpecialty = p.Primary_Podiatry_Practicing_Specialties__c;
        }
        
        return primaryProviderSpecialty;
    }

    public static String getSpecialties(Provider__c p)
    {
        String providerSpecialties = '';
        String recordTypeName = SRUtilities.getRecordTypeName('Provider__c', p.RecordTypeId);
        
        String[] specialtyList = new List<String>();

        if(recordTypeName == 'Dentistry' && p.Dentistry_Practicing_Specialties__c != null)
        {
            specialtyList.add(p.Dentistry_Practicing_Specialties__c);
        }
        else if(recordTypeName == 'Dermatology' && p.Dermatology_Practicing_Specialties__c != null)
        {
            specialtyList.add(p.Dermatology_Practicing_Specialties__c);
        }
        else if(recordTypeName == 'Ophthalmology' && p.Ophthalmology_Practicing_Specialties__c != null)
        {
            specialtyList.add(p.Ophthalmology_Practicing_Specialties__c);
        }
        else if(recordTypeName == 'Optometry' && p.Optometry_Practicing_Specialties__c != null)
        {
            specialtyList.add(p.Optometry_Practicing_Specialties__c);
        }
        else if(recordTypeName == 'Orthodontics' && p.Orthodontics_Practicing_Specialties__c != null)
        {
            specialtyList.add(p.Orthodontics_Practicing_Specialties__c);
        }
        else if(recordTypeName == 'Plastic Surgery' && p.Plastic_Surgery_Practicing_Specialties__c != null)
        {
            specialtyList.add(p.Plastic_Surgery_Practicing_Specialties__c);
        }
        else if(recordTypeName == 'Podiatry' && p.Secondary_Podiatry_Practicing_Specialty__c != null)
        {
            specialtyList.add(p.Secondary_Podiatry_Practicing_Specialty__c);
        }

        providerSpecialties = String.join(specialtyList, ',');
        providerSpecialties = providerSpecialties.replace(';', ',');

        return providerSpecialties;
    }

    public static String getConditions(Provider__c p)
    {
        String providerConditions = '';
        String recordTypeName = SRUtilities.getRecordTypeName('Provider__c', p.RecordTypeId);

        String[] conditionList = new List<String>();
        
        if(recordTypeName == 'Addiction Psychology')
        {
            if(p.Addiction_Psychology_Conditions__c != null) conditionList.add(p.Addiction_Psychology_Conditions__c);
        }
        else if(recordTypeName == 'Allergists')
        {
            if(p.Allergists_Conditions__c != null) conditionList.add(p.Allergists_Conditions__c);
        }
        else if(recordTypeName == 'Chiropractic')
        {
            if(p.Chiropractic_Conditions__c != null) conditionList.add(p.Chiropractic_Conditions__c);
        }
        else if(recordTypeName == 'Dentistry')
        {
            if(p.Cosmetic_Dentistry_Conditions__c != null) conditionList.add(p.Cosmetic_Dentistry_Conditions__c);
            if(p.Dental_Hygiene_Conditions__c != null) conditionList.add(p.Dental_Hygiene_Conditions__c);
            if(p.Dentistry_Conditions__c != null) conditionList.add(p.Dentistry_Conditions__c);
            if(p.Laser_Dentistry_Conditions__c != null) conditionList.add(p.Laser_Dentistry_Conditions__c);
            if(p.Neuromuscular_Dentistry_Conditions__c != null) conditionList.add(p.Neuromuscular_Dentistry_Conditions__c);
            if(p.Pediatric_Dentistry_Conditions__c != null) conditionList.add(p.Pediatric_Dentistry_Conditions__c);
            if(p.Reconstructive_Dentistry_Conditions__c != null) conditionList.add(p.Reconstructive_Dentistry_Conditions__c);
            if(p.Sports_Dentistry_Conditions__c != null) conditionList.add(p.Sports_Dentistry_Conditions__c);
        }
        else if(recordTypeName == 'Dermatology')
        {
            if(p.Dermatology_Conditions__c != null) conditionList.add(p.Dermatology_Conditions__c);
            if(p.Pediatric_Dermatology_Conditions__c != null) conditionList.add(p.Pediatric_Dermatology_Conditions__c);
        }
        else if(recordTypeName == 'Ophthalmology')
        {
            if(p.Ophthalmology_Conditions__c != null) conditionList.add(p.Ophthalmology_Conditions__c);
            if(p.Pediatric_Ophthalmology_Conditions__c != null) conditionList.add(p.Pediatric_Ophthalmology_Conditions__c);
        }
        else if(recordTypeName == 'Optometry')
        {
            if(p.Optometry_Conditions__c != null) conditionList.add(p.Optometry_Conditions__c);
        }
        else if(recordTypeName == 'Orthodontics')
        {
            if(p.Orthodontics_Conditions__c != null) conditionList.add(p.Orthodontics_Conditions__c);
        }
        else if(recordTypeName == 'Physical Therapy')
        {
            if(p.Physical_Therapy_Conditions__c != null) conditionList.add(p.Physical_Therapy_Conditions__c);
        }
        else if(recordTypeName == 'Plastic Surgery')
        {
            if(p.Plastic_Surgery_Conditions__c != null) conditionList.add(p.Plastic_Surgery_Conditions__c);
            if(p.Plastic_Surgery_Additional_Conditions__c != null) conditionList.add(p.Plastic_Surgery_Additional_Conditions__c);
        }
        else if(recordTypeName == 'Psychiatry')
        {
            if(p.Psychiatry_Conditions__c != null) conditionList.add(p.Psychiatry_Conditions__c);
        }
        else if(recordTypeName == 'Psychology')
        {
            if(p.Psychology_Conditions__c != null) conditionList.add(p.Psychology_Conditions__c);
        }      
        else if(recordTypeName == 'Podiatry')
        {
            if(p.Podiatry_Conditions__c != null) conditionList.add(p.Podiatry_Conditions__c);
        }

        providerConditions = String.join(conditionList, ',');
        providerConditions = providerConditions.replace(';', ',');

        return providerConditions;
    }

    public static String getProcedures(Provider__c p)
    {
        String providerProcedures = '';
        String recordTypeName = SRUtilities.getRecordTypeName('Provider__c', p.RecordTypeId);

        String[] ProcedureList = new List<String>(); 

        if(recordTypeName == 'Addiction Psychology')
        {
            if(p.Addiction_Psychology_Procedures__c != null) procedureList.add(p.Addiction_Psychology_Procedures__c);
        }
        else if(recordTypeName == 'Allergists')
        {
            if(p.Allergists_Procedures__c != null) procedureList.add(p.Allergists_Procedures__c);
        }
        else if(recordTypeName == 'Chiropractic')
        {
            if(p.Chiropractic_Procedures__c != null) procedureList.add(p.Chiropractic_Procedures__c);
        }
        else if(recordTypeName == 'Dentistry')
        {
            if(p.Cosmetic_Dentistry_Procedures__c != null) procedureList.add(p.Cosmetic_Dentistry_Procedures__c);
            if(p.Dental_Hygiene_Procedures__c != null) procedureList.add(p.Dental_Hygiene_Procedures__c);
            if(p.Dentistry_Procedures__c != null) procedureList.add(p.Dentistry_Procedures__c);
            if(p.Laser_Dentistry_Procedures__c != null) procedureList.add(p.Laser_Dentistry_Procedures__c);
            if(p.Neuromuscular_Dentistry_Procedures__c != null) procedureList.add(p.Neuromuscular_Dentistry_Procedures__c);
            if(p.Pediatric_Dentistry_Procedures__c != null) procedureList.add(p.Pediatric_Dentistry_Procedures__c);
            if(p.Reconstructive_Dentistry_Procedures__c != null) procedureList.add(p.Reconstructive_Dentistry_Procedures__c);
            if(p.Sports_Dentistry_Procedures__c != null) procedureList.add(p.Sports_Dentistry_Procedures__c);
        }
        else if(recordTypeName == 'Dermatology')
        {
            if(p.Dermatology_Procedure__c != null) procedureList.add(p.Dermatology_Procedure__c);
            if(p.Pediatric_Dermatology_Procedures__c != null) procedureList.add(p.Pediatric_Dermatology_Procedures__c);
        }
        else if(recordTypeName == 'Ophthalmology')
        {
            if(p.Ophthalmology_Procedures__c != null) procedureList.add(p.Ophthalmology_Procedures__c);
            if(p.Pediatric_Ophthalmology_Procedures__c != null) procedureList.add(p.Pediatric_Ophthalmology_Procedures__c);
        }
        else if(recordTypeName == 'Optometry')
        {
            if(p.Optometry_Procedures__c != null) procedureList.add(p.Optometry_Procedures__c);
        }
        else if(recordTypeName == 'Orthodontics')
        {
            if(p.Orthodontics_Procedures__c != null) procedureList.add(p.Orthodontics_Procedures__c);
        }
        else if(recordTypeName == 'Physical Therapy')
        {
            if(p.Physical_Therapy_Procedures__c != null) procedureList.add(p.Physical_Therapy_Procedures__c);
        }
        else if(recordTypeName == 'Plastic Surgery')
        {
            if(p.Plastic_Surgery_Procedures__c != null) procedureList.add(p.Plastic_Surgery_Procedures__c);
            if(p.Plastic_Surgery_Additional_Procedures__c != null) procedureList.add(p.Plastic_Surgery_Additional_Procedures__c);
        }
        else if(recordTypeName == 'Psychiatry')
        {
            if(p.Psychiatry_Procedures__c != null) procedureList.add(p.Psychiatry_Procedures__c);
        }
        else if(recordTypeName == 'Psychology')
        {
            if(p.Psychology_Procedures__c != null) procedureList.add(p.Psychology_Procedures__c);
        }
        else if(recordTypeName == 'Podiatry')
        {
            if(p.Podiatry_Procedures__c != null) procedureList.add(p.Podiatry_Procedures__c);
        }

        providerProcedures = String.join(ProcedureList, ',');
        providerProcedures = providerProcedures.replace(';', ',');
        
        return providerProcedures;
    }
}