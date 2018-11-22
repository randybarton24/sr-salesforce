public class ProcessAddendumValidationController 
{
	@AuraEnabled        
    public static Addendum__c getAddendumById(Id addendumId)
    {                
        return ((Addendum__c[]) AddendaSelector.newInstance().selectSObjectsById(new Set<Id>{ addendumId }))[0];
    }
}