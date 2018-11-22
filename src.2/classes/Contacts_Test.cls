@isTest
private class Contacts_Test {
	
	@isTest static void test_onBeforeInsert() 
	{		
		sfab_FabricatedSObject cFab = TestUtilities2.newContact();

		Contact con = (Contact) cFab.toSObject();

    	Contact existingCon = (Contact) TestUtilities2.existingContact(cFab).toSObject();  

		Contacts contacts = new Contacts(new List<Contact>{ con });         
	    contacts.onBeforeInsert();			
	}

	@isTest static void test_onAfterInsert() 
	{		
		sfab_FabricatedSObject cFab = TestUtilities2.newContact();

		Contact con = (Contact) cFab.toSObject();

    	Contact existingCon = (Contact) TestUtilities2.existingContact(cFab).toSObject();  

		Contacts contacts = new Contacts(new List<Contact>{ con });         
	    contacts.onAfterInsert();			
	}

	@isTest static void test_onBeforeUpdate() 
	{		
		sfab_FabricatedSObject cFab = TestUtilities2.newContact();

		Contact con = (Contact) cFab.toSObject();

    	Contact existingCon = (Contact) TestUtilities2.existingContact(cFab).toSObject();  

		Contacts contacts = new Contacts(new List<Contact>{ con });         
	    contacts.onBeforeUpdate(new Map<Id, SObject>{con.Id =>  cFab.toSObject()});			
	}

    @isTest static void test_createCampaignInfluence()
    {
        Account ac = (Account) TestUtilities2.newAccount().toSObject();

        Campaign camp = (Campaign) TestUtilities2.newCampaign().toSObject();

        User user = (User) TestUtilities2.newUser().toSObject();

        User user2 = (User) TestUtilities2.newUser().toSObject();

    	sfab_FabricatedSObject cFab = TestUtilities2.newContact()
    		.setField(Contact.CampaignId__c, camp.Id)
       		.setField(Contact.AccountId, ac.Id);

		Contact con = (Contact) cFab.toSObject();

    	Contact existingCon = (Contact) TestUtilities2.existingContact(cFab)
    		.setField(Contact.CampaignId__c, '2')
    		.toSObject();

    	Contacts contacts = new Contacts(new List<Contact>{ con });         
	    contacts.createCampaignInfluence(con, existingCon);
	    
	    System.assertEquals(1, contacts.createCI.size()); 
	    System.assert(contacts.createCI.contains(con.Id + '::' + con.CampaignId__c + ':' + UserInfo.getUserId()));  
    }   

    @isTest static void test_createNewAccount()
    {
    	fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

      	Contact con = (Contact) TestUtilities2.newContact()
    		.setField(Contact.FirstName, 'FirstName')
    		.setField(Contact.LastName, 'LastName')
    		.setField(Contact.MailingStreet, 'MailingStreet')
    		.setField(Contact.MailingCity, 'Utah')
    		.setField(Contact.Number_of_Locations__c, 2)
    		.setField(Contact.Number_of_Providers__c, 5)
       		.toSObject();
    	
    	Contacts contacts = new Contacts(new List<Contact>{ con });         
	    contacts.createNewAccount(con, uow);
	    List<Account> acResult = (List<Account>)(uow.m_newListByType.get('Account'));
	    
	    System.assertEquals(1, uow.m_newListByType.get('Account').size()); 
	    System.assertEquals('Account Auto-Created', acResult[0].Description);
	    System.assertEquals('Dental', acResult[0].Industry);
	    System.assertEquals(con.Number_of_Locations__c, acResult[0].Number_of_Locations__c);
	    System.assertEquals(con.Number_of_Providers__c, acResult[0].Number_of_Providers__c);
	    System.assertEquals(con.FirstName + ' ' + con.LastName, acResult[0].Name);
	    System.assertEquals(SRUtilities.getRecordTypeMap('Account').get('Account').getRecordTypeId(), acResult[0].RecordTypeId); 
    }  

    @isTest static void test_createDemoTask()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        Account ac = (Account) TestUtilities2.newAccount().toSObject();

        Contact c = (Contact) TestUtilities2.newContact()
            .setField(Contact.AccountId, ac.Id)
            .setField(Contact.Demo_Scheduled_Date__c, Datetime.now().addDays(5))
            .toSObject();
        
        Contacts contacts = new Contacts(new List<Contact>{ c });         
        contacts.createDemoTask(c, null, uow);
        List<Task> taskResults = (List<Task>)(uow.m_newListByType.get('Task'));
        
