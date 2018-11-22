/**
 * Created by mschetselaar on 9/1/2018.
 */
({
    openModel : function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        helper.getPlaybookList(component, event, helper);
        component.set("v.isOpen", true);
    },

    closeModel : function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        component.set("v.isOpen", false);
    },

    handleChange : function (component, event, helper){
        component.set("v.selectedPlaybook", event.getParam("value"));
    },

    addPlaybook : function(component, event, helper) {
        component.set("v.isOpen", false);
        helper.updateSpinner(component, event, helper, true);
        helper.addPlaybook(component, event, helper);

    },
})