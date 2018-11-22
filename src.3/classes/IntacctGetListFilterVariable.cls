/**
 * File:        IntacctGetListFilterVariable.cls
 * Project:     Sererra 
 * Date:        March 06, 2013
 * Created By:  Alexandru Boghean
 * *************************************************************************
 * Description: 
 *  Represents leaf objects in the composition.
 *  Implements all IntacctGetListExpression methods
 *              
 * *************************************************************************
 * History:
 */
public class IntacctGetListFilterVariable extends IntacctFunctionsHelper implements IntacctGetListExpression
{
	public IntacctObjectsInterface.ExpressionFilter exprFilter {get; private set;}
	public String filterNumber {get; private set;}
	public IntacctGetListFilterVariable(String filterNumber)
	{
		this.filterNumber = filterNumber;
	}
	public IntacctGetListExpression add(IntacctGetListExpression expr)
	{
		return this;
	}
	public IntacctGetListExpression set(String filterNumber, IntacctObjectsInterface.ExpressionFilter exprFilter)
	{
		if(this.filterNumber.equals(filterNumber))
		{
			this.exprFilter = exprFilter;
		}
		return this;
	}
	
	public Dom.xmlNode evaluate(Dom.xmlNode node)
	{
		return createExpressionNode(node, exprFilter);
	}
}