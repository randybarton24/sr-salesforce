({
	doinit : function(component, event, helper) {
		var cmpTarget = document.getElementsByTagName("body")[0];
        $A.util.removeClass(cmpTarget, 'tab1');        
	}
})