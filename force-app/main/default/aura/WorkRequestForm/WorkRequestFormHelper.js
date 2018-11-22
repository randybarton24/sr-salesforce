({
    createRequest : function(component, event, newRequest) {
        var action = component.get("c.saveRequest");
        action.setParams({
            "newRequest": newRequest
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log("Callback Successful");
                console.log(state);
                //component.set("v.newRequest", response.getReturnValue());
                var actionClicked = "NEXT";
                var newRequest = response.getReturnValue();
                var navigateFlow = $A.get("e.c:navigateFlow");
                navigateFlow.setParams({ "newRequest": newRequest });
                navigateFlow.setParams({ "actionClicked": actionClicked });
                navigateFlow.fire();
            }
            else{
                console.log("Error Occurred");
            }
        });
        $A.enqueueAction(action);
    },
})