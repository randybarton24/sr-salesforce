global without sharing class AppAdminAPIClassNew 
{
    //TODO.. let caller handle exceptions
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
            System.debug('Response: ' + response);
            System.debug('Results: ' + result);
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
 
    @future(callout=true)
    public static void syncOpportunityAppAdmin(Set<Id> oppIds, Boolean closeOpp)
    {
        try
        {
            fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            AppAdminAPIClassNew.syncOpportunityAppAdmin(oppIds, closeOpp, closeOpp, uow);
            uow.commitWork();
        }
        catch(Exception e)
        {
            Error_Log__c error = new Error_Log__c(
                Error_Message__c = e.getMessage() + '\n' + e.getLineNumber() + '\n' + e.getStackTraceString(),
                Error_Type__c = 'AppAdmin Sync Error',
                Opportunity__c = new List<Id>(oppIds)[0]);
            insert error;
        }
    }

    public static void syncOpportunityAppAdmin(Set<Id> oppIds, Boolean closeOpp, Boolean syncIntacct, fflib_SObjectUnitOfWork uow)
    {        
        Opportunity[] opportunities = OpportunitiesSelector.newInstance().selectByIdWithAccountsContactsAndProducts(oppIds);
                
        if(opportunities.isEmpty()) return;

        for(Opportunity opp : opportunities)
        {
            Boolean newSubscriber = false;

            if(opp.Account.Subscriber_Id__c == null) newSubscriber = true;

            Account acc = new Account();
            acc.Id = opp.AccountId;
            acc.Subscriber_ID__c = newSubscriber ? AppAdminAPIClassNew.getSubscriberId(opp, uow) : opp.Account.Subscriber_Id__c;
            if(acc.Subscriber_Id__c != null)
            {
                if(hasSRProduct(opp.OpportunityLineItems))
                {
                    acc = AppAdminAPIClassNew.getAccountNumberAndUsername(acc);
                    acc.Password_Reset_URL__c = AppAdminAPIClassNew.getPasswordResetBySubscriberId(acc.Subscriber_Id__c);
                    acc.Limelight_URL__c = AppAdminAPIClassNew.getLimelightUrlBySubscriberId(acc.Subscriber_Id__c);
                    uow.registerDirty(acc);
                }

                AppAdminAPIClassNew.syncAccountProducts(getProductsJson(opp.OpportunityLineItems), acc, uow);

                if(syncIntacct)
                {
                    System.schedule('SyncWithIntacctAndClose_Batch_' + opp.Id + '_' + Datetime.now().getTime(), 
                        AsyncMain.getSchedulerExpression(Datetime.now().addSeconds(10)), 
                        new SyncWithIntacctAndClose_Batch(new Set<Id>{ opp.Id }, closeOpp));
                }
            }
        }        
    }

    public static String getSubscriberId(Opportunity o, fflib_SObjectUnitOfWork uow)
    {
        HTTPResponse response = new HTTPResponse();
        response = sendRequest(buildTransaction(o),o);
        if(String.valueOf(response.getStatusCode()) != statuscode)
        {
            Error_Log__c error = new Error_Log__c(
                Error_Message__c = response.getBody(),
                Error_Type__c = 'AppAdmin Sync Error',
                Opportunity__c = o.Id);
            uow.registerNew(error);
            return null;
        }
        else
        {
            String result = Test.isRunningTest() ? 'test' : response.getHeader('Location').replaceAll(requestUrl,'');
            return result;
        }
    }

    public static String getProductsJson(OpportunityLineItem[] oppLis)
    {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();

        for(OpportunityLineItem oppLi : oppLis) 
        {
            if(oppLi.PricebookEntry.Product2.AppAdminProductKey__c == null || oppLi.PricebookEntry.Product2.Family == null) continue;

            gen.writeStartObject();
            gen.writeStringField('key', oppLi.PricebookEntry.Product2.AppAdminProductKey__c);
            gen.writeStringField('name', oppLi.PricebookEntry.Product2.Family);
            gen.writeBooleanField('active', true);
            gen.writeEndObject();
        }

        gen.writeEndArray();            
        String jsonProducts = gen.getAsString();
        return jsonProducts;
    }

    public static Boolean hasSRProduct(OpportunityLineItem[] oppLis)
    {
        for(OpportunityLineItem oppLi : oppLis) 
        {
            if(oppLi.PricebookEntry.Product2.Family == 'SR Platform' || oppLi.PricebookEntry.Product2.Family == 'SR Reminders') return true;
        }
        return false;
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
        System.debug(billingContactRole);
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
    public static String parsPhone(String phoneNumber,String index)
    {
        String phonePart='';
        System.debug('phoneNumber--index'+phoneNumber+'--'+index);
        if(phoneNumber!= null && phoneNumber.length()>0)
        {
            System.debug('phoneNumber-before-Scrubing->'+phoneNumber);
            phoneNumber= phoneNumber.trim();
            phoneNumber = phoneNumber.replaceAll('\\+', '');
            phoneNumber = phoneNumber.replaceAll('\\(', '');
            phoneNumber = phoneNumber.replaceAll('\\)', '');
            phoneNumber = phoneNumber.replaceAll(' ', '');
            phoneNumber = phoneNumber.replaceAll('-', '');
            phoneNumber = phoneNumber.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '');
            phoneNumber = phoneNumber.replaceAll('[a-zA-Z]', '');
            System.debug('phoneNumber-After-Scrubing->'+phoneNumber);
            if(phoneNumber.length()>10)
            {
                phoneNumber=phoneNumber.substring(phoneNumber.length()-10, phoneNumber.length());
                System.debug('phoneNumber'+phoneNumber);
            }
            System.debug('phoneNumber.length()-->'+phoneNumber.length());
            if(index=='areacode')
            {
                phonePart=phoneNumber.left(3);
            }
            else if(index=='linenumber')
            {
                phonePart=phoneNumber.right(4);
            }
            else if(index=='prefix')
            {
                phonePart=phoneNumber.substring(3, 6);
            }
        }
        System.debug('phonePart-->'+phonePart);
        
        return phonePart;
    }
    
    
    /*gets market index
    *@ Account
    *@ retrun String marketIndex
    */
    public static String getMarketIndex(String vertical , String subvertical)
    {
        String marketIndex='';
        if(vertical == 'Dental')
        {
            marketIndex='1';
        }
        else if(vertical == 'Vision')
        {
            marketIndex='4';
        }
        else if(vertical == 'Medical')
        {
            marketIndex='3';
            if(subvertical == 'Medical Spa or Aesthetic Medicine')
            {
                marketIndex='5';
            }
        }
        else if(vertical == 'Non-Medical')
        {
            marketIndex='8';
        }
        else if(vertical == 'Physical Rehabilitation')
        {
            marketIndex='7';
        }
        
        return marketIndex;    
    }

    public static String getSubscriberUsernameBySubscriberId(String subscriberId) 
    {
        try
        {
            HTTPResponse response = AppAdminAPIClassNew.sendRequestJson(null, 'SubscriberUserName', subscriberId);

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
            HTTPResponse response = AppAdminAPIClassNew.sendRequestJson(null, 'SubscriberUserName', a.Subscriber_ID__c);

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
            HTTPResponse response = AppAdminAPIClassNew.sendRequestJson(null, 'PasswordReset', subscriberId);

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

            HTTPResponse response = AppAdminAPIClassNew.sendRequestJson(null, 'LimelightURL', subscriberId);

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
            HTTPResponse response = AppAdminAPIClassNew.sendRequestJson(null, 'SRCEligibility', phoneNumber);

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
    public static void postHealthgradesStatus(Set<Id> providerIds) 
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

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

        for(Provider__c p : mapProviders.values()) 
        {
            String npi = p.NPI__c == null ? '' : p.NPI__c;

            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            //gen.writeStringField('npi', npi);
            gen.writeStringField('providerUrl', p.Healthgrades_ID__c);
            gen.writeBooleanField('premiumSubscriber', p.Premium_Member__c);
            gen.writeEndObject();
            String jsonProviderInfo = gen.getAsString();
            System.debug(jsonProviderInfo);
            
            try
            {
                HTTPResponse response = AppAdminAPIClassNew.sendRequestJson(jsonProviderInfo, 'HealthgradesSettings', null);

                if(String.valueOf(response.getStatusCode()) != '200' &&
                    String.valueOf(response.getStatusCode()) != '201') 
                {
                    Error_Log__c error = new Error_Log__c(
                        Error_Message__c = response.getBody(),
                        Error_Type__c = 'Healthgrades Sync Error',
                        Provider__c = p.Id);
                    uow.registerNew(error);
                } 
                else 
                {
                    p.Synced_with_AppAdmin_Date__c = Datetime.now();
                    uow.registerDirty(p);

                    if(!p.Assets__r.isEmpty()) 
                    {
                        p.Assets__r[0].Synced_with_AppAdmin_Date__c = Datetime.now();
                        uow.registerDirty(p.Assets__r[0]);
                    }
                }
            } 
            catch(Exception e) 
            {
                Error_Log__c error = new Error_Log__c(
                    Error_Message__c = 'There was an error sending the request to AppAdmin: ' + e,
                    Error_Type__c = 'Healthgrades Sync Error',
                    Provider__c = p.Id);
                uow.registerNew(error);
            }
        }

        uow.commitWork();
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
                HTTPResponse response = AppAdminAPIClassNew.sendRequestJson(jsonProducts, 'ProductsAPI', a.Account.Subscriber_ID__c);

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

    //uow
    public static void syncAccountProducts(String jsonProducts, Account account, fflib_SObjectUnitOfWork uow) 
    {            
        try 
        {    
            HTTPResponse response = AppAdminAPIClassNew.sendRequestJson(jsonProducts, 'ProductsAPI', account.Subscriber_ID__c);

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
    }


    /**
     * Calls method to build request. Uses Custom Settings to send request.
     * @param  jsonString - Provider information JSON
     * @return HTTPResponse to be returned to calling method. Return response blank for testing.
     * @see this.postHealthgradesStatus
     */
    global static HTTPResponse sendRequestJson(String jsonString, String settingName, String subscriberId) 
    {
        AppAdminAPIClassNew.getSettings(settingName, subscriberId);
        HttpRequest req = AppAdminAPIClassNew.buildHttpRequestJson(jsonString);
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