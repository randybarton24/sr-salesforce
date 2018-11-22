/**
 * File:        IntacctObjectVisibility.cls
 * Project:     Sererra 
 * Date:        February 19, 2013
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: Intacct Visibility Node Definition
 * *************************************************************************
 * History:
 * Date:         Modified By:       Description: 
 * 
 */
public with sharing class IntacctObjectVisibility extends IntacctFunctionsHelper
{
    //Properties
    public String visibilityType;
    public List<String> restrictedLocationIds;
    public List<String> restrictedDepartmentIds;
    
    /**
     * Builds the visibility node
     * @param node
     * @return node
    */
    public DOM.xmlNode createVisibilityNode(DOM.xmlNode node)
    {
        Dom.Xmlnode tmpNode = createEmptyNode(node, 'visibility');
        tmpNode = createNode(tmpNode, 'visibility_type', visibilityType);
        tmpNode = createVisibilityChildNode(tmpNode, 'restricted_locs', 'locationid', restrictedLocationIds);
        tmpNode = createVisibilityChildNode(tmpNode, 'restricted_depts', 'departmentid', restrictedDepartmentIds);
        return node;
    }
    
}