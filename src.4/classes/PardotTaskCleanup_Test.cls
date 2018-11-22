@isTest
private class PardotTaskCleanup_Test {
	
	@testSetup static void testData() {

        Account a = TestUtilities.insertBasicAccount(true);
        Opportunity o = TestUtilities.insertBasicOpportunity(a.Id);
        Task t = TestUtilities.createCompletedTask(null, o.Id);
        t.Subject = 'Pardot Email:';
        insert t;
    }

    @isTest static void pardotCleanupTestBatch() {

    	PardotTaskCleanup_Batch batch = new PardotTaskCleanup_Batch();
    	Database.executeBatch(batch);
    }
}