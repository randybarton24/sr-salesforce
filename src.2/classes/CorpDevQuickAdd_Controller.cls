public with sharing class CorpDevQuickAdd_Controller 
{
	public CorpDev_Account__c a { get; set; }
	public CorpDev_Opportunity__c o { get; set; }
	public CorpDev_Contact__c c { get; set; }
	
	public CorpDevQuickAdd_Controller(ApexPages.StandardController stdController) 
	{			
        a = new CorpDev_Account__c();
        o = new CorpDev_Opportunity__c();
        c = new CorpDev_Contact__c();
	}

	public PageReference saveRecords()
	{
		if(a.Name != null) insert a;
		if(o.Name != null) 
		{
			o.CorpDev_Account__c = a.Id;
			insert o;
		}
		if(c.Name != null)
		{
			c.CorpDev_Account__c = a.Id;
			insert c;
		}

		PageReference newPage = new PageReference('/' + a.Id);
		newPage.setRedirect(true);
		return newPage;
	}

	public PageReference cancel()
	{
		PageReference homePage = new PageReference('/');
		homePage.setRedirect(true);
		return homePage;
	}
}