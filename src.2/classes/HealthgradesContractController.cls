public without sharing class HealthgradesContractController extends WebFormsUtilityClass {
    
    public String providerId { get; set; }
    public String oppId { get; set; }
    public String signName { get; set; }
    public String contactSalutation { get; set; }
    public String contactFirstName { get; set; }
    public String contactLastName { get; set; }
    public String contactEmail { get; set; }
    public String contactPhone { get; set; }
    public String contractIP { get; set; }
    public String errorMessage { get; set; }
    public String contractTerm { get; set; }
    public String contractFreeMonths { get; set; }
    public String contractDateTime { get; set; }
    public Boolean renderForm { get; set; }
    public Boolean renderError { get; set; }
    public Boolean renderConfirmation { get; set; }
    public Boolean requestedEmail { get; set; }
    public Boolean acceptedRenewal { get; set; }
    public Boolean acceptedTerms { get; set; }
    public Provider__c prov { get; set; }
    public Opportunity relatedOpportunity { get; set; }
    public Contact relatedContact { get; set; }
    public Account relatedAccount { get; set; }
    public RecurSoft__Product_Subscription__c relatedProdSubscription { get; set; }
    public OpportunityLineItem[] relatedOppLis { get; set; }
    
    /**
     * Constructor to initialize variables. String variables are used for contact information to be displayed and edited on the public facing site.
     * If relatedContact field values are used directly, the update fails because of Guest User permission limitations.
     */
    public HealthgradesContractController() {
          
        providerId = getURParameter('id');
        oppId = getURParameter('oppId');
        signName = '';
        acceptedRenewal = false;
        acceptedTerms = false;
        prov = retrieveProviderData(providerId);

        try {

            relatedProdSubscription = retrieveSubscriptionData(prov.Bill_to_Account__c);
            contractTerm = String.valueOf(calculateContractStartDate(relatedProdSubscription.RecurSoft__Contract_Term_Start_Date__c).monthsBetween(relatedProdSubscription.RecurSoft__Contract_Term_End_Date__c));

        } catch(Exception e) {

            errorMessage = Label.NotCurrentCustomer;
            renderForm = false;
            renderError = true;
            renderConfirmation = false;
            System.debug(e);
        }

        try {
 
            relatedOpportunity = retrieveOpportunityData(oppId);
            relatedContact = retrieveContactData(prov.Related_Contact__r.Id);
            relatedAccount = retrieveAccountData(prov.Bill_to_Account__r.Id);
            relatedOppLis = relatedOpportunity.OpportunityLineItems;
            contactSalutation = relatedContact.Salutation;
            contactFirstName = relatedContact.FirstName;
            contactLastName = relatedContact.LastName;
            contactEmail = relatedContact.Email;
            contactPhone = relatedContact.Phone;
            contractIP = relatedOpportunity.Contract_Signed_IP__c;
            errorMessage = Label.ContractExpired;
            contractFreeMonths = relatedOpportunity.HGFreeMonths__c == null ? '0' : String.valueOf(relatedOpportunity.HGFreeMonths__c);
            contractDateTime = String.valueOf(relatedOpportunity.Contract_Date_Time__c);
            renderForm = readyForContract();
            renderError = !readyForContract();
            renderConfirmation = false;

        } catch(Exception e) {

            errorMessage = Label.ContractExpired;
            renderForm = false;
            renderError = true;
            renderConfirmation = false;
            System.debug(e + ' ' + e.getLineNumber());
        }
    }

    /**
     * Check to see that the relatedOpportunity isn't already closed. 
     * Check that the related Provider has a Healthgrades URL and isn't already Premium.
     */
    public Boolean readyForContract() {

        Boolean results = true;

        Pattern regexPattern = Pattern.compile('(.*)(healthgrades\\.com\\/)(((dentist|physician)\\/([a-z]+\\-){3,}[a-z0-9]{5,10})|(provider\\/([a-z]*\\-){2,}[a-z0-9]{5,10}))((\\?|\\/|#)(.*))?');
        Matcher regexMatcher = regexPattern.matcher(prov.Healthgrades_ID__c);

        if(!validateOpp(relatedOpportunity) ||
            isEmptyOrNull(prov.Healthgrades_ID__c) ||
            prov.Premium_Member__c) {

            results = false;
            errorMessage = Label.Outstanding_Approvals;

        } else if(!regexMatcher.matches()) {

            results = false;
            errorMessage = 'The Healthgrades URL is not formatted correctly.  Please contact your Sales Representative.';

        } else if(relatedProdSubscription == null) { 

            results = false; 
            errorMessage = Label.NotCurrentCustomer;
        } 

        return results;
    }

    /**
     * Update Provider and Contact with any customer-made changes.
     * Update the Opportunity with timestamps, IP address, and Closed Won.
     * Show Confirmation page to customer.
     * Call method to generate PDF of signed contract.
     */
    public void submitForm() {
        
        String errorMsg = 'Please complete all required fields';

        Opportunity currentOpp = retrieveOpportunityData(oppId);

        if(!validateOpp(currentOpp)) {

            errorMsg = Label.Outstanding_Approvals;
            ApexPages.addMessage(returnFailure(errorMsg));
        
        } else {

            if(requiredFieldsComplete()) {
            
                try{

                    update prov;
                
                    relatedContact.FirstName = contactFirstName;
                    relatedContact.LastName = contactLastName;
                    relatedContact.Email = contactEmail;
                    relatedContact.Phone = contactPhone;
                    update relatedContact;

                    relatedOpportunity.RecurSoft__Contract_Signed_Date__c = Date.today();
                    relatedOpportunity.Contract_Date_Time__c = Datetime.now();
                    relatedOpportunity.Contract_Signer__c = signName;
                    relatedOpportunity.CloseDate = Date.today();
                    relatedOpportunity.Contract_Signed_IP__c = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
                    relatedOpportunity.Contract_Signed__c = true;
                    //relatedOpportunity.RecurSoft__Trial__c = 'None';
                    if(relatedProdSubscription != null) {
                        FlowControl.hgContractDatesSet = true;
                        relatedOpportunity.RecurSoft__Contract_Term_End_Date__c = relatedProdSubscription.RecurSoft__Contract_Term_End_Date__c;
                        relatedOpportunity.RecurSoft__Contract_Term_Start_Date__c = calculateContractStartDate(relatedProdSubscription.RecurSoft__Contract_Term_Start_Date__c);
                        contractTerm = String.valueOf(relatedOpportunity.RecurSoft__Contract_Term_Start_Date__c.monthsBetween(relatedOpportunity.RecurSoft__Contract_Term_End_Date__c));
                        relatedOpportunity.RecurSoft__Billing_Contact__c = relatedProdSubscription.RecurSoft__Bill_to_Contact__c;
                        relatedOpportunity.RecurSoft__Shipping_Contact__c = relatedProdSubscription.RecurSoft__Ship_to_Contact__c;
                        relatedOpportunity.RecurSoft__Bill_to_Account__c = relatedProdSubscription.RecurSoft__Bill_to_Account__c;
                    }
                    update relatedOpportunity;

                    if(!System.isFuture() && !System.isBatch()) closeOpp(new Set<Id>{relatedOpportunity.Id});

                    renderForm = false;
                    renderConfirmation = true;
                    contractDateTime = String.valueOf(Datetime.now());
                    contractIP = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
                    generateContractPdf();
                
                } catch(Exception e) {

                    errorMessage = Label.GenericContractError;
                    renderForm = false;
                    renderError = true;
                    renderConfirmation = false;

                    Error_Log__c error = new Error_Log__c(
                        Error_Message__c = 'Healthgrades Contract Error(submitForm): ' + e,
                        Error_Type__c = 'Healthgrades Contract Error(submitForm)',
                        Provider__c = prov.Id,
                        Opportunity__c = relatedOpportunity.Id);
                    insert error;
                }
                
            } else {

                ApexPages.addMessage(returnFailure(errorMsg));
            }
        } 
    }

    @future
    public static void closeOpp(Set<Id> oppIds) {

        Map<ID, SObject> mapInsertSObject = new Map<ID, SObject>();
        Map<ID, SObject> mapUpdateSObject = new Map<ID, SObject>();
        Map<ID, SObject> mapDeleteSObject = new Map<ID, SObject>();

        Opportunity[] oppsToClose = [SELECT Id, StageName FROM Opportunity WHERE Id IN :oppIds];

        for(Opportunity o : oppsToClose) {

            if(o.StageName == 'Closed Won') continue;

            o.StageName = 'Closed Won';
            mapUpdateSObject.put(o.Id, o);
        }

        SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'HealthgradesContractController.closeOpp');
    }

    public Boolean validateOpp(Opportunity opp) {
        
        Boolean result = true;

        if((opp.Approval_Level_Required__c != null && opp.Approval_Level_Required__c > 0) ||
            opp.Contract_Signed__c ||
            opp.StageName == 'Closed Won' ||
            opp.StageName == 'Closed Lost' ||
            opp.CloseDate < Date.today() ||
            !opp.HasOpportunityLineItem) {

            result = false;
        } 
            
        return result;
    }

    /**
     * Check required fields on contract form have been filled in and terms have been accepted.
     */
    public Boolean requiredFieldsComplete() {
        
        Boolean results = true;

        results = (!isEmptyOrNull(contactFirstName) &&
            !isEmptyOrNull(contactLastName) &&
            !isEmptyOrNull(contactPhone) &&
            !isEmptyOrNull(contactEmail) &&
            !isEmptyOrNull(signName) &&
            acceptedRenewal &&
            acceptedTerms);

        return results;
    }

    public Date calculateContractStartDate(Date d) {

        Date results = Date.today();

        if(d >= results) {

            results = d;

        } else if(Date.newInstance(Date.today().year(), Date.today().month(), d.day()) >= Date.today()) {

            results = Date.newInstance(Date.today().year(), Date.today().month(), d.day());

        } else {

            results = Date.newInstance(Date.today().addMonths(1).year(), Date.today().addMonths(1).month(), d.day());
        }

        return results;
    }

    /**
     * Initialize and populate parameters for HealthgradesPDF vf Page with the related contract information.
     * Get content of HealthgradesPDF page as PDF.
     * Call method to send and attach the resulting PDF.
     * PDF not generated in test methods because PageReference.getContent() is not supported in test methods.
     * Any errors logged on related Provider record.
     */
    public void generateContractPdf() {

        Blob body;
        String fileName = relatedContact.FirstName + '_' + relatedContact.LastName 
            + '_Healthgrades_Service_Agreement_' 
            + System.now().format('MM/dd/yyyy HH:mm:ss','America/Denver')
            + '.pdf';

        try {
            PageReference pdf = new PageReference('/apex/HealthgradesPDF');
            pdf.getParameters().put('oppId', oppId);
            pdf.getParameters().put('contractDateTime', contractDateTime);
            pdf.getParameters().put('contractSignedIP', contractIP);
            pdf.getParameters().put('contractSigner', signName);
            pdf.getParameters().put('contractTerm', contractTerm);
            pdf.getParameters().put('contractFreeMonths', contractFreeMonths);
            pdf.getParameters().put('contractDate', Datetime.newInstance(relatedAccount.Probable_Most_Recent_K_Date__c, Datetime.now().time()).format('MMM d, yyyy'));
            pdf.getParameters().put('businessName', relatedAccount.Name);
            pdf.getParameters().put('addressStreet', relatedAccount.BillingStreet);
            pdf.getParameters().put('addressCity', relatedAccount.BillingCity);
            pdf.getParameters().put('addressState', relatedAccount.BillingState);
            pdf.getParameters().put('addressPostalCode', relatedAccount.BillingPostalCode);
            pdf.getParameters().put('addressCountry', relatedAccount.BillingCountry);
            pdf.getParameters().put('providerName', relatedContact.FirstName + ' ' + relatedContact.LastName);
            pdf.getParameters().put('providerEmail', relatedContact.Email);
            pdf.getParameters().put('providerPhone', relatedContact.Phone);
            pdf.getParameters().put('providerNPI', prov.NPI__c);
            pdf.getParameters().put('providerURL', prov.Healthgrades_ID__c);

            body = Test.isRunningTest() ? Blob.valueOf('Test') : pdf.getContent();

            sendAndAttachPdf(body, fileName);

        } catch (VisualforceException e) {
            Error_Log__c error = new Error_Log__c(
                Error__c = 'There was an error creating the Healthgrades PDF: ' + e,
                Error_Type__c = 'Healthgrades PDF Creation Error',
                Provider__c = providerId);
            insert error;
        }
    }

    /**
     * OrgWideEmailAddress(sales@solutionreach.com) and Email Template Ids are set from custom settings.
     * Contract PDF attached and emailed to relatedContact email if customer checks box to receive email.
     * Contract PDF attached and emailed to applications@solutionreach.com.
     * Contract PDF attached to related contact.
     * Any errors are logged on the related Provider record.
     * @param body - PDF version of contract
     * @param fileName - Contract PDF filename
     * @see this.generateContractPdf
     */
    public void sendAndAttachPdf(Blob body, String fileName) {

        ContractEmailTemplate__c contractEmailTemplateID = ContractEmailTemplate__c.getValues('HealthgradesContract');

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setContentType('application/pdf');
        attachment.setFileName(fileName);
        attachment.setInline(false);
        attachment.body = body;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment }); 
        mail.setTemplateId(contractEmailTemplateID.TemplateID__c);
        mail.setTargetObjectId(relatedContact.Id);

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSubject('Thank you for your business!');
        message.setPlainTextBody('Thank you for signing up for a Healthgrades Premium Profile. Please stay tuned for more information regarding our service and your personal Customer Success Representative. This email and attachment are confirmation we have received and processed your contract. Please retain a copy for your records and future reference. If you have any questions or concerns, you may contact support toll free at (866) 605-6867 or by email to support@solutionreach.com.');
        message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        message.setToAddresses(new String[] { 'applications@solutionreach.com' });

        try {
            if(requestedEmail) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail,message });

            } else {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
            }
            

        } catch (Exception e) {
            Error_Log__c error = new Error_Log__c(
                Error__c = 'There was an error sending the Healthgrades PDF email: ' + e,
                Error_Type__c = 'Healthgrades PDF Email Error',
                Provider__c = providerId);
            insert error;
        }

        try {
            Attachment accountAttachment = new Attachment();
            accountAttachment.ParentId = relatedOpportunity.Id;
            accountAttachment.Name = fileName;
            accountAttachment.Body = body;
            insert accountAttachment;

        } catch (Exception e) {
            Error_Log__c error = new Error_Log__c(
                Error__c = 'There was an error attaching the Healthgrades PDF to the Opportunity: ' + e,
                Error_Type__c = 'Healthgrades PDF Attachment Error',
                Provider__c = providerId);
            insert error;
        }
    }
}