/**
 * File:        AppAdminAPIClass.cls
 * Project:     Solutionreach 
 * Date:        March 27, 2014
 * Created By:  Sid Maganti
 * Updated By:  Matthew Schetselaar (Solutionreach)
 * Last Update: May 29, 2018
 * *************************************************************************
 * Description: This class will be used to generate XML structure for creating appAdmin accounts and
 *  this class will be called by trigger on Opportunity when Opportunity stage is Closed Won
 * *************************************************************************
 * History:
 *  Updated the email that goes out to include "Initial Setup" information for WalkMe - MS
 *  Updated the Contact to use the Business Contact Role instead of Office Contact
 *  Include enterprise boolean and Parent Subscriber Id for enterprise accounts
 */

global without sharing class AppAdminAPIClass 
{
    //varaibles used to store values for AppAdmin API call
    private static String username;
    private static String password;
    private static String targetUrl;
    private static String statusCode;
    private static String requestUrl;
    private static Decimal practiceNameLength;
    private static String requestType;
    
     /**
     * Gets the values from AppAdminAPI Settings custom settings 
     * These are credentials
     * Set the endpoint URL to either the test URL or the Production URL based on the Custom Setting for isProduction
     * NOTE: Any URL entered here MUST be configured in Salesforce as a valid URL to connect.
    */
    private static void getSettings(String settingName, String subscriberId) 
    {
        Boolean isProduction = false;
        AppAdminAPI_Settings__c AppAdmin = AppAdminAPI_Settings__c.getValues(settingName);

        isProduction = AppAdmin.isProduction__c;
        statusCode = AppAdmin.successStatusCode__c;
        requestType = AppAdmin.requestType__c;
        practiceNameLength = AppAdmin.practiceNameLength__c;
        username = isProduction ? AppAdmin.productionUsername__c : AppAdmin.sandboxUsername__c;
        password = isProduction ? AppAdmin.productionPassword__c : AppAdmin.sandboxPassword__c;
        targetUrl = isProduction ? AppAdmin.productionTargetUrl__c : AppAdmin.sandboxTargetUrl__c;
        requestUrl = isProduction ? AppAdmin.productionRequestUrl__c : AppAdmin.sandboxRequestUrl__c;    

        if(targeturl.contains('{subscriberIdx}')) 
        {
            targeturl = targeturl.replace('{subscriberIdx}', subscriberId);
        }

        if(practiceNameLength == null) 
        {
            practiceNameLength = 33;
        }
    }

     /**
     * Creates the request
     * @param request
     * @return req
    */
    global static HttpRequest buildHttpRequest(DOM.Document request)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(targeturl);
        req.setMethod(requestType);
        req.setHeader('Content-Type', 'application/xml');
        req.setHeader('Accept', 'application/xml');
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +
        EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setBodyDocument(request);
        req.setTimeout(120000);
        
        return req; 
    }   
    
    /**
     * Sends the request  
     * @param requestBody
     * @return result
    */
    global static HTTPResponse sendRequest(DOM.Document requestBody, Opportunity opp)
    {
        String result = '';System.debug('requestBody'+requestBody.toXmlString());
        getSettings('APISettings', null);
        HttpRequest req = buildHttpRequest(requestBody);
        System.debug('Request: ' + req.getBodyDocument().toXmlString());
        Http http = new Http();
        HTTPResponse response = new HTTPResponse();
        if(!System.Test.isRunningTest()) 
        {
            response = http.send(req);
            result = response.getBody();
        }
        else
        {
            String testresult='';
            testresult='<?xml version="1.0"?>'+
            '<validationErrors>'+
                 '<validationError>'+
                     '<message>firstName is required</message>'+
                     '<messageTemplate>firstName is required</messageTemplate>'+
                     '<path>Application.createApplication.arg0.firstName</path>'+
                 '</validationError>'+
            ' </validationErrors>';
        }
        return response;
    }

