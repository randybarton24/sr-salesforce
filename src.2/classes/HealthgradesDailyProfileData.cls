global class HealthgradesDailyProfileData implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
	
   	String finalDocument = Test.isRunningTest() ? 'Test' : '';
   	String errors = '';
   	Boolean allRecords;
   	String emailDistribution;

   	public HealthgradesDailyProfileData(Boolean allRecords, String emailDistribution)
   	{
   		this.allRecords = allRecords;
   		this.emailDistribution = emailDistribution;
   	}

	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		String header = 'SR Customer Status,Last Updated,Contract Signed Date,First Bill Date,Billing Status,Cancel Request Date,Termination Date,Free Months Given,LH/RW Competitor,Buyout,First Name,Last Name,NPI,' +
		'Healthgrades URL,IsPremium,Account Name,Street,City,' +
		'State,PostalCode,Country,Phone,Email,Practicing Specialty,Insurance Accepted,State License #,' +
		'Licensing State,Degree,Gender,Practice Name,Primary Specialty,Secondary Specialties,Condition Treated,Procedures Performed,Practice URL,Limelight URL,Practice Logo Link,' +
		'Practice Video Link,Provider Photo Link,Accepting New Patients?,' +
		'Languages Spoken,Date of Birth,Medical/Dental School,Year Graduated,Care Philosophy,Contract Signer,\n';

		Integer totalPremium = [SELECT COUNT() FROM Provider__c WHERE Premium_Member__c = true];
		Integer totalNonPremium = [SELECT COUNT() FROM Provider__c WHERE Id IN (SELECT Provider__c FROM Asset) AND Premium_Member__c = false];
		Integer totalProviders = totalPremium + totalNonPremium;

		String totalRow = 'Total Sales: ' + totalProviders + ',Total Active: ' + totalPremium + ',Total Cancelled: ' + totalNonPremium + ',,,,,,,,,,,,,,,,,,,,,,\n';
		String blankRow = ',,,,,,,,,,,,,,,,,,,,,,,,,,,\n';

		finalDocument = finalDocument == '' ? totalRow + blankRow + blankRow + header : finalDocument;
		
		return ProvidersSelector.newInstance().queryLocatorDailyReport(allRecords);
	}

	/**
	 * Create a csv of all Providers. Email csv as attachment to stakeholders
	 * @param  BC - Database.BatchableContext
	 * @param  scope - List of providers to be executed upon. Comes from query string.
	 * @see See ScheduleHealthgradesReport
	 */
	global void execute(Database.BatchableContext BC, List<Provider__c> scope) 
	{
		for(Provider__c p : scope) 
		{	
			p.Last_Reported_Date__c = Date.today();

			String newOrExisting = '';
			String billingStatus = '';
			String lastUpdated = p.Last_Profile_Update_Date__c != null ? p.Last_Profile_Update_Date__c.format('yyyy-MM-dd','America/Denver') : null;
			String contractSignedDate = null;
			String contractSigner = null;
			Integer monthsToAdd = 1;
			String firstBillDate = null;
			String cancelRequestDate = null;
			String cancelledDate = null;
			String competitor = null;
			Boolean lhrw = p.Bill_to_Account__r.SR_Price_Book__c == 'LH/RW Competitor Offer (18 Mo/6 Sat)' ? true : false;

			String philosophy = p.Care_Philosophy__c != null ? p.Care_Philosophy__c.replace('"','\'') : null;
			String primaryProviderSpecialty = '';
			String providerSpecialties = '';
			String providerConditions = '';
			String providerProcedures = '';
			String freeMonths = '0';
			String dateOfBirth = '';
		
			if(p.Date_of_Birth__c != null)
			{
				Datetime dt = Datetime.newInstance(p.Date_of_Birth__c.year(), p.Date_of_Birth__c.month(), p.Date_of_Birth__c.day());
				dateOfBirth = p.Date_of_Birth__c == null ? '' : dt.format('MM/dd/yyyy');
			}

	        if(!p.Opportunities__r.isEmpty())
	        {
	        	contractSigner = p.Opportunities__r[0].Contract_Signer__c != null ? p.Opportunities__r[0].Contract_Signer__c : null;
	        }

	        if(!p.Assets__r.isEmpty()) 
	        {
        		contractSignedDate = p.Assets__r[0].Most_Recent_Contract_Signed_Date__c != null ? p.Assets__r[0].Most_Recent_Contract_Signed_Date__c.format() : null;

        		monthsToAdd = p.Assets__r[0].Most_Recent_Number_of_Free_Months__c != null ? monthsToAdd + Math.min(2, Integer.valueOf(p.Assets__r[0].Most_Recent_Number_of_Free_Months__c)) : monthsToAdd;
	        	
	        	firstBillDate = p.Assets__r[0].Most_Recent_Contract_Term_Start_Date__c != null ? 
        			p.Assets__r[0].Most_Recent_Contract_Term_Start_Date__c.addMonths(monthsToAdd).format() : null;
        		
        		cancelRequestDate = p.Assets__r[0].Most_Recent_Cancel_Request_Date__c != null ? p.Assets__r[0].Most_Recent_Cancel_Request_Date__c.format() : null;
	        	
	        	freeMonths = p.Assets__r[0].Most_Recent_Number_of_Free_Months__c != null ? String.valueOf(p.Assets__r[0].Most_Recent_Number_of_Free_Months__c) : '0';
	        	
	        	competitor = p.Assets__r[0].Most_Recent_Competitor_Buyout__c != null && p.Assets__r[0].Most_Recent_Competitor_Buyout__c != 'None' ? p.Assets__r[0].Most_Recent_Competitor_Buyout__c : null;
	        	
	        	newOrExisting = p.Assets__r[0].Most_Recent_Contract_Term_Start_Date__c != null && p.Bill_to_Account__r.Probable_Most_Recent_K_Date__c != null ?
        		p.Assets__r[0].Most_Recent_Contract_Term_Start_Date__c <= (p.Bill_to_Account__r.Probable_Most_Recent_K_Date__c + 60) ?
        			'New' : 'Existing' : 'New';

	        	if(p.Assets__r[0].Most_Recent_Termination_Date__c != null && !p.Premium_Member__c) 
	        	{
	        		cancelledDate = p.Assets__r[0].Most_Recent_Termination_Date__c.format();	
	        	} 

	        	if(p.Assets__r[0].Most_Recent_Cancel_Request_Stage__c != null && 
	        		p.Assets__r[0].Most_Recent_Cancel_Request_Date__c != null && 
	        		p.Assets__r[0].Most_Recent_Contract_Signed_Date__c != null &&
	        		p.Assets__r[0].Most_Recent_Cancel_Request_Date__c > p.Assets__r[0].Most_Recent_Contract_Signed_Date__c)
	        	{
	        		billingStatus = (p.Assets__r[0].Most_Recent_Cancel_Request_Stage__c == 'Save' || p.Assets__r[0].Most_Recent_Cancel_Request_Stage__c == 'Resume - No Change') ? 'Saved' : 
	        			(p.Assets__r[0].Most_Recent_Cancel_Request_Stage__c == 'Cancelled' || p.Assets__r[0].Most_Recent_Cancel_Request_Stage__c == 'No Sale')  ? 'Cancelled' :
	        			'In Retention';
	        	}
	        	
	        	if(contractSignedDate == null)
	        	{
	        		errors += p.Id + ', Null Contract Signed Date|';
	        		newOrExisting = 'Data Integrity Issue';
	        	} 
	        	if(p.Premium_Member__c != p.Assets__r[0].Active__c)
	        	{
	        		errors += p.Id + ', Provider and Asset Premium Mismatch|';
	        		newOrExisting = 'Data Integrity Issue';
	        	} 
	        	if(firstBillDate == null) 
	        	{
	        		errors += p.Id + ', Null First Bill Date|';
	        		newOrExisting = 'Data Integrity Issue';
	        	}
	        	if(cancelledDate != null && cancelRequestDate == null) billingStatus = 'On Hold';
	        }
	        else
	        {
	        	errors += p.Id + ', No Related Assets|';
	        	newOrExisting = 'Data Integrity Issue';
	        }

	        primaryProviderSpecialty = ProvidersService.getPrimarySpecialty(p);
	        providerSpecialties = ProvidersService.getSpecialties(p);
	        providerConditions = ProvidersService.getConditions(p);
	        providerProcedures = ProvidersService.getProcedures(p);
         
	        String thisProvider = '\"' + newOrExisting + '\",\"'
	        	+ lastUpdated + '\",\"'
	        	+ contractSignedDate + '\",\"'
	        	+ firstBillDate + '\",\"'
	        	+ billingStatus + '\",\"'
	        	+ cancelRequestDate + '\",\"'
	        	+ cancelledDate + '\",\"'
	        	+ freeMonths + '\",\"'
	        	+ lhrw + '\",\"'
	        	+ competitor + '\",\"'
	        	+ p.Related_Contact__r.FirstName + '\",\"' 
				+ p.Related_Contact__r.LastName + '\",\"'  
				+ p.NPI__c + '\",\"' 
				+ p.Healthgrades_ID__c + '\",\"' 
				+ p.Premium_Member__c + '\",\"' 
				+ p.Bill_to_Account__r.Name + '\",\"' 
				+ p.Bill_to_Account__r.ShippingStreet + '\",\"' 
				+ p.Bill_to_Account__r.ShippingCity + '\",\"' 
				+ p.Bill_to_Account__r.ShippingState + '\",\"' 
				+ p.Bill_to_Account__r.ShippingPostalCode + '\",\"' 
				+ p.Bill_to_Account__r.ShippingCountry + '\",\"' 
				+ p.Bill_to_Account__r.Phone + '\",\"' 
				+ p.Email__c + '\",\"'
	        	+ SRUtilities.getRecordTypeName('Provider__c', p.RecordTypeId) + '\",\"'
	        	+ p.Insurance_Accepted__c + '\",\"'
	        	+ p.State_License__c + '\",\"'
	        	+ p.Licensing_State__c + '\",\"'
	        	+ p.Degree__c + '\",\"'
	        	+ p.Gender__c + '\",\"'
	        	+ p.Practice_Name__c + '\",\"'
	        	+ primaryProviderSpecialty + '\",\"'
	        	+ providerSpecialties + '\",\"'
	        	+ providerConditions + '\",\"'
	        	+ providerProcedures + '\",\"'
	        	+ p.Practice_URL__c + '\",\"'
	        	+ p.Bill_to_Account__r.Limelight_URL_for_Healthgrades__c + '\",\"' 
	        	+ p.Practice_Image_Link__c + '\",\"'
	        	+ p.Practice_Video_Link__c + '\",\"'
	        	+ p.Provider_Photo_Link__c + '\",\"'
	        	+ p.Accepting_New_Patients__c + '\",\"'
	        	+ p.Languages_Spoken__c + '\",\"'
	        	+ dateOfBirth + '\",\"'
	        	+ p.Medical_Dental_School__c + '\",\"'
	        	+ p.Year_Graduated__c + '\",\"'
				+ philosophy + '\",\"'
				+ contractSigner + '\",'
				+ '\n';

			finalDocument = finalDocument + thisProvider;
		}	

		update scope;	
  	}
	
	/**
	 * Finish Apex Batch
	 */
	global void finish(Database.BatchableContext BC) {
		
		Date yesterday = Date.today().addDays(-1);
		Date today	= Date.today();
		String subject = allRecords ? ': Healthgrades Daily Profile Data' : ': Healthgrades Daily Profile Data - Updates Only';

		Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
		Blob csvBlob = Blob.valueOf(finalDocument);
      	String csvName = 'HealthgradesDailyProfileData_'
         + System.now().addDays(-1).format('MM/dd/yyyy HH:mm:ss','America/Denver')
         + '.csv';
		csvAttachment.setFileName(csvName);
		csvAttachment.setBody(csvBlob);

		String msg = 'Please see attached Provider list. Lists are limited to 3500 records due to file size limitations.';

		ApexEmailDistributions__c emailSettings = ApexEmailDistributions__c.getValues(emailDistribution);
		String emails = Test.isRunningTest() ? 'randy@solutionreach.com' : emailSettings.Emails__c;
		if(!Test.isRunningTest() && emailSettings.Emails1__c != null) emails += ',' + emailSettings.Emails1__c;
		if(!Test.isRunningTest() && emailSettings.Emails2__c != null) emails += ',' + emailSettings.Emails2__c;
		String[] emailsList = emails.split(',');

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setSubject(yesterday.year() + '_' + yesterday.month() + '_' + yesterday.day() + subject);
		mail.setPlainTextBody(msg);
		mail.setFileAttachments(new Messaging.EmailFileAttachment[] { csvAttachment });
		mail.setToAddresses(emailsList);

		try{

			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

			if(errors != '')
			{
				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	    		message.setSubject('HealthgradesDailyProfileData Error');
	    		message.setPlainTextBody('The following errors were detected: ' + errors);
	    		message.setToAddresses(new String[] {'randy@solutionreach.com'});
	    		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
			}

			if(allRecords)
			{
				Provider__c[] remaining = [SELECT Id FROM Provider__c WHERE Id IN (SELECT Provider__c FROM Asset) AND Last_Reported_Date__c != :today LIMIT 3500];
				
				if(remaining.size() > 0)
				{
					HealthgradesDailyProfileData batch = new HealthgradesDailyProfileData(allRecords, emailDistribution);
					Database.executebatch(batch, 2);
				}
			}
		
		} catch(Exception e) {

			mail.setFileAttachments(null);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    		message.setSubject('HealthgradesDailyProfileData Error');
    		message.setPlainTextBody('The following exception details were caught.  Type: ' + e.getTypeName()
    									+ ' Cause: ' + e.getCause() 
    									+ ' Message: ' + e.getMessage() 
    									+ ' Stack Trace: ' + e.getStackTraceString());
    		message.setToAddresses(new String[] {'randy@solutionreach.com'});
    		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		}
	}

	global void execute(SchedulableContext sc) {
		
		HealthgradesDailyProfileData batch = new HealthgradesDailyProfileData(allRecords, emailDistribution);
		Database.executebatch(batch, 2);
	}	
}