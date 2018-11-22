/**
 * File:        Composite.cls
 * Project:     Sererra 
 * Date:        March 06, 2013
 * Created By:  Alexandru Boghean
 * *************************************************************************
 * Description: 
 *  Represents a composite IntacctGetListExpression (expression having children)
 *  Implements methods to manipulate children
 *  Implements all IntacctGetListExpression methods, generally by delegating them to its children
 *              
 * *************************************************************************
 * History:
 */
public abstract class Composite implements IntacctGetListExpression
{
	public List<IntacctGetListExpression> children {get; private set;}
	public Composite()
	{
		this.children = new List<IntacctGetListExpression>();
	}
	public IntacctGetListExpression add(IntacctGetListExpression expr)
	{
		children.add(expr);
		return this;
	}
	public IntacctGetListExpression set(String filterNumber, IntacctObjectsInterface.ExpressionFilter exprFilter)
	{
		for(IntacctGetListExpression expression : children)
		{
			expression.set(filterNumber, exprFilter);
		}
		return this;
	}
	public abstract Dom.xmlNode evaluate(Dom.xmlNode node);
}