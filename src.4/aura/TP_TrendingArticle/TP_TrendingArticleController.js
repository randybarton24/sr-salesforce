({
	doinit : function(component, event, helper) {
		var action = component.get("c.getTrendingArticles");
        action.setCallback(this, function(data) {            
            var trendArticles = [];
            trendArticles = data.getReturnValue().items;
            component.set("v.trendingArticles",trendArticles);            
        });
        $A.enqueueAction(action);
	},
    removeCss : function(component, event, helper) {
        var cmpTarget = document.getElementsByTagName("body")[0];
        $A.util.removeClass(cmpTarget, 'tab1');        
    }
})