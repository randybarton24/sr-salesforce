<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Campaign_Add_Date_Update</fullName>
        <field>Campaign_Add_Date__c</field>
        <formula>IF( Campaign_Add_Date__c != null , Campaign_Add_Date__c , 
 IF( ISPICKVAL( Campaign__r.Type , &quot;Trade Show/Event&quot; ) &amp;&amp; Campaign__r.CI_From_Task__c = false , DATETIMEVALUE(TEXT( Campaign__r.StartDate ) + &quot; 13:00:00&quot; ) , now() ))</formula>
        <name>Set_Campaign_Add_Date_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set_Campaign_Add_Date_WFR</fullName>
        <actions>
            <name>Set_Campaign_Add_Date_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK( Campaign_Add_Date__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
