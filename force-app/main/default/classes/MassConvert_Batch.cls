global class MassConvert_Batch implements Database.Batchable<sObject> 
{	
	private String whereClause;

	public MassConvert_Batch(String whereString)
	{
		this.whereClause = whereString;
	}
		
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{	
		String query = 'SELECT Id, Owner.Type, OwnerId, Owner.isActive, Phone, Email, Last_ROE_Task_Date__c, UnconvertedOpportunityIds__c, LastModifiedDate, CreatedDate ' +
		'FROM Lead ' + whereClause;
		/*'WHERE Status NOT IN (\'Bogus\',\'Converted\') ' +
		'AND UnconvertedOpportunityIds__c = null ' +
		'ORDER BY ' + this.orderby + ' LIMIT 100000';*/

		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Lead> scope) 
	{
      	fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		for(Lead l : scope)
		{
			try
			{
				convertLead(l);
			}
			catch(Exception e)
			{
				l.UnconvertedOpportunityIds__c = e.getMessage();
        		uow.registerDirty(l);
			}
		}

		uow.commitWork();
	}
			
	global void finish(Database.BatchableContext BC) 
	{	

	}

	public static void convertLead(Lead l)
	{
		FlowControl.isLeadConvert = true;

        // This is the lead convert object that will convert the lead 
        Database.LeadConvert leadConvert = new Database.LeadConvert();
        
        //set lead ID
        leadConvert.setLeadId(l.Id);    

        if(l.Owner.Type != 'User')
        {
        	leadConvert.setOwnerId('00531000008IfAB');
        }

        if(l.OwnerId == '005i0000002gnBL')
    	{
    		leadConvert.setOwnerId('00531000008KcdO');
    	}
        /*else if(!l.Owner.IsActive)
        {
        	
        	else
        	{
        		leadConvert.setOwnerId('00531000008IfAB');
        	}
        }*/
        
        //set the lead convert status
        leadConvert.setConvertedStatus('Converted');
        
        //set the variable to create or not create an opportunity
        leadConvert.setDoNotCreateOpportunity(true);
        
        //set whether to have a notification email
        leadConvert.setSendNotificationEmail(false);
        
        system.debug('leadConvert --> ' + leadConvert);
        
        //convert the lead
        Database.LeadConvertResult leadConvertResult = Database.convertLead(leadConvert);

    }   
}