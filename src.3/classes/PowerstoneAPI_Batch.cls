global class PowerstoneAPI_Batch implements Database.Batchable<sObject>, Database.Stateful, Schedulable 
{		
	String finalDocument = Test.isRunningTest() ? 'Test' : '';
	String emailDistribution;
	
	public PowerstoneAPI_Batch(String emailDistribution)
   	{
   		this.emailDistribution = emailDistribution;
   	}

	global Database.QueryLocator start(Database.BatchableContext BC) 
	{	
		finalDocument = 'phone\n';

		return ContactsSelector.newInstance().queryLocatorPowerstoneContactsWithAccount();
	}

	global void execute(Database.BatchableContext BC, List<Contact> scope) 
	{
      	fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		for(Contact contact : scope) 
		{
			finalDocument = finalDocument + SRUtilities.scrubPhone(contact.Phone) + '\n';
			if(contact.Account.Phone != contact.Phone) finalDocument = finalDocument + SRUtilities.scrubPhone(contact.Account.Phone) + '\n';
			contact.Powerstone__c = false;
			uow.registerDirty(contact);
		}

		uow.commitWork();
	}
			
	global void finish(Database.BatchableContext BC) 
	{	
		if(finalDocument == 'phone\n') return;

		String subject = 'SolutionreachDNC_'
         + System.now().addDays(-1).format('MM/dd/yyyy HH:mm:ss','America/Denver');

		Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
		Blob csvBlob = Blob.valueOf(finalDocument);
      	String csvName = 'SolutionreachDNC_'
         + System.now().addDays(-1).format('MM/dd/yyyy HH:mm:ss','America/Denver')
         + '.csv';
		csvAttachment.setFileName(csvName);
		csvAttachment.setBody(csvBlob);

		ApexEmailDistributions__c emailSettings = ApexEmailDistributions__c.getValues(emailDistribution);
		String emails = Test.isRunningTest() ? 'randy@solutionreach.com' : emailSettings.Emails__c;
		if(!Test.isRunningTest() && emailSettings.Emails1__c != null) emails += ',' + emailSettings.Emails1__c;
		if(!Test.isRunningTest() && emailSettings.Emails2__c != null) emails += ',' + emailSettings.Emails2__c;
		String[] emailsList = emails.split(',');

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setSubject(subject);
		mail.setPlainTextBody(subject);
		mail.setFileAttachments(new Messaging.EmailFileAttachment[] { csvAttachment });
		mail.setToAddresses(emailsList);

		try{

			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
		} catch(Exception e) {

			mail.setFileAttachments(null);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    		message.setSubject('PowerstoneAPI_Batch Error');
    		message.setPlainTextBody('The following exception details were caught.  Type: ' + e.getTypeName()
    									+ ' Cause: ' + e.getCause() 
    									+ ' Message: ' + e.getMessage() 
    									+ ' Stack Trace: ' + e.getStackTraceString());
    		message.setToAddresses(new String[] {'randy@solutionreach.com'});
    		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		}
	}

	global void execute(SchedulableContext sc) 
	{	
		PowerstoneAPI_Batch batch = new PowerstoneAPI_Batch(emailDistribution);
		Database.executebatch(batch);
	}
}