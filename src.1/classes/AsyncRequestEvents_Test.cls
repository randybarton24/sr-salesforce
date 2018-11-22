@isTest
private class AsyncRequestEvents_Test 
{	
	@isTest static void test_Event() 
	{	
		AsyncRequestEvent__e asyncRequestEvent = new AsyncRequestEvent__e();
		
		Test.startTest();
		Database.SaveResult sr = EventBus.publish(asyncRequestEvent);
		Test.stopTest();

		System.assertEquals(true, sr.isSuccess());
	}
}