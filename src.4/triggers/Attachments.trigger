trigger Attachments on Attachment (before insert) {

	Set<Id> parentIds = new Set<Id>();
	Map<Id, Id> addendumToAcctMap = new Map<Id, Id>();
	Attachment[] newAttachments = new List<Attachment>();

	for(Attachment a : trigger.new)
	{
		if(a.ParentId.getSObjectType() == Schema.Addendum__c.SObjectType && a.Name.contains('Signed')) parentIds.add(a.ParentId);
	}

	if(!parentIds.isEmpty()) 
	{
		Addendum__c[] addendums = [SELECT Id, Account__c FROM Addendum__c WHERE Id IN :parentIds];

		for(Addendum__c add : addendums)
		{
			addendumToAcctMap.put(add.Id, add.Account__c);
		}

		for(Attachment a : trigger.new)
		{
			if(addendumToAcctMap.containsKey(a.ParentId))
			{
				Attachment a2 = new Attachment(ParentId = addendumToAcctMap.get(a.ParentId),
					Name = a.Name,
					Description = a.Description,
					Body = a.Body);

				newAttachments.add(a2);
			}
		}

		if(!newAttachments.isEmpty()) insert newAttachments;
	}
}