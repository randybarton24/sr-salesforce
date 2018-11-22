public with sharing class OpportunityTriggerHandler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static final Map<String, Schema.RecordTypeInfo> recordTypeMap = SRUtilities.getRecordTypeMap('Opportunity');
    public static Map<Id, Opportunity> oppDataMap;
    public static Map<Id, Account> relatedAccountsMap;

    public OpportunityTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeInsert(Opportunity[] newOpps){

    }

    public void OnAfterInsert(Opportunity[] newOpps, Map<Id, Opportunity> newOpportunityMap){

    }

    public void OnBeforeUpdate(Opportunity[] oldOpps, Opportunity[] updatedOpps, Map<ID, Opportunity> oldOpportunityMap, Map<ID, Opportunity> newOpportunityMap){
        
        FlowControl.checkOpportunityFieldChanges(updatedOpps, oldOpportunityMap);
    }

    public void OnAfterUpdate(Opportunity[] oldOpps, Opportunity[] updatedOpps, Map<ID, Opportunity> oldOpportunityMap, Map<ID, Opportunity> newOpportunityMap){

        if(FlowControl.fieldChangeIdMap.containsKey('OpportunityRecurSoft__Contract_Term_Start_Date__c') ||
            FlowControl.fieldChangeIdMap.containsKey('OpportunityRecurSoft__Contract_Term_End_Date__c')) {

            OpportunityTriggerHandler.oppDataMap = OpportunityUtilities.getOppData(newOpportunityMap.keySet());
            //OpportunityUtilities.updateOppLiContractDates(oppDataMap);
        }

        /*if(FlowControl.fieldChangeIdMap.containsKey('OpportunityRecurSoft__Number_of_Free_Months__c') ||
            FlowControl.fieldChangeIdMap.containsKey('OpportunityRecurSoft__Free_Months_Setting__c')) {

            OpportunityTriggerHandler.oppDataMap = OpportunityUtilities.getOppData(newOpportunityMap.keySet());
            OpportunityUtilities.setOppLiFreeMonths(oppDataMap);
        }

        if(FlowControl.fieldChangeIdMap.containsKey('OpportunityRecurSoft__Trial__c')) {

            OpportunityTriggerHandler.oppDataMap = OpportunityUtilities.getOppData(newOpportunityMap.keySet());
            OpportunityUtilities.setOppLiTrial(oppDataMap);
        }*/

        if(FlowControl.fieldChangeIdMap.containsKey('OpportunityRecurSoft__Initial_Contract_Term__c')
            && FlowControl.fieldChangeIdMap.get('OpportunityRecurSoft__Initial_Contract_Term__c').size() > 0) {

            OpportunityTriggerHandler.oppDataMap = OpportunityUtilities.getOppData(newOpportunityMap.keySet());
            //OpportunityUtilities.setOppLiBaseTerm(oppDataMap);
        }

        if(FlowControl.fieldChangeIdMap.containsKey('OpportunityIsClosed') 
            && FlowControl.fieldChangeIdMap.get('OpportunityIsClosed').size() > 0) {

            OpportunityTriggerHandler.oppDataMap = OpportunityUtilities.getOppData(newOpportunityMap.keySet());
            //OpportunityUtilities.setModifiedSubscription(oppDataMap.values());
        }          
    }
}