<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Case_Status_to_Opened</fullName>
        <description>Opens the Case back up.</description>
        <field>Status</field>
        <literalValue>Re-Opened</literalValue>
        <name>Case Status to Opened</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Re-open Closed Cases when a reply is received</fullName>
        <actions>
            <name>Case_Status_to_Opened</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>Reopens closed cases when the customer replies after the case is closed. - Matthew Schetselaar</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
