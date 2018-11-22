/**
 * File:        CreditCardValidation.cls
 * Project:     Solutionreach 
 * Date:        Feb, 2014
 * Created By:  Sid Maganti
 * *************************************************************************
 * Description: Validate Credit card number and credit card type
 * *************************************************************************
 * History:
 */
public with sharing class CreditCardValidation {

	public  Boolean isValid(String CardType, String CardNumber)
	{
		CardNumber = CardNumber.replace(' ','');
		Boolean ret = false;		
		if(CardType=='Mastercard')
		{
			ret = true;
			//prefix: 51->55
			ret = ret && (checkPrefix(CardNumber, '51') 
			|| checkPrefix(CardNumber, '52')
			|| checkPrefix(CardNumber, '53')
			|| checkPrefix(CardNumber, '55')
			|| checkPrefix(CardNumber, '54'));
			//length: 16
			ret = ret && CardNumber.length()==16;
			//mod 10
			ret = ret && checkMod10(CardNumber);
		}
		if(CardType=='American Express')
		{
			ret = true;
			//prefix: 34 or 37
			ret = ret && (checkPrefix(CardNumber, '34')
			|| checkPrefix(CardNumber, '37'));
			//length: 15
			ret = ret && (CardNumber.length()==15 || CardNumber.length()==16);
			//mod 10
			ret = ret && checkMod10(CardNumber);
			
		}
		if(CardType=='Discover')
		{
			ret = true;
			//prefix: 6011
			ret = ret && checkPrefix(CardNumber, '6011');
			//length: 16
			ret = ret && CardNumber.length()==16;
			//mod 10
			ret = ret && checkMod10(CardNumber);
			
		}
		if(CardType=='Visa')
		{
			ret = true;
			//prefix: 4
			ret = ret && checkPrefix(CardNumber, '4');
			//length: 13 or 16
			ret = ret && (CardNumber.length()==16 || CardNumber.length()==13);
			//mod 10
			ret = ret && checkMod10(CardNumber);
			
		}
		
		return ret;
	}
	public boolean CheckCardNo(string CardNumber)
	{
		if(CardNumber.length()==16 || CardNumber.length()==13 || CardNumber.length()==15 )
		{
			return checkMod10(CardNumber);
		}
		else {return false;}
	}
	
	private Boolean checkPrefix(String CardNumber, String Prefix)
	{
		return CardNumber.startsWith(Prefix);
	}
	
	private Boolean checkMod10(String CardNumber)
	{
		//first check if all digits are numeric
		if(!pattern.matches('[0-9]+',CardNumber)) return false;
		
		String s = '';
		Integer digit = 0;
		for(Integer d=CardNumber.length()-1; d>=0;d--)
		{
			digit++;
			if(Mod(digit,2)==0)
			{
				Integer i = Integer.valueOf(CardNumber.substring(d,d+1))*2;
				s+=i.format();
			}
			else
			{
				Integer i = Integer.valueOf(CardNumber.substring(d,d+1));
				s+=i.format();
			}
		}
		Integer sum = getSum(s);
		system.debug('s:'+sum);
		system.debug('sum:'+s);
		return Mod(sum,10)==0;
	}
	private Integer getSum(String s)
	{
		Integer sum = 0;
		for(Integer d=0; d<s.length();d++)
		{
			sum+=Integer.valueOf(s.substring(d,d+1));
		}
		return sum;
	}
	public Integer Mod(Integer n, Integer div)
	{	
		while(n>=div)
			n-=div;
		return n;
	}
 	
 	/*
    * Modified by: Alexandru Boghean
    * Date: 4/05/2013
    * Added code to get the credit card type based on the credit card number.
    */
 	public  String getCardTypeBasedOnNumber(String cardNum)
 	{
 		if(!String.isEmpty(cardNum))
 		{
	        String visaType = '^4[0-9]{12}(?:[0-9]{3})?$';
	        String masterType = '^5[1-5][0-9]{14}$';
	        String amExpressType = '^3[47][0-9]{13}$';
	        
	        Pattern visaPattern = Pattern.compile(visaType);
	        Matcher visaMatcher = visaPattern.matcher(cardNum);
	        if(visaMatcher.matches())	
	        {
	        	return 'Visa';
	        }
	        Pattern masterPattern = Pattern.compile(masterType);
	        Matcher masterMatcher = masterPattern.matcher(cardNum);
	        if(masterMatcher.matches())	
	        {
	        	return 'Mastercard';
	        }
	        Pattern amExpressPattern = Pattern.compile(amExpressType);
	        Matcher amExpressMatcher = amExpressPattern.matcher(cardNum);
	        if(amExpressMatcher.matches())	
	        {
	        	return 'American Express';
	        }
 		}
        return '';
 	}
 	/*public  Boolean validateCCV(String ccv, String ccType)
    {
    	String visaAndMasterType = '^[0-9]{3}$';
        String amExpressType = '^[0-9]{4}$';
        if(String.isEmpty(ccv))
        {
        	ccv = '';
        }
        if(!String.isEmpty(ccType))
        {
	        if(ccType.equals('American Express'))
	        {
		        Pattern visaPattern = Pattern.compile(amExpressType);
		        Matcher visaMatcher = visaPattern.matcher(ccv);
		        if(visaMatcher.matches())	
		        {
		        	return true;
		        }
	        }
	        else
	        {
	        	Pattern visaPattern = Pattern.compile(visaAndMasterType);
		        Matcher visaMatcher = visaPattern.matcher(ccv);
		        if(visaMatcher.matches())	
		        {
		        	return true;
		        }
	        }
        }
    	return false;
    }*/
 /*//Test method
    static testMethod void test() 
    {
		CreditCardValidation cc = new CreditCardValidation();
		system.debug('visa:'+cc.isValid('Visa','4111 1111 1111 1111'));
		system.debug('MasterCard:'+cc.isValid('MasterCard','5500 0000 0000 0004'));
		system.debug('American Express:'+cc.isValid('American Express','3400 0000 0000 009 '));
		system.debug('Discover:'+cc.isValid('Discover','6011 0000 0000 0004'));
		system.debug('Discover:'+cc.CheckCardNo('6011000000000004'));
		system.debug('Discover:'+cc.CheckCardNo('6011000004'));
    } */	

}