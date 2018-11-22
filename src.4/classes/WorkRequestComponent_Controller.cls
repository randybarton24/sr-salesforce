public with sharing class WorkRequestComponent_Controller 
{
    @AuraEnabled
    public static agf__ADM_Work__c saveRequest(agf__ADM_Work__c newRequest) 
    {
        // Perform isUpdatable() checking first, then
        System.debug(newRequest);
        WorkRequestMapping__c workRequestMapping = WorkRequestMapping__c.getInstance();
        newRequest.agf__Product_Tag__c = (Id) workRequestMapping.get(newRequest.Category__c.replaceAll(' ', '') + '_ProductTag__c');
        upsert newRequest;
        
        WorkRequestComponent_Controller.createFollower(newRequest.Id, UserInfo.getUserId());
        return newRequest;
    }

    @future
    public static void createFollower(Id parentId, Id subscriberId)
    {
    	insert new EntitySubscription(ParentId = parentId, SubscriberId = subscriberId);
    }
}