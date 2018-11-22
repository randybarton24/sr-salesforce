/**
 * File:        IntacctObjectContactItem.cls
 * Project:     Sererra 
 * Date:        February 19, 2013
 * Created By:  Ionut Boghean
 * *************************************************************************
 * Description: Intacct Contact Item Node Definition
 * *************************************************************************
 * History:
 * Date:         Modified By:       Description: 
 * 
 */
public with sharing class IntacctObjectContactItem extends IntacctFunctionsHelper
{
        //Properties
    public String categoryName;
    public String contactName;
    
    /**
     * Builds the contactitem node
     * @param node
     * @return node
    */
    public DOM.xmlNode createContactItemNode(DOM.xmlNode node)
    {
        DOM.xmlNode tmpNode = createEmptyNode(node, 'contactitem');
        tmpNode = createNode(tmpNode, 'category', categoryName);
        tmpNode = createNode(tmpNode, 'contactname', contactName);
        
        return node;
    }
}