<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Copy_Product_Code</fullName>
        <field>Product_Code_Formula__c</field>
        <formula>Product2.ProductCode</formula>
        <name>Copy Product Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FieldUpdate_Contract_Start_Date</fullName>
        <description>From Product for Addendum Opps</description>
        <field>RecurSoft__Contract_Term_Start_Date__c</field>
        <formula>RecurSoft__Contract_Term_Start_Date_New__c</formula>
        <name>FieldUpdate_Contract_Start_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>OpportunityId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RecurSoft__Update_Counter_Aggregated_Monthly_Min</fullName>
        <field>RecurSoft__Counter_Aggregated_Monthly_Min__c</field>
        <formula>1</formula>
        <name>Update Counter Aggregated Monthly Min</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_HG_Monthly_Revenue</fullName>
        <field>HG_Monthly_Revenue__c</field>
        <formula>IF( AND( ISPICKVAL( Product2.Family , &quot;Healthgrades&quot; ) , Is_Monthly__c ) ,
IF( Invoiced_Price__c &gt; 0 , Invoiced_Price__c * Quantity ,
TotalPrice ) ,
0 )</formula>
        <name>Update HG Monthly Revenue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_LL_Monthly_Revenue</fullName>
        <field>LL_Monthly_Revenue__c</field>
        <formula>IF( AND( ISPICKVAL( Product2.Family , &quot;SR Schedule&quot; ) , Is_Monthly__c ) ,
IF( Invoiced_Price__c &gt; 0 , Invoiced_Price__c * Quantity ,
TotalPrice ) ,
0 )</formula>
        <name>Update LL Monthly Revenue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Monthly_Products</fullName>
        <field>Is_Monthly__c</field>
        <literalValue>1</literalValue>
        <name>Update Monthly Products</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Other_Monthly_Revenue</fullName>
        <field>Other_Monthly_Revenue__c</field>
        <formula>IF( AND( NOT( ISPICKVAL( Product2.Family , &quot;SR Platform&quot; )) ,
NOT( ISPICKVAL( Product2.Family , &quot;Limelight&quot; )) ,
NOT( ISPICKVAL( Product2.Family , &quot;SR Conversations&quot; )) ,
NOT( ISPICKVAL( Product2.Family , &quot;SR Smart Reviews&quot; )) ,
NOT( ISPICKVAL( Product2.Family , &quot;Healthgrades&quot; )) ,
Is_Monthly__c ) , 
IF( Invoiced_Price__c &gt; 0 , Invoiced_Price__c * Quantity , 
TotalPrice ) , 
0 )</formula>
        <name>Update Other Monthly Revenue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SRC_Monthly_Revenue</fullName>
        <field>SRC_Monthly_Revenue__c</field>
        <formula>IF( AND( ISPICKVAL( Product2.Family , &quot;SR Conversations&quot; ) , Is_Monthly__c ) ,
IF( Invoiced_Price__c &gt; 0 , Invoiced_Price__c * Quantity ,
TotalPrice ) ,
0 )</formula>
        <name>Update SRC Monthly Revenue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SRSR_Monthly_Revenue</fullName>
        <field>SRSR_Monthly_Revenue__c</field>
        <formula>IF( AND( ISPICKVAL( Product2.Family , &quot;SR Smart Reviews&quot; ) , Is_Monthly__c ) ,
IF( Invoiced_Price__c &gt; 0 , Invoiced_Price__c * Quantity ,
TotalPrice ) ,
0 )</formula>
        <name>Update SRSR Monthly Revenue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SR_Monthly_Revenue</fullName>
        <field>SR_Monthly_Revenue__c</field>
        <formula>IF( AND( ISPICKVAL( Product2.Family , &quot;SR Platform&quot; ) , Is_Monthly__c ) ,
IF( Invoiced_Price__c &gt; 0 , Invoiced_Price__c * Quantity ,
TotalPrice ) ,
0 )</formula>
        <name>Update SR Monthly Revenue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Total_Monthly_Revenue</fullName>
        <field>Total_Monthly_Revenue__c</field>
        <formula>IF( Is_Monthly__c ,
IF( Invoiced_Price__c &gt; 0 , Invoiced_Price__c * Quantity , 
TotalPrice ) , 0 )</formula>
        <name>Update Total Monthly Revenue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>populate_product_code</fullName>
        <field>Product_Code_Formula__c</field>
        <formula>Product2.ProductCode</formula>
        <name>populate product code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>populate_promo_code</fullName>
        <field>Product_Code_Formula__c</field>
        <formula>Product2.ProductCode</formula>
        <name>populate promo code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ContractStartDateFromProduct_WFR</fullName>
        <actions>
            <name>FieldUpdate_Contract_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>For Addendum Opps</description>
        <formula>(ISCHANGED( RecurSoft__Contract_Term_Start_Date_New__c ) ||   ISNEW()) &amp;&amp; Opportunity.RecordType.DeveloperName = &quot;Add_On_Business&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RecurSoft__Update Counter Aggregated Monthly Min</fullName>
        <actions>
            <name>RecurSoft__Update_Counter_Aggregated_Monthly_Min</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.RecurSoft__Aggregated_Monthly_Minimum_Amount__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Monthly Products</fullName>
        <actions>
            <name>Update_Monthly_Products</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISPICKVAL( PricebookEntry.Product2.RecurSoft__Billing_Frequency__c , &quot;Monthly&quot; ) &amp;&amp;  Is_Monthly__c = false</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Total Monthly Revenue</fullName>
        <actions>
            <name>Update_HG_Monthly_Revenue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_LL_Monthly_Revenue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Other_Monthly_Revenue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_SRC_Monthly_Revenue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_SRSR_Monthly_Revenue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_SR_Monthly_Revenue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Total_Monthly_Revenue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>true || isnew() || ischanged( UnitPrice ) || ischanged( Invoiced_Price__c ) || ischanged( Quantity )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>copy Product Code</fullName>
        <actions>
            <name>populate_product_code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
