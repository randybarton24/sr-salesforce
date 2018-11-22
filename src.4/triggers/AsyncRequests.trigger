trigger AsyncRequests on AsyncRequest__c (after insert, after update) 
{
	AsyncRequestEvent__e asyncRequestEvent = new AsyncRequestEvent__e();
	Database.SaveResult sr = EventBus.publish(asyncRequestEvent);

	if(!sr.isSuccess())
	{
		for(Database.Error err : sr.getErrors())
		{
			Error_Log__c log = new Error_Log__c(
	            Error_Message__c = 'Status Code: ' + err.getStatusCode() + '\nMessage: ' + err.getMessage() + '\nFields: ' + err.getFields(),
	            Error_Type__c = 'AsyncRequestEvent Error');
			insert log;
		}
	}
}