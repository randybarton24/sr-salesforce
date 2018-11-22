<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AR_Email_Support_General_Auto_Response_Email_Template</fullName>
        <description>AR: Email Support General Auto Response Email Template</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@solutionreach.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Client_Success_Folder/Email_Support_General_Auto_Response</template>
    </alerts>
    <alerts>
        <fullName>New_Enterprise_Activation_Case</fullName>
        <description>New Enterprise Activation Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>njensen@solutionreach.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>srreplies@solutionreach.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CS_Enterprise/New_Enterprise_Activation_Case</template>
    </alerts>
    <fieldUpdates>
        <fullName>AR_Email_Support_General_Auto_Response</fullName>
        <field>Email_Alerts_Sent__c</field>
        <formula>IF(ISBLANK(Email_Alerts_Sent__c),
&quot;Email Support General Auto Response&quot;,
Email_Alerts_Sent__c +&quot;;&quot;+&quot;Email Support General Auto Response&quot;
)</formula>
        <name>AR: Email Support General Auto Response</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Activation_Status</fullName>
        <field>Status</field>
        <literalValue>Actively Working</literalValue>
        <name>Activation Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Status_to_Assigned</fullName>
        <field>Status</field>
        <literalValue>Assigned</literalValue>
        <name>Case Status to Assigned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Community_Case_Ownership</fullName>
        <description>Changes case ownership to CS support queue.</description>
        <field>OwnerId</field>
        <lookupValue>CS_Support_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Community Case Ownership</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Onboarding_to_Assigned</fullName>
        <field>Status</field>
        <literalValue>Assigned</literalValue>
        <name>Onboarding to Assigned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SR_Date_Created_Case_Update</fullName>
        <description>Updates the Case.SR_Date_Created__c to the Case.CreatedDate</description>
        <field>SR_Date_Created__c</field>
        <formula>CreatedDate</formula>
        <name>SR Date Created Case Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Survey_Checkbox</fullName>
        <description>Auto Checks when sending out a survey.</description>
        <field>Survey_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Survey Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_owner_team_assignment</fullName>
        <field>Case_Owner_Team_Assignment__c</field>
        <formula>Text( Owner:User.Support_Team_Assignment__c )</formula>
        <name>Update Case owner team assignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <flowActions>
        <fullName>Accounting_Review_Case_Creation</fullName>
        <flow>Accounting_Review_Case_Creation_Flow</flow>
        <flowInputs>
            <name>varAccountID</name>
            <value>{!AccountId}</value>
        </flowInputs>
        <flowInputs>
            <name>varSubjectToReview</name>
            <value>{!Subject}</value>
        </flowInputs>
        <flowInputs>
            <name>varUserID</name>
            <value>{!OwnerId}</value>
        </flowInputs>
        <label>Accounting Review Case Creation</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>Activation_Case_Assignment</fullName>
        <flow>Activation_Case_Auto_Assign</flow>
        <flowInputs>
            <name>varAccountID</name>
            <value>{!AccountId}</value>
        </flowInputs>
        <flowInputs>
            <name>varBusinessName</name>
            <value>{!Account.Name}</value>
        </flowInputs>
        <flowInputs>
            <name>varCaseID</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>varContactID</name>
            <value>{!ContactId}</value>
        </flowInputs>
        <flowInputs>
            <name>varPM</name>
            <value>{!Account.Practice_Management_Software__r.Name}</value>
        </flowInputs>
        <flowInputs>
            <name>varParentID</name>
            <value>{!Account.ParentId}</value>
        </flowInputs>
        <flowInputs>
            <name>varSubVert</name>
            <value>{!Account.Sub_Vertical__c}</value>
        </flowInputs>
        <flowInputs>
            <name>varTeamAssignment</name>
            <value>{!Account.Team_Assignment__c}</value>
        </flowInputs>
        <flowInputs>
            <name>varVertical</name>
            <value>{!Account.Industry}</value>
        </flowInputs>
        <label>Activation Case Assignment</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>Activation_Owner_Changed</fullName>
        <description>Updates the CS Round Robin to the new User and updates the Implementation Rep or Success Coach on the Account.</description>
        <flow>Activation_Case_Update_CS_Round_Robin</flow>
        <flowInputs>
            <name>varAccountID</name>
            <value>{!AccountId}</value>
        </flowInputs>
        <flowInputs>
            <name>varCaseID</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>varCaseRecordID</name>
            <value>{!RecordTypeId}</value>
        </flowInputs>
        <flowInputs>
            <name>varTeamAssignment</name>
            <value>{!Account.Team_Assignment__c}</value>
        </flowInputs>
        <flowInputs>
            <name>varUserID</name>
            <value>{!OwnerId}</value>
        </flowInputs>
        <label>Activation/Onboarding Owner Changed</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>Create_Onboarding_Task</fullName>
        <description>Runs the flow to create a task for the onboarding rep</description>
        <flow>Ready_for_Onboarding_Task</flow>
        <flowInputs>
            <name>BusinessName</name>
            <value>{!Account.Name}</value>
        </flowInputs>
        <flowInputs>
            <name>varAccountID</name>
            <value>{!AccountId}</value>
        </flowInputs>
        <flowInputs>
            <name>varContactID</name>
            <value>{!ContactId}</value>
        </flowInputs>
        <flowInputs>
            <name>varDueDate</name>
            <value>{!Next_Business_Day__c}</value>
        </flowInputs>
        <flowInputs>
            <name>varOwnerID</name>
            <value>{!$User.X18_Character_ID__c}</value>
        </flowInputs>
        <label>Create Onboarding Task</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>Post_Case_Survey_Trigger</fullName>
        <flow>Post_Case_Survey_Creation</flow>
        <flowInputs>
            <name>VarContactEmail</name>
            <value>{!Contact.Email}</value>
        </flowInputs>
        <flowInputs>
            <name>Var_AccountID</name>
            <value>{!AccountId}</value>
        </flowInputs>
        <flowInputs>
            <name>Var_CaseSubject</name>
            <value>{!Subject_for_Surveys__c}</value>
        </flowInputs>
        <flowInputs>
            <name>Var_ContactID</name>
            <value>{!ContactId}</value>
        </flowInputs>
        <flowInputs>
            <name>Var_RepID</name>
            <value>{!OwnerId}</value>
        </flowInputs>
        <flowInputs>
            <name>varBillingEmail</name>
            <value>{!Account.RecurSoft__Billing_Email__c}</value>
        </flowInputs>
        <flowInputs>
            <name>varContactPhone</name>
            <value>{!Contact.Phone}</value>
        </flowInputs>
        <flowInputs>
            <name>varOfficePhone</name>
            <value>{!Account.Phone}</value>
        </flowInputs>
        <flowInputs>
            <name>var_Case_ID</name>
            <value>{!Id}</value>
        </flowInputs>
        <label>Post Case Survey Trigger</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>Task_Creation_after_Case_Reassignment</fullName>
        <description>Creates a task for the new owner of the case when it is reassigned.</description>
        <flow>Task_Creation_after_Case_Reassignment</flow>
        <flowInputs>
            <name>varCaseID</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>varContactID</name>
            <value>{!ContactId}</value>
        </flowInputs>
        <flowInputs>
            <name>varOwnerID</name>
            <value>{!Owner:User.Id}</value>
        </flowInputs>
        <label>Task Creation after Case Reassignment</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>Update_Account_on_Check_up_Case</fullName>
        <description>This will run the flow that will update the Account with today&#39;s date in the Last Check-up Date field</description>
        <flow>Update_Check_up_Date_on_Account</flow>
        <flowInputs>
            <name>varAccountID</name>
            <value>{!Account.Id}</value>
        </flowInputs>
        <label>Update Account on Check up Case</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>Update_Account_on_Sync_Case_Status</fullName>
        <flow>Sync_List_Case_Update</flow>
        <flowInputs>
            <name>varAccountID</name>
            <value>{!AccountId}</value>
        </flowInputs>
        <flowInputs>
            <name>varCaseStatus</name>
            <value>{!Status}</value>
        </flowInputs>
        <label>Update Account on Sync Case Status</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <rules>
        <fullName>AR%3A Email Support General Auto Response</fullName>
        <actions>
            <name>AR_Email_Support_General_Auto_Response_Email_Template</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>AR_Email_Support_General_Auto_Response</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email,Community</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_Alerts_Sent__c</field>
            <operation>notContain</operation>
            <value>Email Support General Auto Response</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Auto response for all new email support requests.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Accounting Review Case Creation</fullName>
        <actions>
            <name>Accounting_Review_Case_Creation</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Accounting</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason</field>
            <operation>equals</operation>
            <value>Trial Cancel,Annual Cancel,No-Sale,Addendums,Past Due,Collection Case,Update Payment Info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Creates a Review case for the user&#39;s managers - Matt Schetselaar</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Activation Case Round Robin</fullName>
        <actions>
            <name>Activation_Case_Assignment</name>
            <type>FlowAction</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Activation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Implementation_Rep__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer</value>
        </criteriaItems>
        <description>Automatically assigns out the Activation Case when a new one comes in - Matthew Schetselaar</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Activation Case Status Update</fullName>
        <actions>
            <name>Activation_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Activation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.First_Contact_Class__c</field>
            <operation>equals</operation>
            <value>complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Updates the Status to Actively working when the First Contact is compleated. - Matt Schetselaar</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Activation%2FOnboarding Case Owner Change</fullName>
        <actions>
            <name>Activation_Owner_Changed</name>
            <type>FlowAction</type>
        </actions>
        <active>false</active>
        <description>Updates the CS Round Robin when an Activation or Onboarding Case Changes Ownership. - Matthew Schetselaar</description>
        <formula>And( Not(IsChanged( CS_Round_Robin_ID__c )), IsChanged( OwnerId ),  OR(RecordTypeId = &quot;012i0000001EALw&quot; , RecordTypeId = &quot;012i0000001Dnil&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner Change</fullName>
        <actions>
            <name>Task_Creation_after_Case_Reassignment</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <description>Creates a Task for the new owner of the case if it&#39;s different than the one modifying the case. - Matthew Schetselaar</description>
        <formula>AND( OwnerId &lt;&gt; LastModifiedById, 
ISCHANGED( OwnerId ), 
ISBLANK( Owner:Queue.QueueName ), 
OR (RecordType.Name &lt;&gt; &quot;Activation&quot;, RecordType.Name &lt;&gt; &quot;Onboarding&quot;),
 Not(ISPICKVAL( Status , &quot;Closed&quot;)), 
NOT(ISPICKVAL(Origin , &quot;Chatbot&quot;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Check up Case Account update</fullName>
        <actions>
            <name>Update_Account_on_Check_up_Case</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Check-Up</value>
        </criteriaItems>
        <description>Updates the Last Check-up Date on the Account - Matt Schetselaar</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Cases Change Ownership</fullName>
        <actions>
            <name>Change_Community_Case_Ownership</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Community</value>
        </criteriaItems>
        <description>Change ownership of community cases to route to CS Support</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Onboarding Task</fullName>
        <actions>
            <name>Create_Onboarding_Task</name>
            <type>FlowAction</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Activation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Custom_Settings_Class__c</field>
            <operation>equals</operation>
            <value>complete</value>
        </criteriaItems>
        <description>Creates a task for the Onboarder to start working with the Office - Matthew Schetselaar</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Post Case Survey Creation</fullName>
        <actions>
            <name>Post_Case_Survey_Trigger</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND (6 OR 12) AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Support,Sync List Case</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Resolution__c</field>
            <operation>equals</operation>
            <value>Fixed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Survey_Sent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.AccountName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Eligible_for_a_Survey__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecurSoft__Status__c</field>
            <operation>equals</operation>
            <value>Active,Pending Setup</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>Customer,Enterprise</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>00Gi0000003T8Bg</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>005i0000003I9Ll</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Survey_Opt_Out__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Creates a Survey through a flow - Matt Schetselaar</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SR Date Created Case Update</fullName>
        <actions>
            <name>SR_Date_Created_Case_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.SR_Date_Created__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>For all Newly created Cases, sets the SR_Date_Created__c field to the value of Created_Date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Sync Case Update</fullName>
        <actions>
            <name>Update_Account_on_Sync_Case_Status</name>
            <type>FlowAction</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Sync List Case</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.BillingStreet</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Marks the Account when a Sync Case is opened and closed - Matthew Schetselaar</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Case owner team assignment</fullName>
        <actions>
            <name>Update_Case_owner_team_assignment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This will update the Team Assignment based on the user&#39;s team assignment. - Matt Schetselaar</description>
        <formula>NOT(ISPICKVAL(Owner:User.Support_Team_Assignment__c , &quot;&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
