@isTest
private class SRContractPDF_Test {
	
	@isTest static void testSRContractPDF() {
		
		Account a = TestUtilities.insertBasicAccount(true);
		Opportunity o = TestUtilities.insertBasicOpportunity(a.Id);

		PageReference pageRef = Page.SRContractPDF;

		pageRef.getParameters().put('id', o.Id);
		
		Test.setCurrentPage(pageRef);

		ContractPDF_Controller controller = new ContractPDF_Controller();
	}	
}