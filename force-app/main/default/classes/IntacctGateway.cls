/**
 * File:        IntacctGateway.cls
 * Project:     Sererra 
 * Date:        December 27, 2012
 * Created By:  Anca Comaneciu
 * *************************************************************************
 * Description: Builds the authentication and the header parts of the XML request
 * *************************************************************************
 * History:
 */
global class IntacctGateway
{
    //varaibles used to store values from Intacct Integration Custom Setting
    private static string gatewayURL;
    private static string senderID;
    private static string senderPassword;
    private static string userID;
    private static string companyID;
    private static string companyPassword;
    
    /**
     * Gets the values from Intacct Integration Custom Setting
    */
    private static void GetSettings()
    {
        Intacct_Integration_Settings__c gw = Intacct_Integration_Settings__c.getValues('Intacct Gateway');
        try
        {
            IntacctEncryptionManager.setPrivateEncryptionKey();
            gatewayURL = gw.Intacct_Gateway_URL__c;
            senderID = IntacctEncryptionManager.decryptValue(EncodingUtil.base64Decode(gw.Intacct_Sender_ID__c));
            senderPassword = IntacctEncryptionManager.decryptValue(EncodingUtil.base64Decode(gw.Intacct_Sender_Password__c));
            userID = IntacctEncryptionManager.decryptValue(EncodingUtil.base64Decode(gw.Intacct_User_ID__c));
            companyID = IntacctEncryptionManager.decryptValue(EncodingUtil.base64Decode(gw.Intacct_Company_ID__c));
            companyPassword = IntacctEncryptionManager.decryptValue(EncodingUtil.base64Decode(gw.Intacct_Password__c));
        }
        catch(Exception ex)
        {
            senderID = '';
            senderPassword = '';
            userID = '';
            companyID = '';
            companyPassword = '';
            gatewayURL = '';
        }
    }   
    
    /**
     * Creates the request
     * @param request
     * @return req
    */
    global static HttpRequest BuildHttpRequest(DOM.Document request)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(gatewayURL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'x-intacct-xml-request');
        req.setBodyDocument(request);
        req.setTimeout(120000);
        
        return req; 
    }

    /**
     * Creates the body for the request
     * @param functions, entity
     * @return requestDoc
    */
    global static DOM.Document BuildRequestDocument(Map<String,List<DOM.xmlNode>> functionsGroupedByEntity)
    {
        GetSettings();
        
        DOM.Document requestDoc = new DOM.Document();
        requestDoc.load('<request></request>');
        DOM.xmlNode request = requestDoc.getRootElement();
        
        String controlId = 'intacct_operation_' + String.valueOf(System.now()); 
        TG_XmlUtils.appendChild(request, BuildControl(controlId, false));
        for(String locationId : functionsGroupedByEntity.keySet())
        {
            TG_XmlUtils.appendChild(request, BuildOperation(functionsGroupedByEntity.get(locationId), locationId));
        }
                    
        return requestDoc;
    }

    /**
     * Creates the Control Block that allows access to the Web Services API gateway.
     * @param controlID, uniqueID
     * @return control
    */
    private static DOM.xmlNode BuildControl(string controlID, boolean uniqueID)
    {
        DOM.Document XML = new DOM.Document();
        XML.load('<control></control>');
        DOM.xmlNode control = XML.getRootElement();
        control.addChildElement('senderid', null, null).addTextNode(senderID);
        control.addChildElement('password', null, null).addTextNode(senderPassword);
        control.addChildElement('controlid', null, null).addTextNode(controlID);
        if(uniqueID)
            control.addChildElement('uniqueid',null,null).addTextNode('true');
        else
            control.addChildElement('uniqueid',null,null).addTextNode('false');
        control.addChildElement('dtdversion', null, null).addTextNode('2.1');        
        return control;
    }
    
    /**
     * Creates the Authentication Block that contains the user's login information
     * @param entity
     * @return authentication
    */
    private static DOM.xmlNode BuildAuthentication(String locationId)
    {
        DOM.Document XML = new DOM.Document();
        XML.load('<authentication></authentication>');
        DOM.xmlNode authentication = XML.getRootElement();
        DOM.xmlNode login = authentication.addChildElement('login', null, null);
        login.addChildElement('userid', null, null).addTextNode(userID);
        login.addChildElement('companyid', null, null).addTextNode(companyID);
        login.addChildElement('password', null, null).addTextNode(companyPassword);
        if(!String.isBlank(locationId))
            login.addChildElement('locationid', null, null).addTextNode(locationId);
        
        return authentication;
    }
    
    /**
     * Creates the Operation Block that contains sections for user authentication and content
     * @param functions, entity
     * @return requestDoc
    */
    private static DOM.xmlNode BuildOperation(List<DOM.xmlNode> functions, String locationId)
    {
        DOM.Document XML = new DOM.Document();
        XML.load('<operation></operation>');
        DOM.xmlNode operation = XML.getRootElement();
        //operation.setAttribute('transaction','true');
        TG_XmlUtils.appendChild(operation, BuildAuthentication(locationId));
        DOM.xmlNode content = operation.addChildElement('content', null, null);
        for(DOM.xmlNode function : functions)
            TG_XmlUtils.appendChild(content, function);

        return operation;
    }
}