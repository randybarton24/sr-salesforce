({
	doinit : function(component, event, helper) {                
        var cmpTarget = document.getElementsByTagName("body")[0];
        $A.util.removeClass(cmpTarget, 'tab1');
        //$A.util.removeClass(cmpTarget, 'tab2');
        //$A.util.removeClass(cmpTarget, 'tab3');
        
        $A.util.addClass(cmpTarget, 'tab1');        
	}
})