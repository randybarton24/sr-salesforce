({
	doInit : function(component, event, helper) {
        var result = '';
        var rec = component.get("v.childRecord", true);    
        var addendumId = component.get("v.recordId", true);          
       
        if (component.get("v.childRecord.Status__c") === 'Needs Accounting Data')
        {
            component.set("v.childRecord.OwnerId", '00Gi00000034JUX');
            result = 'Updated successfully';
        }
        else
        {
            result = 'Data is complete';
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Message",
            "message": result
        });
        
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire()
        
    }
})