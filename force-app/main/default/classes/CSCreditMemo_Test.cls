/**
 * Created by abishop on 11/15/18.
 */

@IsTest
public with sharing class CSCreditMemo_Test {
    @IsTest static void getCreditLimit_Test()
    {
        Profile newProfile = [SELECT Id FROM Profile WHERE Name = 'Support Team Leads' LIMIT 1];

        CSCreditMemoLimits__c creditLimit = new CSCreditMemoLimits__c();
        creditLimit.SetupOwnerId = newProfile.Id ;
        creditLimit.Limit__c = 400;
        insert creditLimit;

        User u = [SELECT Id FROM User WHERE ProfileId = :newProfile.Id AND IsActive = TRUE LIMIT 1];
        System.runAs(u) {


            Case c = new Case();
            c.Subject = 'Test';
            c.Credit_Memo_Amount__c = 100;
            insert c;

            List<CSCreditMemo.OutputData> testList = CSCreditMemo.getCreditLimit();
            System.assertEquals(1, testList.size());
            System.assertEquals(300,testList[0].limitRemaining);

        }
    }

    @IsTest static void getCreditLimit_Test_NoCase()
    {
        Profile newProfile = [SELECT Id FROM Profile WHERE Name = 'Support Team Leads' LIMIT 1];

        CSCreditMemoLimits__c settings = CSCreditMemoLimits__c.getOrgDefaults();
        settings.Limit__c = 500;
        upsert settings CSCreditMemoLimits__c.Id;

        User u = [SELECT Id FROM User WHERE ProfileId = :newProfile.Id AND IsActive = TRUE LIMIT 1];
        System.runAs(u) {


            List<CSCreditMemo.OutputData> testList = CSCreditMemo.getCreditLimit();
            System.assertEquals(1, testList.size());
            System.assertEquals(500,testList[0].limitRemaining);

        }
    }


}