public class Leads
{	
	/*public Leads(Lead[] leads) 
	{
		super(leads);	
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Leads(sObjectList);
		}
	}

	public override void onValidate(Map<Id, SObject> existingRecords)
	{
		//if(FlowControl.isLeadConvert) this.validateLeadConverts();
	}

	public override void onBeforeInsert()
	{
		this.validateCountryByAreaCode();
	}

	public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
	{
		this.validateCountryByAreaCode();
	}

	public override void onAfterUpdate(Map<Id, SObject> existingRecords)
	{
		if(FlowControl.isLeadConvert) this.leadConvert();
	}

	public void validateCountryByAreaCode()
	{
		AreaCodes areaCodes = new AreaCodes();
		String msg = 'The phone area code does not belong to the selected country. Please confirm that this is correct.';

		for(Lead l : (Lead[]) Records)
		{
			Boolean requiresValidation = areaCodes.validateCountryByAreaCode(l.Phone, l.CountryCode);

			if(requiresValidation)
			{
				l.rrpu__Alert_Message__c = l.rrpu__Alert_Message__c != null && !l.rrpu__Alert_Message__c.contains(msg) ? 
					l.rrpu__Alert_Message__c + '\n' + msg : 
					l.rrpu__Alert_Message__c == null ?
						msg : l.rrpu__Alert_Message__c;
			}
			else
			{
				l.rrpu__Alert_Message__c = l.rrpu__Alert_Message__c != null && l.rrpu__Alert_Message__c.contains(msg) ? 
					l.rrpu__Alert_Message__c.replace(msg,'') : l.rrpu__Alert_Message__c;
			}
		}
	}

	public void validateLeadConverts()
	{
		for(Lead l : (Lead[]) Records)
		{
			String errors = validateLeadConvert(l, ', ');

			if(errors != null) l.addError('The Lead isn\'t ready to convert.  Please go back and enter the following: ' + errors);
		}
	}

	public static String validateLeadConvert(Lead l, String joinWith)
	{
		String[] errors = new List<String>();

		if(l.Phone == null) errors.add('Phone');         
        if(l.Lead_Type__c != 'Referral Partner' && l.Practice_Software__c == null) errors.add('Practice Software');
        if(l.Company == null) errors.add('Company');
        if(l.FirstName == null) errors.add('FirstName');
        if(l.LastName == null) errors.add('LastName');
        if(l.Email == null) errors.add('Email');
        if(l.Industry == null) errors.add('Vertical');
        if(l.Sub_Industry__c == null) errors.add('Sub-Vertical');
        if(l.LeadSource == null) errors.add('LeadSource');
        if((l.Sub_Industry__c ==  'Dermatology' || 
            l.Sub_Industry__c == 'Heart and Vascular' || 
            l.Sub_Industry__c == 'Oncology' || 
            l.Sub_Industry__c == 'Other' ) && 
        	(l.Micro_Vertical__c == '' || l.Micro_Vertical__c == null )) errors.add('Micro Vertical');
                        
        if(errors.size() >0) 
        {
        	return String.join(errors, joinWith);
        }
        else
        {
        	return null;
        }
	}

	public void leadConvert()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Set<Id> acctIds = new Set<Id>();
		Set<Id> oppIds = new Set<Id>();
		Set<Id> contactIds = new Set<Id>();
		Map<Id,AccountLeadConvert> accountLeadConvertMap = new Map<Id,AccountLeadConvert>();
		Map<Id,OpportunityLeadConvert> opportunityLeadConvertMap = new Map<Id,OpportunityLeadConvert>();
		Map<Id,ContactLeadConvert> contactLeadConvertMap = new Map<Id,ContactLeadConvert>();
		Map<String,String> acctRecordTypeName = new Map<String,String>{
			'Practice'=>'Account',
			'Group Practice'=>'Account',
			'Enterprise'=>'Major Account',
			'Partner'=>'Partner',
			'Referral Partner'=>'Affiliate/KOL' };
		Map<String,String> oppRecordTypeName = new Map<String,String>{
			'Practice'=>'New Practice Business',
			'Group Practice'=>'New Practice Business',
			'Enterprise'=>'Enterprise New Business',
			'Partner'=>'New Practice Business',
			'Referral Partner'=>'New Practice Business' };

		for(Lead l : (Lead[]) Records)
		{
			acctIds.add(l.ConvertedAccountId);
			accountLeadConvertMap.put(l.ConvertedAccountId, new AccountLeadConvert(SRUtilities.getRecordTypeId('Account',acctRecordTypeName.get(l.Lead_Type__c)), l.ConvertedContactId));
			oppIds.add(l.ConvertedOpportunityId);
			opportunityLeadConvertMap.put(l.ConvertedOpportunityId, new OpportunityLeadConvert(SRUtilities.getRecordTypeId('Opportunity', oppRecordTypeName.get(l.Lead_Type__c)), l.ConvertedContactId));
			contactIds.add(l.ConvertedContactId);
			contactLeadConvertMap.put(l.ConvertedContactId, new ContactLeadConvert(l.ConvertedOpportunityId));
		}

		//LeadsService.reParentOnConversion(new Map<Id, SObject>(Records).keySet(), uow);
		//AccountsService.processAccountLeadConverts(acctIds, accountLeadConvertMap, uow);
		//OpportunitiesService.processOpportunityLeadConverts(oppIds, opportunityLeadConvertMap, uow);
		//ContactsService.processContactLeadConverts(contactIds, contactLeadConvertMap, uow);
		uow.commitWork();
	}

	public class AccountLeadConvert
	{
		public Id recordTypeId;
		public Id officeContactId;

		public AccountLeadConvert(Id recordTypeId, Id officeContactId)
		{
			this.recordTypeId = recordTypeId;
			this.officeContactId = officeContactId;
		}
	}

	public class OpportunityLeadConvert
	{
		public Id recordTypeId;
		public Id billingContactId;

		public OpportunityLeadConvert(Id recordTypeId, Id billingContactId)
		{
			this.recordTypeId = recordTypeId;
			this.billingContactId = billingContactId;
		}
	}

	public class ContactLeadConvert
	{
		public Id convertedOppId;

		public ContactLeadConvert(Id convertedOppId)
		{
			this.convertedOppId = convertedOppId;
		}
	}*/
}