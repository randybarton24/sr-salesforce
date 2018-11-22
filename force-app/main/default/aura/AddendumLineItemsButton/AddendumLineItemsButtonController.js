({	
    addPricebooks : function(component, event, helper) {   
        helper.getAllPricebooks(component, event, helper);        
        component.set("v.isOpen1", true);
    },
    setPrice: function (component, event, helper) {        
        var selectedOptionValue = event.getParam("value");        
        helper.setPrice(component, event, helper, selectedOptionValue);
    },
    searchProducts: function (component, event, helper) {                
        helper.getAllProducts(component, event, helper);
    },
    saveAddProduct : function (component, event, helper){            
        helper.saveAddProduct(component, event, helper);                
    },
    closeModalAddProduct : function(component, event, helper) {                
        helper.closeModalAddProduct(component, event, helper);
    },
    showSpinner: function(component, event, helper) {
        helper.showSpinner(component, event, helper);
    },  
    hideSpinner : function(component,event,helper){
        helper.hideSpinner(component, event, helper);
    }
})