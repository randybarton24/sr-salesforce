public with sharing class PricebookManagement_Controller 
{	
	public ApexPages.StandardController stdCtrl { get; set; }
	public Pricebook2 pricebook { get; set; }
	public PriceBookEntry[] pricebookEntries { get; set; }
	public Boolean renderEdit { get; set; }
	public Boolean error { get; set; }

	public PricebookManagement_Controller(ApexPages.StandardController stdController) 
	{	
		this.pricebook = (Pricebook2)stdController.getRecord();
		stdCtrl = stdController;
		renderEdit = false;
		error = false;
		
		pricebookEntries = PricebookEntriesSelector.newInstance().selectByPricebookId(pricebook.Id);
	}

	public PageReference edit() 
	{
		renderEdit = true;
		return null;
	}

	public PageReference cancel() 
	{
		renderEdit = false;
		return null;
	}

	public PageReference saveEntries() 
	{
		Boolean hasError = false;

		if(!hasError) 
		{
			update pricebookEntries;
			stdCtrl.save();
			renderEdit = false;
			return ApexPages.currentPage();
		} 

		else 
		{
			error = true;
			renderEdit = true;
			return null;
		}
	}
}