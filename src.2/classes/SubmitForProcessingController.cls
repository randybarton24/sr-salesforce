public class SubmitForProcessingController {
	@AuraEnabled        
    public static Integer getCountAssets(string id, string account)
    {                
        Integer countAssets = [SELECT COUNT() FROM Asset WHERE Active__c = true AND AccountId = :account AND Contract_Type__c != 'Month-to-month' AND Id NOT IN (SELECT Asset__c FROM Addendum_Line_Item__c WHERE Addendum__c = :id) ];        
        return countAssets;          
    }
}