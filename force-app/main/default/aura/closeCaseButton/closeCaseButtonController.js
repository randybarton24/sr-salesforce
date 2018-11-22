/**
 * Created by mschetselaar on 9/7/2018.
 */
({
    closeCase : function (component, event, helper) {
        component.set("v.isOpen", true);
    },

    closeModel : function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        component.set("v.isOpen", false);
    },

    saveAndClose : function(component, event, helper) {
        // Display alert message on the click on the "Save and Close" button from Model Footer
        // and set set the "isOpen" attribute to "False for close the model Box.
        // alert('This Playbook will be added to the Account');
        component.set("v.isOpen", false);
        helper.updateSpinner(component, event, helper, true);
        helper.closeCase(component, event, helper);
    },

    setResolution : function (component, event, helper) {
        console.log('Resolution: ' , event.getParam('value'));
        component.set("v.Resolution", event.getParam('value'));
        console.log('After Setting: ' , component.get('v.Resolution'));

    },

})