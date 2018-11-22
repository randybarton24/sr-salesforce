public without sharing class FlowControl {

    //Opportunity FlowControl Static Variables
    public static Boolean opportunityBeforeInsertRecursion = false;
    public static Boolean opportunityBeforeUpdateRecursion = false;
    public static Boolean opportunityAfterInsertRecursion = false;
    public static Boolean opportunityAfterUpdateRecursion = false;
    public static Boolean opportunityAppAdminSyncRecursion = false;
    public static Boolean inOpportunityAfterInsert = false;
    public static Boolean inClass1 = false;
    public static Map<ID, SObject> alreadyDeleted = new Map<ID, SObject>();
    public static Map<ID, SObject> alreadyUpdated = new Map<ID, SObject>();

    //CampaignInfluence FlowControl
    public static Boolean campaignInfluenceBeforeInsertRecursion = false;
    public static Boolean campaignInfluenceBeforeUpdateRecursion = false;
    public static Boolean campaignInfluenceAfterInsertRecursion = false;
    public static Boolean campaignInfluenceAfterUpdateRecursion = false;
    public static Boolean inCampaignInfluenceAfterInsert = false;

    //Task FlowControl
    public static Boolean taskBeforeInsertRecursion = false;
    public static Boolean taskBeforeUpdateRecursion = false;
    public static Boolean taskAfterInsertRecursion = false;
    public static Boolean taskAfterUpdateRecursion = false;
    public static Boolean inTaskAfterInsert = false;

    //Lead FlowControl
    public static Boolean leadBeforeInsertRecursion = false;
    public static Boolean leadBeforeUpdateRecursion = false;
    public static Boolean leadAfterInsertRecursion = false;
    public static Boolean leadAfterUpdateRecursion = false;
    public static Boolean inLeadAfterInsert = false;

    //CampaignMember FlowControl
    public static Boolean campaignMemberBeforeInsertRecursion = false;
    public static Boolean campaignMemberBeforeUpdateRecursion = false;
    public static Boolean campaignMemberAfterInsertRecursion = false;
    public static Boolean campaignMemberAfterUpdateRecursion = false;
    public static Boolean inCampaignMemberAfterInsert = false;

    //Provider FlowControl
    public static Boolean providerBeforeInsertRecursion = false;
    public static Boolean providerBeforeUpdateRecursion = false;
    public static Boolean providerAfterInsertRecursion = false;
    public static Boolean providerAfterUpdateRecursion = false;
    public static Boolean inProviderAfterInsert = false;

    //ProductSubscription FlowControl
    public static Boolean prodSubscriptionBeforeInsertRecursion = false;
    public static Boolean prodSubscriptionBeforeUpdateRecursion = false;
    public static Boolean prodSubscriptionAfterInsertRecursion = false;
    public static Boolean prodSubscriptionAfterUpdateRecursion = false;
    public static Boolean inProdSubscriptionAfterInsert = false;
    public static Boolean prodSubscriptionInsertAsyncRecursion = false;
    public static Boolean prodSubscriptionUpdateAsyncRecursion = false;

    //Transaction FlowControl
    /*public static Boolean transactionBeforeInsertRecursion = false;
    public static Boolean transactionBeforeUpdateRecursion = false;
    public static Boolean transactionAfterInsertRecursion = false;
    public static Boolean transactionAfterUpdateRecursion = false;
    public static Boolean inTransactionAfterInsert = false;*/

    //Asset FlowControl
    public static Boolean assetBeforeInsertRecursion = false;
    public static Boolean assetBeforeUpdateRecursion = false;
    public static Boolean assetAfterInsertRecursion = false;
    public static Boolean assetAfterUpdateRecursion = false;
    public static Boolean inAssetAfterInsert = false;
    public static Boolean assetUpdateAsyncRecursion = false;

    //OpportunityLineItem FlowControl
    public static Boolean oppLineItemRollupRecursion = false;
    public static Boolean oppLineItemBeforeInsertRecursion = false;
    public static Boolean oppLineItemBeforeUpdateRecursion = false;
    public static Boolean oppLineItemAfterInsertRecursion = false;
    public static Boolean oppLineItemAfterUpdateRecursion = false;
    public static Boolean inOppLineItem = false;
    public static Boolean oppLineItemInsertAsyncRecursion = false;
    public static Boolean oppLineItemUpdateAsyncRecursion = false;
    
    public static Boolean suppressRollup = false;
    public static Boolean hgContractDatesSet = false;
    public static Set<String> recordsCreated = new Set<String>();
    public static Boolean isLeadConvert = false;
    public static Boolean isLeadUnConvert = false;

    private static Map<String, SObject> fieldChangeMap = new Map<String, SObject>();
    public static Map<String, Set<Id>> fieldChangeIdMap = new Map<String, Set<Id>>();

    private static Map<String, SObject> priorValueMap = new Map<String, SObject>();
    public static Map<String, Set<Id>> fieldChangeIdMap2 = new Map<String, Set<Id>>();

    public static void checkOpportunityFieldChanges(Opportunity[] newList, Map<Id, Opportunity> oldMap) {

        hasFieldChanged(newList, oldMap, 'StageName', 'Closed Won');
        hasFieldChanged(newList, oldMap, 'RecurSoft__Number_of_Free_Months__c', null);
        hasFieldChanged(newList, oldMap, 'RecurSoft__Free_Months_Setting__c', null);
        hasFieldChanged(newList, oldMap, 'RecurSoft__Initial_Contract_Term__c', null);
        hasFieldChanged(newList, oldMap, 'RecurSoft__Contract_Term_Start_Date__c', null);
        hasFieldChanged(newList, oldMap, 'RecurSoft__Contract_Term_End_Date__c', null);
        hasFieldChanged(newList, oldMap, 'RecurSoft__Billing_Contact__c', null);
        hasFieldChanged(newList, oldMap, 'CampaignId', null);
        hasFieldChanged(newList, oldMap, 'Number_of_Providers__c', null);
        hasFieldChanged(newList, oldMap, 'Number_of_PRT__c', null);
        hasFieldChanged(newList, oldMap, 'RecurSoft__Trial__c', null);
        hasFieldChanged(newList, oldMap, 'Contract_Signed__c', null);
        hasFieldChanged(newList, oldMap, 'IsClosed', null);
        hasFieldChanged(newList, oldMap, 'Pricebook2Id', null);
    }

    public static void checkOppLineItemFieldChanges(OpportunityLineItem[] newList, Map<Id, OpportunityLineItem> oldMap) {

        hasFieldChanged(newList, oldMap, 'RecurSoft__Contract_Term_End_Date_Editable__c', null);
        hasFieldChanged(newList, oldMap, 'RecurSoft__Contract_Term_Start_Date_New__c', null);
        hasFieldChanged(newList, oldMap, 'Number_of_Free_Months__c', null);
        hasFieldChanged(newList, oldMap, 'Free_Month_Setting__c', null);
        hasFieldChanged(newList, oldMap, 'Base_Contract_Term__c', null);
        hasFieldChanged(newList, oldMap, 'Trial__c', null);
        hasFieldChanged(newList, oldMap, 'UnitPrice', null);
        hasFieldChanged(newList, oldMap, 'Approval_Level_Required__c', null);
    }

    public static void checkProdSubscriptionFieldChanges(RecurSoft__Product_Subscription__c[] newList, Map<Id, RecurSoft__Product_Subscription__c> oldMap) {

        hasFieldChanged(newList, oldMap, 'RecurSoft__Billing_Status__c', null);
        hasFieldChanged(newList, oldMap, 'Next_Invoice_Date__c', null);
        hasFieldChanged(newList, oldMap, 'RecurSoft__Contract_Signed_Date__c', null);
        hasFieldChanged(newList, oldMap, 'RecurSoft__Contract_Term_End_Date__c', null);
    }

    public static void checkAssetFieldChanges(Asset[] newList, Map<Id, Asset> oldMap) {

        hasFieldChanged(newList, oldMap, 'Active__c', null);
        hasFieldChanged(newList, oldMap, 'Subscription_Last_Modified_Date__c', null);
    }

    public static void checkProviderFieldChanges(Provider__c[] newList, Map<Id, Provider__c> oldMap) {

        hasFieldChanged(newList, oldMap, 'Premium_Member__c', null);
    }

    public static void checkCancelRequestFieldChanges(Cancel_Request__c[] newList, Map<Id, Cancel_Request__c> oldMap) {

        hasFieldChanged(newList, oldMap, 'Stage__c', 'Save');
        hasFieldChanged(newList, oldMap, 'Stage__c', 'Resume - No Change');
        hasFieldChanged(newList, oldMap, 'Stage__c', 'Cancelled');
        hasFieldChanged(newList, oldMap, 'Stage__c', 'No Sale');
    }

    public static void checkTaskFieldChanges(Task[] newList, Map<Id, Task> oldMap) {

        hasFieldChanged(newList, oldMap, 'Date_Completed_New__c', null);
        hasFieldChanged(newList, oldMap, 'ADR_Set__c', null);
        hasFieldChanged(newList, oldMap, 'Activity_Type__c', 'Group Practice');
    }

    public static Set<Id> hasFieldChanged(SObject[] newList, Map<Id, SObject> oldMap, String fieldName, String fieldValue) {

        Set<Id> results = new Set<Id>();

        for(SObject s : newList) {

            try {

                String objectType = s.getSObjectType().getDescribe().getName();
                String mapKeyChange = fieldValue == null ? objectType + fieldName + s.Id : objectType + fieldName + fieldValue + s.Id;
                String mapKeyValue = fieldValue == null ? objectType + fieldName : objectType + fieldName + fieldValue;             
                
                SObject sOld = fieldChangeMap.containsKey(mapKeyChange) ? fieldChangeMap.get(mapKeyChange) : oldMap.get(s.Id);

                //System.debug(fieldName + ' Old value: ' + sOld.get(fieldName) + ' ' + fieldName + ' New value: ' + s.get(fieldName));
                if(s.get(fieldName) != sOld.get(fieldName)){

                    fieldChangeMap.put(mapKeyChange, s.clone());

                    if((String.valueOf(s.get(fieldName)) == fieldValue || 
                        fieldValue == null)) {
                    
                        results.add(s.Id);
                        if(fieldChangeIdMap.containsKey(mapKeyValue)) {

                            fieldChangeIdMap.get(mapKeyValue).add(s.Id);
                        
                        } else {

                            fieldChangeIdMap.put(mapKeyValue, results);
                        }
                    }

                } else if(fieldChangeIdMap.containsKey(mapKeyValue) && fieldChangeIdMap.get(mapKeyValue).contains(s.Id)) {

                    fieldChangeIdMap.get(mapKeyValue).remove(s.Id);
                }

            } catch(Exception e) {

                System.debug(e);
            }
        }

        return results;
    }

    public static Set<Id> fieldChanges(SObject[] newList, Map<Id, SObject> oldMap, String fieldName, String fieldValue) {

        Set<Id> results = new Set<Id>();

        for(SObject s : newList) {

            try {

                String objectType = s.getSObjectType().getDescribe().getName();
                String mapKeyChange = fieldValue == null ? objectType + fieldName + s.Id : objectType + fieldName + fieldValue + s.Id;
                String mapKeyValue = fieldValue == null ? objectType + fieldName : objectType + fieldName + fieldValue;             
                
                SObject sOld = priorValueMap.containsKey(mapKeyChange) ? priorValueMap.get(mapKeyChange) : oldMap.get(s.Id);

                //System.debug(fieldName + ' Old value: ' + sOld.get(fieldName) + ' ' + fieldName + ' New value: ' + s.get(fieldName));
                if(s.get(fieldName) != sOld.get(fieldName)){

                    priorValueMap.put(mapKeyChange, s.clone());

                    if((String.valueOf(s.get(fieldName)) == fieldValue || 
                        fieldValue == null)) {
                    
                        results.add(s.Id);
                        if(fieldChangeIdMap2.containsKey(mapKeyValue)) {

                            fieldChangeIdMap2.get(mapKeyValue).add(s.Id);
                        
                        } else {

                            fieldChangeIdMap2.put(mapKeyValue, results);
                        }
                    }

                } else if(fieldChangeIdMap2.containsKey(mapKeyValue) && fieldChangeIdMap2.get(mapKeyValue).contains(s.Id)) {

                    fieldChangeIdMap2.get(mapKeyValue).remove(s.Id);
                }

            } catch(Exception e) {

                System.debug(e);
            }
        }

        return results;
    }

    public static Map<String, SObject> oldValuesMap = new Map<String, SObject>();
    public static Map<String, Set<Id>> fieldToIdSetMap = new Map<String, Set<Id>>();
    public static Map<String, Set<Id>> fieldToIdSetMapAfterUpdate = new Map<String, Set<Id>>();
    public static Boolean fieldChangeRecursion = false;

    public static void haveFieldsChanged(SObject[] newList, Map<Id, SObject> oldMap, String[] fieldChanges) 
    {
        for(SObject s : newList) 
        {
            for(String fieldChange : fieldChanges)
            {
                Set<Id> fieldChangedIds = new Set<Id>();
                String fieldName = fieldChange.substringBefore(',');
                String fieldValue = fieldChange.substringAfter(',');

                try 
                {
                    String objectType = s.getSObjectType().getDescribe().getName();
                    String oldValuesMapKey = fieldValue == '' ? objectType + '.' + fieldName + '.' + s.Id : objectType + '.' + fieldName + '.' + fieldValue + '.' + s.Id;
                    String fieldToIdSetMapKey = fieldValue == '' ? objectType + '.' + fieldName : objectType + '.' + fieldName + '.' + fieldValue;             
                    
                    SObject sOld = oldValuesMap.containsKey(oldValuesMapKey) ? oldValuesMap.get(oldValuesMapKey) : oldMap.get(s.Id);

                    System.debug(fieldName + ' Old value: ' + sOld.get(fieldName) + ' ' + fieldName + ' New value: ' + s.get(fieldName));

                    if(s.get(fieldName) != sOld.get(fieldName))
                    {
                        oldValuesMap.put(oldValuesMapKey, s.clone());

                        if((String.valueOf(s.get(fieldName)) == fieldValue || 
                            fieldValue == '')) 
                        {
                            fieldChangedIds.add(s.Id);
                            if(fieldToIdSetMap.containsKey(fieldToIdSetMapKey)) 
                            {
                                fieldToIdSetMap.get(fieldToIdSetMapKey).add(s.Id);
                            } 
                            else 
                            {
                                fieldToIdSetMap.put(fieldToIdSetMapKey, fieldChangedIds);
                            }
                        }

                    } 
                    else if(fieldToIdSetMap.containsKey(fieldToIdSetMapKey) && 
                        fieldToIdSetMap.get(fieldToIdSetMapKey).contains(s.Id)) 
                    {
                        fieldToIdSetMap.get(fieldToIdSetMapKey).remove(s.Id);
                    }

                } 
                catch(Exception e) 
                {
                    System.debug(e);
                }
            }
        }
    }
}