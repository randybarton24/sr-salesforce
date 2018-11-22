public class Surveys extends fflib_SObjectDomain 
{    
    public static Set<Id> surveyRecursion = new Set<Id>();

    public Surveys(Survey__c[] surveys) 
    {
        super(surveys);
        Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Surveys(sObjectList);
        }
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords)
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Survey__c s : (Survey__c[]) Records) 
        {
            Survey__c existingSurvey = (Survey__c) existingRecords.get(s.Id);

            this.createCaseLowSurveyScore(s, existingSurvey, uow);        
        }    
        
        uow.commitWork();
    }

    public void createCaseLowSurveyScore(Survey__c survey, Survey__c existingSurvey, fflib_SObjectUnitOfWork uow)
    {
        if(existingSurvey != null && 
            survey.FS_Would_you_Recommend__c == existingSurvey.FS_Would_you_Recommend__c && 
            survey.FS_Overall_Rep_Experience__c == existingSurvey.FS_Overall_Rep_Experience__c) return;

        if(surveyRecursion.contains(survey.Contact_Name__c)) return;
        surveyRecursion.add(survey.Contact_Name__c);

        if((survey.FS_Would_you_Recommend__c != null && Integer.valueOf(survey.FS_Would_you_Recommend__c) <= 6) ||
            (survey.FS_Overall_Rep_Experience__c != null && Integer.valueOf(survey.FS_Overall_Rep_Experience__c) <= 6))
        {           
            Case c = new Case(AccountId = survey.Business_Name__c,
                ContactId = survey.Contact_Name__c,
                Subject  = 'Low Survey Score',
                Description = survey.How_can_we_improve__c,
                RecordTypeId = SRUtilities.getRecordTypeId('Case','Support'),
                Origin = 'Auto-Created',
                Status = 'New',
                Priority = 'Medium',
                Category__c = 'Poor Service Experience',
                Product__c = 'Low CSAT/RSAT',
                Distribution_Group__c = SR_Default_Values__c.getValues('Case Escalation Queue').Value__c);
            uow.registerNew(c);
        }
    }
}