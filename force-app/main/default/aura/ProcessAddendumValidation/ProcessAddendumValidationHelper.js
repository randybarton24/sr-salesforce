({
	doInit : function(component, event, helper) { 
        var addendumId = component.get("v.recordId", true);         
        var action = component.get("c.getAddendumById");        
        action.setParams({
            addendumId: addendumId
        });
        action.setCallback(this, function(response) { 
            var name = response.getState();
            if (name === "SUCCESS") 
            { 
                var addendum = response.getReturnValue();
                var statusMessage = addendum.Status_Message__c; 
                var subscriberId = addendum.Subscriber_ID__c;                
                if (statusMessage == "Ready")
                {            
                    window.open("/apex/APXTConga4__Conga_Composer?serverUrl={!API.Partner_Server_URL_290}&id="+ addendumId +"&QueryId=[Addenda]a340Z000000hu2KQAQ&DS4=1&DS0=0&DC=0&SC0=0&TemplateId=a3C0Z000000R4KKUA0&OFN=Solutionreach+Addendum+-+Subscriber+ID+"+ subscriberId+"&ESVisible=1&ESAgreementTemplateId=a3Q310000008neA&ESSVBA=1&DS7=14");            
                    $A.get("e.force:closeQuickAction").fire();
                }
                else
                {           
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Message",
                        "message": statusMessage
                    });
                    
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire()
                }
            }
        })
        $A.enqueueAction(action);
    }
})