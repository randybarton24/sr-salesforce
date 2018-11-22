/**
 * File:        ChangeIntacctCredentialsController_Test.cls<br/>
 * Project:     Sererra - Subscription Billing<br/>
 * Date:        September 4, 2014<br/>
 * Created By:  Ionut Boghean<br/>
 * *************************************************************************<br/>
 * Description: Test class for ChangeIntacctCredentialsController.<br/>
 * *************************************************************************<br/>
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 */
@isTest
public class ChangeIntacctCredentialsController_Test 
{
    private static final String TEST_VALUE = 'Test value';
    private static final String INTACCT_SETTING_NAME = 'Intacct Gateway';
    
    /**
    * @author Ionut Boghean
    * @date September 4, 2014
    * @description Test happy flow
    */
    private static testMethod void testHappyFlow()
    {
        Test.startTest();
        ChangeIntacctCredentialsController testInstance = new ChangeIntacctCredentialsController();
        testInstance.companyId = TEST_VALUE;
        testInstance.userName = TEST_VALUE;
        testInstance.userPassword = TEST_VALUE;
        testInstance.senderName = TEST_VALUE;
        testInstance.senderPassword = TEST_VALUE;
        testInstance.saveChanges();
        Test.stopTest();
        Intacct_Integration_Settings__c intacctSetting = Intacct_Integration_Settings__c.getValues(INTACCT_SETTING_NAME);
        System.assertNotEquals(intacctSetting.Intacct_Company_ID__c.length(), 0);
    }
    
}