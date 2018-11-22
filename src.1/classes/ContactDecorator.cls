/*********************Account Object*****************
* Author				Date			Version
* Sid Maganti   	02/26/2014		Initial 
*
* Public class to create Contacts
*/
public with sharing class ContactDecorator {
	
	public String FirstName {get;set;}
	public String LastName {get;set;}
	public String Salutation {get;set;}
	public String Title {get;set;}
	public String DirectPhone {get;set;}
	public String Email {get;set;}
	public String ReferedBY {get;set;}
	public String street { get; set; }
	public String city { get; set; }
	public String state { get; set; }
	public String zip { get; set; }
	public String country { get; set; }
	public boolean isBillingContactRole { get; set; }
	public boolean isBusinessContactRole { get; set; }
	public boolean isContractSignerRole { get; set; }
	public boolean isPrimaryDoctorContactRole { get; set; }
	public id contactID {get;set;}
	public ContactDecorator(){}

}