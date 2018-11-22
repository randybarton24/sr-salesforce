({
    handleNavigate: function(component, event, helper) {
        var newRequest = event.getParam("newRequest");
        component.set("v.newRequest", newRequest);
        console.log(newRequest);
        var navigate = component.get("v.navigateFlow");
        navigate(event.getParam("actionClicked"));
    },
})