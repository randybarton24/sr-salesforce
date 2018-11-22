/**
 * File:        myWeb2LeadExtension_TEST.cls
 * Project:     Solutionreach 
 * Date:        January, 2014
 * Created By:  Delia Sopca
 * *************************************************************************
 * Description: Web to lead extension, to insert leads
 * *************************************************************************
 * History:
 */

@isTest
public class myWeb2LeadExtension_TEST
{    
    @isTest
    public static void testMethodSuccess()
    {
        // create a lead record 
        Lead lead = new Lead(LastName='Test Lead', Company='Test Company'); 
    
        // create a new Account standard controller by passing it the account record
        ApexPages.StandardController controller = new ApexPages.StandardController(lead);
    
        // now pass it to the extension
        myWeb2LeadExtension stdController = new myWeb2LeadExtension(controller);
    
        system.assert(stdController != null); // controller has successfully been created
    
        Test.startTest();
             stdController.saveLead();
             //system.assertNotEquals(lead.ID, null);
        Test.stopTest();
    
    }
    @isTest
    public static void testMethodFail()
    {
        // create a lead record 
        Lead lead = new Lead(LastName='Test Lead'); 
    
        // create a new Account standard controller by passing it the account record
        ApexPages.StandardController controller = new ApexPages.StandardController(lead);
    
        // now pass it to the extension
        myWeb2LeadExtension stdController = new myWeb2LeadExtension(controller);
    
        system.assert(stdController != null); // controller has successfully been created
    
        Test.startTest();
             stdController.saveLead();
             //system.assertEquals(lead.ID, null);
        Test.stopTest();
    
    }
}