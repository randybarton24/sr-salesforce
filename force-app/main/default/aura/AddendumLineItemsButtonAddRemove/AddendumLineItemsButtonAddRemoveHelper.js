({
	getLocalProducts : function(component, event, helper) {		        
        var action = component.get("c.getAssetOptions");                                                                       
        action.setCallback(this, function (response) {
            var name = response.getState();                        
            if (name === "SUCCESS") 
            {                       
                var assetItem = [];
                for (var i = 0; i < response.getReturnValue().length; i++) 
                {
                    var assetItems = {
                        "Name": response.getReturnValue()[i].asset.Name,
                        "id": response.getReturnValue()[i].asset.Id,
                    };
                    assetItem.push(assetItems);
                }                
                component.set("v.data", assetItem);                                             	
            }              
            component.set("v.columns", [{label: 'Product:', fieldName: 'Name' , type: 'text'}]);    
        });
        $A.enqueueAction(action);       
	},    
    getAliProducts : function(component, event, helper) {		        
        var action = component.get("c.getAddmItemOptions");           
        action.setCallback(this, function (response) {            
            var name = response.getState();                        
            if (name === "SUCCESS") 
            {                  
                var aliItem = [];
                for (var i = 0; i < response.getReturnValue().length; i++) 
                {
                    var aliItems = {
                        "Name": response.getReturnValue()[i].addendumLineItem.Asset__c == undefined ? response.getReturnValue()[i].addendumLineItem.PriceBookEntry_Name__c : response.getReturnValue()[i].addendumLineItem.Asset__r.Name,
                        "id": response.getReturnValue()[i].addendumLineItem.Id,
                    };
                    aliItem.push(aliItems);
                }                
                component.set("v.data1", aliItem);                                                           	
            }             
            component.set("v.columns1", [{label: 'Product:', fieldName: 'Name' , type: 'text'}]);    
        });
        $A.enqueueAction(action);       
	},       
    saveAddRemove : function(component, event, helper) {		                        
        var action = component.get("c.getSaveItems");  
        var AddID = component.get("v.addId");     
        var assetList = component.get('v.rowsSelectedAsset');
        var aliList = component.get('v.rowsSelectedAli');             
        action.setParams({
            addendumId: AddID,
            assetList: assetList,
            aliList: aliList
        });         

        action.setCallback(this, function (response) {
            var name = response.getState();
            if (name === "SUCCESS") 
            {
                if (response.getReturnValue())
                {
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Message",
                            "message": "Updated successfully"
                        });
                    toastEvent.fire(); 
                    component.set("v.isOpen", false);                     
                    component.set('v.rowsSelectedAsset', []);
                    component.set('v.rowsSelectedAli', []);                                    
                    $A.get('e.force:refreshView').fire();                                   
                } 
            }             
        });     
        $A.enqueueAction(action);
	},
    closeModalAddRemove : function(component, event, helper){        
        component.set("v.isOpen", false);        
        $A.get('e.force:refreshView').fire(); 
    },
    showSpinner: function(component, event, helper) {       
        component.set("v.Spinner", true); 
    },   
    hideSpinner : function(component,event,helper){    
       component.set("v.Spinner", false);
    }
})