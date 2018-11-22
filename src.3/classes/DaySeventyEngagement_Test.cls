@isTest
private class DaySeventyEngagement_Test {
        
    @testSetup static void testData(){
        
        Date daySeventy = Date.today().addDays(-70);
        Account a = TestUtilities.insertBasicAccount(true);
        a.Probable_Most_Recent_K_Date__c = daySeventy;
        update a;
    }

    @isTest static void DaySeventyEngagementTestBatch(){
        
        DaySeventyEngagement batch = new DaySeventyEngagement();
        Database.executeBatch(batch);
    }
    
    @isTest static void DaySeventyEngagementTestSchedule(){
        
        DaySeventyEngagement schedule= new DaySeventyEngagement();
        System.schedule('Test', '0 0 13 * * ?', schedule);
    }
}