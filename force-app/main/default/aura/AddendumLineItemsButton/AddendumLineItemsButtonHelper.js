({
    getAllProducts : function(component, event, helper) {	                
        var pricebookID = component.get("v.pricebookSelected");     
        var action = component.get("c.getProductOptions");         
        action.setParams({            
            pricebookId : pricebookID          
        });      
        action.setCallback(this, function (response) {            
            var name = response.getState();
            if (name === "SUCCESS") { 
                var items = [];
                for (var i = 0; i < response.getReturnValue().length; i++) {
                    var item = {
                        "label": response.getReturnValue()[i].Product2.Name,
                        "value": response.getReturnValue()[i].Id,
                    };
                    items.push(item);
                }         
                component.set("v.pbEntries", response.getReturnValue());                        
                component.set("v.options", items);                
            }            
        });        
        $A.enqueueAction(action);
    },
    setPrice : function(component, event, helper, idSelected) {           
        var items = component.get("v.pbEntries");         
        for (var i = 0; i < items.length; i++) {            
            if (items[i].Id == idSelected)
            {                
                component.set("v.priceAddProduct", items[i].UnitPrice); 
                component.set("v.pricebookEntryNameSelected", items[i].Product2.Name); 
                component.set("v.pricebookEntryFamily", items[i].Product2.Family);
                component.set("v.pricebookEntryContractSelected", items[i].Product2.Contract_Display_Name__c);                                 
            }
        } 
    },
    getAllPricebooks : function(component, event, helper) {                   
        var action = component.get("c.getPricebookOptions"); 
        action.setCallback(this, function (response) {            
            var name = response.getState();
            if (name === "SUCCESS") { 
                var items = [];
                for (var i = 0; i < response.getReturnValue().length; i++) {
                    var item = {
                        "label": response.getReturnValue()[i].Name,
                        "value": response.getReturnValue()[i].Id,
                    };
                    items.push(item);
                } 
                component.set("v.optionsPricebook", items);                       
                if (component.get("v.pb") != null)
                {
                    component.set("v.pricebookSelected", component.get("v.pb"));
                    helper.getAllProducts(component, event, helper);                    
                }                 
            }            
        });        
        $A.enqueueAction(action);
    },    
    saveAddProduct : function(component, event, helper) {                                      
        var AddID = component.get("v.addId");     
        var pricebookEntryId = component.get('v.pricebookEntrySelected');
        var price = component.get('v.priceAddProduct');  
        var quantity = component.get('v.quantityAddProduct');   
        var name = component.get('v.pricebookEntryNameSelected');
        var contractName = component.get('v.pricebookEntryContractSelected');
        var family = component.get('v.pricebookEntryFamily');
        var pricebookID = component.get("v.pricebookSelected");    
        var existingAddLineItems = component.get("v.existingAddendumLineItems");  
        var existingFamily = false;
       
        if (pricebookID != "" && quantity !="" && price !="" && pricebookEntryId != "")
        {
            for(var i = 0 ; i < existingAddLineItems.length ; i++)
            {                    
                if ((existingAddLineItems[i].Asset_Type__c === family) || existingAddLineItems[i].PriceBookEntry_Product_Family__c === family) existingFamily = true;
            }
            if (!existingFamily)
            {          
                component.set("v.newAddendumLineItem.Addendum__c", AddID); 
                component.set("v.newAddendumLineItem.PriceBookEntryId__c", pricebookEntryId);
                component.set("v.newAddendumLineItem.PriceBookEntry_Name__c", name);
                component.set("v.newAddendumLineItem.PriceBookEntry_Contract_Name__c", contractName);
                component.set("v.newAddendumLineItem.New_Price__c", price);
                component.set("v.newAddendumLineItem.PriceBookEntry_Product_Family__c", family);
                component.set("v.newAddendumLineItem.New_Quantity__c", quantity);
                var newAddLineItem = component.get("v.newAddendumLineItem");             
                var action = component.get("c.saveItemsAddProduct");          
                action.setParams({
                    addendumId: AddID,                    
                    pricebookId: pricebookID,
                    ali: newAddLineItem
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
                                "message": "Added successfully"
                            });
                            toastEvent.fire(); 
                            component.set('v.priceAddProduct', '');
                            component.set('v.quantityAddProduct', '1');
                            component.set('v.pricebookEntrySelected', '');
                            component.set("v.isOpen1", false);                                    
                            $A.get('e.force:refreshView').fire();    
                        }                         
                    }   
                    else 
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "There was an error trying to save."
                        });
                        toastEvent.fire(); 
                    }    
                });     
                $A.enqueueAction(action); 
            }
            else
            {                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Message",
                    "message": "You can only select one product from the same family."
                });
                toastEvent.fire(); 
            }        
        }                      
    },            
    closeModalAddProduct : function(component, event, helper){  
        component.set('v.priceAddProduct', '');
        component.set('v.quantityAddProduct', '');      
        component.set("v.isOpen1", false);        
        $A.get('e.force:refreshView').fire(); 
    },
    showSpinner: function(component, event, helper) {        
        component.set("v.Spinner", true); 
    },   
    hideSpinner : function(component,event,helper){        
        component.set("v.Spinner", false);
    }
})