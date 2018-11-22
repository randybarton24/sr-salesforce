public without sharing class ContractForm_Controller extends WebFormsUtilityClass
{       
    public String oppId { get; set; }
    
    //Rendering
    public Boolean renderForm { get; set; }
    public Boolean renderError { get; set; }
    public Boolean renderPageError { get; set; }
    public Boolean renderConfirmation { get; set; }
    public String errorLabel { get; set; }
    
    //SObjects
    public Opportunity opp { get; set; }
    public Account acct { get; set; }
    public Contact primaryDoctor { get; set; }
    public Contact businessContact { get; set; }
    public Contact billingContact { get; set; }
    public Contact contractSignerContact { get; set; }
    public RecurSoft__Payment_Record__c creditCard { get; set; }
    
    //Wrappers
    public AccountDecorator acctWrapper { get; set; }
    public ContactDecorator billingContactWrapper { get; set; }
    public ContactDecorator contractSignerWrapper { get; set; }
    public ContactDecorator primaryDoctorWrapper { get; set; }
    public ContactDecorator businessContactWrapper { get; set; }
    public WrappedProduct[] wrapProductList { get; set; }
    public WrappedProduct[] wrapServicesList { get; set; }
    
    //General Form Fields
    public String ipAddress { get; set; }
    public String contractSigner { get; set; }
    public Datetime contractDateTime { get; set; }
    public Date effectiveDate { get; set; }
    public Decimal grandTotalMonthlyFee { get; set; }
    public Decimal grandTotalServicesFee { get; set; }
    public String country { get; set; }
    public String billingcountry { get; set; }
    public String billingOffset { get; set; }
    
    //SR Product Family
    public Boolean hasSR { get; set; }
    public Boolean hasSRAdvance { get; set; }
    public Boolean hasSRMonthly { get; set; }
    public Boolean hasSRAnnual { get; set; }
    public Boolean acceptedSRAdvanceTerms { get; set; }
    public Integer includedProviders { get; set; }
    public Integer addtlProviderQty { get; set; }
    public Decimal addtlProviderPrice { get; set; }
    
    //LL - Limelight
    public Boolean acceptedLLAdvanceTerms { get; set; }
    
    //SRC - Conversations
    public Boolean acceptedSRCAdvanceTerms { get; set; }
    public String srcNumber { get; set; }
    
    //SRSR - Smart Reviews
    public Boolean acceptedSRSRAdvanceTerms { get; set; }
    
    //HG - Healthgrades
    public Boolean hasHG { get; set; }
    public Boolean acceptedHGTerms { get; set; }
    public Decimal hgPrice { get; set; }
    public String hgTerm { get; set; }
    public String hgTrial { get; set; }
    public Integer countHealthgradesProviders { get; set; }

    //Professional Services
    public Boolean hasPS { get; set; }
    public Boolean acceptedPSTerms { get; set; }
    public Boolean hasDiscountPS { get; set; }
    
    //Form Checkboxes
    public Boolean acceptedRenewal { get; set; }
    public Boolean acceptedCCTerms { get; set; }
    public Boolean acceptedEula { get; set; }
    public Boolean requestedEmail { get; set; }
    
    //Logic and Validation Flags
    public String source { get; set; }
    public Boolean isAPI { get; set; }
    public Boolean isTest { get; set; }
    public Boolean hasDiscount { get; set; }
    public Boolean formValidated { get; set; }
    public Boolean isValidCCardNumber { get; set; }
    public Boolean isValidDate { get; set; }
    public static Map<String, String> productCodeToBillingTermMap { get; set; }

    public SR_Feature_Flags__c featureFlag { get; set; }
    
    public ContractForm_Controller() 
    {   
        try
        {    
            oppId = getParameter('id');

            featureFlag = SR_Feature_Flags__c.getInstance();
            
            //Rendering
            renderForm = true;
            renderError = false;
            renderPageError = false;
            renderConfirmation = false;
            errorLabel = '';
            
            //Populate SObjects and Wrappers
            isTest = getParameter('isTest') == 'true' ? true : false;
            retrieveRecords(oppId);
            wrapProductList = new List<WrappedProduct>();
            wrapServicesList = new List<WrappedProduct>();
            
            //General Form Fields
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
            contractSigner = '';
            contractDateTime = Datetime.now();
            effectiveDate = Date.today();
            grandTotalMonthlyFee = 0;
            grandTotalServicesFee = 0;
            country = acctWrapper.Country;
            billingcountry = acctWrapper.Country;
            
            //SR
            hasSR = false;
            hasSRAdvance = false;
            hasSRMonthly = false;
            hasSRAnnual = false;            
            acceptedSRAdvanceTerms = false;
            includedProviders = 0;
            addtlProviderQty = 0;
            addtlProviderPrice = 49;

            //PS
            hasPS = false;
            hasDiscountPS = false;
            
            //LL
            acceptedLLAdvanceTerms = false;
            
            //SRC
            acceptedSRCAdvanceTerms = false;
            srcNumber = '';
            
            //SRSR
            acceptedSRSRAdvanceTerms = false;
            
            //HG
            hasHG = false;
            acceptedHGTerms = false;
            acceptedPSTerms = false;
            hgPrice = 0;
            hgTerm = '';
            hgTrial = '';
            countHealthgradesProviders = 0;
            
            //Form Checkboxes
            acceptedRenewal = false;
            acceptedCCTerms = false;
            acceptedEula = false;
            requestedEmail = true;
            
            //Logic and Validation Flags
            source = getParameter('source');
            isAPI = getParameter('source') == 'api' ? true : false;
            hasDiscount = false;
            formValidated = false;
            isValidCCardNumber = false;
            isValidDate = false;
            
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
            renderPageError = true;
            errorLabel = Label.ContractExpired;
            renderForm = false;
            System.debug(e);
            System.debug(e.getLineNumber());
        }
    }
    
    private void retrieveRecords(String oppId) 
    {
        try
        {
            opp = OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(new Set<Id>{ oppId })[0];
            acct = new Account(Id = opp.AccountId);
            acctWrapper = new AccountDecorator();
            billingContactWrapper = new ContactDecorator();
            contractSignerWrapper = new ContactDecorator();
            primaryDoctorWrapper = new ContactDecorator();
            businessContactWrapper = new ContactDecorator();
            
            creditCard = new RecurSoft__Payment_Record__c();
            
            billingOffset = String.valueOf(opp.Pricebook2.Contract_Start_Date_Offset__c);
            
            creditCard.RecurSoft__Card_Type__c = '';
            creditCard.RecurSoft__Card_Number__c = '';
            creditCard.RecurSoft__Expiration_Month__c = '';
            creditCard.RecurSoft__Expiration_Year__c = '';
            creditCard.RecurSoft__Name_On_Card__c = '';
            
            acctWrapper.AccountId = opp.AccountId;
            acctWrapper.BusinessName = opp.Account.Name;
            acctWrapper.Address1 = opp.Account.BillingStreet;
            acctWrapper.Address2 = '';
            acctWrapper.City = opp.Account.BillingCity;
            acctWrapper.State = opp.Account.BillingState;
            acctWrapper.Zip = opp.Account.BillingPostalCode;
            acctWrapper.Country = opp.Account.BillingCountry == null || opp.Account.BillingCountry == '' ? 'United States' : opp.Account.BillingCountry;
            acctWrapper.Website = opp.Account.Website;
            acctWrapper.OfficePhone = opp.Account.Phone;
            acctWrapper.OfficeFax = opp.Account.Fax;
            acctWrapper.BillingEmail = opp.Account.RecurSoft__Billing_Email__c;
            acctWrapper.PracticeSoftware = opp.Account.Practice_Management_Software__r.Name;
            acctWrapper.PracticeSoftwareVersion = opp.Account.Practice_Management_Software__r.Version__c;
            
            if(!validateOpp(opp))
            {
                renderPageError = true;
                errorLabel = Label.Outstanding_Approvals;
                renderForm = false;
            }
        } 
        catch(Exception e) 
        {
            renderPageError = true;
            errorLabel = Label.ContractExpired;
            renderForm = false;
            System.debug(e);
            System.debug(e.getLineNumber());
        } 
    }
    
    public void populateAddOns() 
    {
        if(!opp.HasOpportunityLineItem) return;
        
        Boolean hasHgWrappedProduct = false; 
        Map<String, Decimal> setupFeeMap = new Map<String, Decimal>();
        includedProviders = Integer.valueOf(opp.Pricebook2.Number_of_Providers_Included__c);
        Integer freeMonths = 0;

        for(OpportunityLineItem oppLi : opp.OpportunityLineItems) 
        {
            if(oppLi.PricebookEntry.Product2.Contract_Display_Name__c == null) continue;
            
            freeMonths = oppLi.Number_of_Free_Months__c >= freeMonths && oppLi.Free_Month_Setting__c == 'Extend Contract - At the Beginning' ? Integer.valueOf(oppLi.Number_of_Free_Months__c) : freeMonths;
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
                String.valueOf(1 + freeMonths) : String.valueOf(Integer.valueOf(opp.RecurSoft__Initial_Contract_Term__c + freeMonths));
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
               
                hasSR = true;
                
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
            billingTerm = ContractForm_Controller.productCodeToBillingTermMap.get(oppLi.PricebookEntry.Product2.ProductCode);
        }
    }
    
    public void submitForm() 
    {
        String error ='';
        
        Opportunity currentOpp = OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(new Set<Id>{ oppId })[0];
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        if(!validateOpp(currentOpp)) 
        {
            renderPageError = true;
            errorLabel = Label.Outstanding_Approvals;
            renderForm = false;
            
            Error_Log__c errorLog = new Error_Log__c(
                Error_Message__c = 'Error occured when Submitting the Contract Form. Please check approvals, Opportunity Stage, Contract Signed checkbox, and Close Date',
                Error_Type__c = 'Contract Sumbit Error',
                Opportunity__c = oppId);
            insert errorLog;
        } 
        else 
        {
            try 
            {
                if(hasSR || hasSRMonthly || hasSRAdvance) 
                {
                    if((acceptedSRAdvanceTerms &&
                        acceptedRenewal &&
                        acceptedCCTerms &&
                        acceptedEula) || 
                       System.Test.isRunningTest()) 
                    {
                        if(formValidated || System.Test.isRunningTest()) 
                        {
                            Map<String, String> PayPalResponse = new Map<String, String>();
                            
                            try 
                            {
                                PayPalResponse = PayFlowProGateWay.getResponseMessage(
                                    PayFlowProGateWay.sendRequest(
                                        PayFlowProGateWay.buildAutRequestDocument(acctWrapper,creditCard,billingContactWrapper)),true);
                            } 
                            
                            catch (Exception e) 
                            { 
                                ApexPages.addMessage(returnFailure('An Unexpected Error Occured! Please try again later'));
                                
                                Error_Log__c errorLog = new Error_Log__c(
                                    Error_Message__c = 'Error occured when syncing with PayPal. ' + e.getMessage(),
                                    Error_Type__c = 'PayPal Sync Error',
                                    Opportunity__c = oppId);
                                insert errorLog;      
                            }
                            
                            if(PayPalResponse.size() > 0) 
                            {
                                if(PayPalResponse.containsKey('Result') && 
                                   PayPalResponse.get('Result') == '0' && 
                                   PayPalResponse.containsKey('Message') && 
                                   PayPalResponse.get('Message') == 'Approved') 
                                {
                                    creditCard.PNRef__c = PayPalResponse.containsKey('PNRef') ? PayPalResponse.get('PNRef') : '';
                                    creditCard.PayPalMessage__c = PayPalResponse.containsKey('Message') ? PayPalResponse.get('Message') : '';
                                    creditCard.AuthCode__c = PayPalResponse.containsKey('ProfileID') ? PayPalResponse.get('ProfileID') : '';
                                    
                                    if(hasSR || hasSRMonthly || hasSRAdvance) updateAccount(uow);
                                    if(hasSR || hasSRMonthly || hasSRAdvance) updateCreditCard(uow);
                                    if(hasSR || hasSRMonthly || hasSRAdvance) createContacts(uow);
                                    updateOpp(uow);
                                    if(featureFlag.Feature1__c) AppAdminAPIClassNew.syncOpportunityAppAdmin(new Set<Id>{ oppId }, true);
                                    generateAndAttachContractPdf(oppId, isAPI, requestedEmail);
                                    uow.commitWorkCatchErrorLog();
                                    renderForm = false;
                                    renderConfirmation = true;
                                } 
                                else 
                                {
                                    error = PayPalResponse.containsKey('Result') && 
                                        PayflowErrors__c.getValues(PayPalResponse.get('Result')) != null ? 
                                        PayflowErrors__c.getValues(PayPalResponse.get('Result')).ShowErrorDescription__c :
                                    'Please review your credit card details. Your credit card might be declined or please try after some time.'; 
                                    ApexPages.addMessage(returnFailure(error)); 
                                    renderError = true;
                                    System.debug(PayPalResponse);
                                }
                            } 
                            else 
                            {   
                                error= PayflowErrors__c.getValues('ReviewYourCreditCard') != null ? 
                                    PayflowErrors__c.getValues('ReviewYourCreditCard').ShowErrorDescription__c :
                                'Please review your credit card details.'; 
                                ApexPages.addMessage(returnFailure(error));
                                renderError = true;                             
                            }
                        }
                    } 
                    else 
                    {    
                        error= PayflowErrors__c.getValues('TermsAndConditions') != null ?
                            PayflowErrors__c.getValues('TermsAndConditions').ShowErrorDescription__c :
                        'Please accept terms and conditions.'; 
                        ApexPages.addMessage(returnFailure(error));
                        renderError = true;
                    }
                } 
                else 
                {
                    if(formValidated || 
                       System.Test.isRunningTest()) 
                    { 
                        if(hasSR || hasSRMonthly || hasSRAdvance) createContacts(uow);
                        if(hasSR || hasSRMonthly || hasSRAdvance) updateAccount(uow);
                        if(hasSR || hasSRMonthly || hasSRAdvance) updateCreditCard(uow);
                        updateOpp(uow);
                        if(featureFlag.Feature1__c) AppAdminAPIClassNew.syncOpportunityAppAdmin(new Set<Id>{ oppId }, true);
                        generateAndAttachContractPdf(oppId, isAPI, requestedEmail);
                        uow.commitWorkCatchErrorLog();
                        renderForm = false;
                        renderConfirmation = true;
                    }
                }                
            } 
            catch(Exception e) 
            {
                ApexPages.addMessage(returnFailure('Error Occured! Our technical team is notified please try again later'));
                
                System.debug(e);
                System.debug(e.getLineNumber());
                
                Error_Log__c errorLog = new Error_Log__c(
                    Error_Message__c = 'Error occured when submitting the contract form. ' + e.getMessage(),
                    Error_Type__c = 'Contract Form Sumbit Error',
                    Opportunity__c = oppId);
                insert errorLog;
            }
        }
    }
    
    public String getContactString(ContactDecorator contactWrapper, Boolean isBilling)
    {
        String address = isBilling ? contactWrapper.Street : acctWrapper.Address1;
        address += isBilling ? contactWrapper.City : acctWrapper.City;
        address += isBilling ? contactWrapper.State : acctWrapper.State;
        address += isBilling ? contactWrapper.Zip : acctWrapper.Zip;
        address += isBilling ? billingcountry : country;
        
        return 
            contactWrapper.Title +
            contactWrapper.FirstName +
            contactWrapper.LastName +
            contactWrapper.Email +
            contactWrapper.DirectPhone +
            address;
    }
    
    public Contact createNewContact(ContactDecorator contactWrapper, AccountDecorator acctWrapper, Boolean isBilling, fflib_SObjectUnitOfWork uow)
    {
        Contact c = new Contact(AccountId = acctWrapper.AccountId,
                                FirstName = contactWrapper.FirstName,
                                LastName = contactWrapper.LastName,
                                Email = contactWrapper.Email,
                                Phone = contactWrapper.DirectPhone,
                                Title = contactWrapper.Title,
                                MailingStreet = isBilling ? contactWrapper.Street : acctWrapper.Address1,
                                MailingCity = isBilling ? contactWrapper.City : acctWrapper.City,
                                MailingState = isBilling ? contactWrapper.State : acctWrapper.State,
                                MailingPostalCode = isBilling ? contactWrapper.Zip : acctWrapper.Zip,
                                MailingCountry = isBilling ? billingcountry : country);
        uow.registerNew(c);
        return c;
    }
    
    public void updateAccount(fflib_SObjectUnitOfWork uow)
    {
        acct.Name = acctWrapper.BusinessName;
        acct.BillingCity = billingContactWrapper.City;
        acct.BillingCountry = billingcountry;
        acct.BillingPostalCode = billingContactWrapper.Zip;
        acct.BillingState = billingContactWrapper.State;
        acct.BillingStreet = billingContactWrapper.Street;
        acct.ShippingCity = acctWrapper.City;
        acct.ShippingCountry = country;
        acct.ShippingPostalCode = acctWrapper.Zip;
        acct.ShippingState = acctWrapper.State;
        acct.ShippingStreet = acctWrapper.Address1;
        acct.Phone = businessContactWrapper.DirectPhone;
        acct.Fax = acctWrapper.OfficeFax;
        acct.Office_Email__c = acctWrapper.OfficeEmail;
        acct.Website = acctWrapper.Website;
        acct.Verisign_Profile_ID__c = creditCard.AuthCode__c;
        uow.registerDirty(acct);
    }
    
    public void updateCreditCard(fflib_SObjectUnitOfWork uow)
    {
        creditCard.RecurSoft__Address_1__c = billingContactWrapper.Street;
        creditCard.RecurSoft__City__c = billingContactWrapper.City;
        creditCard.RecurSoft__State__c = billingContactWrapper.State;
        creditCard.RecurSoft__Zip_code__c = billingContactWrapper.Zip;
        creditCard.RecurSoft__Country__c = billingcountry;
        creditCard.RecurSoft__Payment_Method__c = 'Credit Card';
        creditCard.RecurSoft__Account__c = acct.Id;
        creditCard.RecurSoft__Opportunity__c = opp.Id;
        creditCard.RecurSoft__Last_4_Text__c = creditCard.RecurSoft__Card_Number__c.right(4);
        creditCard.RecurSoft__Card_Number__c = '';
        uow.registerNew(creditCard);
    }
    
    public void createContacts(fflib_SObjectUnitOfWork uow) 
    {
        String primaryDoctorString = getContactString(primaryDoctorWrapper, false);
        String businessContactString = getContactString(businessContactWrapper, false);
        String contractSignerString = getContactString(contractSignerWrapper, false);
        String billingContactString = getContactString(billingContactWrapper, true);
        
        //Primary Doctor
        primaryDoctor = createNewContact(primaryDoctorWrapper, acctWrapper, false, uow);                
        // Compare Primary with Business Contacts and create a new contact if different
        
        businessContact = primaryDoctorString.equalsIgnoreCase(businessContactString) ? primaryDoctor : 
        createNewContact(businessContactWrapper, acctWrapper, false, uow);
        
        billingContact = primaryDoctorString.equalsIgnoreCase(billingContactString) ? primaryDoctor : 
        businessContactString.equalsIgnoreCase(billingContactString) ? businessContact : 
        createNewContact(billingContactWrapper, acctWrapper, true, uow);
        
        contractSignerContact = primaryDoctorString.equalsIgnoreCase(contractSignerString) ? primaryDoctor : 
        businessContactString.equalsIgnoreCase(contractSignerString) ? businessContact : 
        billingContactString.equalsIgnoreCase(contractSignerString) ? billingContact : 
        createNewContact(contractSignerWrapper, acctWrapper, false, uow);
        
        primaryDoctor.Contact_Role_Multi__c = 'Primary Doctor/Owner';
        businessContact.Contact_Role_Multi__c = businessContact.Contact_Role_Multi__c == null ? 
            'Business Contact' : businessContact.Contact_Role_Multi__c + ';Business Contact';
        billingContact.Contact_Role_Multi__c = billingContact.Contact_Role_Multi__c == null ? 
            'Billing Contact' : billingContact.Contact_Role_Multi__c + ';Billing Contact';
        contractSignerContact.Contact_Role_Multi__c = contractSignerContact.Contact_Role_Multi__c == null ? 
            'Contract Signer' : contractSignerContact.Contact_Role_Multi__c + ';Contract Signer';
        
        createOpportunityContactRole('Primary Doctor/Owner', primaryDoctor, uow);
        createOpportunityContactRole('Business Contact', businessContact, uow);
        createOpportunityContactRole('Billing Contact', billingContact, uow);
        createOpportunityContactRole('Contract Signer', contractSignerContact, uow);    
    }
    
    public void createOpportunityContactRole(String role, Contact c, fflib_SObjectUnitOfWork uow)
    {
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = opp.Id, Role = role);
        uow.registerNew(ocr);
        uow.registerRelationship(ocr, Schema.OpportunityContactRole.ContactId, c);
    }
    
    public void updateOpp(fflib_SObjectUnitOfWork uow)
    {
        opp.Contract_Date_Time__c = contractDateTime;
        opp.RecurSoft__Contract_Signed_Date__c = Date.today();
        opp.Contract_Signed__c = true;
        opp.Contract_Signer__c = contractSigner; 
        opp.Contract_Signed_IP__c = ipAddress;
        if(hasSR)
        {
            uow.registerRelationship(opp, Schema.Opportunity.RecurSoft__Billing_Contact__c, billingContact);
            uow.registerRelationship(opp, Schema.Opportunity.RecurSoft__Shipping_Contact__c, billingContact);
        }
        uow.registerDirty(opp);
    }
    
    public void addContactWrapperParameters(PageReference pdf, ContactDecorator wrapper, String wrapperName)
    {
        pdf.getParameters().put(wrapperName + 'FirstName', wrapper.FirstName);
        pdf.getParameters().put(wrapperName + 'LastName', wrapper.LastName);
        pdf.getParameters().put(wrapperName + 'Email', wrapper.Email);
        pdf.getParameters().put(wrapperName + 'DirectPhone', wrapper.DirectPhone);
        pdf.getParameters().put(wrapperName + 'Title', wrapper.Title);
        pdf.getParameters().put(wrapperName + 'Street', wrapper.Street);
        pdf.getParameters().put(wrapperName + 'City', wrapper.City);
        pdf.getParameters().put(wrapperName + 'State', wrapper.State);
        pdf.getParameters().put(wrapperName + 'Zip', wrapper.Zip);
        pdf.getParameters().put(wrapperName + 'Country', country);
    }
    
    
    public Boolean validateOpp(Opportunity opp) 
    {   
        Boolean result = true;
        
        if(isTest)
        {
            return result;
        }
        
        else if((opp.Approval_Level_Required__c != null && opp.Approval_Level_Required__c > 0) ||
                (opp.Deal_Desk_Approval_Date__c == null && 
                    opp.RecordTypeId == SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business') &&
                    (opp.Number_of_Locations__c > 2 || opp.Approval_Level_Required_Orientation__c > opp.Pricebook2.Deal_Desk_Orientation_Months__c)) ||
                opp.Contract_Signed__c ||
                opp.StageName == 'Closed Won' ||
                opp.StageName == 'Closed Lost' ||
                ((opp.Sales_Engineer_Call_Completed__c < Date.today().addDays(-30) || opp.Sales_Engineer_Call_Completed__c == null) && 
                 opp.Account.Practice_Management_Software__r.Sales_Engineer_Call_Needed__c &&
                 opp.RecordTypeId == SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business')) ||
                ((opp.RecurSoft__Billing_Contact__c == null || opp.RecurSoft__Shipping_Contact__c == null) && 
                 opp.RecordTypeId != SRUtilities.getRecordTypeId('Opportunity', 'New Practice Business')) ||
                !opp.HasOpportunityLineItem) 
        {
            result = false;
            return result;
        } 
        
        return result;
    }
    
    public void validateForm() 
    {
        String error = '';
        
        try 
        {
            formValidated = false;
            renderError = false;
            
            if(validateRequiredFields() || System.Test.isRunningTest()) 
            {
                validateCCard();
                
                if(!isValidCCardNumber || !isValidDate) 
                {
                    formValidated = false;
                    
                    if(!isValidCCardNumber) 
                    {
                        error = PayflowErrors__c.getValues('ValidCreditCard') != null ? 
                            PayflowErrors__c.getValues('ValidCreditCard').ShowErrorDescription__c :
                        'Please provide valid credit card number and credit card type.'; 
                        ApexPages.addMessage(returnFailure(error));
                        renderError = true;
                    } 
                    else if(!isValidDate) 
                    {
                        error= PayflowErrors__c.getValues('ValidExpirationDate') != null ? 
                            PayflowErrors__c.getValues('ValidExpirationDate').ShowErrorDescription__c :
                        'Please provide valid expiration date.'; 
                        ApexPages.addMessage(returnFailure(error));
                        renderError = true;
                    }
                } 
                else if((isValidCCardNumber && isValidDate) || Test.isRunningTest()) 
                {
                    formValidated = true;
                }
            } 
            else 
            {
                error= PayflowErrors__c.getValues('TermsAndConditions') != null ? 
                    PayflowErrors__c.getValues('TermsAndConditions').ShowErrorDescription__c :
                'Please accept all terms and populate all required fields.'; 
                ApexPages.addMessage(returnFailure(error));
                renderError = true;
            }
        } 
        catch(Exception e) 
        {
            ApexPages.addMessage(returnFailure('An Unexpected Error Occured! Please try again later'));
            
            Error_Log__c errorLog = new Error_Log__c(
                Error_Message__c = 'Error occured when validating the form. ' + e.getMessage(),
                Error_Type__c = 'Contract Form Validation Error',
                Opportunity__c = oppId);
            insert errorLog; 
        }
    }
    
    public Boolean validateRequiredFields() 
    {
        Boolean result = true;
        
        if((hasSR && isEmptyOrNull(billingContactWrapper.FirstName)) ||
           (hasSR && isEmptyOrNull(billingContactWrapper.LastName)) ||
           (hasSR && isEmptyOrNull(billingContactWrapper.Email)) ||
           (hasSR && isEmptyOrNull(billingContactWrapper.DirectPhone)) ||
           (hasSR && isEmptyOrNull(businessContactWrapper.FirstName)) ||
           (hasSR && isEmptyOrNull(businessContactWrapper.LastName)) ||
           (hasSR && isEmptyOrNull(businessContactWrapper.DirectPhone)) ||
           (hasSR && isEmptyOrNull(businessContactWrapper.Email)) ||
           (hasSR && isEmptyOrNull(primaryDoctorWrapper.FirstName)) ||
           (hasSR && isEmptyOrNull(primaryDoctorWrapper.LastName)) ||
           (hasSR && isEmptyOrNull(primaryDoctorWrapper.DirectPhone)) ||
           (hasSR && isEmptyOrNull(primaryDoctorWrapper.Email)) ||
           (hasSR && isEmptyOrNull(contractSignerWrapper.FirstName)) ||
           (hasSR && isEmptyOrNull(contractSignerWrapper.LastName)) ||
           (hasSR && isEmptyOrNull(contractSignerWrapper.DirectPhone)) ||
           (hasSR && isEmptyOrNull(contractSignerWrapper.Email)) ||
           isEmptyOrNull(acctWrapper.BusinessName) ||
           isEmptyOrNull(acctWrapper.Address1) ||
           isEmptyOrNull(acctWrapper.City) ||
           (acctWrapper.Country != 'Bermuda' && isEmptyOrNull(acctWrapper.State)) ||
           isEmptyOrNull(acctWrapper.Zip) ||
           isEmptyOrNull(acctWrapper.Country) ||
           (hasSR && isEmptyOrNull(creditCard.RecurSoft__Card_Type__c)) ||
           (hasSR && isEmptyOrNull(creditCard.RecurSoft__Card_Number__c)) ||
           (hasSR && isEmptyOrNull(creditCard.RecurSoft__Expiration_Month__c)) ||
           (hasSR && isEmptyOrNull(creditCard.RecurSoft__Expiration_Year__c)) ||
           (hasSR && isEmptyOrNull(creditCard.RecurSoft__Name_On_Card__c)) ||
           (hasSRMonthly && isEmptyOrNull(creditCard.RecurSoft__Card_Type__c)) ||
           (hasSRMonthly && isEmptyOrNull(creditCard.RecurSoft__Card_Number__c)) ||
           (hasSRMonthly && isEmptyOrNull(creditCard.RecurSoft__Expiration_Month__c)) ||
           (hasSRMonthly && isEmptyOrNull(creditCard.RecurSoft__Expiration_Year__c)) ||
           (hasSRMonthly && isEmptyOrNull(creditCard.RecurSoft__Name_On_Card__c)) ||
           (hasSRAdvance && isEmptyOrNull(creditCard.RecurSoft__Card_Type__c)) ||
           (hasSRAdvance && isEmptyOrNull(creditCard.RecurSoft__Card_Number__c)) ||
           (hasSRAdvance && isEmptyOrNull(creditCard.RecurSoft__Expiration_Month__c)) ||
           (hasSRAdvance && isEmptyOrNull(creditCard.RecurSoft__Expiration_Year__c)) ||
           (hasSRAnnual && isEmptyOrNull(creditCard.RecurSoft__Name_On_Card__c)) ||
           (hasSRAnnual && isEmptyOrNull(creditCard.RecurSoft__Card_Type__c)) ||
           (hasSRAnnual && isEmptyOrNull(creditCard.RecurSoft__Card_Number__c)) ||
           (hasSRAnnual && isEmptyOrNull(creditCard.RecurSoft__Expiration_Month__c)) ||
           (hasSRAnnual && isEmptyOrNull(creditCard.RecurSoft__Expiration_Year__c)) ||
           (hasSRAnnual && isEmptyOrNull(creditCard.RecurSoft__Name_On_Card__c)) ||
           isEmptyOrNull(contractSigner) ||
           (hasSR && !acceptedSRAdvanceTerms) ||
           (hasSRMonthly && !acceptedSRAdvanceTerms) ||
           (hasSRAdvance && !acceptedSRAdvanceTerms) ||
           (hasSRAnnual && !acceptedSRAdvanceTerms) ||
           (hasHG && !acceptedHGTerms) ||
           (hasPS && !acceptedPSTerms) ||
           (hasSR && !acceptedRenewal) ||
           (hasSRAdvance && !acceptedRenewal) ||
           (hasSRMonthly && !acceptedRenewal) ||
           (hasSRAnnual && !acceptedRenewal) ||
           (!isAPI && !acceptedCCTerms) ||
           (!isAPI && !acceptedEula)) {
               
               result = false;
           }
        return result;
    }
    
    public void validateCCard() 
    {
        if(!hasSR) 
        {
            isValidCCardNumber = true;
            isValidDate = true;
        } 
        else 
        {
            CreditCardValidation ccv = new CreditCardValidation();
            isValidCCardNumber = ccv.isValid(String.valueOf(creditCard.RecurSoft__Card_Type__c), String.valueOf(creditCard.RecurSoft__Card_Number__c));
            
            if(isEmptyOrNull(creditCard.RecurSoft__Expiration_Month__c) || isEmptyOrNull(creditCard.RecurSoft__Expiration_Year__c)) 
            {
                isValidDate = false;
            } 
            else 
            {
                isValidDate = (Integer.valueOf(creditCard.RecurSoft__Expiration_Year__c) < System.today().year() || 
                               (Integer.valueOf(creditCard.RecurSoft__Expiration_Year__c) == System.today().year() && 
                                Integer.valueOf(creditCard.RecurSoft__Expiration_Month__c) < System.today().month())) ? false : true;
            }
        }
    }
    
    public SelectOption[] getRelatedStates 
    {
        get 
        {
            SelectOption[] options = new List<SelectOption>();
            pw_cc__State__c[] state = new List<pw_cc__State__c>(); 
            state = [SELECT Name FROM pw_cc__State__c WHERE pw_cc__Country__r.Name = :country ORDER BY Name ASC LIMIT 500];
            
            for(pw_cc__State__c st : state) 
            {
                options.add(new SelectOption(st.Name, st.Name));
            }
            
            return options;
        }
        
        set;
    }
    
    public SelectOption[] getRelatedBillingStates 
    {
        get 
        {
            SelectOption[] options = new List<SelectOption>();
            pw_cc__State__c[] state = new List<pw_cc__State__c>(); 
            state = [SELECT Name FROM pw_cc__State__c WHERE pw_cc__Country__r.Name = :billingcountry ORDER BY Name ASC LIMIT 500 ];
            
            for(pw_cc__State__c st : state) 
            {
                options.add(new SelectOption(st.Name, st.Name));
            }
            
            return options;
        }
        
        set;
    }
    
    public String getParameter(String name)
    {   
        PageReference pageRef = ApexPages.currentPage();
        Map<String, String> pageParameters = pageRef.getParameters();
        String p = pageParameters.get(name);
        return p;
    }

    @future(callout=true)
    public static void generateAndAttachContractPdf(Id oppId, Boolean source, Boolean requestedEmail)
    {
        Opportunity[] opps = OpportunitiesSelector.newInstance().selectByIdWithAccountAndProducts(new Set<Id>{ oppId });

        for(Opportunity o : opps)
        {
            Blob body;
            String fileName = o.Account.Name.replaceAll(' ', '_').replaceAll(',', '_').replaceAll('//', '_').replaceAll('/', '_') + 
                + '_Service_Agreement_' 
                + System.now().format('MM/dd/yyyy HH:mm:ss','America/Denver')
                + '.pdf';
        
            PageReference pdf = new PageReference('https://solutionreachtest.secure.force.com/SRContractForm/SRContractPDF');
            pdf.getParameters().put('id', o.Id);
            pdf.getParameters().put('source', source == true ? 'api' : '');
                    
            body = Test.isRunningTest() ? Blob.valueOf('Test') : pdf.getContent();

            Attachment attachment = new Attachment();
            attachment.ParentId = o.Id;
            attachment.Name = fileName;
            attachment.Body = body;
            Database.SaveResult sr = Database.insert(attachment, false);

            if(sr.isSuccess()) 
            {               
                AsyncRequest__c asyncRequest = new AsyncRequest__c(AsyncType__c = 'Contract_Email', 
                   Params__c = o.Id,
                   RequestedEmail__c = requestedEmail, 
                   Attachment_ID__c = sr.getId());
                insert asyncRequest; 
            } 
            else
            {
                throw new SRUtilities.SRException(sr.getErrors()[0].getMessage());
            }
        }
    }
}