public without sharing class SalesCreditsService 
{
	public static void assignSalesCreditToSalesTarget(Sales_Credit__c[] salesCredits)
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		String[] targetKeys = new List<String>();
		Map<String, Id> targetIdsByKey = new Map<String, Id>();
		Map<String, Sales_Target__c> newTargetsCreated = new Map<String, Sales_Target__c>();
		Set<Id> repIds = new Set<Id>();
		//String salesTargetRolesProfiles = SR_Default_Values__c.getInstance('salesTargetRolesProfiles').Value__c;
		
		for(Sales_Credit__c sc : salesCredits)
		{
			if(sc.Override_Trigger_Logic__c) continue;
			targetKeys.add(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.Sales_Rep__c + 'Rep');
			targetKeys.add(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.Manager__c + 'Manager');
			targetKeys.add(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.VP__c + 'VP');
			repIds.add(sc.Sales_Rep__c);
		}

		if(targetKeys.size() == 0) return;
	
		Sales_Target__c[] targets = [SELECT Id, Owner__c, Unique_Target__c FROM Sales_Target__c WHERE Unique_Target__c IN :targetKeys];
		//Map<Id, User> usersMap = new Map<Id, User>([SELECT Id, Profile.Name, UserName, UserRole.Name FROM User WHERE Id IN :repIds]);

		for(Sales_Target__c st : targets)
		{
			targetIdsByKey.put(st.Unique_Target__c, st.Id);
		}

		for(Sales_Credit__c sc : salesCredits)
		{
			/*String userRoleString = usersMap.containsKey(sc.Sales_Rep__c) && usersMap.get(sc.Sales_Rep__c).UserRole != null ? usersMap.get(sc.Sales_Rep__c).UserRole.Name : 'null';
			if(sc.Override_Trigger_Logic__c) continue;
			if(usersMap.containsKey(sc.Sales_Rep__c) && 
				!salesTargetRolesProfiles.contains(usersMap.get(sc.Sales_Rep__c).Profile.Name) &&
				!salesTargetRolesProfiles.contains(usersMap.get(sc.Sales_Rep__c).UserName) &&
				!salesTargetRolesProfiles.contains(userRoleString)) continue;*/

			if(sc.Sales_Rep__c != null && targetIdsByKey.containsKey(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.Sales_Rep__c + 'Rep'))
			{
				sc.Sales_Rep_Target__c = targetIdsByKey.get(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.Sales_Rep__c + 'Rep');
			}
			else if(sc.Sales_Rep__c != null)
			{
				Sales_Target__c repTarget = createNewTarget(sc.Sales_Rep__c, 'Rep', sc);
				if(newTargetsCreated.containsKey(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.Sales_Rep__c + 'Rep'))
				{
					uow.registerRelationship(sc, Sales_Credit__c.Sales_Rep_Target__c, newTargetsCreated.get(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.Sales_Rep__c + 'Rep'));
				}
				else
				{
					uow.registerNew(repTarget);
					uow.registerRelationship(sc, Sales_Credit__c.Sales_Rep_Target__c, repTarget);
					newTargetsCreated.put(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.Sales_Rep__c + 'Rep', repTarget);
				}
			}

			if(sc.Manager__c != null && targetIdsByKey.containsKey(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.Manager__c + 'Manager'))
			{
				sc.Manager_Target__c = targetIdsByKey.get(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.Manager__c + 'Manager');
			}
			else if(sc.Manager__c != null)
			{
				Sales_Target__c managerTarget = createNewTarget(sc.Manager__c, 'Manager', sc);
				if(newTargetsCreated.containsKey(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.Manager__c + 'Manager'))
				{
					uow.registerRelationship(sc, Sales_Credit__c.Manager_Target__c, newTargetsCreated.get(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.Manager__c + 'Manager'));
				}
				else
				{
					uow.registerNew(managerTarget);
					uow.registerRelationship(sc, Sales_Credit__c.Manager_Target__c, managerTarget);
					newTargetsCreated.put(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.Manager__c + 'Manager', managerTarget);
				}
			}

			if(sc.VP__c != null && targetIdsByKey.containsKey(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.VP__c + 'VP'))
			{
				sc.VP_Target__c = targetIdsByKey.get(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.VP__c + 'VP');
			}
			else if(sc.VP__c != null)
			{
				Sales_Target__c vpTarget = createNewTarget(sc.VP__c, 'VP', sc);
				if(newTargetsCreated.containsKey(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.VP__c + 'VP'))
				{
					uow.registerRelationship(sc, Sales_Credit__c.VP_Target__c, newTargetsCreated.get(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.VP__c + 'VP'));
				}
				else
				{
					uow.registerNew(vpTarget);
					uow.registerRelationship(sc, Sales_Credit__c.VP_Target__c, vpTarget);
					newTargetsCreated.put(sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + sc.VP__c + 'VP', vpTarget);
				}
			}
		}

		uow.commitWork();
	}

	public static Sales_Target__c createNewTarget(Id ownerId, String targetType, Sales_Credit__c sc)
	{
		Sales_Target__c newTarget = new Sales_Target__c(OwnerId = ownerId,
			Owner__c = ownerId,
			Target_Date__c = sc.Opportunity_Contract_Signed_Date__c.toStartOfMonth(),
			Type__c = targetType,
			Unique_Target__c = sc.Opportunity_Contract_Signed_Year__c + sc.Opportunity_Contract_Signed_Month__c + ownerId + targetType);

		return newTarget;
	}

	public static void createBonusCommissionCredit(Sales_Credit__c[] salesCredits)
    {
    	Set<Id> salesTargetIds = new Set<Id>();
    	Bonus_Commission_Credit__c[] bccList = new List<Bonus_Commission_Credit__c>();
    	Map<Id, Bonus_Commission__c> bcToTargetMap = new Map<Id, Bonus_Commission__c>();

    	for(Sales_Credit__c sc : salesCredits)
    	{
    		salesTargetIds.add(sc.Sales_Rep_Target__c);
    	}

    	Bonus_Commission__c[] bcList = [SELECT Id, Sales_Target__c, OwnerId FROM Bonus_Commission__c WHERE Sales_Target__c IN :salesTargetIds];

    	for(Bonus_Commission__c bc : bcList)
    	{
    		bcToTargetMap.put(bc.Sales_Target__c, bc);
    	}

    	for(Sales_Credit__c sc : salesCredits)
    	{
    		if(sc.Sales_Rep_Target__c == null ||
    		 !bcToTargetMap.containsKey(sc.Sales_Rep_Target__c) ||
    		 bcToTargetMap.get(sc.Sales_Rep_Target__c) == null) continue;
    		
    		Bonus_Commission_Credit__c bcc = new Bonus_Commission_Credit__c(Sales_Credit__c = sc.Id,
    			Bonus_Commission__c = bcToTargetMap.get(sc.Sales_Rep_Target__c).Id,
    			OwnerId = bcToTargetMap.get(sc.Sales_Rep_Target__c).OwnerId);

    		bccList.add(bcc);
    	}

    	insert bccList;
    }
}