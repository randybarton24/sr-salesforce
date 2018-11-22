@isTest
private class CancelledAccountStatusUpdate_Batch_Test 
{
    @testSetup static void testData()
    {
        TestUtilities.newInit();
    }
    
    @isTest static void CancelledAccountStatusUpdate_CancelMonthInPast() 
    {
        Account a = [SELECT Id, RecurSoft__Status__c FROM Account LIMIT 1];
        a.RecurSoft__Status__c = 'Active';
        update a;
        
        Cancel_Request__c cr = [SELECT Id, Stage__c, Cancel_Month__c FROM Cancel_Request__c LIMIT 1];
        cr.Stage__c = 'Cancelled';
        cr.Cancel_Month__c = Date.today().toStartOfMonth();
        update cr;
        
        Test.startTest();
        
        CancelledAccountStatusUpdate_Batch batch = new CancelledAccountStatusUpdate_Batch();
        Database.executebatch(batch);
        
        Test.stopTest();
        
        Account[] acctlist = [SELECT Id, Name, RecurSoft__Status__c FROM Account];
        
        for (Account acct : acctlist)
        {
            System.assertEquals('Cancelled', acct.RecurSoft__Status__c, 'The Account was not Cancelled');   
            System.debug(a);
        }
    }
    
    
    
    @isTest static void CancelledAccountStatusUpdate_CancelMonthInFuture() 
    {
        Account a = [SELECT Id, RecurSoft__Status__c FROM Account LIMIT 1];
        a.RecurSoft__Status__c = 'Active';
        update a;
        
        RecurSoft__Product_Subscription__c ps = [SELECT Id, RecurSoft__Contract_Term_Start_Date__c FROM RecurSoft__Product_Subscription__c LIMIT 1];
        ps.RecurSoft__Contract_Term_Start_Date__c = Date.today().addMonths(-1);
        Update ps;
        
        Cancel_Request__c cr = [SELECT Id, Stage__c, Cancel_Month__c FROM Cancel_Request__c LIMIT 1];
        cr.Stage__c = 'Cancelled';
        cr.Cancel_Month__c = Date.today().toStartOfMonth().addMonths(1);
        update cr;
        
        Test.startTest();
        
        CancelledAccountStatusUpdate_Batch batch = new CancelledAccountStatusUpdate_Batch();
        Database.executebatch(batch);
        
        Test.stopTest();
        
        Account[] acctlist = [SELECT Id, Name, RecurSoft__Status__c FROM Account];
        
        for (Account acct : acctlist)
        {
            
            System.assertEquals('Active', acct.RecurSoft__Status__c, 'The account should still be active');
            
            System.debug(a);
        }
        
    }
    
    @isTest static void CancelledAccountStatusUpdate_Resold() 
    {
        Account a = [SELECT Id, RecurSoft__Status__c FROM Account LIMIT 1];
        a.RecurSoft__Status__c = 'Active';
        update a;
        
        RecurSoft__Product_Subscription__c ps = [SELECT Id, RecurSoft__Contract_Term_Start_Date__c FROM RecurSoft__Product_Subscription__c LIMIT 1];
        ps.RecurSoft__Contract_Term_Start_Date__c = Date.today().addMonths(1);
        Update ps;
        
        Cancel_Request__c cr = [SELECT Id, Stage__c, Cancel_Month__c FROM Cancel_Request__c LIMIT 1];
        cr.Stage__c = 'Cancelled';
        cr.Cancel_Month__c = Date.today().toStartOfMonth();
        update cr;        
        Test.startTest();
        
        CancelledAccountStatusUpdate_Batch batch = new CancelledAccountStatusUpdate_Batch();
        Database.executebatch(batch);
        
        Test.stopTest();
        
        Account[] acctlist = [SELECT Id, Name, RecurSoft__Status__c FROM Account];
        
        for (Account acct : acctlist)
        {
            
            System.assertEquals('Active', acct.RecurSoft__Status__c, 'The account should still be active');
            
            System.debug(a);
        }
        
    }
    
    @isTest static void cancelledAccountStatusTestSchedule()
    {
        CancelledAccountStatusUpdate_Batch schedule = new CancelledAccountStatusUpdate_Batch();
        System.schedule('Test', '0 0 13 * * ?', schedule);
    }
}