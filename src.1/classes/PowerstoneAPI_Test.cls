@IsTest
private with sharing class PowerstoneAPI_Test 
{
	@testSetup
	private	static void createTestData()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Account a = TestUtilities.insertBasicAccount(true);
		Contact c = TestUtilities.insertBasicContact(a.Id);
		a.Last_ROE_Date__c = Datetime.now().addDays(-5);
		uow.registerDirty(a);
		c.Powerstone__c = true;
		uow.registerDirty(c);

		uow.commitWork();
	}

	@IsTest
	private	static void testGET()
	{
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/v1/Powerstone';  
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Map<String, Id> pmNameToIdMap = PowerstoneAPI.getData();

		System.assertEquals(1, pmNameToIdMap.size());
	}

	@IsTest
	private	static void testPUT()
	{
		Account a = [SELECT Id FROM Account LIMIT 1];
		Contact c = [SELECT Id FROM Contact LIMIT 1];
		Management_System__c pm = [SELECT Id FROM Management_System__c LIMIT 1];
		
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/v1/Powerstone';  
		req.httpMethod = 'PUT';
		RestContext.request = req;
		RestContext.response = res;

		JSONGenerator gen = JSON.createGenerator(true);
			gen.writeStartObject();
	            gen.writeStringField('contactId', c.Id);
	            gen.writeFieldName('contactData');
				gen.writeStartObject();
		            gen.writeStringField('firstName', 'TestFirst');
		            gen.writeStringField('lastName', 'TestLast');
		            gen.writeStringField('phone', '123-456-7890');
		            gen.writeStringField('email', 'testemail@testemail.com');
		            gen.writeStringField('contactRole', 'Office Manager');
		            gen.writeBooleanField('doNotContact', false);
		            gen.writeStringField('bestDayToContact', 'Monday');
		            gen.writeStringField('bestTimeToContact', 'Morning');
				gen.writeEndObject();
				gen.writeFieldName('accountData');
				gen.writeStartObject();
		            gen.writeStringField('businessName', 'TestBusinessName');
		            gen.writeStringField('pmId', pm.Id);
		            gen.writeStringField('vertical', 'Vision');
		            gen.writeStringField('subvertical', 'Optometry');
		            gen.writeStringField('salesStatus', 'Contacted');
		            gen.writeStringField('numberOfLocations', '0-9');
		            gen.writeBooleanField('isHospital', false);
				gen.writeEndObject();
	            gen.writeStringField('comments', 'comments');
	            gen.writeDateTimeField('demoScheduledDateTime', Datetime.now().addDays(5));
			gen.writeEndObject();

		req.requestBody = Blob.valueOf(gen.getAsString());

		Test.startTest();

		PowerstoneAPI.ProspectData prospectData = (PowerstoneAPI.ProspectData) JSON.deserialize(req.requestBody.toString(), PowerstoneAPI.ProspectData.class);

		PowerstoneAPI.updateData(prospectData);

		Contact[] c2 = ContactsSelector.newInstance().selectByIdWithAccountAndTasks(new Set<Id>{c.Id});
		String dateTimeString = prospectData.demoScheduledDateTime.format();
		System.debug(prospectData.demoScheduledDateTime);
		System.debug(dateTimeString);
		Test.stopTest();

		/*System.assertEquals(1, c2[0].Tasks.size());
		System.assertEquals(prospectData.contactData.firstName, c2[0].FirstName);
		System.assertEquals(prospectData.contactData.lastName, c2[0].LastName);
		System.assertEquals(prospectData.contactData.phone, c2[0].Phone);
		System.assertEquals(prospectData.contactData.email, c2[0].Email);
		System.assertEquals(prospectData.accountData.businessName, c2[0].Account.Name);
		System.assertEquals(prospectData.accountData.pmId, c2[0].Account.Practice_Management_Software__c);
		System.assertEquals(prospectData.accountData.vertical, c2[0].Account.Industry);
		System.assertEquals(prospectData.accountData.subvertical, c2[0].Account.Sub_Vertical__c);
		System.assertEquals(prospectData.accountData.salesStatus, c2[0].Account.Account_Sales_Status__c);
		System.assertEquals(prospectData.accountData.numberOfLocations, c2[0].Account.Number_of_Locations__c);
		//System.assertEquals(Datetime.parse(dateTimeString), c2[0].Tasks[0].Due_Time__c);
		System.assertEquals(prospectData.demoScheduledDateTime.date(), c2[0].Tasks[0].ActivityDate);
		System.assertEquals(prospectData.comments, c2[0].Tasks[0].Description);
		//System.assertEquals('Powerstone Demo Scheduled ' + prospectData.demoScheduledDateTime.format('MM/dd/yyyy h:mm a','America/Denver'), c2[0].Tasks[0].Subject);
		System.assertEquals(true, c2[0].Tasks[0].ADR_Set__c);
		System.assertEquals('ADR Set', c2[0].Tasks[0].Activity_Type__c);
		System.assertEquals('Future Event', c2[0].Tasks[0].Activity_Results__c);
		System.assertEquals('Scheduled', c2[0].Tasks[0].Status);
		System.assertEquals(c2[0].Id, c2[0].Tasks[0].WhoId);
		System.assertEquals(c2[0].AccountId, c2[0].Tasks[0].WhatId);*/
	}

	@isTest static void testBatch() 
	{
		Test.startTest();

		PowerstoneAPI_Batch batch = new PowerstoneAPI_Batch('Testing');
		//Database.executeBatch(batch);

		Test.stopTest();
	}
}