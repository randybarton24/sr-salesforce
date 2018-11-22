<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SR_Date_Created_Event</fullName>
        <description>Updates the Activity.SR_Date_Created field with the value from the Salesforce CreatedDate field</description>
        <field>SR_Date_Created__c</field>
        <formula>CreatedDate</formula>
        <name>SR_Date_Created_Event</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <flowActions>
        <fullName>Onboarding_Training_Update</fullName>
        <flow>Onboarding_Training_update</flow>
        <flowInputs>
            <name>varCaseID</name>
            <value>{!X18_Character_What_ID__c}</value>
        </flowInputs>
        <flowInputs>
            <name>varMethod</name>
            <value>{!Training_Method__c}</value>
        </flowInputs>
        <flowInputs>
            <name>varTrainingType</name>
            <value>{!Activity_Type__c}</value>
        </flowInputs>
        <label>Onboarding Training Update</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <rules>
        <fullName>Onboarding Training</fullName>
        <actions>
            <name>Onboarding_Training_Update</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding Event</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.Activity_Results__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Updates the Date and Method of training for Onboarding Cases. - Matthew Schetselaar</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SR_Date_Created_Event</fullName>
        <actions>
            <name>SR_Date_Created_Event</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.SR_Date_Created__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Sets the Event.SR_Date_Created field to the value of the Event.CreatedDate field on creation, if there is no previous value.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
