/**
 * Created by mschetselaar on 9/26/2018.
 */
({
    updateTask : function (component, event, helper) {
        var taskId = component.get("v.rTask.Id");
        var completed = component.get("v.completed");
        component.set("v.rTask.Status", completed ? "Completed" : "Scheduled");

        var action = component.get("c.updateTasksApx");
        action.setParams({
            taskId : taskId ,
            completedStatus :completed
        });

        action.setCallback(this, function (response) {
            var name = response.getState();
            if (name === "SUCCESS") {
                // var updatedTask = component.get("v.rTask");
                // var updateEvent = component.getEvent("updateTask");
                // updateEvent.setParams({ "updateTask" : updatedTask});
                // updateEvent.fire();
                helper.updateSpinner(component, event, helper, false);
            }
        });

        $A.enqueueAction(action);

    },

    updateEvent : function(component, event, helper) {
        var eventId = component.get("v.rEvent.Id");
        var completed = component.get("v.completed");
        component.set("v.rEvent.Activity_Results__c", completed ? "Completed" : "Future Event");

        var action = component.get("c.updateEventApx");
        action.setParams({
            eventId : eventId,
            completedStatus : completed
        })

        action.setCallback(this, function (response) {
            var name = response.getState();
            if (name === "SUCCESS") {
                // var updatedTask = component.get("v.rTask");
                // var updateEvent = component.getEvent("updateTask");
                // updateEvent.setParams({ "updateTask" : updatedTask});
                // updateEvent.fire();
                helper.updateSpinner(component, event, helper, false);
            }
        });

        $A.enqueueAction(action);

    },

    updateSpinner : function (component, event, helper, status) {
        var updateEvent = component.getEvent("updateSpinner");
        updateEvent.setParams({ "status" : status});
        updateEvent.fire();

    },
})