/*
     * Future method designed to be called from Opportunity Trigger and  to create subscriber in App Admin
     *@params objectIds
    */
    @future(callout=true)
    public static void syncOpportunityAppAdmin(Set<Id> objectIds)
    {
        Opportunity[] scope = new List<Opportunity>();
        Opportunity[] listOpp = new List<Opportunity>();
        Error_Log__c[] errorLoglist = new List<Error_Log__c>();
        Account[] Accountlist = new List<Account>();
        Set<String> setAccountID = new Set<String>();
        
        scope = OpportunitiesSelector.newInstance().selectByIdWithAccountsContactsAndProducts(objectIds);
        
        if(scope.size() > 0)
        {
            //Because the App admin api will create only one record at a time looping the opportunity 
            //this will show an error if number of call outs are greater than 10 in transaction need to 
            //get updated.
            for(Opportunity opp : scope)
            {
                Boolean hasSR = false;
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartArray();

                for(OpportunityLineItem oppLi : opp.OpportunityLineItems) 
                {
                    if(oppLi.PricebookEntry.Product2.Family == 'SR Platform' || oppLi.PricebookEntry.Product2.Family == 'SR Reminders') hasSR = true;
                    if(oppLi.PricebookEntry.Product2.AppAdminProductKey__c == null || oppLi.PricebookEntry.Product2.Family == null) continue;

                    gen.writeStartObject();
                    gen.writeStringField('key', oppLi.PricebookEntry.Product2.AppAdminProductKey__c);
                    gen.writeStringField('name', oppLi.PricebookEntry.Product2.Family);
                    gen.writeBooleanField('active', true);
                    gen.writeEndObject();
                }

                gen.writeEndArray();            
                String jsonProducts = gen.getAsString();
                System.debug(jsonProducts);

                if(!hasSR && 
                    opp.RecordTypeId != SRUtilities.getRecordTypeMap('Opportunity').get('Healthgrades').getRecordTypeId()) 
                {
                    AppAdminAPIClass.closeNonSROpp(opp);
                    continue;
                }

                // Checking if bill to account is having subscriber id or not
                
                if(opp.Account.Subscriber_ID__c == null)
                {
                    HTTPResponse response = new HTTPResponse();
                    response = sendRequest(buildTransaction(opp),opp);
                    System.debug('Response: ' + response);
                    System.debug('response.getStatusCode(): ' + response.getStatusCode());
                    System.debug('response.getHeaderKeys(): ' + response.getHeaderKeys());
                    System.debug('response.getStatus(): ' + response.getStatus());
                    System.debug('response.getHeader(Location): ' + response.getHeader('Location'));
                    if(String.valueOf(response.getStatusCode()) != statuscode)
                    {
                        Error_Log__c error = new Error_Log__c(
                            Error_Message__c = response.getBody(),
                            Error_Type__c = 'AppAdmin Sync Error',
                            Opportunity__c = opp.Id);

                        errorLoglist.add(error);
                        //errorLoglist.addAll(getResponseMessage(response.getBody(),opp));
                    }
                    else
                    {
                        if(!setAccountID.contains(opp.AccountId) || System.Test.isRunningTest())
                        {
                            Account acc = new Account();
                            acc.Id = opp.AccountId;
                            acc.Subscriber_ID__c = System.Test.isRunningTest() ? 'test' : response.getHeader('Location').replaceAll(requestUrl,'');
                            System.debug('acc.Subscriber_ID__c-->' + acc.Subscriber_ID__c);

                            acc = AppAdminAPIClass.getAccountNumberAndUsername(acc);

                            acc.Password_Reset_URL__c = AppAdminAPIClass.getPasswordResetBySubscriberId(acc.Subscriber_Id__c);

                            acc.Limelight_URL__c = AppAdminAPIClass.getLimelightUrlBySubscriberId(acc.Subscriber_Id__c);

                            AppAdminAPIClass.syncAccountProducts(jsonProducts, acc);

                            if(acc.Admin_Username__c != null && acc.Admin_Username__c != '' && acc.Password_Reset_URL__c != null && acc.Password_Reset_URL__c != '' && !opp.Do_Not_Send_Login_Details__c) 
                            {
                                AppAdminAPIClass.sendLoginEmail(opp, acc.Admin_Username__c, acc.Password_Reset_URL__c);
                            }
                            setAccountID.add(acc.Id);
                            Accountlist.add(acc);
                            opp.Ok_to_Sync_to_Intacct__c = SRHGlobalVariables.READY_TO_SYNC;
                            listOpp.add(opp);
                            System.debug(opp.RecurSoft__Initial_Contract_Term__c);
                        }
                    }
                }
                else
                {
                    AppAdminAPIClass.syncAccountProducts(jsonProducts, opp.Account);
                    listOpp.add(opp);
                    System.debug(opp.RecurSoft__Initial_Contract_Term__c);
                }
            }
            if(Accountlist.size()>0) 
            {
                Database.SaveResult[] srList = Database.update(Accountlist,false);
                
                for(Database.SaveResult sr : srList) 
                {    
                    if(!sr.isSuccess()) 
                    {
                        System.debug(sr.getErrors());
                    }
                }
            }
            
            if(errorLoglist.size() > 0) Database.insert(errorLoglist,false);
            
            if(listOpp.size()>0)
            {
                //IntacctIntegrationScheduler    
                Datetime thisTime = system.now().addSeconds(10); 
                Integer minute = thisTime.minute(); 
                Integer second = thisTime.second(); 
                Integer hour = thisTime.hour(); 
                Integer year = thisTime.year(); 
                Integer month = thisTime.month(); 
                Integer day = thisTime.day(); 
                
                String timeStamp = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year; 
                String jobName = 'IntacctIntegrationScheduler'+system.now(); 
                
                IntacctIntegrationScheduler p = new IntacctIntegrationScheduler(); 
                String jobID = system.schedule(jobName, timeStamp , p);
                for(Opportunity opp : listOpp)
                {
                    opp.Ok_to_Sync_to_Intacct__c = jobID;
                }
                System.debug('jobID-->'+jobID);
                Database.update(listOpp,false);
            }
        }
    }

    public static void closeNonSROpp(Opportunity o) 
    {
        Map<ID, SObject> mapInsertSObject = new Map<ID, SObject>();
        Map<ID, SObject> mapUpdateSObject = new Map<ID, SObject>();
        Map<ID, SObject> mapDeleteSObject = new Map<ID, SObject>();

        o.StageName = 'Closed Won';
        mapUpdateSObject.put(o.Id, o);

        SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'AppAdminAPIClass.closeNonSROpp');
    }


    public static void sendLoginEmail(Opportunity o, String accUserName, String accPasswordResetURL) 
    {
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support@solutionreach.com'];

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSubject('Accessing Your Solutionreach Account');
        message.setPlainTextBody('Congratulations on signing up for Solutionreach! We encourage you to login to the Solutionreach platform ' +
            'and begin to customize your account today. Accessing your account is simple. Just follow the link below to create your password: \n\n' +
            'Your Solutionreach username is: ' + accUserName + '\n\n' + 
            accPasswordResetURL + '\n\n\n' +
            'Once logged in, we encourage you to become familiar with the many patient relationship management tools you have at your fingertips! A few suggestions for you to do today: \n\n' +
            '1.  Complete the "Initial Setup" guides for a timely activation of you account. \n\n' +
            '2.  View materials in the Help Center to begin learning how to utilize all that Solutionreach has to offer \n\n\n' +
            'Someone will be reaching out to you within the next few days to schedule your activation. We look forward to serving you! \n\n' +
            'Sincerely, \n\n' +
            'The Solutionreach Client Success Team');
        message.setTargetObjectId(o.RecurSoft__Billing_Contact__c);
        message.setWhatId(o.AccountId);
        message.setSaveAsActivity(true);
        message.setBccAddresses(new String[] { 'randy@solutionreach.com' });
        
        if(owea.size() > 0) 
        {
            message.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        
        try 
        {                    
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
            
        } 
        catch (Exception e) 
        {    
            Error_Log__c error = new Error_Log__c(
                Error__c = 'There was an error sending the Login Details email: ' + e.getMessage(),
                Error_Type__c = 'Login Details Email Error',
                Opportunity__c = o.Id);
            insert error;
        }
    }


/**
     * Build APP Admin API Mapping 
     * @param list of Opportunity
     * @return DOM.Document
    */
 /*
<?xml version="1.0"?>
<application>
    <address1>2912 Executive Parkway</address1>
    <address2>Suite 300</address2>
    <city>Lehi</city>
    <comments>Here are some comments about the Lehi Dental practice.</comments>
    <country>USA</country>
    <docEmail>personalemail@somewhere.com</docEmail>
    <docPhone>8011234567</docPhone>
    <email>dentist@lehidental.com</email>
    <faxAreaCode>801</faxAreaCode>
    <faxLine>2034</faxLine>
    <faxPrefix>772</faxPrefix>
    <firstName>Kathryn</firstName>
    <lastName>Johnson</lastName>
    <marketIdx>1</marketIdx>
    <numberOfProviders>2</numberOfProviders>
    <phoneAreaCode>801</phoneAreaCode>
    <phoneLine>7100</phoneLine>
    <phonePrefix>331</phonePrefix>
    <practiceName>Lehi Dental</practiceName>
    <referral>Brad Peterson</referral>
    <state>UT</state>
    <timeZone>America/Denver</timeZone>
    <url>www.lehidental.com</url>
    <zip>84043</zip>
</application>
 */
    public static DOM.Document buildTransaction(Opportunity opp)
    {
        Map<String, OpportunityContactRole> ocrMap = OpportunityContactRolesSelector.newInstance().selectRoleMapByOpportunityIdWithContact(new Set<Id>{ opp.Id });
        OpportunityContactRole businessContactRole = ocrMap.get('Business Contact');
        OpportunityContactRole billingContactRole = ocrMap.get('Billing Contact');
        
        String isEnterprise = 'false';
        String parentSubscriberId = '';

        if(opp.Account.RecordTypeId==SRUtilities.getRecordTypeId('Account','Major Account')||
            opp.Account.RecordTypeId==SRUtilities.getRecordTypeId('Account','Child Major Account')||
            opp.Account.RecordTypeId==SRUtilities.getRecordTypeId('Account','Multi-Location Account')||
            opp.Account.RecordTypeId==SRUtilities.getRecordTypeId('Account','Child Multi-Location Account'))
        {
            isEnterprise = 'true';
            parentSubscriberId = opp.Account.ParentId == null ? 'null' : opp.Account.Parent.Subscriber_Id__c;
        }

        String firstName = '';
        String lastName = '';
        getSettings('APISettings', null);
        
        DOM.Document XML = new DOM.Document();
        XML.load('<application></application>');
        DOM.xmlNode applicationNode = XML.getRootElement();
        applicationNode.addChildElement('address1', null, null).addTextNode(opp.Account.BillingStreet==null ?'': opp.Account.BillingStreet);
        applicationNode.addChildElement('address2', null, null);     
        applicationNode.addChildElement('city', null, null).addTextNode(opp.Account.BillingCity==null ?'': opp.Account.BillingCity);
        applicationNode.addChildElement('comments', null, null).addTextNode(opp.Account.Description==null ?'': (opp.Account.Description.length()>500?opp.Account.Description.left(495):opp.Account.Description));
        applicationNode.addChildElement('country', null, null).addTextNode(opp.Account.BillingCountry==null ?'': opp.Account.BillingCountry);
        applicationNode.addChildElement('docEmail', null, null).addTextNode(billingContactRole.Contact.Email==null ?'': billingContactRole.Contact.Email);
        applicationNode.addChildElement('docPhone', null, null).addTextNode(billingContactRole.Contact.Phone==null?'':billingContactRole.Contact.Phone);
        applicationNode.addChildElement('email', null, null).addTextNode(businessContactRole.Contact.Email==null ?'':businessContactRole.Contact.Email);
        if(businessContactRole.Contact.Fax!=null)
        {
            applicationNode.addChildElement('faxAreaCode', null, null).addTextNode(businessContactRole.Contact.Fax==null?'':parsPhone(businessContactRole.Contact.Fax,'areacode'));
            applicationNode.addChildElement('faxLine', null, null).addTextNode(businessContactRole.Contact.Fax==null?'':parsPhone(businessContactRole.Contact.Fax,'linenumber'));
            applicationNode.addChildElement('faxPrefix', null, null).addTextNode(businessContactRole.Contact.Fax==null?'':parsPhone(businessContactRole.Contact.Fax,'prefix'));
        }
        else
        {
        applicationNode.addChildElement('faxAreaCode', null, null).addTextNode(businessContactRole.Contact.Phone==null?'':parsPhone( businessContactRole.Contact.Phone,'areacode'));
        applicationNode.addChildElement('faxLine', null, null).addTextNode(businessContactRole.Contact.Phone==null?'':parsPhone(businessContactRole.Contact.Phone,'linenumber'));
        applicationNode.addChildElement('faxPrefix', null, null).addTextNode(businessContactRole.Contact.Phone==null?'':parsPhone(businessContactRole.Contact.Phone,'prefix'));
        }
        applicationNode.addChildElement('firstName', null, null).addTextNode(businessContactRole.Contact.FirstName==null?'':businessContactRole.Contact.FirstName);
        applicationNode.addChildElement('lastName', null, null).addTextNode(businessContactRole.Contact.LastName==null ?'':businessContactRole.Contact.LastName);
        applicationNode.addChildElement('marketIdx', null, null).addTextNode(opp.Account.Industry==null?'':getMarketIndex(opp.Account.Industry,opp.Account.Sub_Vertical__c));
        applicationNode.addChildElement('planName' , null, null).addTextNode(opp.Pricebook2.AppAdmin_Plan_Name__c == null ? 'Premier' : opp.Pricebook2.AppAdmin_Plan_Name__c);
        if(opp.Account.Care_Credit_Merchant_ID__c!='' && opp.Account.Care_Credit_Merchant_ID__c !=null)
        {
            applicationNode.addChildElement('merchantId', null, null).addTextNode(opp.Account.Care_Credit_Merchant_ID__c);
        }
        applicationNode.addChildElement('numberOfProviders', null, null).addTextNode(opp.Number_of_Providers__c == null ? '1' : String.valueOf(opp.Number_of_Providers__c));
        applicationNode.addChildElement('numberOfPrt', null, null).addTextNode(opp.Number_of_PRT__c == null ? '3' : String.valueOf(opp.Number_of_PRT__c));
        applicationNode.addChildElement('phoneAreaCode', null, null).addTextNode(businessContactRole.Contact.Phone==null?'':parsPhone(businessContactRole.Contact.Phone,'areacode'));
        applicationNode.addChildElement('phoneLine', null, null).addTextNode(businessContactRole.Contact.Phone==null?'':parsPhone(businessContactRole.Contact.Phone,'linenumber'));
        applicationNode.addChildElement('phonePrefix', null, null).addTextNode(businessContactRole.Contact.Phone==null?'':parsPhone(businessContactRole.Contact.Phone,'prefix'));
        applicationNode.addChildElement('practiceName', null, null).addTextNode((opp.Account.Name.length()>practiceNamelength? opp.Account.Name.left(Integer.ValueOF(practiceNamelength)): opp.Account.Name ));
        applicationNode.addChildElement('referral', null, null).addTextNode(opp.Opportunity_Owner__c);
        applicationNode.addChildElement('state', null, null).addTextNode(opp.Account.BillingState==null ?'':opp.Account.BillingState);
        applicationNode.addChildElement('timeZone', null, null).addTextNode(opp.Account.SR_Timezone__c==null?'':opp.Account.SR_Timezone__c);
        applicationNode.addChildElement('url', null, null).addTextNode(opp.Account.Website==null?'':opp.Account.Website);
        applicationNode.addChildElement('zip', null, null).addTextNode(opp.Account.BillingPostalCode==null?'':opp.Account.BillingPostalCode);
        applicationNode.addChildElement('enterpriseAccount', null, null).addTextNode(isEnterprise);
        applicationNode.addChildElement('entSubscriberIdx', null, null).addTextNode(parentSubscriberId);
        
        return XML;
    }
    
    
    /*Pars phone numbers to Area code - prefix- linenumber
    *@ phone no , index= areacode or prefix or linenumber
    *@ return String part of phone no
    */
    public static String parsPhone(String PhoneNo,String index)
    {
        String phonePart='';
        System.debug('PhoneNo--index'+PhoneNo+'--'+index);
        if(PhoneNo!= null && PhoneNo.length()>0)
        {
            System.debug('PhoneNo-before-Scrubing->'+PhoneNo);
            PhoneNo= PhoneNo.trim();
            PhoneNo = PhoneNo.replaceAll('\\+', '');
            PhoneNo = PhoneNo.replaceAll('\\(', '');
            PhoneNo = PhoneNo.replaceAll('\\)', '');
            PhoneNo = PhoneNo.replaceAll(' ', '');
            PhoneNo = PhoneNo.replaceAll('-', '');
            PhoneNo = PhoneNo.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '');
            PhoneNo = PhoneNo.replaceAll('[a-zA-Z]', '');
            System.debug('PhoneNo-After-Scrubing->'+PhoneNo);
            if(PhoneNo.length()>10)
            {
                PhoneNo=PhoneNo.substring(PhoneNo.length()-10, PhoneNo.length());
                System.debug('PhoneNo'+PhoneNo);
            }
            System.debug('PhoneNo.length()-->'+PhoneNo.length());
            if(index=='areacode')
            {
                phonePart=PhoneNo.left(3);
            }
            else if(index=='linenumber')
            {
                phonePart=PhoneNo.right(4);
            }
            else if(index=='prefix')
            {
                phonePart=PhoneNo.substring(3, 6);
            }
        }
        System.debug('phonePart-->'+phonePart);
        
        return phonePart;
    }
    
    
    /*gets market index
    *@ Account
    *@ retrun String marketIndex
    */
    public static String getMarketIndex(String indus, String sub)
    {
        String marketIndex='';
        if(indus=='Dental')
        {
            marketIndex='1';
        }
        else if(indus=='Vision')
        {
            marketIndex='4';
        }
        else if(indus=='Medical')
        {
            marketIndex='3';
            if(sub=='Medical Spa or Aesthetic Medicine')
            {
                marketIndex='5';
            }
        }
        else if(indus=='Non-Medical')
        {
            marketIndex='8';
        }
        else if(indus=='Physical Rehabilitation')
        {
            marketIndex='7';
        }
        
        return marketIndex;    
    }
    
    /**
     *Parses the response from APP Admin
     *@params responseDom
     *@return List<Error_Log__c>
    */
    public static List<Error_Log__c> getResponseMessage(String responseFromAPPAdmin, Opportunity opp)
    {
        DOM.Document resultDocument = new DOM.Document();
        String testresult='<?xml version="1.0"?>'+
        '<validationErrors>'+
             '<validationError>'+
                 '<message>firstName is required</message>'+
                 '<messageTemplate>firstName is required</messageTemplate>'+
                 '<path>Application.createApplication.arg0.firstName</path>'+
             '</validationError>'+
        ' </validationErrors>';
        if(!System.Test.isRunningTest())
        {
            resultDocument.load(responseFromAPPAdmin);
        }
        else
        {
            resultDocument.load(testresult);
        }
        
        Error_Log__c[] errorLoglist = new List<Error_Log__c>();
        System.debug('responseFromAPPAdmin'+responseFromAPPAdmin);
        
        String rootName = resultDocument.getRootElement().getName();
        Boolean isSuccess = false;
        String[] aux = new List<String>();
        for(Dom.XmlNode responseLevelNode : resultDocument.getRootElement().getChildElements())
        {
            System.debug('responseLevelNode.getName()'+responseLevelNode.getName());
            if(responseLevelNode.getName().equals('validationError'))
            {
                 System.debug('responseLevelNode.getName()'+responseLevelNode.getName());
                 String path='';
                
                for(Dom.XmlNode validationErrorNode : responseLevelNode.getChildElements())
                {
                    System.debug('validationErrorNode.getName()'+validationErrorNode.getName());
                    System.debug('validationErrorNode.getName()'+validationErrorNode.getText());
                    
                    if(validationErrorNode.getName().equals('message'))
                    {
                        path=validationErrorNode.getText();
                    }
                    if(validationErrorNode.getName().equals('path'))
                    {
                        path=path+'--'+validationErrorNode.getText();
                    }
                    
                }
                
                if(path != '' && path != null)
                {
                    Error_Log__c ErrorLog = new Error_Log__c();
                    ErrorLog.Opportunity__c=opp.id;
                    ErrorLog.Account__c = opp.AccountId;
                    ErrorLog.Error_Type__c='AppAdmin_Error_Message';
                    ErrorLog.Error__c=path;
                    errorLoglist.add(ErrorLog);
                }
            }           
        }
        System.debug('errorLoglist'+errorLoglist);
        return errorLoglist;
    }

    public static void getSubscriberUsernameById(Set<Id> accountIds) 
    {
        Map<ID, SObject> mapInsertSObject = new Map<ID, SObject>();
        Map<ID, SObject> mapUpdateSObject = new Map<ID, SObject>();
        Map<ID, SObject> mapDeleteSObject = new Map<ID, SObject>();

        Map<Id, Account> mapAccts = new Map<Id, Account>(
            [SELECT Id,
            Subscriber_Id__c
            FROM Account
            WHERE Id IN: accountIds]);

        for(Account a : mapAccts.values()) 
        {
            try
            {
                HTTPResponse response = AppAdminAPIClass.sendRequestJson(null, 'SubscriberUserName', a.Subscriber_Id__c);
                System.debug(response.getBody());

                if(String.valueOf(response.getStatusCode()) != '200' &&
                    String.valueOf(response.getStatusCode()) != '201') 
                {
                    Error_Log__c error = new Error_Log__c(
                        Error_Message__c = response.getBody(),
                        Error_Type__c = 'SubscriberUserName Sync Error',
                        Account__c = a.Id);
                    mapInsertSObject.put(a.Id, error);
                } 
                
                else 
                {
                    JSONParser parser = JSON.createParser(response.getBody());
                    String newUserName = '';

                    while(parser.nextToken() != null) {

                        if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'userName')) {

                            parser.nextValue();
                            newUserName = parser.getText();
                            a.Admin_Username__c = newUserName;
                            mapUpdateSObject.put(a.Id, a);
                            System.debug(newUserName);
                            System.debug('nextToken: ' + parser.nextToken() + 'nextValue: ' + parser.nextValue());
                        }
                    }

                    SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'AppAdminAPIClass.getSubscriberUsername');
                }
            } 

            catch(Exception e) 
            {
                Error_Log__c error = new Error_Log__c(
                    Error_Message__c = 'There was an error sending the request to AppAdmin: ' + e,
                    Error_Type__c = 'SubscriberUserName Sync Error',
                    Account__c = a.Id);
                mapInsertSObject.put(a.Id, error);
            }
        }
    }

    public static String getSubscriberUsernameBySubscriberId(String subscriberId) 
    {
        try
        {
            HTTPResponse response = AppAdminAPIClass.sendRequestJson(null, 'SubscriberUserName', subscriberId);

            if(String.valueOf(response.getStatusCode()) != '200' &&
                String.valueOf(response.getStatusCode()) != '201') 
            {    
                System.debug(response.getBody());
                return '';
            } 

            else 
            {
                JSONParser parser = JSON.createParser(response.getBody());
                String newUserName = '';

                while(parser.nextToken() != null) 
                {
                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'userName')) 
                    {
                        parser.nextValue();
                        newUserName = parser.getText();
                    }
                }

                return newUserName;
            }
        } 

        catch(Exception e) 
        {
            System.debug(e);
            return '';
        }
    }

    public static Account getAccountNumberAndUsername(Account a) 
    {
        try
        {
            HTTPResponse response = AppAdminAPIClass.sendRequestJson(null, 'SubscriberUserName', a.Subscriber_ID__c);

            if(String.valueOf(response.getStatusCode()) != '200' &&
                String.valueOf(response.getStatusCode()) != '201') 
            {    
                System.debug(response.getBody());
            } 

            else 
            {
                JSONParser parser = JSON.createParser(response.getBody());
                String newUserName = '';

                while(parser.nextToken() != null) 
                {
                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME)) 
                    {
                        if(parser.getText() == 'userName')
                        {
                            parser.nextValue();
                            a.Admin_Username__c = parser.getText();
                        }
                        else if(parser.getText() == 'accountId')
                        {
                            parser.nextValue();
                            a.Admin_Account_Id__c = parser.getText();
                        }
                    }
                }
            }
        } 

        catch(Exception e) 
        {
            System.debug(e);
        }

        return a;
    }

    public static String getPasswordResetBySubscriberId(String subscriberId) 
    {
        try
        {
            HTTPResponse response = AppAdminAPIClass.sendRequestJson(null, 'PasswordReset', subscriberId);

            if(String.valueOf(response.getStatusCode()) != '200' &&
                String.valueOf(response.getStatusCode()) != '201') 
            {    
                System.debug(response.getBody());
                return '';
            } 

            else 
            {
                JSONParser parser = JSON.createParser(response.getBody());
                String passwordResetURL = '';

                while(parser.nextToken() != null) 
                {
                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'passwordResetURL')) 
                    {
                        parser.nextValue();
                        passwordResetURL = parser.getText();
                    }
                }

                return passwordResetURL;
            }
        } 

        catch(Exception e) 
        {
            System.debug(e);
            return '';
        }
    }

    public static String getLimelightUrlBySubscriberId(String subscriberId) 
    {
        try{

            HTTPResponse response = AppAdminAPIClass.sendRequestJson(null, 'LimelightURL', subscriberId);

            if(String.valueOf(response.getStatusCode()) != '200' &&
                String.valueOf(response.getStatusCode()) != '201') {
                
                System.debug(response.getBody());
                return '';
            
            } else {

                return response.getBody();
            }

        } catch(Exception e) {

            System.debug(e);
            return '';
        }
    }

    public static SRCEligibility getSRCEligibility(String phoneNumber) 
    {
        SRCEligibility eligibility = new SRCEligibility();

        try
        {
            HTTPResponse response = AppAdminAPIClass.sendRequestJson(null, 'SRCEligibility', phoneNumber);

            if(String.valueOf(response.getStatusCode()) != '200' &&
                String.valueOf(response.getStatusCode()) != '201') 
            {
                System.debug(response.getBody());
                eligibility.canProvision = false;
                eligibility.description = 'Invalid Phone Nubmer. Please make sure to check only 10 digit phone numbers without spaces, dashes, or other non-numeric characters.';

                return eligibility;
            } 
            else 
            {
                JSONParser parser = JSON.createParser(response.getBody());

                while(parser.nextToken() != null) 
                {
                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'code')) 
                    {
                        parser.nextValue();
                        eligibility.code = parser.getText();
                    }

                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'canProvision')) 
                    {
                        parser.nextValue();
                        eligibility.canProvision = parser.getBooleanValue();
                    }

                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'description')) 
                    {
                        parser.nextValue();
                        eligibility.description = parser.getText();
                    }
                }

                return eligibility;
            }

        } 
        catch(Exception e) 
        {
            System.debug(e);
            return eligibility;
        }
    }

    public class SRCEligibility
    {
        public String code;
        public Boolean canProvision;
        public String description;
    }

    /**
     * Creates a JSON with HG Provider information and calls methods to send to AppAdmin.
     * AppAdmin API accepts one Provider per call.
     * Any errors are logged on the related Provider record
     * @param providerIds - list of Provider Ids to be synced
     * @see ProductSubscriptionUtilities.setProviderPremiumStatus & ProductSubscriptionUtilities.cancelProviderPremiumStatus
     */
    public static void postHealthgradesStatus(Set<Id> providerIds) {

        Map<ID, SObject> mapInsertSObject = new Map<ID, SObject>();
        Map<ID, SObject> mapUpdateSObject = new Map<ID, SObject>();
        Map<ID, SObject> mapDeleteSObject = new Map<ID, SObject>();

        Map<Id, Provider__c> mapProviders = new Map<Id, Provider__c>(
            [SELECT Id,
            Healthgrades_ID__c,
            NPI__c,
            Premium_Member__c,
            (SELECT Id,
                Synced_with_AppAdmin_Date__c
                FROM Assets__r 
                LIMIT 1)
            FROM Provider__c
            WHERE Id IN: providerIds]);

        for(Provider__c p : mapProviders.values()) {

            String npi = p.NPI__c == null ? '' : p.NPI__c;

            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            //gen.writeStringField('npi', npi);
            gen.writeStringField('providerUrl', p.Healthgrades_ID__c);
            gen.writeBooleanField('premiumSubscriber', p.Premium_Member__c);
            gen.writeEndObject();
            String jsonProviderInfo = gen.getAsString();
            System.debug(jsonProviderInfo);
            
            try{

                HTTPResponse response = AppAdminAPIClass.sendRequestJson(jsonProviderInfo, 'HealthgradesSettings', null);

                if(String.valueOf(response.getStatusCode()) != '200' &&
                    String.valueOf(response.getStatusCode()) != '201') {
                    Error_Log__c error = new Error_Log__c(
                        Error_Message__c = response.getBody(),
                        Error_Type__c = 'Healthgrades Sync Error',
                        Provider__c = p.Id);
                    mapInsertSObject.put(p.Id, error);
                
                } else {

                    p.Synced_with_AppAdmin_Date__c = Datetime.now();
                    mapUpdateSObject.put(p.Id, p);

                    if(!p.Assets__r.isEmpty()) {

                        p.Assets__r[0].Synced_with_AppAdmin_Date__c = Datetime.now();
                        mapUpdateSObject.put(p.Assets__r[0].Id, p.Assets__r[0]);
                    }
                }

            } catch(Exception e) {

                Error_Log__c error = new Error_Log__c(
                    Error_Message__c = 'There was an error sending the request to AppAdmin: ' + e,
                    Error_Type__c = 'Healthgrades Sync Error',
                    Provider__c = p.Id);
                mapInsertSObject.put(p.Id, error);
            }
        }

        SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'AppAdminAPIClass.postHealthgradesStatus');
    }

    /**
     * Creates a JSON with Limelight status and calls methods to send to AppAdmin.
     * AppAdmin API accepts one Subscriber per call.
     * Any errors are logged on the related Asset record
     * @param providerIds - list of Provider Ids to be synced
     * @see ProductSubscriptionUtilities.setProviderPremiumStatus & ProductSubscriptionUtilities.cancelProviderPremiumStatus
     */
    public static void postAssetStatus(Set<Id> ids) 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Asset[] assets = AssetsSelector.newInstance().selectByIdWithAccountAndProduct(ids);

        for(Asset a : assets) 
        {            
            if(a.Product2.AppAdminProductKey__c == null || a.Product2.Family == null || a.Product2.Family == 'SR Platform') continue;

            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('key', a.Product2.AppAdminProductKey__c);
            gen.writeStringField('name', a.Product2.Family);
            gen.writeBooleanField('active', true);
            gen.writeEndObject();
            gen.writeEndArray();
            String jsonProducts = gen.getAsString();
            System.debug(jsonProducts);
            
            try 
            {    
                HTTPResponse response = AppAdminAPIClass.sendRequestJson(jsonProducts, 'ProductsAPI', a.Account.Subscriber_ID__c);

                if(String.valueOf(response.getStatusCode()) != '200' &&
                    String.valueOf(response.getStatusCode()) != '201') 
                {
                    Error_Log__c error = new Error_Log__c(
                        Error_Message__c = response.getBody(),
                        Error_Type__c = 'Asset Sync Error',
                        Asset__c = a.Id);
                    uow.registerNew(error);
                } 
                
                else 
                {
                    a.Synced_with_AppAdmin_Date__c = Datetime.now();
                    uow.registerDirty(a);
                }
            } 

            catch(Exception e) 
            {
                Error_Log__c error = new Error_Log__c(
                    Error_Message__c = 'There was an error sending the request to AppAdmin: ' + e,
                    Error_Type__c = 'Asset Sync Error',
                    Asset__c = a.Id);
                uow.registerNew(error);
            }
        }

        uow.commitWork();
    }

    public static void syncAccountProducts(String jsonProducts, Account account) 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            
        try 
        {    
            HTTPResponse response = AppAdminAPIClass.sendRequestJson(jsonProducts, 'ProductsAPI', account.Subscriber_ID__c);

            if(String.valueOf(response.getStatusCode()) != '200' &&
                String.valueOf(response.getStatusCode()) != '201') 
            {
                Error_Log__c error = new Error_Log__c(
                    Error_Message__c = response.getBody(),
                    Error_Type__c = 'Account Products Sync Error',
                    Account__c = account.Id);
                uow.registerNew(error);
            } 

            else
            {
                System.debug('Account Products Synced Successfully for ' + account.Subscriber_ID__c);
                System.debug(jsonProducts);
            }
        } 

        catch(Exception e) 
        {
            Error_Log__c error = new Error_Log__c(
                Error_Message__c = 'There was an error sending the request to AppAdmin: ' + e,
                Error_Type__c = 'Account Products Sync Error',
                Account__c = account.Id);
            uow.registerNew(error);
        }

        uow.commitWork();
    }


    /**
     * Calls method to build request. Uses Custom Settings to send request.
     * @param  jsonString - Provider information JSON
     * @return HTTPResponse to be returned to calling method. Return response blank for testing.
     * @see this.postHealthgradesStatus
     */
    global static HTTPResponse sendRequestJson(String jsonString, String settingName, String subscriberId) 
    {
        AppAdminAPIClass.getSettings(settingName, subscriberId);
        HttpRequest req = AppAdminAPIClass.buildHttpRequestJson(jsonString);
        Http http = new Http();
        HTTPResponse response = new HTTPResponse();

        response = Test.isRunningTest() ? response : http.send(req);

        return response;
    }

    /**
     * Builds HTTPRequest with data from Custom Settings
     * @param  jsonString - Provider information JSON
     * @return HTTPRequest to be returned to calling method
     * @see this.sendRequestJson
     */
    global static HttpRequest buildHttpRequestJson(String jsonString) 
    {    
        HttpRequest req = new HttpRequest();
        req.setMethod(requestType);
        req.setEndpoint(targetUrl);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +
        EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        if(jsonString != null) req.setBody(jsonString);
        req.setTimeout(120000);
        
        return req; 
    }
   
}