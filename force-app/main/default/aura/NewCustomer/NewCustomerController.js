/**
 * Created by abishop on 9/17/18.
 */
({
    init: function(cmp, event, helper) {
        cmp.set("v.countryOptions", helper.getCountryOptions());
        cmp.set("v.provinceOptions", helper.getProvinceOptions(cmp.get("v.country")));
        helper.getComList(cmp, event, helper);
        helper.getPmsList(cmp, event, helper);
    },
    updateProvinces: function(cmp, event, helper) {
        cmp.set("v.provinceOptions", helper.getProvinceOptions(cmp.get("v.country")));
    },
    createPartnerRecord: function (cmp, event, helper) {
        console.log("Here in the Controller");
        cmp.set("v.showSpinner", true);
        helper.createPartnerRecord(cmp, event, helper);

    },
    handleChangePms : function (component, event, helper){
        component.set("v.account.Practice_Management_Software__c", event.getParam("value"));
        console.log('PMS', event.getParam("PMS"));
    },
    handleChangeCompetitor : function (component, event, helper){
        component.set("v.opportunity.Competitor__c", event.getParam("value"));
        console.log('COM', event.getParam("COM"));
    },
    handleChangePriceBook : function (component, event, helper) {
        component.set("v.opportunity.Pricebook2Id", event.getParam("value"));
        console.log('PB', event.getParam("PB"));
    },
    handleClick: function (cmp, event) {
        var address = cmp.find("myaddress");
        var isValid = address.checkValidity();
        if(isValid) {
            alert("Creating new address");
        }
        else {
            address.showHelpMessageIfInvalid();
        }
    },
})