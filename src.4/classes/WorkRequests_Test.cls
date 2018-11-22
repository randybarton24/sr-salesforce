@isTest
private class WorkRequests_Test 
{	
    @testSetup static void testData() 
    {
        agf__ADM_Scrum_Team__c team = new agf__ADM_Scrum_Team__c(Name = 'Test Team');
        insert team;
        agf__ADM_Product_Tag__c tag = new agf__ADM_Product_Tag__c(agf__Team__c = team.Id);
        insert tag;

        insert new WorkRequestMapping__c(SetupOwnerId = UserInfo.getOrganizationId(), Bug_ProductTag__c = tag.Id);
    }

    @isTest static void testNewWork() 
    {
    	Test.startTest();

    	agf__ADM_Work__c w = new agf__ADM_Work__c(agf__Subject__c = 'Subject', Category__c = 'Bug');
    	insert w;

    	Test.stopTest();
    }
}