/**
 * File:        IntacctGetListExpressionOrOperator.cls
 * Project:     Sererra 
 * Date:        March 07, 2013
 * Created By:  Alexandru Boghean
 * *************************************************************************
 * Description: 
 *  Represents the "or" type of Composite objects in the composition.
 *              
 * *************************************************************************
 * History:
 */
public class IntacctGetListExpressionOrOperator extends Composite 
{
	public override Dom.xmlNode evaluate(Dom.xmlNode node)
    {
        Dom.xmlNode logicalNode = node.addChildElement('logical', null, null);
        logicalNode.setAttribute('logical_operator', 'or');
        for(IntacctGetListExpression expression : children)
        {
        	logicalNode = expression.evaluate(logicalNode);
        }
        return node;
    }
}