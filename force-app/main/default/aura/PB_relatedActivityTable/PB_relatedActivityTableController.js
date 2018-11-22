/**
 * Created by mschetselaar on 9/26/2018.
 */
({
    navigateToEvent : function (component, event, helper) {
        var eventId = component.get("v.rEvent.Id");
        sforce.one.navigateToSObject(eventId.substring(0,15));
    },

    handleClick: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.rEvent.Id")
        });
        navEvt.fire();
    },

    updateTask : function (component, event, helper) {
        helper.updateSpinner(component, event, helper, true);
        helper.updateTask(component, event, helper);
    },

    updateEvent : function (component, event, helper) {
        helper.updateSpinner(component, event, helper, true);
        helper.updateEvent(component, event, helper);
    }
})