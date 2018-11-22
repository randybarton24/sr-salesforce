({
    recordUpdate : function(component) {       
        var opportunity = component.get("v.opportunity");
        var currentTime = new Date();
        var beforeDate = new Date(currentTime);
        beforeDate.setDate(beforeDate.getDate() + (-30));        
        var error = new Array();
        
        if(opportunity != null){
            if(opportunity.RecurSoft__Bill_to_Account__c === null){ 
                error.push('Please specify the Bill to Account');
            }
            if(opportunity.RecurSoft__Billing_Contact__c === null){
                error.push('Please specify the Biling Contact');
            }
            if(opportunity.RecurSoft__Initial_Contract_Term__c === null || opportunity.RecurSoft__Initial_Contract_Term__c === 0){
                error.push('Please specify the Initial Contract Term (months)');
            }
            if(opportunity.Contract_Signed__c === true){
                error.push('Contract is already signed');
            }
            if(opportunity.Account.Practice_Management_Software__c === null){
                error.push('Please specify a Management System on the Account');
            }           
            if( opportunity.Account.Industry === null){
                error.push('Please specify Vertical on the Account');
            }
            if(opportunity.RecurSoft__Bill_to_Account__r.Industry === null){
                error.push('Please specify Vertical on the Bill to Account');
            }
            if(opportunity.RecurSoft__Intacct_Entity__c === null){
                error.push('Please populate the Intacct Entity field');
            }                               
            if(opportunity.Approval_Level_Required__c != null && opportunity.Approval_Level_Required__c > 0) {
                error.push('This Opportunity has pricing or free months that require approval prior to sending the contract');
            }            
            if((opportunity.Sales_Engineer_Call_Completed__c === null 
                || opportunity.Sales_Engineer_Call_Completed__c < beforeDate) && 
               (opportunity.Account.Practice_Management_Software__c != null && 
                opportunity.Account.Practice_Management_Software__r.Sales_Engineer_Call_Needed__c) &&
               opportunity.RecordType.Name === 'New Practice Business' &&
               opportunity.Owner.Profile.Name != 'Support' &&
               opportunity.Owner.Profile.Name != 'Support Team Leads' &&
               opportunity.Owner.Profile.Name != 'Support Manager'){
                error.push('This Management System requires a Sales Engineer call to be completed within the last 30 days before sending the contract.');
            }
            if (opportunity.Sync_Availability__c === 'Blacklist - DO NOT SELL'){
                    error = 'This account is using a Management System on the Blacklist. DO NOT SELL!';
            }
        }        
        if (error.length === 0){
            component.set("v.validationResult", ""); 
        } 
        else{
            component.set("v.validationResult", error); 
        }          
    },   

    copyClick : function(cmp, event) {     
             
        var urlToCopy = "https://solutionreachtest.secure.force.com/SRContractForm?id=" + cmp.get("v.opportunity.Id");      
        var aux = document.createElement("input");       
        aux.setAttribute("value", urlToCopy);          
        document.body.appendChild(aux);         
        aux.select();         
        document.execCommand("copy");
        document.body.removeChild(aux);

        var toastEvent = $A.get("e.force:showToast");        
        toastEvent.setParams({
            "title": "Success!",
            "message": "The Contract URL has been copied to your clipboard"
        });        
        toastEvent.fire();
    },

    openClick : function(cmp, event) {            
        window.open("https://solutionreachtest.secure.force.com/SRContractForm?id=" + cmp.get("v.opportunity.Id"));              
    }
})