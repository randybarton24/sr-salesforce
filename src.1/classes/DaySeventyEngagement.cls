global class DaySeventyEngagement implements Database.Batchable<sObject>, Schedulable {

    Date daySeventy = Date.today().addDays(-70);
    
    String query = 'SELECT Id, Probable_Most_Recent_K_Date__c, Day_70_Engagement_Score__c, ApptegicEngagement__c FROM Account WHERE Probable_Most_Recent_K_Date__c = :daySeventy';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
    
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
    
        List<Account> accList = new List<Account>();
                
        for (Account a: scope) {
        
            a.Day_70_Engagement_Score__c = a.ApptegicEngagement__c;
            accList.add(a);
        }
        update accList;
    }
    
    global void finish(Database.BatchableContext BC) {
    
    }
    
    global void execute(SchedulableContext sc) {
    
    DaySeventyEngagement batch = new DaySeventyEngagement();
    Database.executebatch(batch);
    
    }

}