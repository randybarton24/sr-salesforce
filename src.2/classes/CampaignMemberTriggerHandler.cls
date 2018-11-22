public with sharing class CampaignMemberTriggerHandler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    //private static final Map<String, Id> StaticCampaignMemberRecordTypes = RecordTypes.GetRecordTypeIdDevMap('CampaignMember');
    public static Map<Id, Contact> contactDataMap;

    public CampaignMemberTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    /*public void OnBeforeInsert(CampaignMember[] newCampaignMembers){
    	
    	if(!FlowControl.campaignMemberBeforeInsertRecursion) {
    		FlowControl.campaignMemberBeforeInsertRecursion = true;
    		
    	}
    }*/

    public void OnAfterInsert(CampaignMember[] newCampaignMembers, Map<Id, CampaignMember> newCampaignMemberMap){
    
    	FlowControl.inCampaignMemberAfterInsert = true;
    	
    	if(!FlowControl.campaignMemberAfterInsertRecursion) {
    		FlowControl.campaignMemberAfterInsertRecursion = true;
            contactDataMap = CampaignMemberUtilities.getRelatedContactsMap(newCampaignMembers);
            CampaignMemberUtilities.createCampaignInfluenceFromCampaignMember(newCampaignMembers);
    	}
    	
    	FlowControl.inCampaignMemberAfterInsert = false;
    }

    //@future public static void OnAfterInsertAsync(Set<ID> newCampaignMemberIDs){}

    public void OnBeforeUpdate(CampaignMember[] oldCampaignMembers, CampaignMember[] updatedCampaignMembers, Map<ID, CampaignMember> oldCampaignMemberMap, Map<ID, CampaignMember> newCampaignMemberMap){
    	
    	if(!FlowControl.campaignMemberBeforeUpdateRecursion) {
    		FlowControl.campaignMemberBeforeUpdateRecursion = true;
    		contactDataMap = CampaignMemberUtilities.getRelatedContactsMap(updatedCampaignMembers);
    		CampaignMemberUtilities.createCampaignInfluenceFromCampaignMember(updatedCampaignMembers);
    	}	
    }

    //public void OnAfterUpdate(CampaignMember[] oldCampaignMembers, CampaignMember[] updatedCampaignMembers, Map<ID, CampaignMember> oldCampaignMemberMap, Map<ID, CampaignMember> newCampaignMemberMap){
    //
    //	if(!FlowControl.campaignMemberAfterUpdateRecursion && !FlowControl.inCampaignMemberAfterInsert) {
    //		FlowControl.campaignMemberAfterUpdateRecursion = true;
    //	}
    //}

    //@future public static void OnAfterUpdateAsync(Set<ID> updatedCampaignMemberIDs){}

    //public void OnBeforeDelete(CampaignMember[] CampaignMembersToDelete, Map<ID, CampaignMember> oldCampaignMemberMap){
    //}

    //public void OnAfterDelete(CampaignMember[] deletedCampaignMembers, Map<ID, CampaignMember> oldCampaignMemberMap){}

    //@future public static void OnAfterDeleteAsync(Set<ID> deletedCampaignMemberIDs){}

    //public void OnUndelete(CampaignMember[] restoredCampaignMembers){}

    //public boolean IsTriggerContext{
    //    get{ return m_isExecuting;}
    //}

    //public boolean IsVisualforcePageContext{
    //    get{ return !IsTriggerContext;}
    //}

    //public boolean IsWebServiceContext{
    //    get{ return !IsTriggerContext;}
    //}

    //public boolean IsExecuteAnonymousContext{
    //    get{ return !IsTriggerContext;}
    //}

}