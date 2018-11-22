({    
	doinit : function(component, event, helper) {
        //debugger;
        var cmpTarget = document.getElementsByTagName("body")[0];                        
        $A.util.addClass(cmpTarget, 'tab1');                                           
	},
    doneRendering : function(component, event, helper) {
        //debugger;
        var cmpSec1 = document.getElementsByClassName('1 tabs__content active uiTab')[0];
        //var cmpSec1 = document.getElementsByTagName('section')[0];
        $A.util.addClass(cmpSec1, 'custom-knowledgebase-CSSClass');
    }
})