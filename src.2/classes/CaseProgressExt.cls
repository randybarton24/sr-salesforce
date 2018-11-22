public class CaseProgressExt {
    private final Case mycase;
    
    public CaseProgressExt(ApexPages.StandardController controller) {
        if(!Test.isRunningTest()){
            controller.addFields(new List<String>{
                'First_Contact__c',
                'Training_Completed__c', 
                'CreatedDate',
                'Graphics_Task_Completed__c',
                'Graphics_Task_Claimed__c',
                'Custom_Settings_Scheduled_For__c',
                'Custom_Settings_Completed__c',
                'Sync_Install_Scheduled_For__c',
                'Sync_Install_Completed__c',
                'Training_Scheduled_For__c',
                'Training_Scheduled__c',
                'Kick_Off_Call__c',
                'Kick_Off_Call_Completed__c',
                'Final_Call__c',
                'Final_Call_Completed__c',
                'Midway_Decision_Maker_Call__c',
                'Midway_Decision_Maker_Call_Completed__c'
            });
        }
        this.mycase = (Case)controller.getRecord();
    }
    
    public String getFirstContactDate() {
        return getDateFormatted(this.mycase.First_Contact__c);
    }

    public String getTrainingScheduledDate() {
        return getDateFormatted(this.mycase.Training_Scheduled_For__c);
    }
    
    public String getTrainingCompletedDate() {
        return getDateFormatted(this.mycase.Training_Completed__c);
    }
    
    public String getGraphicsClaimedDate() {
        return getDateFormatted(this.mycase.Graphics_Task_Claimed__c);
    }
    
    public String getGraphicsSetupDate() {
        return getDateFormatted(this.mycase.Graphics_Task_Completed__c);
    }
    
    public String getSyncInstallScheduledDate() {
        return getDateFormatted(this.mycase.Sync_Install_Scheduled_For__c);
    }
    
    public String getSyncInstallCompletedDate() {
        return getDateFormatted(this.mycase.Sync_Install_Completed__c);
    }
    
    public String getCustomSettingsScheduledDate() {
        return getDateFormatted(this.mycase.Custom_Settings_Scheduled_For__c);
    }
    
    public String getCustomSettingsCompletedDate() {
        return getDateFormatted(this.mycase.Custom_Settings_Completed__c);
    }
    
    public String getKickOffCallScheduledDate(){
        return getDateFormatted(this.mycase.Kick_Off_Call__c);
    }
    
    public String getKickOffCallCompletedDate(){
        return getDateFormatted(this.mycase.Kick_Off_Call_Completed__c);
    }
    
    public String getFinalCallScheduledDate(){
        return getDateFormatted(this.mycase.Final_Call__c);
    }
    
    public String getFinalCallCompletedDate(){
        return getDateFormatted(this.mycase.Final_Call_Completed__c);
    }
    
    public String getMidwayDecisionMakerCallDate(){
        return getDateFormatted(this.mycase.Midway_Decision_Maker_Call__c);
    }
    
    public String getMidwayDecisionMakerCallCompletedDate(){
        return getDateFormatted(this.mycase.Midway_Decision_Maker_Call_Completed__c);
    }
    
    public String getAdminFMSDate(){
        return getDateFormatted(this.mycase.Account.Admin_FMS__c);
    }
    
    //
    // Internal methods for reuse
    //
    private String getDateFormatted(DateTime dt) {
        if (dt == null) {
            return '';
        }
        
        return dt.format('MMM dd, yyyy');
    }
    
}