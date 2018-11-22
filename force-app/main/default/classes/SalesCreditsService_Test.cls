@isTest
private class SalesCreditsService_Test {
	
	@isTest static void test_assignSalesCreditToSalesTarget() 
	{
		Pricebook2 pb = new Pricebook2(
            Name = 'Custom Pricebook',
            IsActive = true,
            Number_of_Providers_Included__c = 10);
        insert pb;

		insert new SR_Default_Values__c(Name = 'salesTargetRolesProfiles',
			Description__c='salesTargetRolesProfiles',
            Value__c = 'System Administrator');

		insert new SR_Default_Values__c(Name = 'defaultPricebookStage',
            Description__c='defaultPricebookStage',
            Value__c = 'Pre-Qualified');

		insert new SR_Default_Values__c(Name = 'defaultPricebookId',
            Description__c='defaultPricebookId',
            Value__c = pb.Id); 

        insert new SR_Default_Values__c(Name = 'leadSourceToCampaignId',
            Description__c='leadSourceToCampaignId',
            Value__c = 'ADR Set:70131000001lbcW::Cold Call:70131000001lbcR::Direct Mail:70131000001Nmcx::Email:70131000001Nmcd::Other Website:70131000001uCC2::PPC:7010Z000001vKi7::Referral Partner:70131000001uGlJ::SR Website:70131000001uCBx::Trade Show/Event:70131000001Nmci');

        insert new SR_Default_Values__c(Name = 'noStealingProfiles',
            Description__c = 'noStealingProfiles',
            Value__c = String.valueOf(UserInfo.getProfileId()));
		
        User u;
        Account a;        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        RecurSoft__Intacct_Entity__c intacct = new RecurSoft__Intacct_Entity__c(Name = 'TestAccount2');
        insert intacct;
        
        System.runAs (thisUser) 
        {            
            String profileName = 'System Administrator';
            String roleName = 'CSR Enterprise';
            Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
            UserRole r = [SELECT Id FROM UserRole WHERE Name = :roleName LIMIT 1];
            u = new User(
                Username = profileName.deleteWhitespace() + '@solutionreach.com',
                Alias = profileName.deleteWhitespace().substring(0,7),
                LastName = 'TestUserLast',
                Email = profileName.deleteWhitespace() + '@solutionreach.com',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Denver',
                ProfileId = p.Id,
                UserRoleId = r.Id);                   
            insert u;

            a = new Account(
                Name = 'TestAccount2',
                RecurSoft__Intacct_Entity__c = intacct.id,
                Industry = 'Dental',
                OwnerId = u.Id);                    
            insert a;
        }

        Opportunity  opp = new Opportunity(
        	Name = 'Test Opportunity',
            StageName = 'No Sale',
            CloseDate = Date.today(),
            AccountId = a.Id,
            OwnerId = u.Id,
            Cancel_Month__c = Date.today().toStartofMonth(),
            RecurSoft__Contract_Signed_Date__c = Date.newInstance(2018,1,1));
        insert opp;

        String monthValue = 'January';
        String yearValue =	String.valueOf(opp.RecurSoft__Contract_Signed_Date__c.year());
        String uniqueValue = yearValue + monthValue + u.Id + 'Rep'; 

        Sales_Target__c st = new Sales_Target__c(
			Owner__c = u.Id,			
			Type__c = 'Rep',			
        	Unique_Target__c = uniqueValue);               
        insert st;
     
        Sales_Credit__c sc = new Sales_Credit__c(
        	Sales_Rep__c = u.Id,
            Manager__c = null,
            VP__c = null,
            Override_Trigger_Logic__c = false,
            Opportunity__c = opp.Id);                   
        insert sc;
		
        System.assertEquals(1, [select count() from Sales_Credit__c where  Sales_Rep_Target__c != null]);

	}
	
}