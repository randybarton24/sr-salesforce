/**
 * File:        PayFlowProGateWay.cls
 * Project:     Solutionreach 
 * Date:        March 4, 2014
 * Created By:  Sid Maganti
 * *************************************************************************
 * Description: This class will handel Payflow pro XML request to PayPal.
 * Documentation: Links are provided
 * https://www.paypalobjects.com/webstatic/en_US/developer/docs/pdf/pp_payflowpro_guide.pdf ( please review page 29 for Submitting Authorization/Delayed Capture Transactions )
 * https://www.paypalobjects.com/webstatic/en_US/developer/docs/pdf/pp_payflowpro_xmlpay_guide.pdf ( please review "Card Authorization Request" and "Card Capture Request" )  
 * *************************************************************************
 * History:
 */

global class PayFlowProGateWay {

	//varaibles used to store values for PayflowPro call
    private static string userName;
    private static string password;
	private static string targeturl;
	private static string vendor;
	private static string partner;
	private static string Term;
	private static string MaxFailPayments;
	private static string TotalAmt;
	private static string OptionalTrans;
	private static string PayPeriod;
	private static string RetryNumDays;
	private static string OptionalTransAmt;
	
	 /**
     * Gets the values from PayPal custom settings 
     * These are credentials
    */
    private static void getSettings()
    {
    	boolean isProduction=false;
    	isProduction=UserInfo.getOrganizationId()==SRHGlobalVariables.PRODUCTION_ORGID?true:false;
        PayPal_Settings__c PayFlowPro = PayPal_Settings__c.getValues('PayPal Settings');
        userName = !isProduction?PayFlowPro.Test_User__c:PayFlowPro.User__c;
        password= !isProduction?PayFlowPro.Test_Password__c:PayFlowPro.Password__c;
        targeturl= !isProduction?PayFlowPro.Test_Live_Target_URL__c:PayFlowPro.Live_Target_URL__c;
        vendor= !isProduction?PayFlowPro.Test_Vendor__c:PayFlowPro.Vendor__c;
        partner= !isProduction?PayFlowPro.Test_Partner__c:PayFlowPro.Partner__c;
        Term=PayFlowPro.Term__c;
		MaxFailPayments=PayFlowPro.MaxFailPayments__c;
	 	TotalAmt=PayFlowPro.TotalAmt__c;
	 	OptionalTrans=PayFlowPro.OptionalTrans__c;
	 	PayPeriod=PayFlowPro.PayPeriod__c;
	 	RetryNumDays=PayFlowPro.RetryNumDays__c;
	 	OptionalTransAmt=PayFlowPro.OptionalTransAmt__c;
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
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/xml');
        req.setBodyDocument(request);
        req.setTimeout(120000);
        
        return req; 
    }   
    
    
    /**
     * Creates the body for the Customer Profile request
     * @param acc, cCard
     * @return requestDoc
    */
    /*
<?xml version="1.0" encoding="UTF-8"?>
<XMLPayRequest Timeout="30" version="2.0" xmlns="http://www.paypal.com/XMLPay">
	<RequestData>
		<Vendor>SolutionTest</Vendor>
		<Partner>PayPal</Partner>
		<Transactions>
			<Transaction>
				<Authorization>
					<PayData>
						<Invoice>
							<BillTo>
								<Address>
									<Street>123 4th street</Street>
									<City>San Jose</City>
									<State>CA</State>
									<Zip>95032</Zip>
									<Country>USA</Country>
								</Address>
							</BillTo>
							<TotalAmt>24.97</TotalAmt>
						</Invoice>
						<Tender>
							<Card>
								<CardType>visa</CardType>
								<CardNum>5105105105105100</CardNum>
								<ExpDate>201411</ExpDate>
								<NameOnCard>Sid Maganti</NameOnCard>
							</Card>
						</Tender>
					</PayData>
				</Authorization>
			</Transaction>
		</Transactions>
	</RequestData>
	<RequestAuth>
		<UserPass>
			<User>SolutionTest</User>
			<Password>ThinkCloud*1</Password>
		</UserPass>
	</RequestAuth>
</XMLPayRequest>
    */
    public static DOM.Document buildAutRequestDocument(AccountDecorator acc, RecurSoft__Payment_Record__c cCard,ContactDecorator Cont)
    {
        getSettings();        
        DOM.Document requestDoc = new DOM.Document();
        requestDoc.load('<XMLPayRequest></XMLPayRequest>');
        DOM.xmlNode XMLPayRequestNode = requestDoc.getRootElement();
        XMLPayRequestNode.setAttribute('xmlns', 'http://www.paypal.com/XMLPay');
        XMLPayRequestNode.setAttribute('version', '2.0');
        XMLPayRequestNode.setAttribute('Timeout', '120000');
        TG_XmlUtils.appendChild(XMLPayRequestNode, buildProfile(acc, cCard,Cont));
        TG_XmlUtils.appendChild(XMLPayRequestNode, buildAuthentication());
        //request.addChildElement('validationMode', null, null).addTextNode('testMode');
        
        return requestDoc;
    }
    
    
     /**
     * Creates the profile Block that contains the customer and credit card information
     * @param acc, cCard
     * @return profile
    */
    public static DOM.xmlNode buildProfile(AccountDecorator acc, RecurSoft__Payment_Record__c cCard,ContactDecorator Cont)
    {
    	String firstName = '';
    	String lastName = '';
        DOM.Document XML = new DOM.Document();
        XML.load('<RequestData></RequestData>');
        DOM.xmlNode RequestDataNode = XML.getRootElement();
        RequestDataNode.addChildElement('Vendor', null, null).addTextNode(vendor);
        RequestDataNode.addChildElement('Partner', null, null).addTextNode(partner);
        
        DOM.xmlNode TransactionsNode = RequestDataNode.addChildElement('RecurringProfiles', null, null);
        TG_XmlUtils.appendChild(TransactionsNode, buildRecurringProfile(acc, cCard, Cont));
		
        return RequestDataNode;
    }
    
    
    
    public static DOM.xmlNode buildTransaction(AccountDecorator acc, RecurSoft__Payment_Record__c cCard)
    {
    	String firstName = '';
    	String lastName = '';
        DOM.Document XML = new DOM.Document();
        XML.load('<Transaction></Transaction>');
        DOM.xmlNode TransactionNode = XML.getRootElement();
        DOM.xmlNode AuthorizationNode = TransactionNode.addChildElement('Authorization', null, null);
        DOM.xmlNode PayDataNode = AuthorizationNode.addChildElement('PayData', null, null);
        DOM.xmlNode InvoiceNode = PayDataNode.addChildElement('Invoice', null, null);
        DOM.xmlNode BillToNode = InvoiceNode.addChildElement('BillTo', null, null);
        DOM.xmlNode AddressNode = BillToNode.addChildElement('Address', null, null);
        AddressNode.addChildElement('Street', null, null).addTextNode(acc.address1);
        AddressNode.addChildElement('City', null, null).addTextNode(acc.city);
        AddressNode.addChildElement('State', null, null).addTextNode(acc.state);
        AddressNode.addChildElement('Zip', null, null).addTextNode(acc.zip);
        AddressNode.addChildElement('Country', null, null).addTextNode(acc.country);
		InvoiceNode.addChildElement('TotalAmt', null, null).addTextNode(acc.TotalAmount);       
        DOM.xmlNode TenderNode = PayDataNode.addChildElement('Tender', null, null);
        DOM.xmlNode CardNode = TenderNode.addChildElement('Card', null, null);
		CardNode.addChildElement('CardType', null, null).addTextNode(cCard.RecurSoft__Card_Type__c);       
		CardNode.addChildElement('CardNum', null, null).addTextNode(cCard.RecurSoft__Card_Number__c);       
		CardNode.addChildElement('ExpDate', null, null).addTextNode(cCard.RecurSoft__Expiration_Year__c+''+cCard.RecurSoft__Expiration_Month__c);       
		CardNode.addChildElement('NameOnCard', null, null).addTextNode(cCard.RecurSoft__Name_On_Card__c);             
        return TransactionNode;
    }
    
    /*
    <RecurringProfiles>
			<RecurringProfile>
				<Add>
                	<Tender>
						<Card>
							<CardType>visa</CardType>
							<CardNum>5105105105105100</CardNum>
							<ExpDate>201411</ExpDate>
							<NameOnCard>Siddardha Maganti</NameOnCard>
						</Card>
					</Tender>
					<RPData>
						<Name>Siddardha Maganti</Name>
						<TotalAmt>1.0</TotalAmt>
						<Start>08042014</Start>
						<Term>0</Term>
						<PayPeriod>Monthly</PayPeriod>
						<MaxFailPayments>0</MaxFailPayments>
						<RetryNumDays>2</RetryNumDays>
						<EMail>smaganti@sererra.com</EMail>
						<CompanyName>Sererra Test</CompanyName>
						<Comment>Test</Comment>
						<OptionalTrans>Authorization</OptionalTrans>
						<OptionalTransAmt>1</OptionalTransAmt>
						<BillTo>
							<Name>Siddardha Maganti</Name>
							<Address>
								<Street>123 4th street</Street>
								<City>San Jose</City>
								<State>CA</State>
								<Zip>95032</Zip>
								<Country>United States</Country>
							</Address>
							<Phone>4797475669</Phone>
							<Fax>4797475669</Fax>
						</BillTo>
						<ShipTo>
							<Name>Siddardha Maganti</Name>
							<Address>
								<Street>123 4th street</Street>
								<City>San Jose</City>
								<State>CA</State>
								<Zip>95032</Zip>
								<Country>United States</Country>
							</Address>
							<Phone>4797475669</Phone>
							<Fax>4797475669</Fax>
						</ShipTo>
					</RPData>
				</Add>
			</RecurringProfile>
		</RecurringProfiles>    
    */
    
     
    public static DOM.xmlNode buildRecurringProfile(AccountDecorator acc, RecurSoft__Payment_Record__c cCard,ContactDecorator Cont)
    {
    	String firstName = '';
    	String lastName = '';
    	Date TodayDateTenYears= Date.newInstance(Date.Today().year()+10, Date.Today().month(), 
											(Date.daysInMonth(Date.Today().year()+10,Date.Today().month()) >= Date.Today().day()) ? 
											 Date.Today().day() : Date.daysInMonth(Date.Today().year()+10,Date.Today().month()));
		string month='';
		string year='';
		string day='';
		if(TodayDateTenYears.month()<10)
			month='0'+String.ValueOf(TodayDateTenYears.month());
		else
			month=string.ValueOf(TodayDateTenYears.month());
		if(TodayDateTenYears.day()<10)
			day='0'+String.ValueOf(TodayDateTenYears.day());
		else
			day=String.ValueOf(TodayDateTenYears.day());
		year= String.ValueOf(TodayDateTenYears.year());
		
        DOM.Document XML = new DOM.Document();
        XML.load('<RecurringProfile></RecurringProfile>');
        DOM.xmlNode RecurringProfileNode = XML.getRootElement();
        DOM.xmlNode AddNode = RecurringProfileNode.addChildElement('Add', null, null);
        DOM.xmlNode TenderNode = AddNode.addChildElement('Tender', null, null);
        DOM.xmlNode CardNode = TenderNode.addChildElement('Card', null, null);
		CardNode.addChildElement('CardType', null, null).addTextNode(cCard.RecurSoft__Card_Type__c);       
		CardNode.addChildElement('CardNum', null, null).addTextNode(cCard.RecurSoft__Card_Number__c);       
		CardNode.addChildElement('ExpDate', null, null).addTextNode(cCard.RecurSoft__Expiration_Year__c+''+cCard.RecurSoft__Expiration_Month__c);       
		CardNode.addChildElement('NameOnCard', null, null).addTextNode(cCard.RecurSoft__Name_On_Card__c);  
        DOM.xmlNode RPDataNode = AddNode.addChildElement('RPData', null, null);
        RPDataNode.addChildElement('Name', null, null).addTextNode(Cont.FirstName+' '+Cont.LastName);
        RPDataNode.addChildElement('TotalAmt', null, null).addTextNode(TotalAmt);
        RPDataNode.addChildElement('Start', null, null).addTextNode(month+''+day+''+year);
        RPDataNode.addChildElement('Term', null, null).addTextNode(Term);
        RPDataNode.addChildElement('PayPeriod', null, null).addTextNode(PayPeriod);
        RPDataNode.addChildElement('MaxFailPayments', null, null).addTextNode(MaxFailPayments);
        RPDataNode.addChildElement('RetryNumDays', null, null).addTextNode(RetryNumDays);
        RPDataNode.addChildElement('EMail', null, null).addTextNode(Cont.Email);
        RPDataNode.addChildElement('CompanyName', null, null).addTextNode(acc.BusinessName);
        RPDataNode.addChildElement('OptionalTrans', null, null).addTextNode(OptionalTrans);
        RPDataNode.addChildElement('OptionalTransAmt', null, null).addTextNode(OptionalTransAmt);
        DOM.xmlNode BillToNode = RPDataNode.addChildElement('BillTo', null, null);
        DOM.xmlNode AddressNode = BillToNode.addChildElement('Address', null, null);
        AddressNode.addChildElement('Street', null, null).addTextNode(acc.address1);
        AddressNode.addChildElement('City', null, null).addTextNode(acc.city);
        AddressNode.addChildElement('State', null, null).addTextNode(acc.state);
        AddressNode.addChildElement('Zip', null, null).addTextNode(acc.zip);
        AddressNode.addChildElement('Country', null, null).addTextNode(acc.country);
		BillToNode.addChildElement('Phone', null, null).addTextNode(Cont.DirectPhone);       
                   
        return RecurringProfileNode;
    }
    
    
    
    
    
    /**
     * Creates the Authentication Block that contains the user's login information
     * @return authentication
    */
    public static DOM.xmlNode buildAuthentication()
    {
        DOM.Document XML = new DOM.Document();
        XML.load('<RequestAuth></RequestAuth>');
        DOM.xmlNode RequestAuth = XML.getRootElement();
        DOM.xmlNode UserPassNode = RequestAuth.addChildElement('UserPass', null, null);
        UserPassNode.addChildElement('User', null, null).addTextNode(userName);
        UserPassNode.addChildElement('Password', null, null).addTextNode(password);
        return RequestAuth;
    }
	
	  /**
     * Sends the request  
     * @param requestBody
     * @return result
    */
    global static String sendRequest(DOM.Document requestBody)
    {
    	String result = '';
    	HttpRequest req = PayFlowProGateWay.buildHttpRequest(requestBody);
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
        	result='<?xml version="1.0" encoding="UTF-8" ?>'+
        	'<XMLPayResponse>'+
			 '<ResponseData>'+
			 '<Vendor>vendor</Vendor>'+
			'<Partner>partner</Partner>'+
			 '<RecurringProfileResults>'+
			'<RecurringProfileResult>'+
			'<Result>0</Result>'+
			'<Message>Approved</Message>'+
			'<ProfileID>V63A09910356</ProfileID>'+
			'<PNRef>V63A09910356</PNRef>'+
			'</RecurringProfileResult>'+
			'</RecurringProfileResults>'+
			'</ResponseData>'+
			'</XMLPayResponse>';
        	
        }
        System.debug('Response: ' + result);
        return result;
    }
    
    /**
	 * Gets the authorization code for a valid credit card
	 * @params response
	 * @return authResponse
	*/
  /*  public static String getAuthCodeFromResponse(String response, Boolean isTransaction)
    {
    	String authResponse = '';
    	DOM.Document resultDocument = new DOM.Document();
    	resultDocument.load(response);
    	authResponse = getValidationMessage(resultDocument, isTransaction); 
    	//will return response message and auth code   	
    	return authResponse;
    }*/
    
    /**
	 * Gets custmer profile Id and the payment profile Id 
	 * @params response
	 * @return authResponse
	*/
   /* public static String getInformationFromResponse(String response, Boolean forCustomer)
    {
    	String ids = '';
    	DOM.Document resultDocument = new DOM.Document();
    	resultDocument.load(response);
    	//ids = getResponseMessage(resultDocument, forCustomer); 
    	//will return response message and auth code   	
    	return ids;
    }*/
    
    /**
	 *Parses the response from Authorize.Net
	 *@params responseDom
	 *@return response
	*/
   /* global static String getValidationMessage(DOM.Document responseDom, Boolean isTransaction)
    {
    	String response = '';
    	String nodeName = (isTransaction) ? 'directResponse' : 'validationDirectResponse';
    	List<String> aux = new List<String>();
        for(Dom.XmlNode responseLevelNode : responseDom.getRootElement().getChildElements())
        {
            if(responseLevelNode.getName().equals(nodeName))
            {
            	aux = responseLevelNode.getText().split(',');
            	//add message and auth code.
            	response = aux[3] + '->' + aux[4];
            }
        }
        return response;
    }
    */
    /*
    <XMLPayResponse  
    xmlns="http://www.paypal.com/XMLPay">
    <ResponseData>
        <Vendor>SolutionTest01</Vendor>
        <Partner>paypal</Partner>
        <RecurringProfileResults>
            <RecurringProfileResult>
                <Result>0</Result>
                <Message>Approved</Message>
                <ProfileID>RT0000000003</ProfileID>
                <RPRef>R7X56BE2375A</RPRef>
            </RecurringProfileResult>
        </RecurringProfileResults>
    </ResponseData>
</XMLPayResponse>
    */
    
    
    /**
	 *Parses the response from Authorize.Net
	 *@params responseDom
	 *@return response
	*/
    public static map<string,string> getResponseMessage(String responseFromPaypal, Boolean forCustomer)
    {
    	DOM.Document resultDocument = new DOM.Document();
    	system.debug('responseFromPaypal-->'+responseFromPaypal);
    	resultDocument.load(responseFromPaypal);
    	map <string,string> responseMap = new map<string,string>();
    	String rootName = resultDocument.getRootElement().getName();
    	Boolean isSuccess = false;
    	List<String> aux = new List<String>();
        for(Dom.XmlNode ResponseLevelNode : resultDocument.getRootElement().getChildElements())
        {
        	system.debug('ResponseLevelNode.getName()'+ResponseLevelNode.getName());
            if(ResponseLevelNode.getName().equals('ResponseData'))
            {
            	 system.debug('ResponseLevelNode.getName()'+ResponseLevelNode.getName());
            	
            	for(Dom.XmlNode ResponseDataNode : ResponseLevelNode.getChildElements())
            	{
            		 system.debug('ResponseDataNode.getName()'+ResponseDataNode.getName());
            		
            		if(ResponseDataNode.getName().equals('RecurringProfileResults'))
            		{

        			for(Dom.XmlNode TransactionResultsNode : ResponseDataNode.getChildElements())
		            	{
		            		system.debug('RecurringProfileResults.getName()'+TransactionResultsNode.getName());
		            		
		            		if(TransactionResultsNode.getName().equals('RecurringProfileResult'))
		            		{
		            			for(Dom.XmlNode TransactionResultNode : TransactionResultsNode.getChildElements())
		            			{
		            				system.debug('TransactionResultNode.getName()'+TransactionResultNode.getName());
		            				if(TransactionResultNode.getName().equals('Result'))
		            				{
		            				system.debug('RecurringProfileResult.getName().equals(Result)-->'+TransactionResultNode.getName());
		            					
		            					responseMap.put('Result',TransactionResultNode.getText());
		            				}
		            				if(TransactionResultNode.getName().equals('Message'))
		            				{
		            					responseMap.put('Message',TransactionResultNode.getText());
		            				}
		            				if(TransactionResultNode.getName().equals('PNRef'))
		            				{
		            					responseMap.put('PNRef',TransactionResultNode.getText());
		            				}
		            				if(TransactionResultNode.getName().equals('ProfileID'))
		            				{
		            					responseMap.put('ProfileID',TransactionResultNode.getText());
		            				}
		            				
		            			}			            				
		            		}            		
		            	}
            		}            		
            	}
            }        	
        }
        system.debug('responseMap'+responseMap);
        return responseMap;
    }

}