<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_SFDC_Id_Prefix</fullName>
        <description>Updates the SFDC Id Prefix field with the parent&#39;s first 3 characters.</description>
        <field>SFDC_Id_Prefix_Text__c</field>
        <formula>LEFT( Parent_Id__c , 3)</formula>
        <name>Populate SFDC Id Prefix</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>true</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update SFDC Id Prefix</fullName>
        <actions>
            <name>Populate_SFDC_Id_Prefix</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Intacct_Error__c.Parent_Id__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Trigger the update of the SFDC Id Prefix field.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
