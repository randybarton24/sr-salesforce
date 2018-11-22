<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Addendum_Notification</fullName>
        <description>Addendum Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>srreplies@solutionreach.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Addendum_Owner</template>
    </alerts>
    <rules>
        <fullName>Addendum Owner Notification</fullName>
        <actions>
            <name>Addendum_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( OwnerId ) &amp;&amp;
OwnerId = CreatedById</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
