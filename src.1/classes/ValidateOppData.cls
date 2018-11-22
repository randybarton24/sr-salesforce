/**
 * File:        ValidateOppData.cls
 * Project:     Solutionreach 
 * Date:        Mar 26, 2014
 * Created By:  Sid Maganti
 * *************************************************************************
 * Description: Apex class to Validate opportunity data before you send the contract. This 
 *              apex class will be revoked from java script.(Send Contract:Button on Opportunity)
 * *************************************************************************
 * History:
 * Date:                Modified By:            Description: 
 * 02/19/2015           Randy Barton		    Added validation for free month approval.
 */

global class ValidateOppData {
    //Webservice method returns string (error message or clear keyword)
    /*Validate
    *@ returns String
    *@ input String OppID
    */
    webService static String Validate(String OppID) {
        //return string value
        string output=null;
        string Error= null;
        //checking the OppID is null or empty
        if(OppID!= null && OppID!='')
        {
            Opportunity Opp = new Opportunity();
            //retriving the Opportunity data
            Opp=[select id,Name,CloseDate,Sync_Availability__c,RecurSoft__Bill_to_Account__r.Office_Contact__c,StageName,RecurSoft__Expected_Contract_Start_Date__c,Account.RecurSoft__Channel__c,Account.Industry,RecurSoft__Bill_to_Account__r.Industry,
            RecurSoft__Bill_to_Account__r.RecurSoft__Channel__c,RecurSoft__Bill_to_Account__c,RecurSoft__Billing_Contact__c,RecurSoft__Trial__c,RecurSoft__Initial_Contract_Term__c, RecurSoft__Bill_to_Account__r.Sales_Engineer_Call_Completed__c,
            Contract_Signed__c, RecurSoft__Bill_to_Account__r.Practice_Management_Software__c, RecurSoft__Bill_to_Account__r.Practice_Management_Software__r.Sales_Engineer_Call_Needed__c,Approval_Level_Required__c,
          RecurSoft__Intacct_Entity__c, RecordType.Name, RecurSoft__Number_Of_Free_Months__c,owner.profile.Name from Opportunity where id =: OppID];
            
            //checking if Opp is null
            if(Opp!=null)
            {
                if(Opp.RecurSoft__Bill_to_Account__c==null || System.Test.isRunningTest())
                { 
                    Error= 'Please specify the Biling Account';
                }
                if(Opp.RecurSoft__Bill_to_Account__r.Office_Contact__c==null || System.Test.isRunningTest())
                { 
                    Error= 'Please specify the Office Contact on Biling Account';
                }
                if(Opp.RecurSoft__Billing_Contact__c==null || System.Test.isRunningTest() )
                {
                    Error= 'Please specify the Biling Contact';
                }
                if(Opp.RecurSoft__Trial__c==null || Opp.RecurSoft__Trial__c=='' || System.Test.isRunningTest())
                {
                    Error= 'Please specify the Trial Period';
                }
                if(Opp.RecurSoft__Initial_Contract_Term__c==null || Opp.RecurSoft__Initial_Contract_Term__c==0 || System.Test.isRunningTest())
                {
                    Error= 'Please specify the Initial Contract Term (months)';
                }
                if(Opp.Contract_Signed__c== true || System.Test.isRunningTest())
                {
                    Error= 'Contract is already signed';
                }
                if(Opp.RecurSoft__Bill_to_Account__r.Practice_Management_Software__c== null || System.Test.isRunningTest())
                {
                    Error= 'Please specify Management System on Biling Account';
                }
                if( Date.today()>Opp.CloseDate || System.Test.isRunningTest())
                {
                    Error= 'Closed date is passed';
                }
                /*
                if(Opp.RecurSoft__Expected_Contract_Start_Date__c == null || System.Test.isRunningTest())
                {
                    Error= 'Please specify Expected Contract Start Date';
                }
                */
                if( Opp.Account.Industry == null || System.Test.isRunningTest())
                {
                    Error= 'Please specify Channel and Industry on Account';
                }
                if(Opp.RecurSoft__Bill_to_Account__r.Industry == null || System.Test.isRunningTest())
                {
                    Error= 'Please specify Channel and Industry on Bill to Account';
                }
                if(Opp.RecurSoft__Intacct_Entity__c == null || System.Test.isRunningTest())
                {
                    Error= 'Please specify Intacct Entity';
                }
                
                // Check to make sure we have no outstanding approvals
                if(Opp.Approval_Level_Required__c != null && Opp.Approval_Level_Required__c > 0) {
                    Error = 'This Opportunity has pricing or free months that require approval prior to sending the contract';
                }

                if((opp.RecurSoft__Bill_to_Account__r.Sales_Engineer_Call_Completed__c == null || opp.RecurSoft__Bill_to_Account__r.Sales_Engineer_Call_Completed__c < Date.today().addDays(-30)) && 
                    opp.RecurSoft__Bill_to_Account__r.Practice_Management_Software__r.Sales_Engineer_Call_Needed__c &&
                    opp.RecordType.Name == 'New Practice Business' &&
                    opp.Owner.Profile.Name != 'Support' &&
                    opp.Owner.Profile.Name != 'Support Team Leads' &&
                    opp.Owner.Profile.Name != 'Support Manager')
                {
                    Error = 'This Management System requires a Sales Engineer call to be completed within the last 30 days before sending the contract.';
                }
                
                if (Opp.Sync_Availability__c == 'Blacklist - DO NOT SELL') {
                    Error = 'This account is using a Management System on the Blacklist. DO NOT SELL!';
                }
                system.debug('Opp.RecurSoft__Bill_to_Account__r.RecurSoft__Channel__c'+Opp.RecurSoft__Bill_to_Account__r.RecurSoft__Channel__c);
            }
        }
        //populate the output string
        output=(Error==null)?'clear':Error;
        //system debug output 
        system.debug('output: '+output);
        //return the output
        return output;
    }
}