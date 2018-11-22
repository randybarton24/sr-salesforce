@isTest
private class Surveys_Test 
{	
	@isTest static void test_createCaseLowSurveyScore() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		Account ac = (Account) TestUtilities2.newAccount().toSObject(); 

		sfab_FabricatedSObject sFab = TestUtilities2.newSurvey()
			.setField(Survey__c.Contact_Name__c, 'Test Name')
			.setField(Survey__c.How_can_we_improve__c, 'Test how can we improve')
			.setField(Survey__c.FS_Would_you_Recommend__c, '4')
			.setField(Survey__c.Business_Name__c, ac.Id);			
		
		Survey__c s = (Survey__c) sFab.toSObject();

		Survey__c existingSurvey = (Survey__c) TestUtilities2.existingSurvey(sFab)
			.toSObject();

		insert new SR_Default_Values__c(Name = 'Case Escalation Queue',
			Description__c = 'Case Escalation Queue',
            Value__c = '00Gi00000034JUX');	

		Surveys survey = new Surveys(new List<Survey__c>{ s });
		survey.createCaseLowSurveyScore(s, existingSurvey, uow);

		List<Case> cases = (List<Case>)(uow.m_newListByType.get('Case'));

		System.assertEquals(1, uow.m_newListByType.get('Case').size());	
		System.assertEquals(ac.Id, cases[0].AccountId);
		System.assertEquals(s.Contact_Name__c, cases[0].ContactId);
		System.assertEquals(s.How_can_we_improve__c, cases[0].Description);
		System.assertEquals('Poor Service Experience', cases[0].Category__c);
		System.assertEquals('Medium', cases[0].Priority);
		System.assertEquals(SR_Default_Values__c.getValues('Case Escalation Queue').Value__c, cases[0].Distribution_Group__c);
		System.assertEquals(SRUtilities.getRecordTypeId('Case','Support'), cases[0].RecordTypeId);
	}	

	@isTest static void test_createCaseLowSurveyScoreFail() 
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		Account ac = (Account) TestUtilities2.newAccount().toSObject(); 

		sfab_FabricatedSObject sFab = TestUtilities2.newSurvey()
			.setField(Survey__c.Contact_Name__c, 'Test Name')
			.setField(Survey__c.How_can_we_improve__c, 'Test how can we improve')
			.setField(Survey__c.FS_Would_you_Recommend__c, '8')
			.setField(Survey__c.Business_Name__c, ac.Id);			
		
		Survey__c s = (Survey__c) sFab.toSObject();

		Survey__c existingSurvey = (Survey__c) TestUtilities2.existingSurvey(sFab)
			.toSObject();

		insert new SR_Default_Values__c(Name = 'Case Escalation Queue',
			Description__c = 'Case Escalation Queue',
            Value__c = '00Gi00000034JUX');	

		Surveys survey = new Surveys(new List<Survey__c>{ s });
		survey.createCaseLowSurveyScore(s, existingSurvey, uow);

		System.assertEquals(0, uow.m_newListByType.get('Case').size());			
	}	

	@isTest static void test_onAfterUpdate() 
    {       
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		Account ac = (Account) TestUtilities2.newAccount().toSObject(); 

		sfab_FabricatedSObject sFab = TestUtilities2.newSurvey()
			.setField(Survey__c.Contact_Name__c, 'Test Name')
			.setField(Survey__c.How_can_we_improve__c, 'Test how can we improve')
			.setField(Survey__c.FS_Would_you_Recommend__c, '8')
			.setField(Survey__c.Business_Name__c, ac.Id);			
		
		Survey__c s = (Survey__c) sFab.toSObject();

		Surveys survey = new Surveys(new List<Survey__c>{ s });
        survey.onAfterUpdate(new Map<Id, SObject>{s.Id => s});          
    }
}