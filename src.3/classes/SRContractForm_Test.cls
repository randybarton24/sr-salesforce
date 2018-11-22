@isTest
private class SRContractForm_Test {
	
	@isTest static void testSRContractForm() {

		Map<ID, SObject> insertSObject = new Map<ID, SObject>();
		Map<ID, SObject> updateSObject = new Map<ID, SObject>();
		Map<ID, SObject> deleteSObject = new Map<ID, SObject>();

		Account a = TestUtilities.insertBasicAccount(true);
		Contact c = TestUtilities.insertBasicContact(a.Id);
		Opportunity o = TestUtilities.insertBasicOpportunity(a.Id);
		OpportunityLineItem oppLi1 = TestUtilities.createOpportunityLineItem(o, TestUtilities.standardPricebookEntries.get('SR Schedule - Bundle'), 1);
		insertSObject.put(o.Id, oppLi1);
		OpportunityLineItem oppLi2 = TestUtilities.createOpportunityLineItem(o, TestUtilities.standardPricebookEntries.get('Additional Providers'), 1);
		insertSObject.put(c.Id, oppLi2);
		OpportunityLineItem oppLi3 = TestUtilities.createOpportunityLineItem(o, TestUtilities.standardPricebookEntries.get('Promo Product'), 1);
		insertSObject.put(a.Id, oppLi3);

		o.RecurSoft__Billing_Contact__c = c.Id;
		o.RecurSoft__Shipping_Contact__c = c.Id;
		o.RecurSoft__Bill_to_Account__c = a.Id;
		o.RecurSoft__Initial_Contract_Term__c = 24;
		o.RecurSoft__Contract_Term_Start_Date__c = Date.today();
		o.RecurSoft__Intacct_Entity__c = a.RecurSoft__Intacct_Entity__c;
		updateSObject.put(o.Id, o);
		
		a.RecurSoft__Synced_With_Intacct__c = true;
		a.RecurSoft__Synced_With_Intacct_Date__c = Date.today();
		a.RecurSoft__IntacctID__c = '12345';
		a.Probable_Most_Recent_K_Date__c = Date.today();
		a.Office_Contact__c = c.Id;
		updateSObject.put(a.Id, a);
		
		c.RecurSoft__Synced_With_Intacct__c = true;
		c.RecurSoft__Synced_With_Intacct_Date__c = Date.today();
		c.RecurSoft__Intacct_Contact_ID__c = '12345';
		updateSObject.put(c.Id, c);
		
		SRUtilities.runDml(insertSObject, updateSObject, deleteSObject, 'SRContractForm_Test');

		Test.startTest();
		PageReference pageRef = Page.SRContractForm;

		Test.setCurrentPageReference(pageRef);
		pageRef.getParameters().put('id', o.Id);

		ContractForm_Controller controller = new ContractForm_Controller();

		//controller.submitForm();
		//ApexPages.Message[] msgs = ApexPages.getMessages();
		//System.assert(msgs.size() > 0);

		controller.acceptedRenewal = true;
		controller.acceptedCCTerms = true;
		controller.acceptedEula = true;
		controller.contractSigner = 'signName';
		controller.requestedEmail = false;

		//controller.submitForm();
		//controller.generateContractPdf();
		//controller.updateRecords();
		controller.validateForm();
		Test.stopTest();

	}

}