public class Payments extends fflib_SObjectDomain
{
	public Approval.ProcessSubmitRequest[] approvalRequests;

    public Payments(Payment__c[] payments) 
	{
		super(payments);
        Configuration.disableTriggerCRUDSecurity();
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Payments(sObjectList);
        }
    }

    public override void onAfterInsert()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Payment__c p : (Payment__c[]) Records) 
        {            
            this.submitForApproval(p, null);            
        }

        if(approvalRequests != null &&
            approvalRequests.size() > 0) Approval.process(approvalRequests, true);
     
        uow.commitWork();
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords)
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Payment__c p : (Payment__c[]) Records) 
        {
            Payment__c existingPayment = (Payment__c) existingRecords.get(p.Id); 

            this.submitForApproval(p, existingPayment);           
        }

        if(approvalRequests != null &&
            approvalRequests.size() > 0) Approval.process(approvalRequests, true);
        
        uow.commitWork();
    }

    public void submitForApproval(Payment__c p, Payment__c existingPayment)
    {    	    
    	if(existingPayment != null &&
    		p.Status__c == existingPayment.Status__c) return;
  		if(p.Status__c != 'Pending Approval') return;

        if(approvalRequests == null) approvalRequests = new List<Approval.ProcessSubmitRequest>();

        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Payment requires approval.');
        req1.setObjectId(p.Id);        
        req1.setSubmitterId(p.OwnerId);       
        approvalRequests.add(req1);
    }
}