public with sharing class CRW_SettingsCtrl {


	public String getURL() {
	    return String.format(
	      'https://{0}.salesforce.com',
	      new String[]{
	        URL.getSalesforceBaseUrl().getHost().substringAfter('.').substringBefore('.')
	      });
	}
	//------------ Section for the remote site check/creation if needed -------------//
    public Boolean remoteSiteUrlNeedBoolean {get;set;}
	public String siteUrlPost {get; set;}
	public String remoteSiteUrlString{
    public get {
    	String remoteSiteUrlString = '';
    	if(!CRW_SettingsCtrl.checkMetadataAPIConnection())
    	{
			//return the url to be used on the new remote site
			String orgId = UserInfo.getOrganizationId();
            String userId = UserInfo.getUserId();
            String sessionId = UserInfo.getSessionId();
            //use getSalesforceBaseUrl within batches and schedules (not Visualforce), and fix inconsistent protocol
            if (sessionId == null) return Url.getSalesforceBaseUrl().toExternalForm().replace('http:', 'https:');
            PageReference pr = new PageReference('/id/' + orgId + '/' + userId);
            pr.getParameters().put('oauth_token', sessionId);
            pr.getParameters().put('format', 'json');
            //within test context use url class, else derive from identity api
            String data = Test.isRunningTest() ? '{"urls": {"rest": "' + Url.getSalesforceBaseUrl().toExternalForm() + '"}}' : pr.getContent().toString();
            Map<String,Object> result = (Map<String,Object>)Json.deserializeUntyped(data);
            Map<String,Object> urls = (Map<String,Object>)result.get('urls');
            Url rest = new Url((String)urls.get('rest'));
            remoteSiteUrlString =  rest.getProtocol() + '://' + rest.getHost();
			siteUrlPost = URL.getSalesforceBaseUrl().toExternalForm();
    	}
    	return remoteSiteUrlString;
    	}
    	public set;
    }
	// Method to check if there is any issue with the connection to the metadata api (used to know if its necesary add the remote site)
    public static Boolean checkMetadataAPIConnection()
    {
    	try {
    		CRW_MetadataService.MetadataPort service = new CRW_MetadataService.MetadataPort();
    		service.SessionHeader = new CRW_MetadataService.SessionHeader_element();
    		service.SessionHeader.sessionId = UserInfo.getSessionId();
    		List<CRW_MetadataService.ListMetadataQuery> queries = new List<CRW_MetadataService.ListMetadataQuery>();
    		CRW_MetadataService.ListMetadataQuery remoteSites = new CRW_MetadataService.ListMetadataQuery();
    		remoteSites.type_x = 'RemoteSiteSetting';
    		system.debug('remoteSites: ' + remoteSites);
    		queries.add(remoteSites);
    		service.listMetadata(queries, 28);
    	 }
		 catch (Exception e) {
    		//LastMetadataAPIConnectionException = e;
    		return false;
    	}
    	//LastMetadataAPIConnectionException = null;
    	return true;
    }

    //------------------- End of the section to check/create remote site -----------------------//

	public RecommendationSettings__c setupObj{get;set;}

	public Map<String,list<String>> fieldControllingMap{
		get{
				if (null == fieldControllingMap ) {
					 fieldControllingMap = CRW_SettingsHandler.getFieldControllingMap(null);
				}
				return fieldControllingMap;
		}
		private set;
	}
	public Map<String,List<Map<String,List<String>>>> fieldValuesControllingMap{
		get{
				if (null == fieldValuesControllingMap ) {
					 fieldValuesControllingMap = CRW_SettingsHandler.getAllPickListOptionsDependency();
				}
				return fieldValuesControllingMap;
		}
		private set;
	}


	public CRW_SettingsCtrl() {
			setupObj  =  CRW_SettingsHandler.getAppSettings();
	}


	/*
		@params: none
		@return: void
			invokes process that updates custom setting for controlling values
				- calls soap API
				- updates cSetting records
	*/
	public void updateSyncFields(){
		CRW_SettingsHandler.updateCaseFieldControllingMap();
		fieldControllingMap = null;
		fieldValuesControllingMap = null;
		updateAsyncValues(UserInfo.getSessionId());
	}
	/*
		@params: none
		@return: void
			invokes process that updates custom setting for controlling values
				- calls soap API
				- updates cSetting records
	*/
	public void refreshFields(){
			fieldControllingMap = null;
			fieldValuesControllingMap = null;
	}

	/*
		@params: none
		@return: void
			invokes process that updates custom setting for controlling fields
				- calls soap API
				- updates cSetting records
	*/
	public  void refreshValues(){
		fieldValuesControllingMap = null;
	}


	/*
		@params: sessionId
		@return: void
			invokes process that updates custom setting for controlling values
				- calls soap API
				- updates cSetting records
	*/
	@future (callout=true)
	public static void updateAsyncValues(String  sessionId){
		CRW_SettingsHandler.SESSION_ID = sessionId;
		CRW_SettingsHandler.updateCaseFieldValueControllingMap();

	}

	/*
		@params: none
		@return: void
			updates custom setting that holds values to recomendations display and star icon
	*/
	public void save(){

		try{
			upsert setupObj;
		}catch( Exception e ) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}

	}

}