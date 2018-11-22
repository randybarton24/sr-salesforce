public class Addenda extends fflib_SObjectDomain 
{
	public Set<Id> signatureReceived;

	public Addenda(Addendum__c[] addenda) 
	{
		super(addenda);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Addenda(sObjectList);
		}
	}

	public override void onBeforeInsert()
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Addendum__c a : (Addendum__c[]) Records) 
        {        	
			this.setDataStatus(a, null);
        }

        uow.commitWork();
	}

	public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Addendum__c a : (Addendum__c[]) Records) 
        {        	
			Addendum__c existingAddendum = (Addendum__c) existingRecords.get(a.Id);

			this.setDataStatus(a, existingAddendum);
			this.setSignedDate(a, existingAddendum);
        }

        uow.commitWork();
	}

	public override void onAfterUpdate(Map<Id, SObject> existingRecords)
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Addendum__c a : (Addendum__c[]) Records) 
        {        	
			Addendum__c existingAddendum = (Addendum__c) existingRecords.get(a.Id);

			this.deleteAddProducts(a, existingAddendum, uow);
			this.checkSignatureReceived(a, existingAddendum);
        }

        if(signatureReceived != null && 
            !signatureReceived.isEmpty()) AddendaService.processSignatureReceived(signatureReceived, uow);

        uow.commitWork();
	}

	public void checkSignatureReceived(Addendum__c a, Addendum__c existingAddendum)
	{
		if(existingAddendum != null && 
			existingAddendum.Status__c == a.Status__c) return;
		if(a.Status__c != 'Signature Received') return;

		if(signatureReceived == null) signatureReceived = new Set<Id>();
		signatureReceived.add(a.Id);
	}

	public void setSignedDate(Addendum__c a, Addendum__c existingAddendum)
	{
		if(existingAddendum != null && 
			existingAddendum.Status__c == a.Status__c) return;
		if(a.Status__c != 'Signature Received') return;

		a.Signed_Date__c = Date.today();
	}

	public void setDataStatus(Addendum__c a, Addendum__c existingAddendum)
	{
		a.Status__c = a.Data__c != null ? a.Data__c : a.Status__c == 'Needs Accounting Data' ? 'New' : a.Status__c;
	}

	public void deleteAddProducts(Addendum__c a, Addendum__c existingAddendum, fflib_SObjectUnitOfWork uow)
	{
		if(existingAddendum != null && 
			existingAddendum.Price_Book__c == a.Price_Book__c) return;
		
		Addendum_Line_Item__c[] aliList = AddendumLineItemsSelector.newInstance().selectAddProductsByAddendumId(new Set<Id>{ a.Id });
		
		uow.registerDeleted(aliList);
	}
}