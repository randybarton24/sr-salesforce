@isTest
private class AddendumLineItems_Test 
{	
    @isTest static void test_onBeforeInsert()
    {        
        Addendum_Line_Item__c ali = (Addendum_Line_Item__c) TestUtilities2.newAddendumLineItems()
            .toSObject();

        AddendumLineItems addendumLineItems = new AddendumLineItems(new List<Addendum_Line_Item__c>{ ali });
        addendumLineItems.onBeforeInsert();
    }

    @isTest static void test_onBeforeUpdate()
    {                
        Addendum_Line_Item__c ali = (Addendum_Line_Item__c) TestUtilities2.newAddendumLineItems()
            .toSObject();
        
        Addendum_Line_Item__c existingAli = (Addendum_Line_Item__c) TestUtilities2.existingAddendumLineItem(ali)                        
            .toSObject();

        AddendumLineItems addendumLineItems = new AddendumLineItems(new List<Addendum_Line_Item__c>{ ali });
        addendumLineItems.onBeforeUpdate(new Map<Id, SObject>(new List<Addendum_Line_Item__c>()));        
    }

	@isTest static void test_setRecordType()
	{
		sfab_FabricatedSObject pr = TestUtilities2.newProduct() 
            .setField(Product2.Family, 'SR Platform');             
        Product2 prod = (Product2) pr.toSObject();

        sfab_FabricatedSObject a = TestUtilities2.newAsset()
            .setField(Asset.Product2Id, prod.Id)        
            .setParent('Product2', pr);
        Asset ast = (Asset) a.toSObject();

        Addendum_Line_Item__c ali = (Addendum_Line_Item__c) TestUtilities2.newAddendumLineItems()
        	.setField(Addendum_Line_Item__c.RecordTypeId, SRUtilities.getRecordTypeMap('Addendum_Line_Item__c').get('SR').getRecordTypeId())        	
        	.setField(Addendum_Line_Item__c.Asset__c, ast.Id)
        	.setParent('Asset__r', a)
        	.toSObject();

        Addendum_Line_Item__c existingAli = (Addendum_Line_Item__c) TestUtilities2.existingAddendumLineItem(ali)
            .setField(Addendum_Line_Item__c.RecordTypeId, SRUtilities.getRecordTypeMap('Addendum_Line_Item__c').get('ANY').getRecordTypeId())        	        	
        	.toSObject();

        AddendumLineItems addendumLineItems = new AddendumLineItems(new List<Addendum_Line_Item__c>{ ali });
        addendumLineItems.setRecordType(ali, existingAli);

        System.assertEquals(ali.RecordTypeId, SRUtilities.getRecordTypeMap('Addendum_Line_Item__c').get('ANY').getRecordTypeId());        
	}

