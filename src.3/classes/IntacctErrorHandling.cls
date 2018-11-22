/**
 * File:        IntacctErrorHandling.cls
 * Project:     Sererra 
 * Date:        February 11, 2013
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: This is the controller for the Intacct Error Handling visualforce page.
 *              Contains methods to handle the actions of the page and to create dynamic visualforce components.
 * *************************************************************************
 * History:
 */
public with sharing class IntacctErrorHandling extends VisualforceDynamicComponents
{
    /**
     * Public variables
    */
    public List<selectOption> selectObjectTypeList {get; set;}
    public List<Intacct_Error__c> errorRecords {get; set;}
    public ApexPages.StandardSetController errorRecordsSet {get; set;}
    
    public Intacct_Error__c dateField {get; set;}
    
    public String selectedObject {get; set;}
    public String pageErrorMessage {get; set;}
    
    public Boolean isThereAnyError {get; set;}
    public Boolean isErrorListEmpty {get; set;}
    
    /**
     * Private variables
    */
    private ObjectPrefixes allObjects;
    
    /**
     * Constructor
    */
    public IntacctErrorHandling()
    {
        pageErrorMessage = init();
        displayPageErrors(pageErrorMessage, IntacctGlobalVariables.ERROR_SEVERITY);
    }
    
    /**
     * Indicates whether there are more records after the current page set.
    */
    public Boolean hasNext
    {
        get 
        {
            if(errorRecordsSet == null)
            {
                return false;
            }
            return errorRecordsSet.getHasNext();
        }
        set;
    }
    
    /**
     * Indicates whether there are more records before the current page set.
    */
    public Boolean hasPrevious 
    {
        get 
        {
            if(errorRecordsSet == null)
            {
                return false;
            }
            return errorRecordsSet.getHasPrevious();
        }
        set;
    }
    
    /**
     * Creates the initial state of the page
     * @return errorMessage
    */
    private String init()
    {
        String errorMessage = IntacctGlobalVariables.NO_ERROR_STRING;
        pageErrorMessage = errorMessage;
        allObjects = new ObjectPrefixes();
        selectObjectTypeList = new List<selectOption>();
        isThereAnyError = true;
        isErrorListEmpty = true;
        errorMessage = populateObjectTypeList();
        errorRecords = new List<Intacct_Error__c>();
        dateField = new Intacct_Error__c();
        return errorMessage;
    }
    
    /**
     * Populates the selectObjectTypeList
     * @return errorMessage 
    */
    private String populateObjectTypeList()
    {
        String errorMessage = IntacctGlobalVariables.NO_ERROR_STRING;
        List<Intacct_Error__c> intacctErrors = new List<Intacct_Error__c>();
        try
        {
            intacctErrors = DataBase.query(GenerateSFDCObjectQueries.generateIntacctErrorQuery(IntacctGlobalVariables.ACTION_TYPE_GROUP_BY));
            isThereAnyError = (intacctErrors.isEmpty()) ? false : true; 
            selectObjectTypeList.add(new selectOption('', '--None--'));
            selectObjectTypeList.add(new selectOption('Account', 'Account'));
            selectObjectTypeList.add(new selectOption('Contact', 'Contact'));
            selectObjectTypeList.add(new selectOption('Other', 'Other'));
            //selectObjectTypeList.add(new selectOption('Other', 'Other'));
            if(!isThereAnyError)
            {
                errorMessage = 'There are no Intacct Error records in the system.';
            }
        }
        catch(Exception ex)
        {
            errorMessage = 'Error occured while grouping the errors by object type.';
        }
        return errorMessage;
    }
    
    /**
     * Displays any error message on the page
     * @params errorMessage, severity
    */
    private void displayPageErrors(String errorMessage, String severity)
    {
        if(!String.isBlank(errorMessage))
        {
            if(severity.equals(IntacctGlobalVariables.ERROR_SEVERITY))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            }
            if(severity.equals(IntacctGlobalVariables.WARNING_SEVERITY))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, errorMessage));
            }
            if(severity.equals(IntacctGlobalVariables.CONFIRM_SEVERITY))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, errorMessage));
            }
        }
    }
    
    /**
     * Populates the object error standard set
    */
    public void populateErrorSet()
    {
        String queryIntacctError = '';
        String objectPrefix = '';
        if(!String.isBlank(selectedObject))
        {
            try
            {
                if(selectedObject.equals('Other'))
                {
                    objectPrefix = '';
                }
                else
                {
                    objectPrefix = allObjects.getPrefixByObjectName(selectedObject);
                    system.debug('Prefix: ' + objectPrefix);
                }
                queryIntacctError = GenerateSFDCObjectQueries.generateIntacctErrorQuery(IntacctGlobalVariables.ACTION_TYPE_PREFIX + IntacctGlobalVariables.CONTROLID_SEPARATOR + objectPrefix);
                errorRecordsSet = new ApexPages.StandardSetController(Database.getQueryLocator(queryIntacctError));
                system.debug('SIZE: ' + errorRecordsSet.getRecords().size());
                if(errorRecordsSet != null && !errorRecordsSet.getRecords().isEmpty())
                {
                    errorRecordsSet.setPageSize(IntacctGlobalVariables.NUMBER_OF_RECORDS_ON_PAGE);
                    populateErrorList();
                    pageErrorMessage = '';
                }
                else
                {
                    isErrorListEmpty = true;
                    pageErrorMessage = 'There are no Intacct Error records in the system.';
                }
            }
            catch(Exception ex)
            {
                isErrorListEmpty = true;
                pageErrorMessage = 'Error occured while getting the Intacct Errors for ' + selectedObject + ' object.';
            }
            finally
            {
                displayPageErrors(pageErrorMessage, IntacctGlobalVariables.ERROR_SEVERITY);
            }
        }
    }
    
    /**
     * Populates the object error list
    */
    public void populateErrorList()
    {
        isErrorListEmpty = false;
        errorRecords = errorRecordsSet.getRecords();
        system.debug('Errors Size: ' + errorRecords.size());
    }
    
    /**
     * Deletes intacct errors
    */
    public void deleteIntacctErrors()
    {
        List<Intacct_Error__c> recordsToDelete = new List<Intacct_Error__c>();
        String formattedDateString = '';
        try
        {
            if(dateField.Date_Picker__c != null)
            {
                formattedDateString = dateField.Date_Picker__c.formatGMT('yyyy-MM-dd') + 'T' + dateField.Date_Picker__c.formatGMT('HH:mm:ss') + 'Z';        
            }
            String queryString = GenerateSFDCObjectQueries.generateIntacctErrorQuery(IntacctGlobalVariables.ACTION_TYPE_DELETE + IntacctGlobalVariables.CONTROLID_SEPARATOR + formattedDateString);
            recordsToDelete = Database.query(queryString);
            if(!recordsToDelete.isEmpty())
            {
                delete recordsToDelete;
            }
            dateField.Date_Picker__c = null;
            selectObjectTypeList = new List<selectOption>();
            pageErrorMessage = populateObjectTypeList();
        }
        catch(Exception ex)
        {
            pageErrorMessage = 'Error occured while deleting Intacct Errors records.';
        }
        finally
        {
            displayPageErrors(pageErrorMessage, IntacctGlobalVariables.ERROR_SEVERITY);
        }
    }
    
    /**
     * Generate the dynamic pageblock component for the header
     * @return headerPageBlock
    */
    public Component.Apex.PageBlock getDynamicHeaderPageBlock()
    {
        Component.Apex.PageBlock headerPageBlock = generatePageBlock('Object Selection', 'intacctHeaderPageBlock', 'Contract');
        
        Component.Apex.PageBlockSection newPageBlockSection = generatePageBlockSection('', 'intacctHeaderPageBlockSection', 1, false, false);
        
        Component.Apex.SelectList newSelectList = generateSelectList('{!selectedObject}', 'Select Object', 'intacctHeaderSelectList');
        newSelectList.childComponents.add(generateActionSupport('onchange', '{!populateErrorSet}', 'intacctHeaderActionSupport', new Set<String>{'intacctBodyOutputPanel'}));
        newSelectList.childComponents.add(generateSelectOptions('{!selectObjectTypeList}', 'intacctHeaderSelectOptions'));
        
        newPageBlockSection.childComponents.add(newSelectList);
        
        headerPageBlock.childComponents.add(newPageBlockSection);
        return headerPageBlock;
    }
    
    /**
     * Generate the dynamic pageblock component for the body
     * @return bodyPageBlock
    */
    public Component.Apex.PageBlock getDynamicBodyPageBlock()
    {
        system.debug('Selected object: ' + selectedObject);
        system.debug('Selected object list: ' + errorRecords.size());
        Component.Apex.PageBlock bodyPageBlock = generatePageBlock('Error List', 'intacctBodyPageBlock', 'Contract');
        
        Component.Apex.PageBlockTable newPageBlockTable = generatePageBlockTable('{!errorRecords}', 'errorRecord', 'intacctBodyPageBlockTable');
        newPageBlockTable.expressions.rendered = '{!!isErrorListEmpty}';
        
        Component.Apex.OutputText newOutputText = new Component.Apex.OutputText();
        newOutputText.value = 'There are no Intacct Errors for the selected object!';
        newOutputText.expressions.rendered = '{!isErrorListEmpty}';
        
        List<Apexpages.Component> newColumns = new List<Apexpages.Component>(); 
        newColumns.add(generateColumn('{!errorRecord.Name}', 'Name', 'intacctNameCloumn'));
        newColumns.add(generateColumn('{!errorRecord.Description__c}', 'Description', 'intacctDescriptionCloumn'));
        newColumns.add(generateColumn('{!errorRecord.Errors__c}', 'Error Messages', 'intacctErrorCloumn'));
        newColumns.add(generateColumn('{!errorRecord.CreatedDate}', 'Created Date', 'intacctDateCloumn'));
        if(!String.isBlank(selectedObject) && !selectedObject.equals('Other'))
        {
            Component.Apex.Column newColumn = generateColumn('', 'Actions', 'intacctActionsCloumn');
            Component.Apex.CommandButton newCommandButton = generateCommandButton('View Related Object Record', '{!URLFOR($Action.' + selectedObject + '.View,errorRecord.Parent_Id__c)}', null, false, '');
            newColumn.childComponents.add(newCommandButton);
            newColumns.add(newColumn);
        }
        
        newPageBlockTable.childComponents.addAll(newColumns);
        
        bodyPageBlock.childComponents.add(newPageBlockTable);
        bodyPageBlock.childComponents.add(newOutputText);
        return bodyPageBlock;
    }
    
    /**
     * Generate the dynamic panelgrid component for the footer
     * @return footerPanelGrid
    */
    public Component.Apex.PanelGrid getDynamicFooterPanelGrid()
    {
        Component.Apex.PanelGrid footerPanelGrid = generatePanelGrid(4, 'intacctFooterPanelGrid');
        footerPanelGrid.expressions.rendered = '{!!isErrorListEmpty}';
        List<Apexpages.Component> newCommandButtons = new List<Apexpages.Component>();
        Set<String> reRenderList = new Set<String>{'intacctBodyOutputPanel'};
        newCommandButtons.add(generateCommandButton('First', '{!first}', reRenderList, false, ''));
        newCommandButtons.add(generateCommandButton('Previous', '{!previous}', reRenderList, false, '{!hasPrevious}'));
        newCommandButtons.add(generateCommandButton('Next', '{!next}', reRenderList, false, '{!hasNext}'));
        newCommandButtons.add(generateCommandButton('Last', '{!last}', reRenderList, false, ''));
        
        footerPanelGrid.childComponents.addAll(newCommandButtons);
        
        return footerPanelGrid;
    }
    
    /**
     * Generate the dynamic pageblock component for the delete tab
     * @return deletePageBlock
    */
    public Component.Apex.PageBlock getDynamicDeletePageBlock()
    {
        Component.Apex.PageBlock deletePageBlock = generatePageBlock('Delete Intacct Errors', 'intacctDeletePageBlock', 'Contract');
        Component.Apex.PageBlockSection newPageBlockSection = generatePageBlockSection('', 'intacctDeletePageBlockSection', 2, false, false);
        
        List<Apexpages.Component> deleteComponents = new List<Apexpages.Component>();
        deleteComponents.add(generateInputField('{!dateField.Date_Picker__c}', 'Choose Date', 'intacctDeleteDate'));
        deleteComponents.add(generateCommandButton('Delete Errors', '{!deleteIntacctErrors}', null, false, ''));
        newPageBlockSection.childComponents.addAll(deleteComponents);
        
        deletePageBlock.childComponents.add(newPageBlockSection);
        return deletePageBlock;
    }
    
    /**
     * Sets the displayed record set to the first page
    */
    public void first() 
    {
        errorRecordsSet.first();
        populateErrorList();
    }
    
    /**
     * Sets the displayed record set to the last page
    */
    public void last() 
    {
        errorRecordsSet.last();
        populateErrorList();
    }
    
    /**
     * Sets the displayed record set to the previous page
    */
    public void previous() 
    {
        errorRecordsSet.previous();
        populateErrorList();
    }
    
    /**
     * Sets the displayed record set to the next page
    */
    public void next() 
    {
        errorRecordsSet.next();
        populateErrorList();
    }
}