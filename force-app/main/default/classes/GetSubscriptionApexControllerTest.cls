@isTest
public class GetSubscriptionApexControllerTest {
    
    @testSetup static void testData() {
        
        Account a = TestUtilities.insertBasicAccount(true);
        
    }
    
    @isTest static void testSubscriptionController() {
        
        Account a = [SELECT Id FROM Account LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        
        RecurSoft__Product_Subscription__c pc = new RecurSoft__Product_Subscription__c(
            RecurSoft__Account__c = a.Id,
            RecurSoft__Product__c = p.Id,
            RecurSoft__Billing_Status__c = 'Regular Invoicing');
        
        insert pc;
        
        Test.StartTest();
        
        PageReference pageRef = Page.ActiveProductSubscriptions;
        pageRef.getParameters().put('id', String.valueOf(a.Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController acct = new ApexPages.StandardController(a);
        GetSubscriptionApexController ext = new GetSubscriptionApexController(acct);
        List<RecurSoft__Product_Subscription__c> pslist = ext.getSubscriptions();
        
        
        Test.stopTest();
    }
}