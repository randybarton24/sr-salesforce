<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Do_not_allow_Product_Code_duplicates</fullName>
        <field>Product_Code_Duplicates_Are_Not_Allowed__c</field>
        <formula>ProductCode</formula>
        <name>Do not allow Product Code duplicates</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Unique Product Code</fullName>
        <actions>
            <name>Do_not_allow_Product_Code_duplicates</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR   (    ISNEW(),    ISCHANGED( ProductCode ),    ISCHANGED ( Description ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
