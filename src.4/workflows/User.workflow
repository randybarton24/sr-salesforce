<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Insert_Hire_Date</fullName>
        <field>Hire_Date__c</field>
        <formula>Today()</formula>
        <name>Insert Hire Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Hire Date</fullName>
        <actions>
            <name>Insert_Hire_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.Hire_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Adds Today as the Hire Date if when created a user has no Hire Date - Matthew Schetselaar</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
