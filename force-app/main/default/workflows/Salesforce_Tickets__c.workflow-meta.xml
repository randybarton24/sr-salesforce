<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Completed_date_is_Today</fullName>
        <description>Updates the Completed Date to Today</description>
        <field>Completed_Date__c</field>
        <formula>Today()</formula>
        <name>Completed date is Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Completed date</fullName>
        <actions>
            <name>Completed_date_is_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Salesforce_Tickets__c.Completed_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Salesforce_Tickets__c.Ticket_Status__c</field>
            <operation>equals</operation>
            <value>Closed No Resolution,Closed Fixed,Closed No Fix</value>
        </criteriaItems>
        <description>Updates the Completed Date if none exists</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
