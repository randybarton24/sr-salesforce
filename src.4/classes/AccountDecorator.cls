/*********************Account Object*****************
* Author				Date			Version
* Sid Maganti   	02/26/2014		Initial 
*
* Public class to create Accounts
*/
public class AccountDecorator 
{
	public String BusinessName {get;set;}
	public String OfficeEmail {get;set;}
	public String BillingEmail { get; set; }
	public String OfficePhone { get; set; }
	public String OfficeFax { get; set; }
	public String OfficephoneCountryCode {get;set;}
	public String OfficephoneAreaCode {get;set;}
	public String OfficephoneCode {get;set;}
	public String address1 {get;set;}
	public String address2 {get;set;}
	public String city {get;set;}
	public String state {get;set;}
	public String zip {get;set;}
	public String country {get;set;}
	public String website {get;set;}
	public String PractivceSoftware {get;set;}
	public String PractivceSoftwareVersoin {get;set;}
	public String PracticeSoftware {get;set;}
	public String PracticeSoftwareVersion {get;set;}
	public string AccountID {get;set;}
	public string OfficeContactID {get;set;}
	public string TotalAmount {get;set;}

	
	public AccountDecorator(){}
}