    @isTest static void test_updateSnippets()
    {        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        sfab_FabricatedSObject proSub = TestUtilities2.newRecurSoftProductSubscription() 
            .setField(RecurSoft__Product_Subscription__c.RecurSoft__Unit_Price__c, 127.9);              
        RecurSoft__Product_Subscription__c proSub2 = (RecurSoft__Product_Subscription__c) proSub.toSObject();

        sfab_FabricatedSObject a = TestUtilities2.newAsset()
            .setField(Asset.Price, 127.9);                        
        Asset ast = (Asset) a.toSObject();

        Addendum_Line_Item__c ali = (Addendum_Line_Item__c) TestUtilities2.newAddendumLineItems()            
            .setField(Addendum_Line_Item__c.RecordTypeId, SRUtilities.getRecordTypeMap('Addendum_Line_Item__c').get('ANY').getRecordTypeId())            
            .setField(Addendum_Line_Item__c.Header_Text__c, 'Addendum_Line_Item__c')        
            .setField(Addendum_Line_Item__c.Intro_Language_Text__c, 'Addendum_Line_Item__c')
            .setField(Addendum_Line_Item__c.Confidentiality_Clause_Text__c, 'Addendum_Line_Item__c')
            .setField(Addendum_Line_Item__c.Outro_Language_Text__c, 'Addendum_Line_Item__c')
            .setField(Addendum_Line_Item__c.Defer_Billing_Text__c, 'Addendum_Line_Item__c')
            .setField(Addendum_Line_Item__c.Defer_Billing__c, true)
            .setField(Addendum_Line_Item__c.Deferred_Months__c, 3)
            .setField(Addendum_Line_Item__c.Waive_Billing_Text__c, 'Addendum_Line_Item__c')
            .setField(Addendum_Line_Item__c.Waive_Billing__c, true)
            .setField(Addendum_Line_Item__c.Waived_Months__c, 3)
            .setField(Addendum_Line_Item__c.NewTerm_Text__c, 'Addendum_Line_Item__c')
            .setField(Addendum_Line_Item__c.NewTerm__c, 3)
            .setField(Addendum_Line_Item__c.NewTerm_Months__c, 3)
            .setField(Addendum_Line_Item__c.New_Next_Invoice_Date__c, Date.today())
            .setField(Addendum_Line_Item__c.New_MSF__c, 12)
            .setField(Addendum_Line_Item__c.New_Price__c, 3)                                    
            .setField(Addendum_Line_Item__c.Extend_Satisfaction_Period_Text__c, 'Addendum_Line_Item__c')
            .setField(Addendum_Line_Item__c.Extend_Satisfaction_Period__c, true)
            .setField(Addendum_Line_Item__c.Trial_End_Date__c, Date.today())        
            .setField(Addendum_Line_Item__c.Asset__c, ast.Id)
            .setParent('Asset__r', a)
            .toSObject();

        Map<String, String> snipText = new Map<String, String>{ 
            'ANY_Waive_Billing__c' =>'<ul><li>Monthly billing shall be waived for {{Waived_Months__c}} monthly payment(s).  Billing will resume with the subsequently due payment on {{New_Next_Invoice_Date__c}}.</li></ul>'
        };

        AddendumLineItemsSelector mockSelector = (AddendumLineItemsSelector) mocks.mock(AddendumLineItemsSelector.class);

        mocks.startStubbing();
        mocks.when(mockSelector.getSObjectType2())
            .thenReturn(Addendum_Line_Item__c.SObjectType);
        mocks.when(mockSelector.getSnippetMap())
            .thenReturn(snipText);
        mocks.stopStubbing();

        Application.Selector.setMock(mockSelector);

        Addendum_Line_Item__c existingAli = (Addendum_Line_Item__c) TestUtilities2.existingAddendumLineItem(ali)            
            .toSObject();

        AddendumLineItems addendumLineItems = new AddendumLineItems(new List<Addendum_Line_Item__c>{ ali });
        addendumLineItems.updateSnippets(ali, existingAli);      

        System.assert(ali.Waive_Billing_Text__c.contains('Monthly billing shall be waived for ' + ali.Waived_Months__c));
        System.assert(ali.Waive_Billing_Text__c.contains('due payment on ' + Datetime.now().format('MMMM d, YYYY')));
        System.assert(!ali.Waive_Billing_Text__c.contains('{{'));
        System.assert(!ali.Waive_Billing_Text__c.contains('}}'));             
    }
	
    @isTest static void test_setNewNextInvoiceDate()
    {        
        sfab_FabricatedSObject proSub = TestUtilities2.newRecurSoftProductSubscription() 
            .setField(RecurSoft__Product_Subscription__c.RecurSoft__Unit_Price__c, 127.9)
            .setField(RecurSoft__Product_Subscription__c.Next_Payment_Date__c, Date.today());              
        RecurSoft__Product_Subscription__c prodSub = (RecurSoft__Product_Subscription__c) proSub.toSObject();

        sfab_FabricatedSObject a = TestUtilities2.newAsset()
            .setField(Asset.Next_Payment_Date__c, Date.today());
        Asset ast = (Asset) a.toSObject();

        Addendum_Line_Item__c ali = (Addendum_Line_Item__c) TestUtilities2.newAddendumLineItems()            
            .setField(Addendum_Line_Item__c.NewTerm__c, false)
            .setField(Addendum_Line_Item__c.Defer_Billing__c, false)
            .setField(Addendum_Line_Item__c.Waive_Billing__c, true)
            .setField(Addendum_Line_Item__c.New_Next_Invoice_Date__c, Date.today())
            .setField(Addendum_Line_Item__c.Current_Next_Invoice_Date__c, ast.Next_Payment_Date__c)
            .setField(Addendum_Line_Item__c.Deferred_Months__c, 2) 
            .setField(Addendum_Line_Item__c.Waived_Months__c, 3)
            .setParent('Asset__r', a)            
            .toSObject();

        Addendum_Line_Item__c existingAli = (Addendum_Line_Item__c) TestUtilities2.existingAddendumLineItem(ali)            
            .setField(Addendum_Line_Item__c.NewTerm__c, false)
            .setField(Addendum_Line_Item__c.Defer_Billing__c, true)
            .setField(Addendum_Line_Item__c.Waive_Billing__c, false)
            .toSObject();

        AddendumLineItems addendumLineItems = new AddendumLineItems(new List<Addendum_Line_Item__c>{ ali });
        addendumLineItems.setNewNextInvoiceDate(ali, existingAli);
        
        System.assertEquals(ali.New_Next_Invoice_Date__c , ali.Current_Next_Invoice_Date__c.addMonths(Integer.valueOf(ali.Waived_Months__c)));        
    }

