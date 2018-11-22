@isTest
private class UpdateMilestoneMomentsOnAccount_Test {

    @isTest static void UpdateMM(){
        Account a = TestUtilities.insertBasicAccount(true);
        Milestone_Moment__c m = new Milestone_Moment__c();
        m.Number_of_Patients__c                    = 1000;
        m.Number_of_Calls_Generated_from_HG__c     = 100;
        m.Number_of_Competitors_Blocked__c         = 20;
        m.Number_of_Confirmations_received__c      = 200;
        m.Number_of_HG_Profile_Views__c            = 3;
        m.Number_of_LL_Appt_Requests_Received__c   = 5;
        m.Number_of_Patient_Referrals__c           = 2;
        m.Number_of_Reviews_Generated__c           = 25;
        m.Recare_Dollars_Generated_via_SR__c       = 2500;
        m.Account__c                               = a.Id;
        
        insert m;
        
       Account updatedAccount = [SELECT Current_of_Patients__c,
                                  Current_of_Calls_Generated_from_HG__c,
                                  Current_of_Competitors_Blocked__c,
                                  Current_of_confirms_received_via_SR__c,
                                  Current_of_HG_Profile_Views__c,
                                  Current_of_LL_Appt_Requests_Received__c,
                                  Current_of_Patient_Referrals__c,
                                  Current_of_Reviews_Generated__c,
                                  Current_Recare_Dollars_Generated_via_SR__c FROM Account WHERE Id = :a.Id];
        
        System.assert(updatedAccount.Current_of_Patients__c                       == 1000);
        System.assert(updatedAccount.Current_of_Calls_Generated_from_HG__c        == 100);
        System.assert(updatedAccount.Current_of_Competitors_Blocked__c            == 20);
        System.assert(updatedAccount.Current_of_confirms_received_via_SR__c       == 200);
        System.assert(updatedAccount.Current_of_HG_Profile_Views__c               == 3);
        System.assert(updatedAccount.Current_of_LL_Appt_Requests_Received__c      == 5);
        System.assert(updatedAccount.Current_of_Patient_Referrals__c              == 2);
        System.assert(updatedAccount.Current_of_Reviews_Generated__c              == 25);
        System.assert(updatedAccount.Current_Recare_Dollars_Generated_via_SR__c   == 2500);
                
    }
}