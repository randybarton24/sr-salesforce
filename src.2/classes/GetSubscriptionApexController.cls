public class GetSubscriptionApexController {
    private final Account acct;

    public GetSubscriptionApexController(ApexPages.StandardController stdController) {

        this.acct = (Account)stdController.getRecord();
    }
    
    public List<RecurSoft__Product_Subscription__c> getSubscriptions () {
        List<RecurSoft__Product_Subscription__c> subscriptions = [
            SELECT Id, 
                        Name,
                        RecurSoft__Product__r.Name,
                        RecurSoft__Unit_Price__c, 
                        RecurSoft__Contract_Term_End_Date__c, 
                        RecurSoft__Billing_Status__c, 
                        RecurSoft__Account__c,
                        RecurSoft__Billing_Frequency__c
                FROM RecurSoft__Product_Subscription__c 
                WHERE RecurSoft__Account__c = :acct.Id AND
                        RecurSoft__Billing_Status__c = 'Regular Invoicing'
                        AND RecurSoft__Billing_Frequency__c != 'One-Time'
                        ORDER BY RecurSoft__Unit_Price__c];
        return subscriptions;
    }
    

}