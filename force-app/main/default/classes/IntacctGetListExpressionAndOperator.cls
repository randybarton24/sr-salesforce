/**
 * File:        IntacctGetListExpressionAndOperator.cls
 * Project:     Sererra 
 * Date:        March 06, 2013
 * Created By:  Alexandru Boghean
 * *************************************************************************
 * Description: 
 *  Represents the "and" type of Composite objects in the composition.
 *              
 * *************************************************************************
 * History:
 */
public class IntacctGetListExpressionAndOperator extends Composite 
{
	public override Dom.xmlNode evaluate(Dom.xmlNode node)
    {
        Dom.xmlNode logicalNode = node.addChildElement('logical', null, null);
        logicalNode.setAttribute('logical_operator', 'and');
        for(IntacctGetListExpression expression : children)
        {
        	logicalNode = expression.evaluate(logicalNode);
        }
        return node;
    }
}