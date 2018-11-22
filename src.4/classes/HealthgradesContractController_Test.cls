@isTest
private class HealthgradesContractController_Test {
	
	@isTest static void testHGContractController() {
		
		Map<ID, SObject> insertSObject = new Map<ID, SObject>();
		Map<ID, SObject> updateSObject = new Map<ID, SObject>();
		Map<ID, SObject> deleteSObject = new Map<ID, SObject>();

		Account a = TestUtilities.insertBasicAccount(true);
		Contact c = TestUtilities.insertBasicContact(a.Id);
		Provider__c p = TestUtilities.insertProvider(a.Id, c.Id, '1');
		Opportunity o = TestUtilities.insertRecordTypeOpportunity(a.Id, 'Healthgrades');
		OpportunityLineItem oppLi = TestUtilities.createOpportunityLineItem(o, TestUtilities.standardPricebookEntries.get('Healthgrades Premium Profile'), 1);
		oppLi.Provider__c = p.Id;
		insertSObject.put(o.Id, oppLi);

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
		updateSObject.put(a.Id, a);
		
		c.RecurSoft__Synced_With_Intacct__c = true;
		c.RecurSoft__Synced_With_Intacct_Date__c = Date.today();
		c.RecurSoft__Intacct_Contact_ID__c = '12345';
		updateSObject.put(c.Id, c);
		
		SRUtilities.runDml(insertSObject, updateSObject, deleteSObject, 'HealthgradesContractController_Test');

		PageReference pageRef = Page.HealthgradesContractReview;

		pageRef.getParameters().put('id', p.Id);
		pageRef.getParameters().put('oppId', o.Id);

		Test.setCurrentPage(pageRef);

		HealthgradesContractController controller = new HealthgradesContractController();

		controller.submitForm();
		ApexPages.Message[] msgs = ApexPages.getMessages();
		System.assert(msgs.size() > 0);

		controller.acceptedRenewal = true;
		controller.acceptedTerms = true;
		controller.signName = 'signName';
		controller.requestedEmail = true;

		controller.submitForm();
		controller.calculateContractStartDate(Date.today());
		//controller.generateContractPdf();


		//System.assert(controller.renderConfirmation);
	}
}