({
	doInit : function(component, event, helper) {
		helper.getPlaybookCase(component, event, helper);
	},

    showToast : function (component, event, helper) {
	    helper.showToast(component, event, helper);

    },

    handlePlaybookSpinner : function (component, event, helper) {
		helper.handlePlaybookSpinner(component, event, helper);

    },

    handleUpdatePlaybookCases : function (component, event, helper) {
		console.log("Handling Update Cases");
		component.set("v.openCases", []);
        helper.getPlaybookCase(component, event, helper);

    },

})