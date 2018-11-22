@isTest
public class AgentContributionArticleControllerTest {
    
    @testSetup static void testData() {
        
        Account a = TestUtilities.insertBasicAccount(true);
        
    }
    
    @isTest static void testAgentContributionArticleController() {
        
        Account a = [SELECT Id FROM Account LIMIT 1];
        Contact con = new Contact();
        con.AccountId = a.Id;
        con.FirstName = 'Testy';
        con.LastName = 'McTestor';
        insert con;
        String caseSubject = 'my test';
        String caseDesc = 'my test description';
        Case c = new Case();
        c.subject = caseSubject;
        c.description = caseDesc;
        c.AccountId = a.Id;
        c.ContactId = con.Id;
        insert c;
        String caseId = c.id;
        
        System.debug('Created Case: ' + caseId);
        
        ApexPages.currentPage().getParameters().put('sourceId', caseId);
        ApexPages.currentPage().getParameters().put('sfdc.override', '1');
        ApexPages.KnowledgeArticleVersionStandardController ctl =
        new ApexPages.KnowledgeArticleVersionStandardController(new How_to_Article__kav());
        
        new AgentContributionArticleController(ctl);
        
        System.assertEquals(caseId, ctl.getSourceId());
        System.assertEquals('From Case: '+caseSubject, ctl.getRecord().get('title'));
        System.assertEquals(a.Id, ctl.getRecord().get('Suggesting_Account__c'));
        System.assertEquals(con.Id, ctl.getRecord().get('Suggesting_Contact__c'));
        
    }
    
}