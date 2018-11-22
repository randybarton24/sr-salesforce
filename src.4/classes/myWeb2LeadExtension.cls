/**
 * File:        myWeb2LeadExtension.cls
 * Project:     Solutionreach 
 * Date:        January, 2014
 * Created By:  Delia Sopca
 * *************************************************************************
 * Description: Web to lead extension, to insert leads
 * *************************************************************************
 * History:
 */

public class myWeb2LeadExtension {

 

    private final Lead weblead;

 

    public myWeb2LeadExtension(ApexPages.StandardController

                                stdController) {

       weblead = (Lead)stdController.getRecord();

    }

 

     public PageReference saveLead() {

       weblead.LeadSource='Website';
       try {

       insert(weblead);

       }

       catch(System.DMLException e) {

           ApexPages.addMessages(e);

           return null;

       }

       PageReference p = Page.ThankYou;

       p.setRedirect(true);

       return p;

     }

}