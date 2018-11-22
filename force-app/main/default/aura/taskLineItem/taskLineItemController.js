/**
 * Created by mschetselaar on 9/6/2018.
 */
({
    doInit : function (component, event, helper) {
        var status = component.get("v.task").Status;
        var completed = status === "Completed";
        console.log("Status: ",status);
        component.set("v.completed", completed);
        helper.getAllTasks(component, event, helper);
        helper.getAllEvents(component, event, helper);
    },

    updateTask : function (component, event, helper) {
        helper.updateSpinner(component,event,helper,true);
        helper.updateTask(component, event, helper);
    },

    
})