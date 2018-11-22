public without sharing class SRUtilities 
{	
	public static Messaging.SendEmailResult[] catchExceptionEmailResults;
	private static Pricebook2 stdPriceBook; 

	public static Id getStdPricebookId() 
	{
	    if(Test.isRunningTest()) return Test.getStandardPricebookId();

	    return getStdPricebook().Id;    
	} 

	public static Pricebook2 getStdPriceBook() 
	{
	    if(stdPriceBook == null)
	    {
	    	stdPriceBook = Test.isRunningTest() ? null : [SELECT Id, Name FROM Pricebook2 WHERE isStandard = true LIMIT 1];
	    } 
	        
	    return stdPriceBook;    
	}

	/**
	 * Utility method to get RecordType info for static variable cache
	 * @param  objectName - Name of object to get RecordType info for
	 * @return Map of RecordTypeInfo with the RecordType name as key
	 * @see OpportunityTriggerHandler.recordTypeMap
	 */
	public static Map<String, Schema.RecordTypeInfo> getRecordTypeMap(String objectName) {

		Map<String, Schema.RecordTypeInfo> results = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName();

		return results;
	}

	public static Map<Id, Schema.RecordTypeInfo> getRecordTypeMapById(String objectName) {

		Map<Id, Schema.RecordTypeInfo> results = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById();

		return results;
	}

	public static Id getRecordTypeId(String objectName, String type)
	{
		return SRUtilities.getRecordTypeMap(objectName).get(type).getRecordTypeId();
	}

	public static String getRecordTypeName(String objectName, Id id)
	{
		return SRUtilities.getRecordTypeMapById(objectName).get(id).getName();
	}

	public static void scheduleAsync(Set<Id> idsToProcess, String asyncType) 
	{
		if(idsToProcess.size() == 0) return;

		AsyncRequest__c[] newRequests = new List<AsyncRequest__c>();
		Id[] idsForRequest = new List<Id>();

		for(Id i : idsToProcess) 
		{
			idsForRequest.add(i);

			if(idsForRequest.size() == 10) 
			{
				newRequests.add(new AsyncRequest__c(AsyncType__c = asyncType, 
					Params__c = String.join(idsForRequest, ',')));
				idsForRequest.clear();
			}
		}

		if(idsForRequest.size() > 0) 
		{
			newRequests.add(new AsyncRequest__c(AsyncType__c = asyncType, 
				Params__c = String.join(idsForRequest, ',')));
		}

		insert newRequests;
	}

	public static void scheduleAsync(Set<Id> idsToProcess, String asyncType, fflib_SObjectUnitOfWork uow) 
	{
		if(idsToProcess.size() == 0) return;

		Id[] idsForRequest = new List<Id>();

		for(Id i : idsToProcess) 
		{
			idsForRequest.add(i);

			if(idsForRequest.size() == 10) 
			{
				AsyncRequest__c ar = new AsyncRequest__c(AsyncType__c = asyncType, 
					Params__c = String.join(idsForRequest, ','));
				idsForRequest.clear();
				uow.registerNew(ar);
			}
		}

		if(idsForRequest.size() > 0) 
		{
			AsyncRequest__c ar = new AsyncRequest__c(AsyncType__c = asyncType, 
				Params__c = String.join(idsForRequest, ','));
			uow.registerNew(ar);
		}
	}

	public static void scheduleAsync(Set<String> idsToProcess, String asyncType, fflib_SObjectUnitOfWork uow) 
	{
		if(idsToProcess.size() == 0) return;

		String[] idsForRequest = new List<String>();

		for(String i : idsToProcess) 
		{
			idsForRequest.add(i);

			if(idsForRequest.size() == 10) 
			{
				AsyncRequest__c ar = new AsyncRequest__c(AsyncType__c = asyncType, 
					Params__c = String.join(idsForRequest, ','));
				idsForRequest.clear();
				uow.registerNew(ar);
			}
		}

		if(idsForRequest.size() > 0) 
		{
			AsyncRequest__c ar = new AsyncRequest__c(AsyncType__c = asyncType, 
				Params__c = String.join(idsForRequest, ','));
			uow.registerNew(ar);
		}
	}

	public static void processStampUpdates(Map<Id, Set<String>> objectToStampMap, SObject[] objects, fflib_SObjectUnitOfWork uow)
	{
		Stamp_Field_Mapping__c[] stampMappings = [SELECT Id, 
			Stamp_From_Object__c, 
			Stamp_To_Object__c, 
			Stamp_From_Field__c, 
			Stamp_To_Field__c, 
			Field_Changed__c, 
			Field_Changed_Value__c
			FROM Stamp_Field_Mapping__c];

		for(SObject o : objects)
		{
			String stampValue;

			for(Stamp_Field_Mapping__c mapping : stampMappings)
			{
				if(String.valueOf(o.getSObjectType()) != mapping.Stamp_To_Object__c) continue;
				if(!objectToStampMap.get(o.Id).contains(mapping.Id)) continue;
				String[] stampFrom = mapping.Stamp_From_Object__c.split(':');
				if(stampFrom.size() == 0) continue;

				if(mapping.Stamp_To_Object__c == mapping.Stamp_From_Object__c)
				{
					stampValue = (String) o.get(mapping.Stamp_From_Field__c);
				}
				else
				{
					if(stampFrom.size() == 3) stampValue = (String) o.getSObject(stampFrom[0]).getSObject(stampFrom[1]).getSObject(stampFrom[2]).get(mapping.Stamp_From_Field__c);
					if(stampFrom.size() == 2) stampValue = (String) o.getSObject(stampFrom[0]).getSObject(stampFrom[1]).get(mapping.Stamp_From_Field__c);
					if(stampFrom.size() == 1) stampValue = (String) o.getSObject(stampFrom[0]).get(mapping.Stamp_From_Field__c);
				}

				o.put(mapping.Stamp_To_Field__c, stampValue);
				uow.registerDirty(o);
			}
		}
	}

	public static String processStampUpdates(SObject o, SObject existingObject, Stamp_Field_Mapping__c[] stampMappings)
	{
		String[] mappingsToProcess = new List<String>();
		
		for(Stamp_Field_Mapping__c mapping : stampMappings)
		{
			if(o.get(mapping.Field_Changed__c) == null) continue;

			if(existingObject != null &&
				mapping.Field_Changed__c != null &&
				existingObject.get(mapping.Field_Changed__c) == o.get(mapping.Field_Changed__c)) continue;

			if(mapping.Field_Changed_Value__c != null &&
				mapping.Field_Changed__c != null &&
				String.valueOf(o.get(mapping.Field_Changed__c)) != mapping.Field_Changed_Value__c) continue;
			
			mappingsToProcess.add(mapping.Id);
		}

		if(mappingsToProcess.isEmpty()) return null;
		String mappingsToProcessCombined = String.join(mappingsToProcess, ':');

		return o.Id + '::' + mappingsToProcessCombined;
	}

	/**
	 * Utility class to run DML on applicable maps.  Exceptions are caught and sent as an email.
	 * @param mapInsert - Map for SObjects to be inserted
	 * @param mapUpdate - Map for SObjects to be updated
	 * @param mapDelete - Map for SObjects to be deleted
	 * @param context - Where the method was called from in order to provide the info in the exception email
	 * @see OpportunityUtilities.addStandardProducts, OpportunityUtilities.updatePricingForCampaignChange 
	 * @see OpportunityUtilities.updateAPProductForNumberOfProvidersChange
	 */
	public static void runDml(Map<ID, SObject> mapInsert, Map<ID, SObject> mapUpdate, Map<ID, SObject> mapDelete, String context) {
    	
    	try {
	    	if(!mapInsert.isEmpty()) {
	    		SObject[] insertList = mapInsert.values();
	    		insertList.sort();
	    		System.debug(insertList);
	    		insert insertList;
	    	}
	    	if(!mapUpdate.isEmpty()) {
	    		SObject[] updateList = mapUpdate.values();
	    		updateList.sort();
	    		System.debug(updateList);
	    		update updateList;
	    	}
	    	if(!mapDelete.isEmpty()) {
	    		SObject[] deleteList = mapDelete.values();
	    		deleteList.sort();
	    		System.debug(deleteList);
	    		delete deleteList;
	    	}
    	}
    	catch(Exception e) {
    		
    		System.debug(e);

    		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    		message.setSubject(context + ' Error');
    		message.setPlainTextBody('The following exception details were caught.  Type: ' + e.getTypeName()
    									+ ' Cause: ' + e.getCause() 
    									+ ' Message: ' + e.getMessage() 
    									+ ' Stack Trace: ' + e.getStackTraceString());
    		message.setTargetObjectId('005i0000002fU4O');
    		message.setSaveAsActivity(false);
    		catchExceptionEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    	}
    }

    public static void runDmlNoLock(Map<ID, SObject> mapInsert, Map<ID, SObject> mapUpdate, Map<ID, SObject> mapDelete, String context) {
      
      try {
        if(!mapInsert.isEmpty()) {
          SObject[] insertList = mapInsert.values();
          insertList.sort();
          System.debug(insertList);
          insert insertList;
        }
        if(!mapUpdate.isEmpty()) {
          SObject[] updateList = mapUpdate.values();
          updateList.sort();
          System.debug(updateList);
          update updateList;
        }
        if(!mapDelete.isEmpty()) {
          SObject[] deleteList = mapDelete.values();
          deleteList.sort();
          System.debug(deleteList);
          delete deleteList;
        }
      }
      catch(DMLException e) {
        
        if(e.getDmlType(0) == StatusCode.UNABLE_TO_LOCK_ROW)
        {
          throw e;

          System.debug(e);

          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
          message.setSubject(context + ' LOCK ERROR THROWN');
          message.setPlainTextBody('The following exception details were caught.  Type: ' + e.getTypeName()
                        + ' Cause: ' + e.getCause() 
                        + ' Message: ' + e.getMessage() 
                        + ' Stack Trace: ' + e.getStackTraceString());
          message.setTargetObjectId('005i0000002fU4O');
          message.setSaveAsActivity(false);
          catchExceptionEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        }
        else
        {
          System.debug(e);

          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
          message.setSubject(context + ' Error');
          message.setPlainTextBody('The following exception details were caught.  Type: ' + e.getTypeName()
                        + ' Cause: ' + e.getCause() 
                        + ' Message: ' + e.getMessage() 
                        + ' Stack Trace: ' + e.getStackTraceString());
          message.setTargetObjectId('005i0000002fU4O');
          message.setSaveAsActivity(false);
          catchExceptionEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        }
        
      }
    }

    public class SRUnitOfWork implements fflib_SObjectUnitOfWork.IDoWork
    {
    	public SObject[] objectsToInsert;
    	public Map<Id, SObject> objectsToUpdate;
    	public Map<Id, SObject> objectsToDelete;

    	public void registerNewWithCatch(SObject objectToInsert)
    	{
    		if(this.objectsToInsert == null) 
    		{
    			this.objectsToInsert = new List<SObject>{objectToInsert};
    		}
    		
    		else
    		{
    			this.objectsToInsert.add(objectToInsert);
    		}
    	}

    	public void registerDirtyWithCatch(SObject objectToUpdate)
    	{
    		if(this.objectsToUpdate == null) 
    		{
    			this.objectsToUpdate = new Map<Id, SObject>{objectToUpdate.Id => objectToUpdate};
    		}
    		
    		else
    		{
    			this.objectsToUpdate.put(objectToUpdate.Id, objectToUpdate);
    		}
    	}

    	public void doWork()
    	{
    		if(objectsToInsert == null &&
    			objectsToUpdate == null &&
    			objectsToDelete == null) return;

    		try
    		{
    			if(objectsToInsert != null)
    			{
    				objectsToInsert.sort();
    				insert objectsToInsert;
    			}

    			if(objectsToUpdate != null)
    			{
    				SObject[] updateList = objectsToUpdate.values();
    				updateList.sort();
    				update updateList;
    			}
    		}
    		
    		catch(Exception e)
    		{
    			System.debug(e);
    			sendErrorEmail(e, 'SRUnitOfWork');
    		}
    	}
    }

    public static void sendErrorEmail(Exception e, String context)
    {
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.setSubject(context + ' Error');
		message.setPlainTextBody('The following exception details were caught.  Type: ' + e.getTypeName()
					+ ' Cause: ' + e.getCause() 
					+ ' Message: ' + e.getMessage() 
					+ ' Message: ' + e.getLineNumber() 
					+ ' Stack Trace: ' + e.getStackTraceString());
		message.setTargetObjectId('005i0000002fU4O');
		message.setSaveAsActivity(false);
		catchExceptionEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }

    //converts a given string to Title Case where the
	//first letter of every word is capitalized and the rest are small
	public static String titleCase(String phrase){
		
		String titlePhrase = '';

		Set<String> forceLower = new Set<String>{'of', 'the', 'for', 'and', 'a', 'to', 'at' ,'an', 'but', 'if', 'or', 'nor'};

		if(phrase != null && phrase.length() > 0) {
		
			String[] splitPhrase = phrase.trim().split(' ');

			for(integer i = 0; i < splitPhrase.size(); i++) {

				if(splitPhrase[i] == '') continue;
				
				if(!forceLower.contains(splitPhrase[i].toLowerCase()) || i == 0 || i == (splitPhrase.size() - 1)) {
					
					titlePhrase += (splitPhrase[i].substring(0,1).toUpperCase()) + (splitPhrase[i].substring(1).toLowerCase()) + ' ';
				
				}else{
					
					titlePhrase += splitPhrase[i].toLowerCase() + ' ';
				}
			}
		}

		return titlePhrase.trim();
	}

	public static String scrubPhone(String phoneNumber)
    {
        if(phoneNumber!= null && phoneNumber.length() > 0)
        {
            System.debug('phoneNumber-before-scrubbing-> '+phoneNumber);
            phoneNumber = phoneNumber.trim();
            phoneNumber = phoneNumber.replaceAll('\\+', '');
            phoneNumber = phoneNumber.replaceAll('\\(', '');
            phoneNumber = phoneNumber.replaceAll('\\)', '');
            phoneNumber = phoneNumber.replaceAll(' ', '');
            phoneNumber = phoneNumber.replaceAll('-', '');
            phoneNumber = phoneNumber.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '');
            phoneNumber = phoneNumber.replaceAll('[a-zA-Z]', '');
            System.debug('phoneNumber-after-scrubbing-> '+phoneNumber);
        }
        
        return phoneNumber;
    }

	@InvocableMethod(label='postChatterFiles' description='Post Files in a Chatter Feed')
	public static void postChatterFiles(ChatterFilesInputVariables[] variables)
	{
		for(ChatterFilesInputVariables var : variables)
		{
			if(!var.fileIds.isEmpty()) postChatterFiles(var.fileIds, var.subjectId);
		}
	}

	public class ChatterFilesInputVariables
	{
		@InvocableVariable(required=true)
		public Id subjectId;

		@InvocableVariable(required=true)
		public Id[] fileIds;
	}
	
	public static void postChatterFiles(Id[] filesToPost, Id subjectId)
	{
		// Define the FeedItemInput object to pass to postFeedElement
		ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
		feedItemInput.subjectId = subjectId;

		ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
		textSegmentInput.text = 'See Related Files Below';

		// The MessageBodyInput object holds the text in the post
		ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
		messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
		messageBodyInput.messageSegments.add(textSegmentInput);
		feedItemInput.body = messageBodyInput;

		// The FeedElementCapabilitiesInput object holds the capabilities of the feed item.
		// For this feed item, we define a files capability to hold the file(s).

		List<String> fileIds = new List<String>();
		//fileIds.add(filesToPost);
		for(String recordId : filesToPost)
		{
			fileIds.add(recordId);
		}

		ConnectApi.FilesCapabilityInput filesInput = new ConnectApi.FilesCapabilityInput();
		filesInput.items = new List<ConnectApi.FileIdInput>();

		for (String fileId : fileIds) {
		    ConnectApi.FileIdInput idInput = new ConnectApi.FileIdInput();
		    idInput.id = fileId;
		    filesInput.items.add(idInput);
		}

		ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
		feedElementCapabilitiesInput.files = filesInput;

		feedItemInput.capabilities = feedElementCapabilitiesInput;

		// Post the feed item. 
		ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
	}

	public class SRException extends Exception
	{
		
	}
}