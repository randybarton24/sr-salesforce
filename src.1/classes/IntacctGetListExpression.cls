/**
 * File:        IntacctGetListExpression.cls
 * Project:     Sererra 
 * Date:        March 06, 2013
 * Created By:  Alexandru Boghean
 * *************************************************************************
 * Description: Interface that allows to create logical filters
 *              
 * *************************************************************************
 * History:
 */
public interface IntacctGetListExpression 
{
	IntacctGetListExpression add(IntacctGetListExpression expr);
	IntacctGetListExpression set(String filterNumber, IntacctObjectsInterface.ExpressionFilter exprFilter);
	Dom.xmlNode evaluate(Dom.xmlNode node);	
}