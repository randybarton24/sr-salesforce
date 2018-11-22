/**
 * Created by mschetselaar on 9/6/2018.
 */
({
    updateTask : function (component, event, helper) {
        var taskId = component.get("v.task.Id");
        var action = component.get("c.completeOpenTasksApx");
        action.setParams({
            taskId : taskId
        });

        action.setCallback(this, function (response) {
            var name = response.getState();
            if (name === "SUCCESS") {
                var updatedTask = component.get("v.task");
                var updateEvent = component.getEvent("updateTask");
                updateEvent.setParams({ "updateTask" : updatedTask});
                updateEvent.fire();
            }
        });

        $A.enqueueAction(action);

    },
})