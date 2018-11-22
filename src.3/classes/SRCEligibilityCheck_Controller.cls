public with sharing class SRCEligibilityCheck_Controller extends WebFormsUtilityClass 
{
	public String phoneNum { get; set; }
	public Account a { get; set; }
	public String code { get; set; }
	public Boolean canProvision { get; set; }
	public String msg { get; set; }

	public SRCEligibilityCheck_Controller(ApexPages.StandardController controller) 
	{
		a = (Account) controller.getRecord();
		phoneNum = '';
		msg = 'Enter phone number below to check SRC eligibility';
	}

	public void check() 
	{
		AppAdminAPIClass.SRCEligibility srcEligible = AppAdminAPIClass.getSRCEligibility(phoneNum);

		code = srcEligible.code;
		canProvision = srcEligible.canProvision;
		msg = srcEligible.canProvision ? 'Success! This number is eligible for SRC.' : srcEligible.description == null ? 'Sorry, this number isn\'t eligible for SRC.  ' : srcEligible.description;

		System.debug(srcEligible.code);
		System.debug(srcEligible.canProvision);
		System.debug(srcEligible.description);

	}

	public PageReference back() 
	{
		PageReference page = new PageReference('/' + a.id);
	    page.setRedirect(true);

	    return page;
	}
}