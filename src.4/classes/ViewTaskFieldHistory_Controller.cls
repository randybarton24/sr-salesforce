public with sharing class ViewTaskFieldHistory_Controller 
{
	public Task_History__c[] taskHistory { get; set; }


	public ViewTaskFieldHistory_Controller(ApexPages.StandardController stdController) 
	{
		Id taskId = stdController.getId();
		taskHistory = [SELECT Task_Id__c, Field__c, Old_Value__c, New_Value__c, Owner.Name, CreatedDate 
			FROM Task_History__c 
			WHERE Task_Id__c = :taskId 
			ORDER BY CreatedDate DESC];		
	}
}