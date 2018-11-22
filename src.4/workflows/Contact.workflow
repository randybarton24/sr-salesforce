<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <flowActions>
        <fullName>Update_Billing_Email</fullName>
        <description>Updates the billing Address on the Account</description>
        <flow>Account_Billing_Email_Update</flow>
        <flowInputs>
            <name>varAccountID</name>
            <value>{!Account.Id}</value>
        </flowInputs>
        <flowInputs>
            <name>varEmailAddress</name>
            <value>{!Email}</value>
        </flowInputs>
        <label>Update Billing Email</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
</Workflow>
