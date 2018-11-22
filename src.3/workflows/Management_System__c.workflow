<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Production_ID_c_on_creation</fullName>
        <description>Sets Production_ID__c as External ID. Used for testing in Sandboxes</description>
        <field>Production_ID__c</field>
        <formula>Id</formula>
        <name>Set Production_ID__c on creation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Production_ID%5F%5Fc on creation</fullName>
        <actions>
            <name>Set_Production_ID_c_on_creation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Production_ID__c as External ID.  Used for testing in Sandboxes</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
