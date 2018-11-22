@RestResource(urlMapping='/customer_data/*')
global with sharing class CustomerDataAPI 
{	
	@HttpGet
	global static CustomerData getSubscriptions()
	{
		CustomerData results = new CustomerData();
		results.subscriptions = new List<Subscriptions>();

		RestRequest req = RestContext.request;
		String subscriberId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

		RecurSoft__Product_Subscription__c[] subscriptions = ProductSubscriptionsSelector.newInstance().selectActiveSubscriptionsBySubscriberId(subscriberId);
		RecurSoft__Payment_Record__c paymentRecord = [SELECT Id, RecurSoft__Expiration_Month__c, RecurSoft__Expiration_Year__c, RecurSoft__Card_Type__c, RecurSoft__Last_4_Text__c 
			FROM RecurSoft__Payment_Record__c WHERE RecurSoft__Account__r.Subscriber_Id__c = :subscriberId ORDER BY CreatedDate DESC LIMIT 1];

		results.ccType = paymentRecord.RecurSoft__Card_Type__c;
		results.ccLast4 = paymentRecord.RecurSoft__Last_4_Text__c;
		results.ccExpMonth = paymentRecord.RecurSoft__Expiration_Month__c;
		results.ccExpYear = paymentRecord.RecurSoft__Expiration_Year__c;

		for(RecurSoft__Product_Subscription__c subscription : subscriptions)
		{
			if(subscription.RecurSoft__Product__r.Family == 'SR Platform')
			{
				results.customerName = subscription.RecurSoft__Account__r.Name;
				results.billingContact = subscription.RecurSoft__Bill_to_Contact__r.Name;
			}
			
			Subscriptions newSubscription = new Subscriptions();
			newSubscription.productName = subscription.RecurSoft__Product__r.Family;
			newSubscription.price = subscription.RecurSoft__Unit_Price__c;
			newSubscription.nextInvoiceDate = subscription.Next_Invoice_Date__c;
			newSubscription.contractStartDate = subscription.RecurSoft__Contract_Term_Start_Date__c;
			newSubscription.contractRenewalDate = subscription.RecurSoft__Contract_Term_End_Date__c;

			results.subscriptions.add(newSubscription);
		}

		return results;
	}

	global class CustomerData
	{
		global String customerName;
		global String billingContact;
		global String ccType;
		global String ccLast4;
		global String ccExpMonth;
		global String ccExpYear;
		global Subscriptions[] subscriptions;
	}

	global class Subscriptions
	{
		global String productName;
		global Decimal price;
		global Date nextInvoiceDate;
		global Date contractStartDate;
		global Date contractRenewalDate;
	}
}