@isTest
private class SertifiInternalUnitTests 
{
	static TestMethod void triggerTest() 
	{
		Account act = TestUtilities.insertBasicAccount(true);
		//This next thing must be the custom object being linked to, make sure to check this
		Addendum__c newContract = new Addendum__c ();
		newContract.Name = 'Test';
		newContract.Account__c = act.Id;
		insert newContract;
		Sertifi2_0__TestContract__c sertifiContract = new Sertifi2_0__TestContract__c();
		insert sertifiContract;
		sertifiContract.Sertifi2_0__CustomLinkID__c = newContract.id;
		update sertifiContract;
		//System.assertEquals(newContract.id, sertifiContract.Contract__c);
 	}
}