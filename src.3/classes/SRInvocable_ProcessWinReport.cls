public with sharing class SRInvocable_ProcessWinReport 
{
	@InvocableMethod(label='processWinReport' description='Process Win Report Data')
	public static void processWinReport(InputData[] input)
	{
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Map<Id, String> contactIdToInvolvementMap = new Map<Id, String>();
		Map<Id, String> contactIdToRoleMap = new Map<Id, String>();
		for(String s : input[0].involvement)
		{
			String[] split = s.split(':');
			contactIdToInvolvementMap.put(split[0], split[1]);
		}

		for(Id s1 : contactIdToInvolvementMap.keySet())
		{
			Contact c = new Contact(Id = s1, Purchase_Involvement__c = contactIdToInvolvementMap.get(s1));
			if(contactIdToRoleMap.containsKey(s1)) c.Contact_Role_Multi__c = contactIdToRoleMap.get(s1);
			uow.registerDirty(c);
		}

		Opportunity o = new Opportunity(Id = input[0].opportunityId, 
			Competitor__c = input[0].competitors,
			Other_Competitor__c = input[0].competitorOther,
			Win_Report_Completed_Date__c = Datetime.now());
		uow.registerDirty(o);
		
		uow.commitWork();

		generatePDF(input[0], contactIdToInvolvementMap.keySet());
	}

	public class InputData
	{
		@InvocableVariable(required=false)
		public String opportunityId;

		@InvocableVariable(required=false)
		public String competitors;

		@InvocableVariable(required=false)
		public String competitorOther;

		@InvocableVariable(required=false)
		public String primaryBenefit;

		@InvocableVariable(required=false)
		public String goalsDefined;

		@InvocableVariable(required=false)
		public String otherInformation;

		@InvocableVariable(required=false)
		public String[] involvement;
	}

	public static void generatePDF(InputData input, Set<Id> ids)
	{
		Contact[] contacts = ContactsSelector.newInstance().selectByIdWithAccount(ids);
		Opportunity o = [SELECT Id, Account.Name, Account.Subscriber_Id__c, Contract_Date_Time__c 
			FROM Opportunity WHERE Id = :input.opportunityId];

		String fileName = o.Account.Name.replaceAll(' ', '_').replaceAll(',', '_').replaceAll('//', '_').replaceAll('/', '_') + 
            + '_Win_Report.pdf';

        String contractDate = o.Contract_Date_Time__c != null ? o.Contract_Date_Time__c.format('MM/dd/yyyy HH:mm:ss','America/Denver') : 'Unknown';

		String competitorsCombined = input.competitorOther == null ?
			input.competitors : input.competitors + '; ' + input.competitorOther;

		String pdfString = '<p style="text-align: center;"><strong>Win Report</strong></p>' +
			+ '<p><strong>Subscriber ID: </strong>' + o.Account.Subscriber_Id__c +
			+ '<br /><strong>Account Name: </strong>' + o.Account.Name +
			+ '<br /><strong>Contract Signed Date:</strong>' + contractDate +
			+ '<p>&nbsp;</p>' +
			+ '</p><p style="text-align: center;"><strong>Contact Information</strong></p>' +
			+ '<p>&nbsp;</p>';

		for(Contact c : contacts)
		{
			pdfString += '<p><strong>Role(s): ' + c.Contact_Role_Multi__c + '</strong>' +
				+ '<br />Title: ' + c.Title +
				+ '<br />First Name: ' + c.FirstName +
				+ '<br />Last Name: ' + c.LastName +
				+ '<br />Phone: ' + c.Phone +
				+ '<br />Email: ' + c.Email +
				+ '<br />Involvement in Purchase Decision: ' + c.Purchase_Involvement__c +
				+ '<p>&nbsp;</p>';
		}
			
		pdfString += '</p><p><strong>What competitor(s) was the customer using or evaluating?: ' +
			+ '<br /></strong>' + competitorsCombined +
			+ '</p><p><strong>What is the primary benefit the customer is purchasing Solutionreach for?: ' +
			+ '<br /></strong>' + input.primaryBenefit +
			+ '</p><p><strong>What goals were defined with the customer?: ' +
			+ '<br /></strong>' + input.goalsDefined +
			+ '</p><p><strong>Is there anything else we should know about the customer?: ' +
			+ '<br /></strong>' + input.otherInformation + '</p>';
		
		Blob b = Blob.toPdf(pdfString);

		Attachment opportunityAttachment = new Attachment();
            opportunityAttachment.ParentId = o.Id;
            opportunityAttachment.Name = fileName;
            opportunityAttachment.Body = b;

        insert opportunityAttachment;
	}
}