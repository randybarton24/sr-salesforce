<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Closed_Checkbox</fullName>
        <field>Closed__c</field>
        <literalValue>1</literalValue>
        <name>Closed Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Engagement</fullName>
        <field>Engagement_Score_when_entering__c</field>
        <formula>Account__r.ApptegicEngagement__c</formula>
        <name>Current Engagement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ICU_Disposition_date</fullName>
        <description>Updates the Dispositioned date when marked with one of the dispositioned statuses</description>
        <field>Dispositioned_Date__c</field>
        <formula>Now ()</formula>
        <name>ICU Disposition date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Exit_Engagement</fullName>
        <field>Engagement_Score_when_Exiting__c</field>
        <formula>Account__r.ApptegicEngagement__c</formula>
        <name>Update Exit Engagement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ICU Closed Date</fullName>
        <actions>
            <name>Closed_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ICU_Disposition_date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Exit_Engagement</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ICU_Target__c.Target_Status__c</field>
            <operation>equals</operation>
            <value>Declined,Set Provided,No Change,Passed,Closed,Assist Provided,Deferred,Requeue</value>
        </criteriaItems>
        <criteriaItems>
            <field>ICU_Target__c.Dispositioned_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Date/Time stamps the Dispositioned date when marked as dispositioned. - Matt Schetselaar</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Entering Engagement Score</fullName>
        <actions>
            <name>Current_Engagement</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.IsActive</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>ICU_Target__c.Engagement_Score_when_entering__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Puts the current Engagement score of the account in the Target when it is created - Matthew Schetselaar</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
