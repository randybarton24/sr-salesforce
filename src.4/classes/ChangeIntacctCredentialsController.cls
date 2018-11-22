/**
 * File:        ChangeIntacctCredentialsController.cls<br/>
 * Project:     Sererra - Subscription Billing<br/>
 * Date:        September 3, 2014<br/>
 * Created By:  Ionut Boghean<br/>
 * *************************************************************************<br/>
 * Description: The controller for the change intacct credentials page.<br/>
 * *************************************************************************<br/>
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 */
public with sharing class ChangeIntacctCredentialsController 
{
    private static final String INTACCT_SETTING_NAME = 'Intacct Gateway';
    private static final String INTACCT_GATEWAY_URL = 'https://www.intacct.com/ia/xml/xmlgw.phtml';
    private Intacct_Integration_Settings__c intacctCredentials;
    public String companyId {get; set;}
    public String userName {get; set;}
    public String userPassword {get; set;}
    public String senderName {get; set;}
    public String senderPassword {get; set;}
    
    /**
    * @author Ionut Boghean
    * @date September 3, 2014
    * @description Constructor
    */
    public ChangeIntacctCredentialsController()
    {
        companyId = '';
        userName = '';
        userPassword = '';
        senderName = '';
        senderPassword = '';
    }
    
    /**
    * @author Ionut Boghean
    * @date September 3, 2014
    * @description Save the changes
    */
    public void saveChanges()
    {
        retrieveIntacctCredentials();
        IntacctEncryptionManager.setPrivateEncryptionKey();
        if(!String.isBlank(companyId))
        {
            intacctCredentials.Intacct_Company_ID__c = IntacctEncryptionManager.encryptValue(Blob.valueOf(companyId));
        }
        if(!String.isBlank(userName))
        {
            intacctCredentials.Intacct_User_ID__c = IntacctEncryptionManager.encryptValue(Blob.valueOf(userName));
        }
        if(!String.isBlank(userPassword))
        {
            intacctCredentials.Intacct_Password__c = IntacctEncryptionManager.encryptValue(Blob.valueOf(userPassword));
        }
        if(!String.isBlank(senderName))
        {
            intacctCredentials.Intacct_Sender_ID__c = IntacctEncryptionManager.encryptValue(Blob.valueOf(senderName));
        }
        if(!String.isBlank(senderPassword))
        {
            intacctCredentials.Intacct_Sender_Password__c = IntacctEncryptionManager.encryptValue(Blob.valueOf(senderPassword));
        }
        upsertIntacctCredentials();
        IntacctEncryptionManager.upsertEncryptionObject();
    }
    
    /**
    * @author Ionut Boghean
    * @date September 3, 2014
    * @description Retrieve the intacct credentials and populate the page fields
    */
    private void retrieveIntacctCredentials()
    {
        intacctCredentials = Intacct_Integration_Settings__c.getValues(INTACCT_SETTING_NAME);
        if(intacctCredentials == null)
        {
            intacctCredentials = new Intacct_Integration_Settings__c();
            intacctCredentials.Name = INTACCT_SETTING_NAME;
            intacctCredentials.Intacct_Gateway_URL__c = INTACCT_GATEWAY_URL;
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date September 3, 2014
    * @description Upsert the intacct credentials setting
    */
    private void upsertIntacctCredentials()
    {
        try
        {
            upsert intacctCredentials;
        }
        catch(DmlException dmlEx)
        {
            
        }
    }
    
}