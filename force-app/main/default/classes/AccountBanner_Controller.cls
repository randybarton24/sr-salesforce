public class AccountBanner_Controller 
{
	public Boolean srsEligible { get; set; }
	public Boolean srcEligible { get; set; }

	public AccountBanner_Controller(ApexPages.StandardController stdController) 
	{
		Id acctId = stdController.getId();
		Account acct = (Account) stdController.getRecord();
		Date cancelCutoff = Date.today().addDays(-60);
		
		RecurSoft__Product_Subscription__c[] activeSRSSubscription = [SELECT Id 
			FROM RecurSoft__Product_Subscription__c 
			WHERE RecurSoft__Bill_to_Account__c = :acctId 
			AND RecurSoft__Product__r.Family = 'SR Schedule'
			AND RecurSoft__Billing_Status__c = 'Regular Invoicing'];

		RecurSoft__Product_Subscription__c[] activeSRCSubscription = [SELECT Id 
			FROM RecurSoft__Product_Subscription__c 
			WHERE RecurSoft__Bill_to_Account__c = :acctId 
			AND RecurSoft__Product__r.Family = 'SR Conversations'
			AND RecurSoft__Billing_Status__c = 'Regular Invoicing'];

		Cancel_Request__c[] srsCancelRequest = [SELECT Id 
			FROM Cancel_Request__c 
			WHERE Asset__r.AccountId = :acctId 
			AND Asset__r.Product2.Family = 'SR Schedule'
			AND Stage__c IN ('Cancelled','No Sale')
			AND Processed_Date__c > :cancelCutoff];

		Cancel_Request__c[] srcCancelRequest = [SELECT Id 
			FROM Cancel_Request__c 
			WHERE Asset__r.AccountId = :acctId 
			AND Asset__r.Product2.Family = 'SR Conversations'
			AND Stage__c IN ('Cancelled','No Sale')
			AND Processed_Date__c > :cancelCutoff];

		srsEligible = activeSRSSubscription.isEmpty() && srsCancelRequest.isEmpty() && acct.Practice_Management_Software__r.Limelight_Available__c;
		srcEligible = activeSRCSubscription.isEmpty() && srcCancelRequest.isEmpty(); 
	}
}