trigger AsyncRequestEvents on AsyncRequestEvent__e (after insert) 
{
	if(!AsyncMain.isAsyncMainRunning() && !Test.isRunningTest())
	{
		AsyncMain am = new AsyncMain();
		Database.executeBatch(am, 1);
	}
}