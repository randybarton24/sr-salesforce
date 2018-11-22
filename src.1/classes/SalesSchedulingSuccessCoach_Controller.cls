public without sharing class SalesSchedulingSuccessCoach_Controller 
{
    public TimeZone userTimeZone { get; set; }
    public final Opportunity varOpp;
    public Opportunity oppData;
    public String successCoachTimeZone { get; set; }
    public Boolean successCoachAssigned { get; set; }
    public Flow.Interview.Activation_Assignment_on_Opportunity myFlow { get; set; }

    /**
     * Constructor to initialize variables. Timezone info for logged in user and Account Success Coach.
     * @param  stdController - Opportunity standard controller
     * @see Success_Coach_Schedule.page
     */
     
    public SalesSchedulingSuccessCoach_Controller(ApexPages.StandardController stdController) 
    {    
        this.varOpp = (Opportunity)stdController.getRecord();
        oppData = [SELECT Id, Account.Id, Account.Team_Assignment__c, Account.Success_Coach__c, Account.Success_Coach__r.Start_Hour__c, Account.Success_Coach__r.End_Hour__c From Opportunity WHERE Id = :varOpp.Id];
        userTimeZone = UserInfo.getTimeZone();
        successCoachTimeZone = oppData.Account.Success_Coach__c != null ? [SELECT Id, TimeZoneSidKey FROM User WHERE Id = :oppData.Account.Success_Coach__c].TimeZoneSidKey : null;
        successCoachAssigned = oppData.Account.Success_Coach__c != null;
    }

    /**
     * Difference between current user timezone and Account Success Coach.
     * Subtracts offsets from GMT.  Divide by 3600000 because results are in milliseconds.
     * @return Decimal - Number of hours difference
     */
    public Decimal getTimeZoneDifference() 
    {
        Decimal results = 0;

        TimeZone tz = TimeZone.getTimeZone(successCoachTimeZone);
        results = (UserInfo.getTimeZone().getOffset(Date.today()) - tz.getOffset(Date.today()))/3600000;

        return results;
    }
    
    /**
     * Standard start time is 6 plus timezone difference.  Custom start times based on Account Success Coach Start Time field.
     * @return Decimal - Start hour based on 24hr clock
     */
    public Decimal getStartTime() 
    {    
        Decimal results = 0;

        if(oppData.Account.Success_Coach__r.Start_Hour__c == null) 
        {
            results = 6 + getTimeZoneDifference();
        } 
        else 
        {
            results = oppData.Account.Success_Coach__r.Start_Hour__c + getTimeZoneDifference();
        }

        return results;
    }

    /**
     * Standard end time is 17 plus timezone difference.  Custom end times based on Account Success Coach End Time field.
     * @return Decimal - Ending hour based on 24hr clock
     */
    public Decimal getEndTime() 
    {    
        Decimal results = 0;

        if(oppData.Account.Success_Coach__r.End_Hour__c == null) 
        {
            results = 17 + getTimeZoneDifference();
        } 
        else 
        {
            results = oppData.Account.Success_Coach__r.End_Hour__c + getTimeZoneDifference();
        }

        return results;
    }
    
        public void start() 
        {
                Map<String, Object> myMap = new Map<String, Object>();
                myMap.put('varOppId', oppData.Id);
                myMap.put('varTeamAssignment', oppData.Account.Team_Assignment__c);
                myMap.put('varAccountID', oppData.AccountId);
                myFlow = new Flow.Interview.Activation_Assignment_on_Opportunity(myMap);
                System.debug(myMap);
                myFlow.start();
   }
    
}