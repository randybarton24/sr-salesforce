public without sharing class TimeZoneControllerExtension {

    public final Case varCase;
    public Case caseData;
    public TimeZone userTimeZone { get; set; }
    public String caseOwnerTimeZone { get; set; }

    /**
     * Constructor to initialize variables. Timezone info for logged in user and case owner.
     * @param  stdController - Case standard controller
     * @see Activation_Reps_Schedule.page
     */
    public TimeZoneControllerExtension(ApexPages.StandardController stdController) {
        
        this.varCase = (Case)stdController.getRecord();
        caseData = [SELECT Id, OwnerId, Case_Owner_Start_Time__c, Case_Owner_End_Time__c FROM Case WHERE Id = :varCase.Id];
        userTimeZone = UserInfo.getTimeZone();
        caseOwnerTimeZone = [SELECT Id, TimeZoneSidKey FROM User WHERE Id = :caseData.OwnerId].TimeZoneSidKey;
    }

    /**
     * Difference between current user timezone and case owner timezone.
     * Subtracts offsets from GMT.  Divide by 3600000 because results are in milliseconds.
     * @return Decimal - Number of hours difference
     */
    public Decimal getTimeZoneDifference() {

        Decimal results = 0;

        TimeZone tz = TimeZone.getTimeZone(caseOwnerTimeZone);
        results = (UserInfo.getTimeZone().getOffset(Date.today()) - tz.getOffset(Date.today()))/3600000;

        return results;
    }
    
    /**
     * Standard start time is 6 plus timezone difference.  Custom start times based on Case Owner Start Time field.
     * @return Decimal - Start hour based on 24hr clock
     */
    public Decimal getStartTime() {
        
        Decimal results = 0;

        if(caseData.Case_Owner_Start_Time__c == null) {
            results = 6 + getTimeZoneDifference();
        } else {
            results = caseData.Case_Owner_Start_Time__c + getTimeZoneDifference();
        }

        return results;
    }

    /**
     * Standard end time is 17 plus timezone difference.  Custom end times based on Case Owner End Time field.
     * @return Decimal - Ending hour based on 24hr clock
     */
    public Decimal getEndTime() {
        
        Decimal results = 0;

        if(caseData.Case_Owner_End_Time__c == null) {
            results = 17 + getTimeZoneDifference();
        } else {
            results = caseData.Case_Owner_End_Time__c + getTimeZoneDifference();
        }

        return results;
    }
}