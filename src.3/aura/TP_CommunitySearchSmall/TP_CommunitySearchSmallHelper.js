({
	removeBackgroundCss : function() {
		var cmpTarget = document.getElementsByTagName("body")[0];
        $A.util.removeClass(cmpTarget, 'tab1');
	},
    searchResult : function(component){
        var searchText = component.find("inputText").getElement().value;
		var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/global-search/"+searchText          
        });
        urlEvent.fire();
    }
})