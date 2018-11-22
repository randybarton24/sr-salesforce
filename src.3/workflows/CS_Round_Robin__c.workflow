<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CS_Round_Robin_Name_Change</fullName>
        <description>Changes the Name of the Record to the name of the Implementation Rep</description>
        <field>Name</field>
        <formula>Rep_Name__r.Id</formula>
        <name>CS Round Robin Name Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Scheduler_Number_Assigned</fullName>
        <description>Updates the number of assigned cases by 1</description>
        <field>Number_of_Cases_Assigned__c</field>
        <formula>Number_of_Cases_Assigned__c  + 1</formula>
        <name>Update Scheduler Number Assigned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Jason B%2E Add 1</fullName>
        <actions>
            <name>Update_Scheduler_Number_Assigned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Add&#39;s one count to Jason B&#39;s and Karyn N. total to give them half as many accounts - Matthew Schetselaar</description>
        <formula>OR(Id = &quot;a22i0000003xReY&quot;, Id = &quot;a22i0000003xfmv&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update CS RR Name</fullName>
        <actions>
            <name>CS_Round_Robin_Name_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Name of the Round Robin to be the Implementation Rep&#39;s name - Matthew Schetselaar</description>
        <formula>AND(  OR(RecordType.Name = &quot;Tech Rep&quot;, RecordType.Name = &quot;Implementation Rep&quot;, RecordType.Name = &quot;Scheduler Rep&quot;, RecordType.Name = &quot;Success Coach&quot;, RecordType.Name=&quot;ICU Rep&quot;), Or(  ISNEW(), ISCHANGED( Rep_Name__c )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
