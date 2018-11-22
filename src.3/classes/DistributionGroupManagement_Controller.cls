public with sharing class DistributionGroupManagement_Controller 
{
	public Distribution_Group_Member__c distGroupMember { get; set; }
	public Distribution_Group_Member__c[] distGroupMembers { get; set; }
	public Distribution_Group__c distGroup { get; set; }
	public Id distGroupId { get; set; }
	public Id distGroupMemberId { get; set; }
	public static Boolean isNextUpSet = false;

	// Constructor
	public DistributionGroupManagement_Controller() 
	{
		distGroupMember = new Distribution_Group_Member__c();
		distGroupMembers = new List<Distribution_Group_Member__c>(); 
		distGroupId = getDistributionGroups().size() > 0 ? getDistributionGroups()[0].getValue() : null;
		distGroup = new Distribution_Group__c();
	}

	// Query distGroupMember records to populate the table
	public PageReference queryGroupMembers() 
	{    
		getGroupMembers();
		return null;
	}

	// Execute on page *load*, call via action parameter of apex:page header
	public PageReference onLoad() 
	{
		populateNextUp();  
		//populateOpenLeadCount();
		return null;
	}

	public SelectOption[] getDistributionGroups() 
	{
        SelectOption[] options = new List<SelectOption>();

        for(Distribution_Group__c dg : [SELECT Id, Name FROM Distribution_Group__c ORDER BY CreatedDate DESC]) 
        {    
            SelectOption so = new SelectOption(dg.Id, dg.Name);
            options.add(so);
        }

        return options;
    }

	public PageReference del()
	{
		try
		{
			Distribution_Group_Member__c dgm = new Distribution_Group_Member__c(Id = distGroupMemberId);
			delete dgm;
			return null;
		}
		catch (Exception e)
		{
			ApexPages.addMessages(e); 
		}
		return null;
	}
	// Save changes made to the table (update Distribution_Group_Member__c record(s) based on user input)
	public PageReference save() 
	{
		try 
		{
			Boolean isNextUpMarked= true;

			for(Distribution_Group_Member__c distGroupMember : distGroupMembers) 
			{
				if(distGroupMember.Next_Up__c && !distGroupMember.Available__c) 
				{
					distGroupMember.Next_Up__c = false;
					isNextUpMarked = false;
				}

				if(!isNextUpMarked && distGroupMember.Available__c) 
				{
					distGroupMember.Next_Up__c = true;
					isNextUpMarked = true;
				}
			}

			upsert distGroupMembers;
			populateNextUp();
			return null; 
		} 
		catch(System.DMLException e) 
		{
			ApexPages.addMessages(e); 
		}

		return null;
	}

	public PageReference newGroup() 
	{
		try 
		{
			insert distGroup;

			return null; 
		} 
		catch(System.DMLException e) 
		{
			ApexPages.addMessages(e); 
		}

		return null;
	}

	// Insert a new Distribution_Group_Member__c record based on the lookup field
	public PageReference add() 
	{    
		//if user lookup field is empty OR the particular user already exists as a distGroupMember DON'T add new record
		if(distGroupMember.User__c == null) 
		{
			distGroupMember.User__c = null;
			return null;
		}
		else //otherwise, add a new record 
		{
			try 
			{  
				User[] lstUser = [SELECT UserRole.Name,Id 
					FROM User 
					WHERE Id = :distGroupMember.User__c];

				Distribution_Group_Member__c newRecipient = new Distribution_Group_Member__c(User__c = lstUser[0].Id, 
					Available__c = true,
					Next_Up__c = false,
					Distribution_Group__c = distGroupId);

				insert newRecipient;
				populateNextUp();
				distGroupMember.User__c = null;
				return null;
			} 
			catch(System.DMLException e) 
			{
				ApexPages.addMessages(e); 
				return null;
			}
		}
	}

	// Helper function: DML query
	public Distribution_Group_Member__c[] getGroupMembers() 
	{
		distGroupMembers = [SELECT Available__c, c.User__c, c.User_Role__c, c.Next_Up__c
		FROM Distribution_Group_Member__c c
		WHERE c.Distribution_Group__c = :distGroupId 
		ORDER BY c.Available__c DESC, c.User__r.LastName ASC LIMIT 5000];

		return distGroupMembers;
	} 

	// Helper function: ensure integrity of "Next Up" flag
	private void populateNextUp() 
	{
		if(isNextUpSet) 
		{
			return;
		}

		Distribution_Group_Member__c[] nextDistGroupMember = [SELECT Id 
			FROM Distribution_Group_Member__c 
			WHERE Distribution_Group__c = :distGroupId 
			AND Next_Up__c = TRUE];
		
		if(!nextDistGroupMember.isEmpty()) 
		{
			isNextUpSet = true;
			return;
		}
		
		nextDistGroupMember = [SELECT dgm.Id 
			FROM Distribution_Group_Member__c dgm 
			Where dgm.Available__c = TRUE 
			AND User__r.isActive = TRUE 
			AND dgm.Distribution_Group__c = :distGroupId
			ORDER BY dgm.User__r.LastName ASC];
		
		if(!nextDistGroupMember.isEmpty()) 
		{
			nextDistGroupMember[0].Next_Up__c = true;
			update nextDistGroupMember[0];
		}
	}

	// Helper function: query Leads
	/*public void populateOpenLeadCount() 
	{
		Distribution_Group_Member__c[] distGroupMembers = [SELECT Id,openLeads__c,
			(SELECT Id 
				FROM Leads__r 
				WHERE IsConverted = false) 
			FROM Distribution_Group_Member__c];
		
		for(Distribution_Group_Member__c distGroupMember : distGroupMembers) 
		{
			distGroupMember.openLeads__c = distGroupMember.Leads__r.size();
		}
		
		if(!distGroupMembers.isEmpty()) 
		{
			update distGroupMembers;
		}
	}*/

}