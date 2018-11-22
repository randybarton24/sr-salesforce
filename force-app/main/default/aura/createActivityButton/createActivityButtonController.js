/**
 * Created by mschetselaar on 9/10/2018.
 */
({
    addEvent : function (component, event, helper) {
        component.set("v.isOpen", true);
        console.log('CaseId: ', component.get("v.CaseId"));
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
        console.log('Adding the Activity');
        helper.addActivity(component, event, helper);
    },

    TaskEventSelector : function (component, event, helper) {
        var taskevent = event.getParam("value");
        console.log("Value: ", taskevent);
        if(taskevent == "Task")
        {
            component.set("v.isTask", true);
        } else{
            component.set("v.isTask", false);
        }
    },

    setDuration : function (component, event, helper) {
        console.log('Duration: ' , event.getParam('value'));
        component.set("v.newEvent.DurationInMinutes", event.getParam('value'));

    },

    setType : function (component, event, helper) {
        console.log('Type: ' , event.getParam('value'));
        component.set('v.newEvent.Activity_Type__c', event.getParam('value'));
    },

})