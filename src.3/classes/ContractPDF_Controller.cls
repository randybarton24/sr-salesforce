public without sharing class ContractPDF_Controller 
{	
	public String oppId { get; set; }

	//SObjects
	public Opportunity opp { get; set; }
    public RecurSoft__Payment_Record__c creditCard { get; set; }
    public OpportunityContactRole primaryContactRole { get; set; }
    public OpportunityContactRole businessContactRole { get; set; }
    public OpportunityContactRole billingContactRole { get; set; }
    public OpportunityContactRole contractSignerRole { get; set; }

	//Wrappers
    public AccountDecorator acctWrapper { get; set; }
    public ContactDecorator primaryDoctorWrapper { get; set; }
    public ContactDecorator businessContactWrapper { get; set; }
    public ContactDecorator billingContactWrapper { get; set; }
    public ContactDecorator contractSignerWrapper { get; set; }
    public WrappedProduct[] wrapProductList { get; set; }
    public WrappedProduct[] wrapServicesList { get; set; }

    //General Form Fields
    public String ipAddress { get; set; }
    public String contractSigner { get; set; }
    public String contractDateTime { get; set; }
    public String effectiveDate { get; set; }
    public Decimal grandTotalMonthlyFee { get; set; }
    public Decimal grandTotalServicesFee { get; set; }
    public String country { get; set; }
    public String billingcountry { get; set; }
    public SelectOption[] stateOptions { get; set; }
    public String cardType { get; set; }
    public String cardNumber { get; set; }
    public String cardMonth { get; set; }
    public String cardYear { get; set; }
    public String cardName { get; set; }
    
    //SR Product Family
    public Boolean hasSR { get; set; }
    public Boolean hasSRAdvance { get; set; }
    public Boolean hasSRMonthly { get; set; }
    public Boolean hasSRAnnual { get; set; }
    public Integer includedProviders { get; set; }
    public Integer addtlProviderQty { get; set; }
    public Decimal addtlProviderPrice { get; set; }

    //SRC - Conversations
    public String srcNumber { get; set; }

    //HG - Healthgrades
    public Boolean hasHG { get; set; }
    public Boolean acceptedHGTerms { get; set; }
    public Decimal hgPrice { get; set; }
    public String hgTerm { get; set; }
    public String hgTrial { get; set; }
    public Integer countHealthgradesProviders { get; set; }

    //Professional Services
    public Boolean hasPS { get; set; }
    public Boolean hasDiscountPS { get; set; }

    //Logic and Validation Flags
    public String source { get; set; }
    public Boolean isAPI { get; set; }
    public Boolean isTest { get; set; }
    public Boolean hasDiscount { get; set; }

    public static Map<String, String> productCodeToBillingTermMap { get; set; }
    
	public ContractPDF_Controller() 
    {
		try
        {
            oppId = getParameter('id');

            //Populate SObjects and Wrappers
            isTest = getParameter('isTest') == 'true' ? true : false;  
            retrieveRecords(oppId);
            wrapProductList = new List<WrappedProduct>();
            wrapServicesList = new List<WrappedProduct>();

            //General Form Fields - Most passed as URL parameters
            grandTotalMonthlyFee = 0;
            grandTotalServicesFee = 0;

            //SR
            hasSR = false;
            hasSRAdvance = false;
            hasSRMonthly = false;
            hasSRAnnual = false;
            includedProviders = 0;
            addtlProviderQty = 0;
            addtlProviderPrice = 49;

            //PS
            hasPS = false;
            hasDiscountPS = false;

            //SRC
            srcNumber = '';

            //HG
            hasHG = false;
            acceptedHGTerms = true;
            hgPrice = 0;
            hgTerm = '';
            hgTrial = '';
            countHealthgradesProviders = 0;

            //Logic and Validation Flags
            source = getParameter('source');
            isAPI = getParameter('source') == 'api' ? true : false;
            hasDiscount = false;

            productCodeToBillingTermMap = new Map<String, String>{
                '3000' => 'Arrears',
                '3003' => 'Arrears',
                '3010' => 'Arrears',
                '3020' => 'Arrears',
                '3030' => 'Arrears',
                '3100' => 'Arrears',
                '3101' => 'Arrears',
                '3004' => 'Monthly',
                '3007' => 'Monthly',
                '3011' => 'Monthly',
                '3013' => 'Monthly',
                '3021' => 'Monthly',
                '3031' => 'Monthly',
                '3041' => 'Monthly',
                '3006' => 'Advance',
                '3008' => 'Advance',
                '3012' => 'Advance',
                '3014' => 'Advance',
                '3022' => 'Advance',
                '3032' => 'Advance',
                '3042' => 'Advance',
                '3202' => 'AdvanceAnnual',
                '3015' => 'AdvanceAnnual',
                '3023' => 'AdvanceAnnual',
                '3033' => 'AdvanceAnnual'
            };

            populateAddOns();
        } 
        catch(Exception e) 
        {
        	System.debug(e.getStackTraceString());
        }
	}

	private void retrieveRecords(String oppId) 
    {
        try
        {
        	opp = OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(new Set<Id>{ oppId })[0];
            
            Map<String, OpportunityContactRole> ocrMap = OpportunityContactRolesSelector.newInstance().selectRoleMapByOpportunityIdWithContact(new Set<Id>{ oppId });
            primaryContactRole = ocrMap.get('Primary Doctor/Owner');
            businessContactRole = ocrMap.get('Business Contact');
            billingContactRole = ocrMap.get('Billing Contact');
            contractSignerRole = ocrMap.get('Contract Signer');

	        creditCard = opp.RecurSoft__RecurSoft_Payment_Records__r == null || opp.RecurSoft__RecurSoft_Payment_Records__r.size() == 0 ? new RecurSoft__Payment_Record__c() : opp.RecurSoft__RecurSoft_Payment_Records__r[0];
	        cardType = getParameter('cardType') == null ? creditCard.RecurSoft__Card_Type__c : getParameter('cardType');
	        cardNumber = getParameter('cardNumber') == null ? creditCard.RecurSoft__Last_4_Text__c : getParameter('cardNumber');
	        cardMonth = getParameter('cardMonth') == null ? creditCard.RecurSoft__Expiration_Month__c : getParameter('cardMonth');
	        cardYear = getParameter('cardYear') == null ? creditCard.RecurSoft__Expiration_Year__c : getParameter('cardYear');
	        cardName = getParameter('cardName') == null ? creditCard.RecurSoft__Name_On_Card__c : getParameter('cardName');
	        contractSigner = getParameter('contractSigner') == null ? opp.Contract_Signer__c : getParameter('contractSigner');
	        contractDateTime = getParameter('contractDateTime') == null ? 
	        	opp.Contract_Date_Time__c != null ?	opp.Contract_Date_Time__c.format('MM/dd/yyyy HH:mm:ss', 'America/Denver') : 
	        	'' : getParameter('contractDateTime');
	        ipAddress = getParameter('ipAddress') == null ? opp.Contract_Signed_IP__c : getParameter('ipAddress');

	        acctWrapper = new AccountDecorator();
            primaryDoctorWrapper = new ContactDecorator();
            businessContactWrapper = new ContactDecorator();
            billingContactWrapper = new ContactDecorator();
            contractSignerWrapper = new ContactDecorator();

            acctWrapper.BusinessName = getParameter('acctWrapperBusinessName') == null ? opp.Account.Name : getParameter('acctWrapperBusinessName');
	        acctWrapper.Website = getParameter('acctWrapperWebsite') == null ? opp.Account.Website : getParameter('acctWrapperWebsite');
	        acctWrapper.Address1 = getParameter('acctWrapperAddress1') == null ? opp.Account.ShippingStreet == null ? opp.Account.BillingStreet : opp.Account.ShippingStreet : 
	        	getParameter('acctWrapperAddress1');
			acctWrapper.City = getParameter('acctWrapperCity') == null ? opp.Account.ShippingStreet == null ? opp.Account.BillingCity : opp.Account.ShippingCity : 
				getParameter('acctWrapperCity');
			acctWrapper.State = getParameter('acctWrapperState') == null ? opp.Account.ShippingStreet == null ? opp.Account.BillingState : opp.Account.ShippingState : 
				getParameter('acctWrapperState');
			acctWrapper.Zip = getParameter('acctWrapperZip') == null ? opp.Account.ShippingStreet == null ? opp.Account.BillingPostalCode : opp.Account.ShippingPostalCode : 
				getParameter('acctWrapperZip');
			acctWrapper.Country = getParameter('acctWrapperCountry') == null ? opp.Account.ShippingStreet == null ? opp.Account.BillingCountry : opp.Account.ShippingCountry : 
				getParameter('acctWrapperCountry');

            primaryDoctorWrapper = initializeContactWrapper(primaryDoctorWrapper, 'primaryDoctorWrapper', primaryContactRole);
            businessContactWrapper = initializeContactWrapper(businessContactWrapper, 'businessContactWrapper', businessContactRole);
            billingContactWrapper = initializeContactWrapper(billingContactWrapper, 'billingContactWrapper', billingContactRole);
            contractSignerWrapper = initializeContactWrapper(contractSignerWrapper, 'contractSignerWrapper', contractSignerRole);
        } 
        catch(Exception e) 
        {
        	System.debug(e);
        	System.debug(e.getLineNumber());
        	System.debug(e.getStackTraceString());
        } 
    }

    public ContactDecorator initializeContactWrapper(ContactDecorator wrapper, String wrapperName, OpportunityContactRole ocr)
    {
        wrapper.FirstName = getParameter(wrapperName + 'FirstName') == null ? 
            ocr != null && ocr.Contact.FirstName != null ? ocr.Contact.FirstName : '' : getParameter(wrapperName + 'FirstName');
        wrapper.LastName = getParameter(wrapperName + 'LastName') == null ? 
            ocr != null && ocr.Contact.LastName != null ? ocr.Contact.LastName : '' : getParameter(wrapperName + 'LastName');
        wrapper.DirectPhone = getParameter(wrapperName + 'DirectPhone') == null ? 
            ocr != null && ocr.Contact.Phone != null ? ocr.Contact.Phone : '' : getParameter(wrapperName + 'DirectPhone');
        wrapper.Email = getParameter(wrapperName + 'Email') == null ? 
            ocr != null && ocr.Contact.Email != null ? ocr.Contact.Email : '' : getParameter(wrapperName + 'Email');
        wrapper.Street = getParameter(wrapperName + 'Street') == null ? 
            ocr != null && ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet : '' : getParameter(wrapperName + 'Street');
        wrapper.City = getParameter(wrapperName + 'City') == null ? 
            ocr != null && ocr.Contact.MailingCity != null ? ocr.Contact.MailingCity : '' : getParameter(wrapperName + 'City');
        wrapper.State = getParameter(wrapperName + 'State') == null ? 
            ocr != null && ocr.Contact.MailingState != null ? ocr.Contact.MailingState : '' : getParameter(wrapperName + 'State');
        wrapper.Zip = getParameter(wrapperName + 'Zip') == null ? 
            ocr != null && ocr.Contact.MailingPostalCode != null ? ocr.Contact.MailingPostalCode : '' : getParameter(wrapperName + 'Zip');
        wrapper.Country = getParameter(wrapperName + 'Country') == null ? 
            ocr != null && ocr.Contact.MailingCountry != null ? ocr.Contact.MailingCountry : '' : getParameter(wrapperName + 'Country');
        wrapper.Title = getParameter(wrapperName + 'Title') == null ? 
            ocr != null && ocr.Contact.Title != null ? ocr.Contact.Title : '' : getParameter(wrapperName + 'Title');
        return wrapper;
    }

	public void populateAddOns() 
    {
        if(!opp.HasOpportunityLineItem) return;

        Boolean hasHgWrappedProduct = false; 
        Map<String, Decimal> setupFeeMap = new Map<String, Decimal>();
        includedProviders = Integer.valueOf(opp.Pricebook2.Number_of_Providers_Included__c);

        for(OpportunityLineItem oppLi : opp.OpportunityLineItems) 
        {
            if(oppLi.PricebookEntry.Product2.Contract_Display_Name__c == null) continue;

            if(oppLi.PricebookEntry.Product2.Contract_Display_Name__c == 'Setup Fee') 
            {
                if(oppLi.PricebookEntry.Product2.Name == 'SR Platform Setup Fee') setupFeeMap.put('SR Platform', (oppLi.UnitPrice * oppLi.Quantity));
                if(oppLi.PricebookEntry.Product2.Name == 'Healthgrades Setup Fee') setupFeeMap.put('Healthgrades', (oppLi.UnitPrice * oppLi.Quantity));
                if(oppLi.PricebookEntry.Product2.Name == 'SR Schedule Setup Fee') setupFeeMap.put('SR Schedule', (oppLi.UnitPrice * oppLi.Quantity));
                if(oppLi.PricebookEntry.Product2.Name == 'SR Conversations Setup Fee') setupFeeMap.put('SR Conversations', (oppLi.UnitPrice * oppLi.Quantity));
                if(oppLi.PricebookEntry.Product2.Name == 'Smart Reviews Setup Fee') setupFeeMap.put('SR Smart Reviews', (oppLi.UnitPrice * oppLi.Quantity));
            } 

            if(oppLi.PricebookEntry.Product2.Contract_Display_Name__c == 'Additional Providers') 
            {
                addtlProviderPrice = oppLi.UnitPrice;
                addtlProviderQty = Integer.valueOf(oppLi.Quantity);
            } 

            if(oppLi.PricebookEntry.Product2.Family == 'Healthgrades') 
            {
                countHealthgradesProviders += 1;
            } 
        }

        for(OpportunityLineItem oppLi2 : opp.OpportunityLineItems) 
        { 
            if(oppLi2.PricebookEntry.Product2.RecurSoft__Billing_Frequency__c == 'One-Time' && oppLi2.PricebookEntry.Product2.Family != 'Professional Services') continue; 
            if(oppLi2.PricebookEntry.Product2.Contract_Display_Name__c == null || 
                oppLi2.PricebookEntry.Product2.Contract_Display_Name__c == 'Additional Providers') continue;

            if(oppLi2.PricebookEntry.UnitPrice > oppLi2.UnitPrice) hasDiscount = true;

            WrappedProduct wp;
            String calculatedTerm = productCodeToBillingTermMap.containsKey(oppLi2.PricebookEntry.Product2.ProductCode) && 
                productCodeToBillingTermMap.get(oppLi2.PricebookEntry.Product2.ProductCode) == 'Monthly' ? 
                String.valueOf(1 + oppLi2.Number_of_Free_Months__c) :
                oppLi2.RecurSoft__Contract_Term_Start_Date_New__c.day() == 1 ? 
                    String.valueOf(oppLi2.RecurSoft__Contract_Term_Start_Date_New__c.monthsBetween(oppLi2.RecurSoft__Contract_Term_End_Date_Editable__c) + 1) : 
                    String.valueOf(oppLi2.RecurSoft__Contract_Term_Start_Date_New__c.monthsBetween(oppLi2.RecurSoft__Contract_Term_End_Date_Editable__c));
            Decimal setupFee = oppLi2.PricebookEntry.Product2.Family != null && setupFeeMap.containsKey(oppLi2.PricebookEntry.Product2.Family) ? 
                setupFeeMap.get(oppLi2.PricebookEntry.Product2.Family) : 0;

            if(oppLi2.PricebookEntry.Product2.Family == 'SR Platform') 
            {
                if(oppLi2.PricebookEntry.Product2.ProductCode == '3004')
                {
                    hasSRMonthly = true;
                }
                else if(oppLi2.PricebookEntry.Product2.ProductCode == '3006')
                {
                    hasSRAdvance = true;
                }
                else if(oppLi2.PricebookEntry.Product2.ProductCode == '3202')
                {
                    hasSRAnnual = true;
                }
                else
                {
                    hasSR = true;
                }

                wp = new WrappedProduct(oppLi2, setupFee, addtlProviderPrice, addtlProviderQty, calculatedTerm);
                wrapProductList.add(wp);
                grandTotalMonthlyFee += (oppLi2.UnitPrice * oppLi2.Quantity) + (addtlProviderQty * addtlProviderPrice);
                continue;
            } 
            else if(oppLi2.PricebookEntry.Product2.Family == 'Healthgrades' && !hasHgWrappedProduct) 
            {
                hasHG = true;
                hgPrice = oppLi2.UnitPrice * oppLi2.Quantity;
                hgTrial = oppLi2.Trial__c == null ? '0' : oppLi2.Trial__c;

                wp = new WrappedProduct(oppLi2, setupFee, oppLi2.UnitPrice, countHealthgradesProviders, calculatedTerm);
                wrapProductList.add(wp);
                hasHgWrappedProduct = true;
                grandTotalMonthlyFee += (oppLi2.UnitPrice * countHealthgradesProviders);
                continue;
            }  
            else if(oppLi2.PricebookEntry.Product2.Family == 'SR Conversations') 
            {
                srcNumber = srcNumber == '' ? oppLi2.SR_Conversations_Phone_Number__c : srcNumber + ',' + oppLi2.SR_Conversations_Phone_Number__c;
            } 
            else if(oppLi2.PricebookEntry.Product2.Family == 'Professional Services') 
            {                
                hasPS = true;
                if(oppLi2.PricebookEntry.UnitPrice > oppLi2.UnitPrice) hasDiscountPS = true;
                setupFee = oppLi2.UnitPrice;           
                addtlProviderQty = Integer.valueOf(oppLi2.Quantity);
                wp = new WrappedProduct(oppLi2, setupFee, 0, addtlProviderQty, calculatedTerm);
                wp.hasPSOneTime = (oppLi2.PricebookEntry.Product2.RecurSoft__Billing_Frequency__c == 'One-Time' ? true : false);                                
                wrapServicesList.add(wp);
                grandTotalServicesFee += (oppLi2.UnitPrice * oppLi2.Quantity);
                System.debug(wrapServicesList);
                System.debug(grandTotalServicesFee);
                continue;
            } 

            wp = new WrappedProduct(oppLi2, setupFee, 0, 0, calculatedTerm);
            wrapProductList.add(wp);
            grandTotalMonthlyFee += (oppLi2.UnitPrice * oppLi2.Quantity);
        }
    }

	public class WrappedProduct 
    {
        public String productName { get; set; }
        public String term { get; set; }
        public Decimal termMonths { get; set; }
        public String trial { get; set; }
        public Decimal trialDays { get; set; }
        public Decimal setupFee { get; set; }
        public Decimal monthlyFee { get; set; }
        public Decimal addtlProviderPrice { get; set; }
        public Integer addtlProviderQty { get; set; }
        public Decimal totalMonthlyFee { get; set; }
        public String termMonthsText { get; set; }
        public String promoPriceText { get; set; }
        public Decimal promoPrice { get; set; }
        public Decimal discountAmount { get; set; }
        public Decimal freeMonths { get; set; }
        public String billingTerm { get; set; }
        public Boolean hasPSOneTime { get; set; }

        public WrappedProduct(OpportunityLineItem oppLi, Decimal setFee, Decimal aProviderPrice, Integer aProviderQty, String calculatedTerm) 
        {
            productName = oppLi.PricebookEntry.Product2.Contract_Display_Name__c;
            termMonthsText = oppLi.Total_Contract_Term__c == 1 ? ' Month' : ' Months';
            term = oppLi.Number_of_Free_Months__c > 0 ? calculatedTerm + termMonthsText + ' (' + String.valueOf(oppLi.Number_of_Free_Months__c) + ' Orientation Months)' : calculatedTerm + termMonthsText;
            termMonths = Decimal.valueOf(calculatedTerm);
            trial = oppLi.Trial__c != null && oppLi.Trial__c != '0 - Waived' && oppLi.Trial__c != '0' ? String.valueOf(oppLi.Trial__c) + ' Days' : 'N/A';
            trialDays = oppLi.Trial__c != null && oppLi.Trial__c != '0 - Waived' ? Decimal.valueOf(oppLi.Trial__c) : 0; 
            setupFee = setFee;
            monthlyFee = oppLi.PricebookEntry.Product2.Contract_Display_Name__c == 'SR Elite' && oppLi.List_Price_Override__c != null ? 
                oppLi.List_Price_Override__c * oppLi.Quantity : oppLi.PricebookEntry.UnitPrice * oppLi.Quantity;
            promoPriceText = oppLi.Number_of_Free_Months__c > 0 ? '($' + (oppLi.Promotional_Price__c == null ? '0.00' : String.valueOf(oppLi.Promotional_Price__c)) + ' Orientation)' : '';
            promoPrice = oppLi.Promotional_Price__c == null ? 0 : oppLi.Promotional_Price__c;
            freeMonths = oppLi.Number_of_Free_Months__c == null ? 0 : Integer.valueOf(oppLi.Number_of_Free_Months__c);
            discountAmount = oppLi.PricebookEntry.Product2.Contract_Display_Name__c == 'SR Elite' && oppLi.List_Price_Override__c != null ? oppLi.List_Price_Override__c - oppLi.UnitPrice : oppLi.PricebookEntry.UnitPrice - oppLi.UnitPrice;
            addtlProviderPrice = aProviderPrice;
            addtlProviderQty = aProviderQty;
            totalMonthlyFee = monthlyFee - discountAmount + (aProviderQty * aProviderPrice);
            billingTerm = ContractPDF_Controller.productCodeToBillingTermMap.get(oppLi.PricebookEntry.Product2.ProductCode);
        }
    }

    public String getParameter(String name)
    {   
        PageReference pageRef = ApexPages.currentPage();
        Map<String, String> pageParameters = pageRef.getParameters();
        String p = pageParameters.get(name);
        return p;
    }
}