    @isTest static void test_setNewRenewalDate()
    {        
        sfab_FabricatedSObject proSub = TestUtilities2.newRecurSoftProductSubscription() 
            .setField(RecurSoft__Product_Subscription__c.RecurSoft__Unit_Price__c, 127.9)
            .setField(RecurSoft__Product_Subscription__c.Contract_End_Date__c, Date.today());            
        RecurSoft__Product_Subscription__c prodSub = (RecurSoft__Product_Subscription__c) proSub.toSObject();

        sfab_FabricatedSObject a = TestUtilities2.newAsset()
            .setField(Asset.Contract_End_Date__c, Date.today());
        Asset ast = (Asset) a.toSObject();

        Addendum_Line_Item__c ali = (Addendum_Line_Item__c) TestUtilities2.newAddendumLineItems()            
            .setField(Addendum_Line_Item__c.NewTerm__c, true)
            .setField(Addendum_Line_Item__c.Defer_Billing__c, false)
            .setField(Addendum_Line_Item__c.Waive_Billing__c, false)
            .setField(Addendum_Line_Item__c.New_Renewal_Date__c, Date.today())            
            .setField(Addendum_Line_Item__c.Deferred_Months__c, 2) 
            .setField(Addendum_Line_Item__c.NewTerm_Months__c, 12)
            .setParent('Asset__r', a)           
            .toSObject();

        Addendum_Line_Item__c existingAli = (Addendum_Line_Item__c) TestUtilities2.existingAddendumLineItem(ali)            
            .setField(Addendum_Line_Item__c.NewTerm__c, true)
            .setField(Addendum_Line_Item__c.Defer_Billing__c, true)
            .setField(Addendum_Line_Item__c.Waive_Billing__c, false)
            .toSObject();

        AddendumLineItems addendumLineItems = new AddendumLineItems(new List<Addendum_Line_Item__c>{ ali });
        addendumLineItems.setNewRenewalDate(ali, existingAli);
        
        System.assertEquals(ali.New_Renewal_Date__c , Date.today().addMonths(Integer.valueOf(ali.NewTerm_Months__c)).addDays(-1));        
    }

    @isTest static void test_setNewContractStartDate()
    {                
        sfab_FabricatedSObject proSub = TestUtilities2.newRecurSoftProductSubscription() 
            .setField(RecurSoft__Product_Subscription__c.RecurSoft__Unit_Price__c, 127.9)
            .setField(RecurSoft__Product_Subscription__c.Next_Payment_Date__c, Date.today());            
        RecurSoft__Product_Subscription__c prodSub = (RecurSoft__Product_Subscription__c) proSub.toSObject();

        sfab_FabricatedSObject a = TestUtilities2.newAsset()
            .setField(Asset.Most_Recent_Contract_Signed_Date__c, Date.today())
            .setField(Asset.Next_Payment_Date__c, Date.today());
        Asset ast = (Asset) a.toSObject();

        Addendum_Line_Item__c ali = (Addendum_Line_Item__c) TestUtilities2.newAddendumLineItems()            
            .setField(Addendum_Line_Item__c.Original_Agreement_Date__c, ast.Most_Recent_Contract_Signed_Date__c)
            .setField(Addendum_Line_Item__c.NewTerm__c, true)
            .setField(Addendum_Line_Item__c.New_Contract_Start_Date__c, Date.today())
            .setField(Addendum_Line_Item__c.Current_Next_Invoice_Date__c, ast.Next_Payment_Date__c)            
            .setParent('Asset__r', a)           
            .toSObject();

        Addendum_Line_Item__c existingAli = (Addendum_Line_Item__c) TestUtilities2.existingAddendumLineItem(ali)                        
            .toSObject();

        AddendumLineItems addendumLineItems = new AddendumLineItems(new List<Addendum_Line_Item__c>{ ali });
        addendumLineItems.setNewContractStartDate(ali, existingAli);
        
        System.assertEquals(ali.New_Contract_Start_Date__c , Date.today());        
    }
	
