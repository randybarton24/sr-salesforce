trigger Work on agf__ADM_Work__c (before insert, before update) 
{
	WorkRequestMapping__c workRequestMapping = WorkRequestMapping__c.getInstance();
    Map<Id, agf__ADM_Product_Tag__c> productTagMap = new Map<Id, agf__ADM_Product_Tag__c>(
    	[SELECT Id, Color__c, Column__c FROM agf__ADM_Product_Tag__c]);
    Map<Id, agf__ADM_Column__c> columnMap = new Map<Id, agf__ADM_Column__c>(
    	[SELECT Id, Name, agf__Parent_Column__r.Name FROM agf__ADM_Column__c]);

	for(agf__ADM_Work__c w : trigger.new)
	{
		if(trigger.isInsert)
		{
			if(w.agf__Product_Tag__c == null) w.agf__Product_Tag__c = (Id) workRequestMapping.get(w.Category__c.replaceAll(' ', '') + '_ProductTag__c');
			if(w.agf__Color__c == null && productTagMap.containsKey(w.agf__Product_Tag__c))	w.agf__Color__c = productTagMap.get(w.agf__Product_Tag__c).Color__c;
			if(w.agf__Column__c == null && productTagMap.containsKey(w.agf__Product_Tag__c)) w.agf__Column__c = productTagMap.get(w.agf__Product_Tag__c).Column__c;
		}

		if(trigger.isUpdate && w.agf__Product_Tag__c != trigger.oldMap.get(w.Id).agf__Product_Tag__c)
		{
			if(productTagMap.containsKey(w.agf__Product_Tag__c)) w.agf__Color__c = productTagMap.get(w.agf__Product_Tag__c).Color__c;
			if(productTagMap.containsKey(w.agf__Product_Tag__c)) w.agf__Column__c = productTagMap.get(w.agf__Product_Tag__c).Column__c;
		}

		if(trigger.isBefore &&
			trigger.isUpdate && 
			w.agf__Column__c != null &&
			columnMap.get(w.agf__Column__c).agf__Parent_Column__c != null &&
			(columnMap.get(w.agf__Column__c).agf__Parent_Column__r.Name == 'Prioritized' ||
			columnMap.get(w.agf__Column__c).agf__Parent_Column__r.Name == 'Unprioritized') &&
			w.agf__Column__c != trigger.oldMap.get(w.Id).agf__Column__c)
		{
			if(columnMap.get(w.agf__Column__c).Name == 'S') w.agf__Story_Points__c = 2;
			if(columnMap.get(w.agf__Column__c).Name == 'M') w.agf__Story_Points__c = 5;
			if(columnMap.get(w.agf__Column__c).Name == 'L') w.agf__Story_Points__c = 8;
			if(columnMap.get(w.agf__Column__c).Name == 'XL') w.agf__Story_Points__c = 11;
		}
	}		
}