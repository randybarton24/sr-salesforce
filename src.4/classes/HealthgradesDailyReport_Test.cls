@isTest
private class HealthgradesDailyReport_Test 
{
	@isTest static void reportCreation1() 
	{
		Account a = TestUtilities.insertBasicAccount(true);
		for(Integer i = 0; i < 9; i++) 
		{
			Contact c = TestUtilities.insertBasicContact(a.Id);
			Provider__c p = TestUtilities.insertProvider(a.Id, c.Id, String.valueOf(i));
		}

		Test.startTest();

		HealthgradesDailyProfileData report = new HealthgradesDailyProfileData(true, 'Testing');
		//Database.executeBatch(report);

		Test.stopTest();
	}
}