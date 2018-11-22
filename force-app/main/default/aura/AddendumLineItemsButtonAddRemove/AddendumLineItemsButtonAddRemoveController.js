({
	addRemoveProducts : function(component, event, helper) {                                       
        var action = component.get("c.fillLists");                           
        var AddID = component.get("v.addId");                
        action.setParams({
            addendumId: AddID
        });                       
        $A.enqueueAction(action);  
        helper.getLocalProducts(component, event, helper);                
        helper.getAliProducts(component, event, helper);        
        component.set("v.isOpen", true);
	},
    updateSelectedAssetText: function (component, event, helper) {        
        var selectedRows = event.getParam('selectedRows');       
        var setRowsAsset  = [];
        for (var i = 0; i < selectedRows.length; i++)
        {
            setRowsAsset.push(selectedRows[i].id);
        }        
        component.set("v.rowsSelectedAsset", setRowsAsset);           
    },
    updateSelectedAliText: function (component, event, helper) {        
        var selectedRows = event.getParam('selectedRows');       
        var setRowsAli  = [];
        for (var i = 0; i < selectedRows.length; i++)
        {
            setRowsAli.push(selectedRows[i].id);
        }      
        component.set("v.rowsSelectedAli", setRowsAli);          
    },
    saveAddRemove : function (component, event, helper){            
        helper.saveAddRemove(component, event, helper);                
    },        
    closeModelAddRemove : function(component, event, helper) {                
        helper.closeModalAddRemove(component, event, helper);
	},
    showSpinner: function(component, event, helper) {       
        helper.showSpinner(component, event, helper);
    },     
    hideSpinner : function(component,event,helper){
        helper.hideSpinner(component, event, helper);
    }
})