        System.assertEquals(1, taskResults.size()); 
        System.assertEquals(true, taskResults[0].ADR_Set__c);
        System.assertEquals(Date.valueOf(c.Demo_Scheduled_Date__c), taskResults[0].ActivityDate);
        System.assertEquals('Phone Demo', taskResults[0].Activity_Type__c);
        System.assertEquals('Future Event', taskResults[0].Activity_Results__c);
        System.assertEquals('Scheduled', taskResults[0].Status);
        System.assertEquals(c.Demo_Scheduled_Date__c, taskResults[0].Due_Time__c);
        System.assertEquals(c.Id, taskResults[0].WhoId);
        System.assertEquals(c.AccountId, taskResults[0].WhatId);
    }  

    @isTest static void test_processDistributionGroup()
    {
    	Distribution_Group__c distGroup = (Distribution_Group__c) TestUtilities2.newDistributionGroup().toSObject();

    	Distribution_Group__c distGroup2 = (Distribution_Group__c) TestUtilities2.newDistributionGroup().toSObject();

      	sfab_FabricatedSObject cFab = TestUtilities2.newContact()
    		.setField(Contact.DistGroup__c, 'DistGroup1')
       		.setField(Contact.Distribution_Group__c, distGroup.Id);

		Contact con = (Contact) cFab.toSObject();

    	Contact existingCon = (Contact) TestUtilities2.existingContact(cFab)
    		.setField(Contact.DistGroup__c, 'DistGroup2')
    		.setField(Contact.Distribution_Group__c, distGroup2.Id)
    		.toSObject();
    	
    	Contacts contacts = new Contacts(new List<Contact>{ con });         
	    contacts.processDistributionGroup(con, existingCon);
	     
	    System.assertEquals(1, contacts.contactsDistGroup.size()); 
	    System.assert(contacts.contactsDistGroup.contains(con.Id + '::' + con.Distribution_Group__c + ':' + UserInfo.getUserId()));	   
    }  

    @isTest static void test_validateCountryByAreaCode()
    {
    	Distribution_Group__c distGroup = (Distribution_Group__c) TestUtilities2.newDistributionGroup().toSObject();

    	Distribution_Group__c distGroup2 = (Distribution_Group__c) TestUtilities2.newDistributionGroup().toSObject();

      	sfab_FabricatedSObject cFab = TestUtilities2.newContact()
    		.setField(Contact.Phone, '1112223333')
       		.setField(Contact.MailingCountryCode, 'Code1');

		Contact con = (Contact) cFab.toSObject();

    	Contact existingCon = (Contact) TestUtilities2.existingContact(cFab)
    		.setField(Contact.Phone, '4445556666')
    		.setField(Contact.MailingCountryCode, 'Code2')
    		.toSObject();
    	
    	Contacts contacts = new Contacts(new List<Contact>{ con });         
	    contacts.validateCountryByAreaCode(con, existingCon);
	     
	    System.assertEquals(null, con.rrpu__Alert_Message__c); 	    
    }  

    @isTest static void test_validateContactOwnerChange()
    {    	
    	User user = (User) TestUtilities2.newUser().toSObject();

        User user2 = (User) TestUtilities2.newUser().toSObject();

      	sfab_FabricatedSObject cFab = TestUtilities2.newContact()
    		.setField(Contact.OwnerId, user.Id)
       		.setField(Contact.MailingCountryCode, 'Code1');

		Contact con = (Contact) cFab.toSObject();

    	Contact existingCon = (Contact) TestUtilities2.existingContact(cFab)
    		.setField(Contact.OwnerId, user2.Id)
    		.setField(Contact.MailingCountryCode, 'Code2')
    		.toSObject();

    	insert new SR_Default_Values__c(Name = 'noStealingProfiles',
            Description__c = 'noStealingProfiles',
            Value__c = '00ei0000001247zAAA');

    	insert new SR_Default_Values__c(Name = 'jennyPoolUserId',
            Description__c = 'jennyPoolUserId',
            Value__c = con.OwnerId);

    	insert new SR_Default_Values__c(Name = 'contactChangeOwnerErrorMessage',
			Description__c = 'contactChangeOwnerErrorMessage',
	        Value__c = 'Adderror Message');  
    	
    	Contacts contacts = new Contacts(new List<Contact>{ con });         
	    contacts.validateContactOwnerChange(con, existingCon);	     	   
    }    	
}