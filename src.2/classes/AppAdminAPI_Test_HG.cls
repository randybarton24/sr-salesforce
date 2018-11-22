@isTest
private class AppAdminAPI_Test_HG {
	
	@isTest static void providerAPICall() {

		Set<Id> providerIds = new Set<Id>();
		Account a = TestUtilities.insertBasicAccount(true);

		for(Integer i = 0; i < 5; i++) {
			Contact c = TestUtilities.insertBasicContact(a.Id);
			Provider__c p = TestUtilities.insertProvider(a.Id, c.Id, String.valueOf(i));
			providerIds.add(p.Id);
		}

		AppAdminAPIClass.postHealthgradesStatus(providerIds);
	}

	@isTest static void subscriberAPICall() {

		Set<Id> oppIds = new Set<Id>();

		Account a = TestUtilities.insertBasicAccount(true);
		Contact c = TestUtilities.insertBasicContact(a.Id);
		Opportunity o = TestUtilities.insertBasicOpportunity(a.Id);

		TestUtilities.prepForOpportunityClose(a, c, o);

		oppIds.add(o.Id);

		//AppAdminAPIClass.syncOpportunityAppAdmin(oppIds);
		String testResult = '<?xml version="1.0"?>'+
						    '<validationErrors>'+
						         '<validationError>'+
						             '<message>firstName is required</message>'+
						             '<messageTemplate>firstName is required</messageTemplate>'+
						             '<path>Application.createApplication.arg0.firstName</path>'+
						         '</validationError>'+
						    ' </validationErrors>';
		AppAdminAPIClass.getResponseMessage(testResult, o);
		AppAdminAPIClass.getPasswordResetBySubscriberId('123');
		AppAdminAPIClass.getSubscriberUsernameBySubscriberId('123');
	    AppAdminAPIClass.parsPhone('8013317150', 'linenumber');
	    AppAdminAPIClass.parsPhone('8013317150', 'prefix');
	    AppAdminAPIClass.parsPhone('8013317150', 'areacode');
	    AppAdminAPIClass.getSubscriberUsernameById(new Set<Id> {a.Id} );
	}
}