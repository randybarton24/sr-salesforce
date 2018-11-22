({        
    doInit : function(component, event, helper) {        
        //debugger;
        var cmpTarget = document.getElementsByTagName("body")[0];                
        $A.util.addClass(cmpTarget, 'tab1');  
                
        var action = component.get("c.getUserName");
        action.setCallback(this, function(data) {
            debugger;
            var loggedInUserName = data.getReturnValue();
            if(loggedInUserName.includes("Site Guest User")){
                document.getElementById("main-div").style.display = 'none';
                document.getElementById("child-div").style.display = 'block';                                                
            }                       
        });
        $A.enqueueAction(action);        
    },
        
	callLiveAgent : function(component, event, helper) {
		console.log('call live agent');
        var urlEvent = $A.get("e.force:navigateToURL");
        debugger;
        urlEvent.setParams({
          "url": "/liveagent"
        });
        urlEvent.fire();
        //window.open("https://home-c4.incontact.com/inContact/ChatClient/ChatClient.aspx?poc=a08bb6bb-30e1-4316-a794-e0c64e2ec1de&bu=4592828", "_blank", "toolbar=no,scrollbars=no,resizable=yes,width=500,height=922");
	},
        
    submitTicket : function(component, event, helper) {
        console.log('submit Ticket');
        
        var cmpTarget = document.getElementsByTagName("body")[0];
        $A.util.removeClass(cmpTarget, 'tab1');                      
                
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/contactsupport"
        });
        urlEvent.fire();
	},
        
    callNow : function(component, event, helper) {        
		console.log('call Now');                                        
        
        //get login user name
        var usernameaction = component.get("c.getUserName");
        usernameaction.setCallback(this, function(data) {
            console.log('login user name---'+data.getReturnValue());
            //loginuserName = data.getReturnValue();
            var action = component.get("c.getAccountTypeInformation");
            action.setParams({
                userName : data.getReturnValue()
            });
            action.setCallback(this, function(data) {
                console.log('>>>'+data.getReturnValue());
                var phNo = "";
                var userAccType = "";
                userAccType = data.getReturnValue();
                if(userAccType == "Major Account" || userAccType == "Child Major Account"){
                    phNo = "855-689-1096";
                }else if(userAccType == "Multi-Location Account" || userAccType == "Child Multi-Location Account"){
                    phNo = "855 689 1661";
                }else if(userAccType == "Account" || userAccType == "Child Account"){
                    //phNo = "Chat to Connect";
                    phNo = "855-733-5228";
                }else {
                    phNo = "855-733-5228";
                    //phNo = "Chat to Connect";
                }
                
                component.set("v.phnumber",phNo);
            });
            $A.enqueueAction(action);
        });
		$A.enqueueAction(usernameaction);
                
        //display phone number
        document.getElementById("PhoneNo").style.display = "block";
	},
    openBot : function(component, event, helper) {

        var standardEvent = $A.get("e.nfchat:ChatEvent");

        console.log(standardEvent);

        standardEvent.setParams({

            type: 'action',

            payload: 'openChat'

        });

        standardEvent.fire();

    }
})