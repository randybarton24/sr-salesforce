/**
 * File:        IntacctFunctions.cls
 * Project:     Sererra 
 * Date:        December 20, 2012
 * Created By:  Anca Comaneciu
 * *************************************************************************
 * Description: IntacctFunctions class that extends IntacctFunctionsHelper
 *              This is a collection of methods that allows you to create/update/delete objects in Intacct
 * *************************************************************************
 * History:
 */
public with sharing class IntacctFunctions extends IntacctFunctionsHelper 
{

    /**
     *Creates body for the http request that checks if the object exists in Intacct
     *@params intacctObjects
     *@return functions
    */
    public Map<String, List<DOM.xmlNode>> getRecordRequest(List<IntacctObjectsInterface.IntacctObject> intacctObjects)
    {
        Map<String, List<DOM.xmlNode>> functions = new Map<String, List<DOM.xmlNode>>();
        
        for(IntacctObjectsInterface.IntacctObject tmpObject : intacctObjects ) 
        {
            DOM.xmlNode function;
            
            //if you add new object you need to update this section
            
            //contact object
            if(tmpObject.intacctObject instanceOf IntacctObjectContact) { function = ((IntacctObjectContact)tmpObject.intacctObject).getRecordRequest(); }
            
            //customer object
            if(tmpObject.intacctObject instanceOf IntacctObjectCustomer) { function = ((IntacctObjectCustomer)tmpObject.intacctObject).getRecordRequest(); }
            
            if(functions.get(tmpObject.intacctEntity) == null) 
            {
                functions.put(tmpObject.intacctEntity, new List<DOM.xmlNode>());
            }
            
            functions.get(tmpObject.intacctEntity).add(function);
        }
        
        return functions;
    }

    /**
     * Builds the function blocks that describes the business function to be executed for the Intacct Object creation/update object
     * @param intacctObjects
     * @return functions
    */
    public Map<String, List<DOM.xmlNode>> setRecordRequest(List<IntacctObjectsInterface.IntacctObject> intacctObjects)
    {

        Map<String, List<DOM.xmlNode>> functions = new Map<String, List<DOM.xmlNode>>();
        
        for(IntacctObjectsInterface.IntacctObject tmpObject : intacctObjects ) {
            DOM.xmlNode function;
            String actionType = (tmpObject.isCreate == true) ? IntacctGlobalVariables.actionType_Create : IntacctGlobalVariables.actionType_Update;
            
            //if you add new object you need to update this section
            
            //contact object
            if(tmpObject.intacctObject instanceOf IntacctObjectContact) { function = ((IntacctObjectContact)tmpObject.intacctObject).setRecordRequest(tmpObject.isCreate, actionType); }
            
            //customer object
            if(tmpObject.intacctObject instanceOf IntacctObjectCustomer) { function = ((IntacctObjectCustomer)tmpObject.intacctObject).setRecordRequest(tmpObject.isCreate, actionType); }
            
            if(functions.get(tmpObject.intacctEntity) == null) {
            	functions.put(tmpObject.intacctEntity, new List<DOM.xmlNode>());
            }
            
            functions.get(tmpObject.intacctEntity).add(function);
        }

        return functions;
    }
    
    /**
     *Creates body for the http request that deletes the object from Intacct
     *@params intacctObjects
     *@return functions
    */
    public Map<String, List<DOM.xmlNode>> deleteRecordRequest(List<IntacctObjectsInterface.IntacctObject> intacctObjects)
    {
        Map<String, List<DOM.xmlNode>> functions = new Map<String, List<DOM.xmlNode>>();
        
        for(IntacctObjectsInterface.IntacctObject tmpObject : intacctObjects ) {
            DOM.xmlNode function;
            
            //if you add new object you need to update this section
            
            //contact object
            if(tmpObject.intacctObject instanceOf IntacctObjectContact) { function = ((IntacctObjectContact)tmpObject.intacctObject).deleteRecordRequest(); }
            
            //customer object
            if(tmpObject.intacctObject instanceOf IntacctObjectCustomer) { function = ((IntacctObjectCustomer)tmpObject.intacctObject).deleteRecordRequest(); }
            
            if(functions.get(tmpObject.intacctEntity) == null) {
                functions.put(tmpObject.intacctEntity, new List<DOM.xmlNode>());
            }
            
            functions.get(tmpObject.intacctEntity).add(function);
        }
        
        return functions;
    }
}