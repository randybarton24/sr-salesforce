({
	myAction : function(component, event, helper) {
        var action1 = component.get("c.getUserProfile");
        action1.setCallback(this, function(data1) {            
            component.set("v.profileName", data1.getReturnValue());
            var action = component.get("c.getUsers");
            action.setCallback(this, function(data) {
                console.log(data.getReturnValue());
                component.set("v.users", data.getReturnValue());        	
            });
            $A.enqueueAction(action);
            
            debugger;
            var userProfile = component.get("v.profileName");
            var customlabel = $A.get("$Label.c.Profile_Name");
            if(userProfile == customlabel){
                var cmpTarget = component.find('GuestUser');
        		$A.util.addClass(cmpTarget, 'showData');
                $A.util.removeClass(cmpTarget, 'hideData');
                //$A.util.toggleClass(cmpTarget, "showData");
                
                var cmpTarget1 = component.find('CommunityUser');
        		$A.util.addClass(cmpTarget1, 'hideData');
                $A.util.removeClass(cmpTarget1, 'showData');
                //$A.util.toggleClass(cmpTarget1, "hideData");
            }/*else{
                var cmpTarget = component.find('GuestUser');
        		$A.util.addClass(cmpTarget, 'hideData');
                $A.util.removeClass(cmpTarget, 'showData');
                //$A.util.toggleClass(cmpTarget, "hideData");
                
                var cmpTarget1 = component.find('CommunityUser');
        		$A.util.addClass(cmpTarget1, 'showData');
                $A.util.removeClass(cmpTarget1, 'hideData');
                //$A.util.toggleClass(cmpTarget1, "showData");
            }*/
            
        });
        $A.enqueueAction(action1);
	},
    removeCss : function(component, event, helper) {
        var cmpTarget = document.getElementsByTagName("body")[0];
        $A.util.removeClass(cmpTarget, 'tab1');        
    }
})