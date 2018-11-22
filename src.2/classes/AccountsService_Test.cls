/**
 * Created by mschetselaar on 10/10/2018.
 */

@IsTest
private class AccountsService_Test
{
    @TestSetup
    static void testSetup()
    {
        TestUtilities.newInit();
    }
    
    @IsTest
    static void test_syncRecordOwners()
    {
        Map<Id,Id> accountIdToOwnerId = new Map<Id,Id>();
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account acct = [SELECT Id, OwnerId FROM Account LIMIT 1];
        User user = [SELECT Id FROM User WHERE IsActive = TRUE AND Id != :acct.OwnerId LIMIT 1];
        accountIdToOwnerId.put(acct.Id,user.Id);
        
        Test.startTest();
            AccountsService.syncRecordOwners(accountIdToOwnerId, uow);
            uow.commitWork();
        Test.stopTest();
        
        Account updateAccount = [SELECT Id, OwnerId FROM Account LIMIT 1];
        
        System.assert(updateAccount != null);
        System.assertEquals(user.Id,updateAccount.OwnerId);
    }
    
    @IsTest
    static void test_processParentChildUpdates()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Set<Id> ids = new Set<Id>();
        List<Account> accts = [SELECT Id, Account_Sales_Status__c, Do_Not_Contact__c, Phone FROM Account];
        List<Contact> contacts = new List<Contact>();
        for(Account a : accts)
        {
            ids.add(a.Id);
            a.Account_Sales_Status__c = 'Bogus';
            a.Do_Not_Contact__c = true;
            a.Phone = '8013317129';
            contacts.add(new Contact(FirstName = 'Test', LastName = 'Testor', AccountId = a.Id));
        }
        insert contacts;
        update accts;
        
        List<Parent_Child_Mapping__c> mappings = new List<Parent_Child_Mapping__c>();
        mappings.add(new Parent_Child_Mapping__c(Active__c = true, Parent_Object__c = 'Account', Child_Object__c = 'Contact', Parent_Field_Name__c = 'Account_Sales_Status__c', Child_Field_Name__c = 'Account_Sales_Status__c'));
        mappings.add(new Parent_Child_Mapping__c(Active__c = true, Parent_Object__c = 'Account', Child_Object__c = 'Contact', Parent_Field_Name__c = 'Do_Not_Contact__c', Child_Field_Name__c = 'Do_Not_Contact__c'));
        mappings.add(new Parent_Child_Mapping__c(Active__c = true, Parent_Object__c = 'Account', Child_Object__c = 'Contact', Parent_Field_Name__c = 'Phone', Child_Field_Name__c = 'Account_Phone__c'));
        
        Test.startTest();
            AccountsService.processParentChildUpdates(ids, accts, mappings, uow);
            uow.commitWork();
        Test.stopTest();
        
        List<Contact> updatedContacts = [SELECT Id, Account_Sales_Status__c, Do_Not_Contact__c, Account_Phone__c FROM Contact];
        
        System.assert(updatedContacts.size()>0);
        for(Contact c : updatedContacts)
        {
            System.assertEquals('Bogus', c.Account_Sales_Status__c);
            System.assertEquals(true, c.Do_Not_Contact__c);
            System.assertEquals('8013317129', c.Account_Phone__c);
        }
    }
    
    @IsTest
    static void test_processNewScorecards()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account acct = [SELECT Id, Last_HG_Scorecard_Date__c FROM Account LIMIT 1];
        acct.Last_HG_Scorecard_Date__c = Datetime.now().addDays(-10);
        update acct;
        
        Set<Id> ids = new Set<Id>();
        ids.add(acct.Id);
        
        Test.startTest();
            AccountsService.processNewScorecards(ids, uow);
            uow.commitWork();
        Test.stopTest();
        
        Account updatedAccount = [SELECT Id, Last_HG_Scorecard_Date__c FROM Account LIMIT 1];
        System.assert(updatedAccount.Last_HG_Scorecard_Date__c > Datetime.now().addDays(-1));
    }
}