    @isTest static void test_setNewPrice()
    {        
        sfab_FabricatedSObject proSub = TestUtilities2.newRecurSoftProductSubscription() 
            .setField(RecurSoft__Product_Subscription__c.RecurSoft__Unit_Price__c, 127.9);              
        RecurSoft__Product_Subscription__c prodSub = (RecurSoft__Product_Subscription__c) proSub.toSObject();

        sfab_FabricatedSObject a = TestUtilities2.newAsset()
            .setField(Asset.Price, 127.9);
        Asset ast = (Asset) a.toSObject();

        Addendum_Line_Item__c ali = (Addendum_Line_Item__c) TestUtilities2.newAddendumLineItems()            
            .setField(Addendum_Line_Item__c.New_MSF__c, 12)
            .setField(Addendum_Line_Item__c.New_Price__c, 12)
            .setParent('Asset__r', a)                    
            .toSObject();

        Addendum_Line_Item__c existingAli = (Addendum_Line_Item__c) TestUtilities2.existingAddendumLineItem(ali)                        
            .toSObject();

        AddendumLineItems addendumLineItems = new AddendumLineItems(new List<Addendum_Line_Item__c>{ ali });
        addendumLineItems.setNewPrice(ali, existingAli);

        System.assertEquals(ali.New_Price__c , ali.New_MSF__c);        
    }

    @isTest static void test_setNewTrialEndDate()
    {        
        sfab_FabricatedSObject proSub = TestUtilities2.newRecurSoftProductSubscription() 
            .setField(RecurSoft__Product_Subscription__c.RecurSoft__Unit_Price__c, 127.9)
            .setField(RecurSoft__Product_Subscription__c.Trial_End_Date__c, Date.today());              
        RecurSoft__Product_Subscription__c prodSub = (RecurSoft__Product_Subscription__c) proSub.toSObject();

        sfab_FabricatedSObject a = TestUtilities2.newAsset()
            .setField(Asset.Most_Recent_Contract_Signed_Date__c, Date.today())
            .setField(Asset.Trial_End_Date__c, Date.today());
        Asset ast = (Asset) a.toSObject();

        Addendum_Line_Item__c ali = (Addendum_Line_Item__c) TestUtilities2.newAddendumLineItems()            
            .setField(Addendum_Line_Item__c.Trial_End_Date__c, Date.today())
            .setField(Addendum_Line_Item__c.New_Trial_End_Date__c, Date.today())
            .setField(Addendum_Line_Item__c.Waive_Satisfaction_and_Send_Promo__c, null)
            .setField(Addendum_Line_Item__c.Original_Agreement_Date__c, ast.Most_Recent_Contract_Signed_Date__c)
            .setParent('Asset__r', a)                    
            .toSObject();

        Addendum_Line_Item__c existingAli = (Addendum_Line_Item__c) TestUtilities2.existingAddendumLineItem(ali)                        
            .toSObject();

        AddendumLineItems addendumLineItems = new AddendumLineItems(new List<Addendum_Line_Item__c>{ ali });
        addendumLineItems.setNewTrialEndDate(ali, existingAli);
        
        System.assertEquals(ali.New_Trial_End_Date__c , ali.Original_Agreement_Date__c);        
    }

