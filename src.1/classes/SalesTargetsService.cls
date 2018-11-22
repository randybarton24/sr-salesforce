public class SalesTargetsService 
{
	public static void calculateMultiplier(Set<Id> targetIds, fflib_SObjectUnitOfWork uow)
	{
		Sales_Target__c[] targets = SalesTargetsSelector.newInstance().selectSObjectsById(targetIds);
		calculateMultiplier(targets, uow);
	}

	public static void calculateMultiplier(Sales_Target__c[] targets)
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		calculateMultiplier(targets, uow);
	}

	public static void calculateMultiplier(Sales_Target__c[] targets, fflib_SObjectUnitOfWork uow)
	{
		Map<Id, Comp_Plan__c> compPlanMap = new Map<Id, Comp_Plan__c>([SELECT Id, Name, 
			(SELECT Id, Type__c, Variable__c, Variable2__c, Operator__c, Operator2__c, Value__c, Value2__c, Result__c 
				FROM Comp_Plan_Rules__r ORDER BY Name) 
			FROM Comp_Plan__c]);

		for(Sales_Target__c target : targets)
		{
			if(!compPlanMap.containsKey(target.Comp_Plan__c)) continue;
			Comp_Plan__c plan = compPlanMap.get(target.Comp_Plan__c);
			
			Decimal result = calculateMultiplier(target, plan);			
			if(target.Multiplier__c != result)
			{
				target.Multiplier__c = result;
				uow.registerDirty(target);
			}
			
			Decimal availableCommision = calculateAvailableCommission(target, plan);
			if(target.Available_Commission__c != availableCommision)
			{
				target.Available_Commission__c = availableCommision;
				uow.registerDirty(target);
			}
		}
	}

	public static Decimal calculateMultiplier(Sales_Target__c target, Comp_Plan__c plan)
	{
		//List to collect results from multiple rules
		String[] exprResults = new List<String>();
		
		for(Comp_Plan_Rule__c rule : plan.Comp_Plan_Rules__r)
		{
			if(rule.Type__c != 'Multiplier') continue;

			//Multiple Criteria - Final expression to be evaluated
			String expr;
			//List to collect multiple criteria
			String[] exprMultiple = new List<String>();
			
			//Add first criteria
			exprMultiple.add('('+ target.get(rule.Variable__c) + rule.Operator__c + rule.Value__c + ')');
			
			//Add second criteria
			if(rule.Variable2__c != null) exprMultiple.add('(' + target.get(rule.Variable2__c) + rule.Operator2__c + rule.Value2__c + ')');
			
			//Combine criteria for final expression
			if(exprMultiple.size() == 1)
			{
				expr = exprMultiple[0] + ' * ' + rule.Result__c;
			}
			else
			{
				expr = '(' + String.join(exprMultiple, ' && ') + ') * ' + rule.Result__c;
			}

			System.debug(expr);
			//Add result for this criteria
			exprResults.add(String.valueOf(new RT_Expression(expr).eval()));
		}

		//Multiple Rules - Combine rules for final expression to be evaluated
		if (exprResults.isEmpty()) return null;
		String maxExpr = 'MAX(' + String.join(exprResults,',') + ')';
		System.debug(maxExpr);
		Decimal result = new RT_Expression(maxExpr).eval();
		System.debug(result);

		return result;
	}

	public static Double calculateAvailableCommission(Sales_Target__c target, Comp_Plan__c plan)
	{
		Decimal totalCommission = 0;

		for(Integer i = 0; i < plan.Comp_Plan_Rules__r.size(); i++)
		{
			Comp_Plan_Rule__c rule = plan.Comp_Plan_Rules__r[i];
			if(rule.Type__c != 'Marginal') continue;

			String expr;
			String[] exprMultiple = new List<String>();
			
			exprMultiple.add('('+ target.get(rule.Variable__c) + rule.Operator__c + rule.Value__c + ')');
			
			if(rule.Variable2__c != null) exprMultiple.add('(' + target.get(rule.Variable2__c) + rule.Operator2__c + rule.Value2__c + ')');
			
			if(exprMultiple.size() == 1)
			{
				expr = exprMultiple[0] + ' * ' + rule.Result__c;
			}
			else
			{
				expr = '(' + String.join(exprMultiple, ' && ') + ') * ' + rule.Result__c;
			}
			System.debug(expr);

			Double result = new RT_Expression(expr).eval();
			System.debug(result);
			Double salesRepRevenueCredit = Double.valueOf(target.get(rule.Variable__c));
			if (result > 0)
			{
				Double nextValue = (i == plan.Comp_Plan_Rules__r.size()-1) ? salesRepRevenueCredit : Double.valueOf(plan.Comp_Plan_Rules__r[i+1].Value__c);
				
				if (salesRepRevenueCredit > nextValue)
				{
					totalCommission += (Double.valueOf(plan.Comp_Plan_Rules__r[i+1].Value__c) - Double.valueOf(rule.Value__c)) * rule.Result__c;
				}
				else
				{					
					totalCommission += Math.abs(salesRepRevenueCredit - Double.valueOf(rule.Value__c)) * rule.Result__c;							
				}									
			}			
		}		

		return totalCommission;
	}
}