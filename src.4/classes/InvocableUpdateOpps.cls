public with sharing class InvocableUpdateOpps {
    
    @InvocableMethod(label='updateOpps' description='Update Opportunities passed from a flow')
    public static Id[] flowUpdateOpp(Opportunity[] opps) {

    	for(Opportunity o : opps) {
    		o.StageName = 'Qualified';
    		o.RecurSoft__Trial__c = null;
    		o.RecurSoft__Number_of_Free_Months__c = '0';
    		o.RecurSoft__Free_Months_Setting__c = null;

    	}

    	Database.SaveResult[] results = Database.update(opps);
    	Id[] oppIds = new List<Id>();
    	
    	for(Database.SaveResult result : results) {
    		
    		if(result.isSuccess()) {
    			oppIds.add(result.getId());
    		}
    	}

    	return oppIds;
    }
}