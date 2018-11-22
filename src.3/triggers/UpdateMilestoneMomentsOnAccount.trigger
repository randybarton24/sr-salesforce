trigger UpdateMilestoneMomentsOnAccount on Milestone_Moment__c (after insert) {
    
    Set<Id> parentIds = new Set<Id>();
    List<Account> accountsToUpdate = new List<Account>{};
    for(Milestone_Moment__c mm :trigger.new){
        parentIds.add(mm.Account__c);
    }
    
    Map<Id, Account> parentMap = new Map<Id, Account>([SELECT Id, Current_of_Patients__c, Current_of_Calls_Generated_from_HG__c, Current_of_Competitors_Blocked__c, Current_of_confirms_received_via_SR__c, Current_of_HG_Profile_Views__c, Current_of_LL_Appt_Requests_Received__c, Current_of_Patient_Referrals__c, Current_of_Reviews_Generated__c, Current_Recare_Dollars_Generated_via_SR__c FROM Account WHERE Id IN :parentIds]);
    
    for(Milestone_Moment__c mm :System.Trigger.New){
        Account acct = parentMap.get(mm.Account__c);
        
        acct.Current_of_Patients__c                     = mm.Number_of_Patients__c;
        acct.Current_of_Calls_Generated_from_HG__c      = mm.Number_of_Calls_Generated_from_HG__c;
        acct.Current_of_Competitors_Blocked__c          = mm.Number_of_Competitors_Blocked__c;
        acct.Current_of_confirms_received_via_SR__c     = mm.Number_of_Confirmations_received__c;
        acct.Current_of_HG_Profile_Views__c             = mm.Number_of_HG_Profile_Views__c;
        acct.Current_of_LL_Appt_Requests_Received__c    = mm.Number_of_LL_Appt_Requests_Received__c;
        acct.Current_of_Patient_Referrals__c            = mm.Number_of_Patient_Referrals__c;
        acct.Current_of_Reviews_Generated__c            = mm.Number_of_Reviews_Generated__c;
        acct.Current_Recare_Dollars_Generated_via_SR__c = mm.Recare_Dollars_Generated_via_SR__c;
        
        accountsToUpdate.add(acct);
        
    }
	update accountsToUpdate;    
}