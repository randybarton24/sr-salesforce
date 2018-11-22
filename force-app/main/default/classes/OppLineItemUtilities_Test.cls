@isTest
private class OppLineItemUtilities_Test {
	
	@testSetup static void testData1() {

        Account a = TestUtilities.insertBasicAccount(true);
        Opportunity o = TestUtilities.insertBasicOpportunity(a.Id); 
        Opportunity hgOpp = TestUtilities.insertRecordTypeOpportunity(a.Id, 'Healthgrades');
        Contact c = TestUtilities.insertBasicContact(a.Id);
        Provider__c p = TestUtilities.insertProvider(a.Id, c.Id, '1');       
    }

    @testSetup static void testData2() {

        Account a2 = [SELECT Id FROM Account LIMIT 1];
        
    }

    @isTest static void checkDefaults() {

    	Opportunity o = TestUtilities.getOppData([SELECT Id FROM Opportunity WHERE RecordType.Name = 'New Practice Business' LIMIT 1].Id);
    	Integer expectedBaseContractTerm;

    	for(OpportunityLineItem oppLi : o.OpportunityLineItems) {

    		System.debug(oppLi);
    		expectedBaseContractTerm = !OppLi.PricebookEntry.Product2.Default_Co_Terminate__c ? Integer.valueOf(OppLi.PricebookEntry.Product2.Default_Contract_Term__c) :
				o.RecurSoft__Initial_Contract_Term__c == null ? 24 : Integer.valueOf(o.RecurSoft__Initial_Contract_Term__c);

    		System.assertEquals(oppLi.PricebookEntry.Product2.Default_Co_Terminate__c, oppLi.Co_Terminate__c);
    		System.assertEquals(expectedBaseContractTerm, oppLi.Base_Contract_Term__c);
    		//System.assertEquals(oppLi.PricebookEntry.Product2.Default_Renewal_Rule__c, oppLi.RecurSoft__Renewal_Rule__c);

    	}

    }

	/*@isTest static void addHgToExistingProducts() {
		
		Opportunity o = [SELECT Id FROM Opportunity WHERE RecordType.Name != 'Healthgrades' LIMIT 1];
		Provider__c p = [SELECT Id FROM Provider__c LIMIT 1];
		PricebookEntry pbEntry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Name = 'Healthgrades Premium Profile' AND Pricebook2.Name = '1. SR Premier' LIMIT 1];
		System.debug(o);
		System.debug(TestUtilities.standardPricebookEntries.get('Healthgrades Premium Profile'));
		System.debug(pbEntry);

		Test.startTest();

		try{
			OpportunityLineItem oppLi = TestUtilities.createOpportunityLineItem(o, pbEntry, 1);
			oppLi.Provider__c = p.Id;
			insert oppLi;
			System.assertEquals(null, oppLi.Id);

		} catch(Exception e) {
			Boolean expectedErrorMsg = e.getMessage().contains(Label.Error_Healthgrades_Mix_Products);
			System.assert(expectedErrorMsg);
		}

		Test.stopTest();
	}

	@isTest static void addProductsToHGProducts() {
		
		Id pbookId = Test.getStandardPricebookId();
		Opportunity o = [SELECT Id FROM Opportunity WHERE RecordType.Name = 'Healthgrades' LIMIT 1];
		Provider__c p = [SELECT Id FROM Provider__c LIMIT 1];
		PricebookEntry pbEntry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Name = 'Healthgrades Premium Profile' AND Pricebook2Id = :pbookId LIMIT 1];
		PricebookEntry pbEntry2 = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Name = 'SR Premier' AND Pricebook2Id = :pbookId LIMIT 1];
		System.debug([SELECT Name, Pricebook2.Name FROM PricebookEntry]);

		OpportunityLineItem oppLi = TestUtilities.createOpportunityLineItem(o, pbEntry, 1);
		oppLi.Provider__c = p.Id;

		insert oppLi;

		Test.startTest();
		
		try{
			OpportunityLineItem oppLi2 = TestUtilities.createOpportunityLineItem(o, pbEntry2, 1);
			insert oppLi2;
			System.assertEquals(null, oppLi.Id);
		
		} catch(Exception e) {
			
			Boolean expectedErrorMsg = e.getMessage().contains(Label.Error_Healthgrades_Mix_Products2);
			System.assert(expectedErrorMsg);
		}
		
		Test.stopTest();
	}*/
}