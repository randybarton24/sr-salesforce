<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>RR_Email_Alert</fullName>
        <ccEmails>randy@solutionreach.com</ccEmails>
        <description>RR Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>srreplies@solutionreach.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/LeadsNewassignmentnotification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Last_Owner_Change</fullName>
        <field>Last_Owner_Change__c</field>
        <formula>now()</formula>
        <name>Last Owner Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_Email_From</fullName>
        <description>Updates the New_Email_From__c field with the profile of the User who updated the email field.</description>
        <field>New_Email_From__c</field>
        <formula>$Profile.Name</formula>
        <name>New Email From</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RR_Time_Update</fullName>
        <description>Stamps 1 hr behind the current time for use in Current RR Owner Lead workflow time-based trigger.</description>
        <field>Current_RR_Time__c</field>
        <formula>now()- 0.0408</formula>
        <name>RR Time Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_IsRoundRobin</fullName>
        <description>After Round Robin occurs, reset flag to false.</description>
        <field>IsRoundRobin__c</field>
        <literalValue>0</literalValue>
        <name>Reset IsRoundRobin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SR_Date_Created_Lead_Update</fullName>
        <description>For all NEW Leads, Sets the SR_Date_Created__c field to the Created_Date field</description>
        <field>SR_Date_Created__c</field>
        <formula>CreatedDate</formula>
        <name>SR Date Created Lead Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <flowActions>
        <fullName>Lead_Conversion</fullName>
        <flow>Account_Billing_Email_Update</flow>
        <flowInputs>
            <name>varAccountID</name>
            <value>{!ConvertedAccountId}</value>
        </flowInputs>
        <flowInputs>
            <name>varEmailAddress</name>
            <value>{!Email}</value>
        </flowInputs>
        <label>Lead Conversion</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <rules>
        <fullName>Current RR Time Lead</fullName>
        <actions>
            <name>RR_Time_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.IsRoundRobin__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Stamps 1 hr behind the current time for use in related time-based trigger.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Last Owner Change</fullName>
        <actions>
            <name>Last_Owner_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( OwnerId )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New Email From</fullName>
        <actions>
            <name>New_Email_From</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule will check to see if the email field has been updated to a new value.  If so, it will update the New_Email_From__c field with the role of the user who changed the email field.</description>
        <formula>ISCHANGED(Email) &amp;&amp; NOT(ISNEW()) &amp;&amp; NOT(ISBLANK(Email)) &amp;&amp; NOT(ISNULL(Email))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PM Sync Available</fullName>
        <active>true</active>
        <formula>ISCHANGED( Practice_Software__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RR Email Notification</fullName>
        <active>true</active>
        <description>Lead Round Robin(RR) email notification</description>
        <formula>IsRoundRobin__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>RR_Email_Alert</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Reset_IsRoundRobin</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Lead.Current_RR_Time__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SR Date Created Lead Update</fullName>
        <actions>
            <name>SR_Date_Created_Lead_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.SR_Date_Created__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>For all NEWly created Leads, sets the SR_Date_Created__c field to the value of Created_Date</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
