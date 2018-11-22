({
	handleClick : function(component, event, helper) {          
        helper.searchResult(component);
        helper.removeBackgroundCss();
	},
    enterPress : function(component, event, helper) {        
        if(event.keyCode == 13){            
        	var searchText = component.find("inputText").getElement().value;
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/global-search/"+searchText            
                //"url": "/search/null/null/"+searchText
            });   
            urlEvent.fire();
            
            helper.removeBackgroundCss();
            event.preventDefault()
            return false;
        }
        
    }
})