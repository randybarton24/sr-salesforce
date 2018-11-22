@isTest
private class HealthgradesPDFController_Test {
	
	@isTest static void testHGPDFController() {
		
		Account a = TestUtilities.insertBasicAccount(true);
		Opportunity o = TestUtilities.insertBasicOpportunity(a.Id);

		PageReference pageRef = Page.HealthgradesPDF;

		pageRef.getParameters().put('oppId', o.Id);
		
		Test.setCurrentPage(pageRef);

		HealthgradesPDFController controller = new HealthgradesPDFController();
	}	
}