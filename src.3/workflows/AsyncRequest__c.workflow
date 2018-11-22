<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AsyncPriorityUpdate</fullName>
        <field>Priority__c</field>
        <formula>IF(Priority__c != 9,
			CASE(TEXT(AsyncType__c), 
						&quot;Set_Approvals&quot;, 1, 
						&quot;Create_Asset&quot;, 1,
						&quot;Process_Dist_Group&quot;, 1,
						&quot;Create_CI&quot;, 7,
						&quot;Stamp_Updates&quot;, 4,
						&quot;Demo_Request_Reason&quot;, 5,
						&quot;Link_Opp_CI&quot;, 6,
						2) ,
			9)</formula>
        <name>AsyncPriorityUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TempFixFieldUpdate</fullName>
        <field>AsyncType__c</field>
        <literalValue>Update_Opp_Stage_Demo_Scheduled</literalValue>
        <name>TempFixFieldUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <flowActions>
        <fullName>five9test</fullName>
        <flow>TestFive9</flow>
        <label>five9test</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <rules>
        <fullName>AsyncPriority</fullName>
        <actions>
            <name>AsyncPriorityUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Five9Test</fullName>
        <actions>
            <name>five9test</name>
            <type>FlowAction</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>AsyncRequest__c.Params__c</field>
            <operation>equals</operation>
            <value>0013100001spifeAAA</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>TempFix</fullName>
        <actions>
            <name>TempFixFieldUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>AsyncRequest__c.AsyncType__c</field>
            <operation>equals</operation>
            <value>Update_Opp_Stage_Demo_Completed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
