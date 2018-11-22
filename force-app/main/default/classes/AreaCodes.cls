public class AreaCodes extends fflib_SObjectDomain 
{

	private static Area_Code__c[] areaCodes = [SELECT Country__c, Name FROM Area_Code__c];
	public Map<String,String> countryByAreaCode = new Map<String,String>();

	public AreaCodes() 
	{
		super(areaCodes);

		for(Area_Code__c areaCode : areaCodes) 
		{
			countryByAreaCode.put(String.valueOf(areaCode.Name), areaCode.Country__c);
		}	
	}

	public Boolean validateCountryByAreaCode(String phone, String countryCode) 
	{
		String areaCode = AppAdminAPIClass.parsPhone(phone,'areacode');

		if(!countryByAreaCode.containsKey(areaCode)) 
		{
			System.debug('Area Code not in known list');
			return false;
		}

		if(countryCode != countryByAreaCode.get(areaCode)) 
		{
			System.debug('Area Code in known list and Country does not match');
			return true;
		}  
		else 
		{
			System.debug('Area Code in known list and Country matches');
			return false;
		}
	}
}