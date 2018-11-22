public class CancelRequests extends fflib_SObjectDomain
{
    public static Map<String, Id> currentSubscriptionMap;
    public Map<Id, Asset> relatedAssets;

    public CancelRequests(Cancel_Request__c[] cancelRequests)
    {
        super(cancelRequests);
        Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new CancelRequests(sObjectList);
        }
    }

    public override void onBeforeInsert()
    {
        CancelRequestUtilities.setModifiedSubscription((Cancel_Request__c[]) Records, new Map<Id, Cancel_Request__c>());

        /*fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Cancel_Request__c cro : (Cancel_Request__c[]) Records)
        {
            this.setModifiedSubscriptions(cro, null, uow);
        }

        uow.commitWork();*/
    }

    public override void onAfterInsert()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Cancel_Request__c cro : (Cancel_Request__c[]) Records)
        {
            this.updateAccountDNS(cro, null, uow);
        }

        uow.commitWork();
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
    {
        FlowControl.checkCancelRequestFieldChanges((Cancel_Request__c[]) Records, (Map<Id, Cancel_Request__c>) existingRecords);

        CancelRequestUtilities.setModifiedSubscription((Cancel_Request__c[]) Records, (Map<Id, Cancel_Request__c>) existingRecords);

        if(FlowControl.fieldChangeIdMap.containsKey('Cancel_Request__cStage__cSave')) {

            CancelRequestUtilities.createAddendumOpp((Cancel_Request__c[]) Records);
        }

        if(FlowControl.fieldChangeIdMap.containsKey('Cancel_Request__cStage__cCancelled') ||
            FlowControl.fieldChangeIdMap.containsKey('Cancel_Request__cStage__cNo Sale')) {

            CancelRequestUtilities.createCancelCase((Cancel_Request__c[]) Records);
        }

        /*fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Cancel_Request__c cro : (Cancel_Request__c[]) Records)
        {
            Cancel_Request__c existingCRO = (Cancel_Request__c) existingRecords.get(cro.Id);

            this.setModifiedSubscriptions(cro, null, uow);
        }

        uow.commitWork();*/
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords)
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for(Cancel_Request__c cro : (Cancel_Request__c[]) Records)
        {
            Cancel_Request__c existingCRO = (Cancel_Request__c) existingRecords.get(cro.Id);

            this.updateAccountDNS(cro, existingCRO, uow);
        }

        uow.commitWork();
    }

    public void createAddendumOpp(Cancel_Request__c cro, Cancel_Request__c existingCRO, fflib_SObjectUnitOfWork uow) 
    {
        if(cro.Stage__c != 'Save') return;
        if(existingCRO != null && 
            cro.Stage__c == existingCRO.Stage__c) return;

        if(relatedAssets == null) relatedAssets = new Map<Id, Asset>(AssetsSelector.newInstance().selectByCancelRequestsWithAccountAndProduct((Cancel_Request__c[]) Records));
        Asset ast = relatedAssets.get(cro.Asset__c);

        Opportunity o = new Opportunity(RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get('Add-On Business').getRecordTypeId(),
            AccountId = ast.AccountId,
            Description = cro.Notes_for_Accounting__c,
            CloseDate = Date.today(),
            StageName = 'Qualified',
            Name = ast.Name + ' - ' + cro.Cancel_Request_Type__c + ' Save',
            OwnerId = '005i0000002gn9T');
        uow.registerNew(o);
    }

    public void createCancelCase(Cancel_Request__c cro, Cancel_Request__c existingCRO, fflib_SObjectUnitOfWork uow) 
    {
        if(cro.Stage__c != 'Cancelled' && 
            cro.Stage__c != 'No Sale') return;
        if(existingCRO != null && 
            cro.Stage__c == existingCRO.Stage__c) return;

        if(relatedAssets == null) relatedAssets = new Map<Id, Asset>(AssetsSelector.newInstance().selectByCancelRequestsWithAccountAndProduct((Cancel_Request__c[]) Records));
        Asset ast = relatedAssets.get(cro.Asset__c);

        String cancelType = cro.Stage__c == 'Cancelled' ? cro.Cancel_Request_Type__c + ' Cancel' : 'No Sale';
        String subject = cancelType == 'Annual Cancel' ? 'Turn off any Renewals' : cancelType == 'Trial Cancel' ? '' : 'Refund MSF and Setup';

        Case c = new Case(RecordTypeId = SRUtilities.getRecordTypeMap('Case').get('Accounting').getRecordTypeId(),
            AccountId = ast.AccountId,
            Description = cro.Notes_for_Accounting__c,
            Origin = 'Phone',
            OwnerId = '00Gi00000034JUX',
            Reason = cancelType,
            Related_Opportunity__c = cro.Opportunity__c,
            Subject = ast.Name + ' - ' + cancelType + ' - ' + subject);
        uow.registerNew(c);
    }

    public void setModifiedSubscriptions(Cancel_Request__c cro, Cancel_Request__c existingCRO, fflib_SObjectUnitOfWork uow)
    {
        if(existingCRO != null && 
            (existingCRO.Stage__c == 'Save' || 
            existingCRO.Stage__c == 'Cancelled' ||
            existingCRO.Stage__c == 'No Sale' ||
            existingCRO.Stage__c == 'Resume - No Change')) return;

        this.setModifiedSubscriptions('Modified_Subscription__c', cro, uow);
        this.setModifiedSubscriptions('Current_SR_Subscription__c', cro, uow);
    }

    public void setModifiedSubscriptions(String fieldName, Cancel_Request__c cro, fflib_SObjectUnitOfWork uow) 
    {
        if((Boolean) cro.get('Override_' + fieldName)) return;
        
        if(relatedAssets == null) relatedAssets = new Map<Id, Asset>(AssetsSelector.newInstance().selectByCancelRequestsWithAccountAndProduct((Cancel_Request__c[]) Records));
        Asset ast = relatedAssets.get(cro.Asset__c);

        if(currentSubscriptionMap == null) currentSubscriptionMap = AssetsSelector.newInstance().selectCurrentSubscriptionsByCancelRequests((Cancel_Request__c[]) Records);
        String productName = fieldName == 'Current_SR_Subscription__c' ? 'SR Platform' : ast.Product2.Family;

        if(!currentSubscriptionMap.containsKey(ast.AccountId + productName + ast.Provider__c)) return;
        if(cro.get(fieldName) == currentSubscriptionMap.get(ast.AccountId + productName + ast.Provider__c)) return;

        cro.put(fieldName, currentSubscriptionMap.get(ast.AccountId + productName + ast.Provider__c));
        uow.registerDirty(cro);
    }

    public void updateAccountDNS(Cancel_Request__c cro, Cancel_Request__c existingCRO, fflib_SObjectUnitOfWork uow)
    {
        if(cro.Stage__c != 'Save' &&
                cro.Stage__c != 'Resume - No Change' &&
                cro.Stage__c != 'Cancelled' &&
                cro.Stage__c != 'No Sale') return;

        if(existingCRO != null && 
            cro.Stage__c == existingCRO.Stage__c) return;

        if(relatedAssets == null) relatedAssets = new Map<Id, Asset>(AssetsSelector.newInstance().selectByCancelRequestsWithAccountAndProduct((Cancel_Request__c[]) Records));
        Asset ast = relatedAssets.get(cro.Asset__c);

        System.debug(ast.AccountId);

        Account a = new Account(Id = ast.AccountId,
            Do_Not_Support_Sync__c = false,
            Do_Not_Support_Reason__c = null);
        uow.registerDirty(a);
    }
}