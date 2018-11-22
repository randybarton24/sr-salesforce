<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AddendumLineItem_Duplicate_Block</fullName>
        <field>Duplicate_Block__c</field>
        <formula>Addendum__c +  Asset__c</formula>
        <name>AddendumLineItem_Duplicate_Block</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AddendumLineItem_Duplicate_Block</fullName>
        <actions>
            <name>AddendumLineItem_Duplicate_Block</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() || ISCHANGED(Asset__c) || ISCHANGED(Addendum__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
