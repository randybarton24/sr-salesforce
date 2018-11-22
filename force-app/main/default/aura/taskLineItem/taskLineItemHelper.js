/**
 * Created by mschetselaar on 9/6/2018.
 */
({
    updateTask : function (component, event, helper) {
        var taskId = component.get("v.task.Id");
        var completed = component.get("v.completed");
        var action = component.get("c.updateTasksApx");
        action.setParams({
            taskId : taskId ,
            completedStatus :completed
        });

        action.setCallback(this, function (response) {
            var name = response.getState();
            if (name === "SUCCESS") {
                var updatedTask = component.get("v.task");
                var updateEvent = component.getEvent("updateTask");
                updateEvent.setParams({ "updateTask" : updatedTask});
                updateEvent.fire();
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

    getAllTasks : function(component, event, helper) {
        console.log('getting open Tasks');
        var caseId = component.get("v.case.Id");
        var action = component.get("c.getAllTasksApx");
        action.setParams({
            caseId : caseId,
            relatedPlay : component.get("v.task.Id")
        });

        action.setCallback(this, function (response) {
            console.log('Tasks Returned',response.getReturnValue());
            var name = response.getState();
            if (name === "SUCCESS") {
                component.set("v.relatedTasks", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);

    },

    getAllEvents : function(component, event, helper) {
        var caseId = component.get("v.case.Id");
        var action = component.get("c.getAllEventsApx");
        action.setParams({
            caseId : caseId,
            relatedPlay : component.get("v.task.Id")
        });

        action.setCallback(this, function (response) {
            var name = response.getState();
            if(name === "SUCCESS") {
                component.set("v.relatedEvents", response.getReturnValue());
                console.log('Events: ', response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
    },
})