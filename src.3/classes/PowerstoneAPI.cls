@RestResource(urlMapping='/v1/Powerstone/*')
global with sharing class PowerstoneAPI 
{	
	@HttpGet
	global static Map<String, Id> getData()
	{
		return ManagementSystemsSelector.newInstance().selectNameToIdMap();	
	}

	@HttpPut
	global static String updateData(ProspectData data)
	{
		try
		{
			fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
			fflib_SObjectUnitOfWork uow1 = Application.UnitOfWork.newInstance();
			Id powerstoneDistGroup = SR_Default_Values__c.getValues('Powerstone Distribution Group').Value__c;
			Contact[] contact = ContactsSelector.newInstance().selectByIdWithAccount(new Set<Id>{data.contactId});

			if(data.accountData != null)
			{
				Account a = new Account();
				a.Id = contact[0].AccountId;
				a.Name = data.accountData.businessName != null ? data.accountData.businessName : contact[0].Account.Name;
				a.Phone = data.accountData.accountPhone != null ? data.accountData.accountPhone : contact[0].Account.Phone;
				a.Industry = data.accountData.vertical != null ? data.accountData.vertical : contact[0].Account.Industry;
				a.Sub_Vertical__c = data.accountData.subvertical != null ? data.accountData.subvertical : contact[0].Account.Sub_Vertical__c;
				a.Number_of_Locations__c = data.accountData.numberOfLocations != null ? data.accountData.numberOfLocations : contact[0].Account.Number_of_Locations__c;
				a.Practice_Management_Software__c = data.accountData.pmId != null ? data.accountData.pmId : contact[0].Account.Practice_Management_Software__c;
				a.Account_Sales_Status__c = data.accountData.salesStatus != null ? data.accountData.salesStatus : contact[0].Account.Account_Sales_Status__c;
				a.Number_of_Locations__c = data.accountData.numberOfLocations != null ? data.accountData.numberOfLocations : contact[0].Account.Number_of_Locations__c;
				a.RecordTypeId = data.accountData.isHospital || (data.accountData.numberOfLocations != '0-9' && data.accountData.numberOfLocations != null) 
					? SRUtilities.getRecordTypeId('Account','Major Account') : contact[0].Account.RecordTypeId;
				uow.registerDirty(a);
			}
			
			if(data.contactData != null)
			{
				contact[0].FirstName = data.contactData.firstName != null ? data.contactData.firstName : contact[0].FirstName;
				contact[0].LastName = data.contactData.lastName != null ? data.contactData.lastName : contact[0].LastName;
				contact[0].Phone = data.contactData.contactPhone != null ? data.contactData.contactPhone : contact[0].Phone;
				contact[0].Email = data.contactData.email != null ? data.contactData.email : contact[0].Email;
				contact[0].DoNotCall = data.contactData.doNotContact != null ? data.contactData.doNotContact : contact[0].DoNotCall;
				contact[0].Contact_Role__c = data.contactData.contactRole != null ? data.contactData.contactRole : contact[0].Contact_Role__c;
				contact[0].Best_Day_to_Contact__c = data.contactData.bestDayToContact != null ? data.contactData.bestDayToContact : contact[0].Best_Day_to_Contact__c;
				contact[0].Best_Time_to_Contact__c = data.contactData.bestTimeToContact != null ? data.contactData.bestTimeToContact : contact[0].Best_Time_to_Contact__c;
				uow.registerDirty(contact[0]);
			}

			if(data.demoScheduledDateTime != null)
			{
				contact[0].DistGroup__c = powerstoneDistGroup;
				uow.registerDirty(contact[0]);

				String dateTimeString = data.demoScheduledDateTime.format();
				
				Task t = new Task(Subject = 'Powerstone Demo Scheduled with ' + contact[0].FirstName + ' - ' + data.demoScheduledDateTime.format('MM/dd/yyyy h:mm a','America/Denver'),
					ADR_Set__c = true,
					Description = data.comments,
					ActivityDate = Date.valueOf(data.demoScheduledDateTime),
					Activity_Type__c = 'ADR Set',
					Activity_Results__c = 'Future Event',
					Status = 'Scheduled',
					Due_Time__c = Datetime.parse(dateTimeString),
					WhoId = data.contactId,
					WhatId = contact[0].AccountId);
				uow.registerNew(t);
			}
			else
			{
				Task t = new Task(Subject = 'Contacted by Powerstone',
					Description = data.comments,
					ActivityDate = Date.today(),
					Activity_Type__c = '',
					Activity_Results__c = 'Completed',
					Status = 'Completed',
					WhoId = data.contactId,
					WhatId = contact[0].AccountId);
				uow.registerNew(t);
			}

			uow.commitWork();
			return 'Success';
		}
		catch(Exception e)
		{
			return e.getMessage();
		}
		
	}

	global class ProspectData 
	{
		global String contactId;
		global ContactData contactData;
		global AccountData accountData;
		global Datetime demoScheduledDateTime;
		global String comments;
	}

	global class ContactData
	{
		global String firstName;
		global String lastName;
		global String contactPhone;
		global String email;
		global String contactRole;
		global Boolean doNotContact;
		global String bestDayToContact;
		global String bestTimeToContact;
	}

	global class AccountData
	{
		global String businessName;
		global String accountPhone;
		global String pmId;
		global String vertical;
		global String subvertical;
		global String salesStatus;
		global String numberOfLocations;
		global Boolean isHospital;
	}
}