/**
 * File:        ObjectPrefixes_Test.cls
 * Project:     Sererra 
 * Date:        February 11, 2013
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: Collection of methods to create dynamic visualforce components with the basic attributes
 * *************************************************************************
 * History:
 */
public virtual class VisualforceDynamicComponents 
{
    /**
     * Generate a pageblock component
     * @params title, id, tabStyle
     * @return newPageBlock
    */
    public virtual Component.Apex.PageBlock generatePageBlock(String title, String id, String tabStyle)
    {
    	Component.Apex.PageBlock newPageBlock = new Component.Apex.PageBlock();
    	newPageBlock.title = title;
    	newPageBlock.id = id;
    	if(!String.isBlank(tabStyle))
    	{
    	   newPageBlock.tabstyle = tabstyle;
    	}
    	return newPageBlock;
    }
    
    /**
     * Generate a pageblocksection component
     * @params title, id, columns, collapsible, showHeader
     * @return newPageBlockSection
    */
    public virtual Component.Apex.PageBlockSection generatePageBlockSection(String title, String id, Integer columns, Boolean collapsible, Boolean showHeader)
    {
        Component.Apex.PageBlockSection newPageBlockSection = new Component.Apex.PageBlockSection();
        newPageBlockSection.title = title;
        newPageBlockSection.id = id;
        newPageBlockSection.columns = columns;
        newPageBlockSection.collapsible = collapsible;
        newPageBlockSection.showHeader = showHeader;
        return newPageBlockSection;
    }
    
    /**
     * Generate a pageblocktable component
     * @params value(name of a variable - should contain an array), var, id
     * @return newPageBlockTable
    */
    public virtual Component.Apex.PageBlockTable generatePageBlockTable(String value, String var, String id)
    {
        Component.Apex.PageBlockTable newPageBlockTable = new Component.Apex.PageBlockTable();
        newPageBlockTable.expressions.value = value;
        newPageBlockTable.var = var;
        newPageBlockTable.id = id;
        return newPageBlockTable;
    }
    
    /**
     * Generate a column component
     * @params value, headerValue, id
     * @return newColumn
    */
    public virtual Component.Apex.Column generateColumn(String value, String headerValue, String id) 
    {
        Component.Apex.Column newColumn = new Component.Apex.Column();
        if(!String.isBlank(value))
        {
            newColumn.expressions.value = value;
        }
        newColumn.headerValue = headerValue;
        newColumn.id = id;
        return newColumn;
    }
    
    /**
     * Generate a commandbutton component
     * @params value, action, reRenderList, immediate, rendered
     * @return newCommandButton
    */
    public virtual Component.Apex.CommandButton generateCommandButton(String value, String action, Set<String> reRenderList, Boolean immediate, String rendered) 
    {
    	Component.Apex.CommandButton newCommandButton = new Component.Apex.CommandButton();
        if(reRenderList != null && !reRenderList.isEmpty())
        {
            newCommandButton.reRender = reRenderList;
        }
        newCommandButton.value = value;
        if(!String.isBlank(action))
        {
            newCommandButton.expressions.action = action;
        }
        newCommandButton.immediate = immediate;
        if(!String.isBlank(rendered))
        {
        	newCommandButton.expressions.rendered = rendered;
        }
        return newCommandButton;
    }
    
    /**
     * Generate a selectlist component
     * @params value, label, id
     * @return newSelectList
    */
    public virtual Component.Apex.SelectList generateSelectList(String value, String label, String id) 
    {
        Component.Apex.SelectList newSelectList = new Component.Apex.SelectList();
        if(!String.isBlank(value))
        {
            newSelectList.expressions.value = value;
        }
        system.debug('label: ' + label);
        if(!System.Test.isRunningTest())
        {
            newSelectList.label = label;
        }
        newSelectList.id = id;
        newSelectList.multiselect = false;
        newSelectList.size = 1;
        return newSelectList;
    }
    
    /**
     * Generate a selectoptions component
     * @params value, id
     * @return newSelectOptions
    */
    public virtual Component.Apex.SelectOptions generateSelectOptions(String value, String id) 
    {
        Component.Apex.SelectOptions newSelectOptions = new Component.Apex.SelectOptions();
        if(!String.isBlank(value))
        {
            newSelectOptions.expressions.value = value;
        }
        newSelectOptions.id = id;
        return newSelectOptions;
    }
    
    /**
     * Generate a actionsupport component
     * @params event, action, id, reRenderList
     * @return newActionSupport
    */
    public virtual Component.Apex.ActionSupport generateActionSupport(String event, String action, String id, Set<String> reRenderList) 
    {
        Component.Apex.ActionSupport newActionSupport = new Component.Apex.ActionSupport();
        if(!String.isBlank(action))
        {
            newActionSupport.expressions.action = action;
        }
        newActionSupport.event = event;
        newActionSupport.id = id;
        if(reRenderList != null && !reRenderList.isEmpty())
        {
        	newActionSupport.rerender = reRenderList;
        }
        return newActionSupport;
    }
    
    /**
     * Generate a panelgrid component
     * @params columns, id
     * @return newActionSupport
    */
    public virtual Component.Apex.PanelGrid generatePanelGrid(Integer columns, String id) 
    {
        Component.Apex.PanelGrid newPanelGrid = new Component.Apex.PanelGrid();
        newPanelGrid.columns = columns;
        newPanelGrid.id = id;
        return newPanelGrid;
    }
    
    /**
     * Generate a inputfield component
     * @params value, label, id
     * @return newInputField
    */
    public virtual Component.Apex.InputField generateInputField(String value, String label, String id) 
    {
        Component.Apex.InputField newInputField = new Component.Apex.InputField();
        if(!String.isBlank(value))
        {
        	newInputField.expressions.value = value;
        }
        newInputField.label = label;
        newInputField.id = id;
        return newInputField;
    }
}