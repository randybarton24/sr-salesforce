<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CRO_Duplicate_Block</fullName>
        <field>Duplicate_Block__c</field>
        <formula>Asset__c +  Opportunity__c</formula>
        <name>CRO_Duplicate_Block</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CR_Processed_Date</fullName>
        <description>Updates the Cancel Request Processed Date</description>
        <field>Processed_Date__c</field>
        <formula>Now()</formula>
        <name>Update CR Processed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CR Closed update Fields</fullName>
        <actions>
            <name>Update_CR_Processed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Cancel_Request__c.Stage__c</field>
            <operation>equals</operation>
            <value>Cancelled,No Sale,Save,Resume - No Change</value>
        </criteriaItems>
        <criteriaItems>
            <field>Cancel_Request__c.Processed_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>This will update the processed date to be today when a request is closed. - Matt Schetselaar</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CRO_Duplicate_Block</fullName>
        <actions>
            <name>CRO_Duplicate_Block</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() || ISCHANGED(Asset__c) || ISCHANGED(Opportunity__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
