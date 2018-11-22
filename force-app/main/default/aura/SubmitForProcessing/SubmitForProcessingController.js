({
	doInit : function(component, event, helper) {
        var readyToProcess = '';
        var rec = component.get("v.childRecord", true);    
        var addendumId = component.get("v.recordId", true);         
        var action = component.get("c.getCountAssets");        
        action.setParams({
            id: addendumId,
            account: component.get("v.childRecord.Account__c")
        });
        action.setCallback(this, function(response) {            
            var countAssets = response.getReturnValue();             
           	var result = '';
            if(countAssets > 0 && component.get("v.childRecord.CoTerm_Change__c") == 'CoTerm') 
            { 
                readyToProcess += 'When changing the renewal date, all coterminous products must also be changed. Please adjust the current modifications or add all coterminous products to the addendum. '; 
            }
            if(component.get("v.childRecord.CoTerm_Dates__c") != 1) 
            { 
                readyToProcess += 'The new renewal date must be the same for all products. Please adjust the current modifications. '; 
            }             
            if(component.get("v.childRecord.Addendum_Signer__c") == '') 
            {                
                readyToProcess += 'Please select an Addendum Signer. '; 
            }         
            if(readyToProcess == '') 
            {                 
                component.set("v.childRecord.OwnerId", component.get("v.childRecord.QueueID__c"));
                component.set("v.childRecord.Status__c", 'Ready for Processing');                   
                component.find("recordLoaderChild").saveRecord($A.getCallback(function(saveResult) 
                {
                    if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") 
                    {
                        result = 'Updated successfully';            
                    } 
                    else if (saveResult.state === "ERROR") 
                    {
                        result = 'Problem saving record, error: ' + JSON.stringify(saveResult.error);
                    } 
                    else 
                    {
                        result = 'Something broke.';
                    }
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Message",
                        "message": result
                    });
                    
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire()
                }
				));
                
            } 
            else 
            { 
                System.debug('else');
                result = readyToProcess; 
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Message",
                        "message": result
                    });
                
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire()
            }   
            
        })
        $A.enqueueAction(action);
    }
})