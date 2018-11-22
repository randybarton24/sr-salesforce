public with sharing class AccountContactDetails_Controller 
{	
	public Id acctId { get; set; }
	public Account acct { get; set; }
	public Contact[] listContacts { get; set; }
	public Contact newContact { get; set; }
	public Boolean renderNewContact { get; set; }
	
	public AccountContactDetails_Controller(ApexPages.StandardController stdController) 
	{	
		this.acctId = stdController.getId();
		renderNewContact = false;
		
        try
        {
	    	acct = [SELECT Id, Name FROM Account WHERE Id = :acctId];
	    	listContacts = ContactsSelector.newInstance().selectContactsByAccountId(new Set<Id>{acctId});
		} 
		catch(Exception e) 
		{
			System.debug(e);
		}
	}

	public PageReference newContactForm()
	{
		newContact = new Contact(AccountId = acctId);
		renderNewContact = true;
		return null;
	}

	public PageReference createNewContact()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		uow.registerNew(newContact);
		uow.commitWork();

		return ApexPages.currentPage();
	}

	public PageReference cancel() 
	{
		renderNewContact = false;
		return null;
	}
}