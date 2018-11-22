@RestResource(urlMapping='/scorecards/*')
global with sharing class HealthgradesScorecards {
	
	@HttpPost
	global static String updateProviderRecords(String[] pwid_list)
	{
		try
		{
			Set<String> pwid_set = new Set<String>();

			for(String s : pwid_list)
			{
				pwid_set.add(s.toLowerCase());
			}

			fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
			ProvidersService.processNewScorecards(pwid_set, uow);
			uow.commitWork();
			return 'Success';
		}
		catch(Exception e)
		{
			return 'Failed with the following exception: ' + e;
		}
	}
}