    @isTest static void test_setNewTrialPeriodDays()
    {        
        sfab_FabricatedSObject proSub = TestUtilities2.newRecurSoftProductSubscription() 
            .setField(RecurSoft__Product_Subscription__c.RecurSoft__Unit_Price__c, 0)            
            .setField(RecurSoft__Product_Subscription__c.Trial_End_Date__c, Date.today());            
        RecurSoft__Product_Subscription__c prodSub = (RecurSoft__Product_Subscription__c) proSub.toSObject();

        sfab_FabricatedSObject a = TestUtilities2.newAsset()            
            .setField(Asset.Trial_End_Date__c, Date.today());        
        Asset ast = (Asset) a.toSObject();

        Addendum_Line_Item__c ali = (Addendum_Line_Item__c) TestUtilities2.newAddendumLineItems()                        
            .setField(Addendum_Line_Item__c.New_Trial_End_Date__c, Date.today().addMonths(2))            
            .setField(Addendum_Line_Item__c.New_Contract_Start_Date__c, Date.today())
            .setField(Addendum_Line_Item__c.New_Trial_Period_Days__c, 9) 
            .setField(Addendum_Line_Item__c.Current_Trial_End_Date__c, ast.Trial_End_Date__c)            
            .setParent('Asset__r', a)                   
            .toSObject();

        Addendum_Line_Item__c existingAli = (Addendum_Line_Item__c) TestUtilities2.existingAddendumLineItem(ali)                        
            .toSObject();

        AddendumLineItems addendumLineItems = new AddendumLineItems(new List<Addendum_Line_Item__c>{ ali });
        addendumLineItems.setNewTrialPeriodDays(ali, existingAli);
        
        System.assertEquals(ali.New_Trial_Period_Days__c , ali.New_Contract_Start_Date__c.daysBetween(ali.New_Trial_End_Date__c));        
        System.debug(ali.New_Trial_Period_Days__c);
        System.debug(ali.New_Contract_Start_Date__c.daysBetween(ali.New_Trial_End_Date__c));
    }

    @isTest static void test_setNewContractTermMonths()
    {        
        sfab_FabricatedSObject a = TestUtilities2.newAsset()            
            .setField(Asset.Most_Recent_Contract_Signed_Date__c, Date.today());                
        Asset ast = (Asset) a.toSObject();

        Addendum_Line_Item__c ali = (Addendum_Line_Item__c) TestUtilities2.newAddendumLineItems()                        
            .setField(Addendum_Line_Item__c.Original_Agreement_Date__c, ast.Most_Recent_Contract_Signed_Date__c)
            .setField(Addendum_Line_Item__c.New_Contract_Start_Date__c, Date.today())            
            .setField(Addendum_Line_Item__c.New_Contract_Term_Months__c, 2)          
            .setField(Addendum_Line_Item__c.New_Renewal_Date__c, Date.today())  
            .setParent('Asset__r', a)                    
            .toSObject();

        Addendum_Line_Item__c existingAli = (Addendum_Line_Item__c) TestUtilities2.existingAddendumLineItem(ali)                        
            .toSObject();

        AddendumLineItems addendumLineItems = new AddendumLineItems(new List<Addendum_Line_Item__c>{ ali });
        addendumLineItems.setNewContractTermMonths(ali, existingAli);
       
        System.assertEquals(ali.New_Contract_Term_Months__c , ali.New_Contract_Start_Date__c.monthsBetween(ali.New_Renewal_Date__c));        
    }

    @isTest static void test_setNewFreeMonths()
    {        
        Addendum_Line_Item__c ali = (Addendum_Line_Item__c) TestUtilities2.newAddendumLineItems()                    
            .setField(Addendum_Line_Item__c.New_Free_Months__c, 12)
            .setField(Addendum_Line_Item__c.New_Free_Month_Setting__c, ' tester')
            .setField(Addendum_Line_Item__c.Deferred_Months__c, 5)
            .setField(Addendum_Line_Item__c.Waived_Months__c, 4)
            .toSObject();

        Addendum_Line_Item__c existingAli = (Addendum_Line_Item__c) TestUtilities2.existingAddendumLineItem(ali)                        
            .toSObject();

        AddendumLineItems addendumLineItems = new AddendumLineItems(new List<Addendum_Line_Item__c>{ ali });
        addendumLineItems.setNewFreeMonths(ali, existingAli);
        
        System.assertEquals(ali.New_Free_Months__c , ali.Months_To_Add__c);
    }
}