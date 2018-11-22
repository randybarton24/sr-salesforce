public class PartenerNewSaleApxc {

    public class PicklistOptions
    {
        @AuraEnabled
        String label {get; set;}
        @AuraEnabled
        String value {get; set;}
    }
    @AuraEnabled
    public static void createPartnerRecordApxc(Account acct, Contact con, Opportunity opp){
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        System.debug('Account: ' + acct);
        System.debug('I am here');
        System.debug('Contact: ' + con);
        System.debug('Opp: ' + opp);
        acct.industry = acct.industry == null ? 'Dental' : acct.industry;
        acct.ParentId = acct.Practice_Management_Software__c == 'a00i000000Mq9mL' ? '0010Z00001wOggb' : '0010Z00001wOggv';
        uow.registerNew(acct);
        uow.registerNew(con, Contact.AccountId, acct);
            opp.Name = acct.Name;
            opp.StageName = 'Qualified';
//          opp.Pricebook2Id = pBook[0].Id;
            opp.RecordTypeId = SRUtilities.getRecordTypeMap('Opportunity').get('New Practice Business').getRecordTypeId();
            opp.RecurSoft__Trial__c = 'None';
            opp.CloseDate = Date.today();
            opp.RecurSoft__Initial_Contract_Term__c = 24;
//          opp.RecurSoft__Intacct_Entity__c = intacctEntity;
            opp.RecurSoft__Contract_Signed_Date__c = Date.today();
            opp.RecurSoft__Bill_to_Account__c = acct.ParentId;
        uow.registerNew(opp, Opportunity.AccountId, acct);
        uow.commitWork();
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput2 = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        mentionSegmentInput.id = '005i0000002gnC6';
        messageBodyInput.messageSegments.add(mentionSegmentInput);

        mentionSegmentInput2.id = '005i0000002gn9T';
        messageBodyInput.messageSegments.add(mentionSegmentInput2);

        textSegmentInput.text = ' New SR Partner sale ';
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = acct.Id;

        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
    }
    @AuraEnabled
    public static List<String> getPickListValuesIntoList(String objectType, String selectedField){
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }
    @AuraEnabled
    public static List<PicklistOptions> getNonBlacklistedPms()
    {
        Management_System__c[] options = ManagementSystemsSelector.newInstance().selectNonBlacklistedManagementSystems();
        List<PicklistOptions> newList = new List<PicklistOptions>();
        for(Management_System__c pms : options)
        {
            PicklistOptions plo = new PicklistOptions();
            plo.label = pms.Name;
            plo.value = pms.Id;
            newList.add(plo);
        }
        return newList;
    }
}