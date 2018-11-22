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
    <flowActions>
        <fullName>five9test2</fullName>
        <flow>TestFive9</flow>
        <label>five9test2</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <rules>
        <fullName>Five9Test2</fullName>
        <actions>
            <name>five9test2</name>
            <type>FlowAction</type>
        </actions>
        <active>false</active>
        <formula>Id = &#39;0033100003Bor2T&#39;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
