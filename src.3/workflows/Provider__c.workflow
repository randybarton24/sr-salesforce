<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PUID_Duplicate_Field_Update</fullName>
        <field>PUID_Unique__c</field>
        <formula>PUID__c</formula>
        <name>PUID Duplicate Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Profile_Update</fullName>
        <field>Last_Profile_Update_Date__c</field>
        <formula>NOW()</formula>
        <name>Profile Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Provider_Email_From_Contact</fullName>
        <field>Email__c</field>
        <formula>Related_Contact__r.Email</formula>
        <name>Provider: Email From Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>PUID Duplicate Blocker</fullName>
        <actions>
            <name>PUID_Duplicate_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(PUID__c) ||
ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Profile Update</fullName>
        <actions>
            <name>Profile_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT( $Setup.HG_WFR__c.HG_WFR_OFF__c ) &amp;&amp;
NOT(ISCHANGED( Last_Reported_Date__c )) &amp;&amp;  
NOT(ISCHANGED( Last_Scorecard_Date__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Provider%3A On Create</fullName>
        <actions>
            <name>Provider_Email_From_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
