/**
 * Created by abishop on 9/17/18.
 */
({
    countryProvinceMap: {
        US: [
            {'label': 'Alabama', 'value': 'Alabama'},
            {'label': 'Alaska', 'value': 'Alaska'},
            {'label': 'Arizona', 'value': 'Arizona'},
            {'label': 'Arkansas', 'value': 'Arkansas'},
            {'label': 'California', 'value': 'California'},
            {'label': 'Colorado', 'value': 'Colorado'},
            {'label': 'Connecticut', 'value': 'Connecticut'},
            {'label': 'Delaware', 'value': 'Delaware'},
            {'label': 'District of Columbia', 'value': 'District of Columbia'},
            {'label': 'Florida', 'value': 'Florida'},
            {'label': 'Georgia', 'value': 'Georgia'},
            {'label': 'Hawaii', 'value': 'Hawaii'},
            {'label': 'Idaho', 'value': 'Idaho'},
            {'label': 'Illinois', 'value': 'Illinois'},
            {'label': 'Indiana', 'value': 'Indiana'},
            {'label': 'Iowa', 'value': 'Iowa'},
            {'label': 'Kansas', 'value': 'Kansas'},
            {'label': 'Kentucky', 'value': 'Kentucky'},
            {'label': 'Louisiana', 'value': 'Louisiana'},
            {'label': 'Maine', 'value': 'Maine'},
            {'label': 'Maryland', 'value': 'Maryland'},
            {'label': 'Massachusetts', 'value': 'Massachusetts'},
            {'label': 'Michigan', 'value': 'Michigan'},
            {'label': 'Minnesota', 'value': 'Minnesota'},
            {'label': 'Mississippi', 'value': 'Mississippi'},
            {'label': 'Missouri', 'value': 'Missouri'},
            {'label': 'Montana', 'value': 'Montana'},
            {'label': 'Nebraska', 'value': 'Nebraska'},
            {'label': 'Nevada', 'value': 'Nevada'},
            {'label': 'New Hampshire', 'value': 'New Hampshire'},
            {'label': 'New Jersey', 'value': 'New Jersey'},
            {'label': 'New Mexico', 'value': 'New Mexico'},
            {'label': 'New York', 'value': 'New York'},
            {'label': 'North Carolina', 'value': 'North Carolina'},
            {'label': 'North Dakota', 'value': 'North Dakota'},
            {'label': 'Ohio', 'value': 'Ohio'},
            {'label': 'Oklahoma', 'value': 'Oklahoma'},
            {'label': 'Oregon', 'value': 'Oregon'},
            {'label': 'Pennsylvania', 'value': 'Pennsylvania'},
            {'label': 'Rhode Island', 'value': 'Rhode Islanda'},
            {'label': 'South Carolina', 'value': 'South Carolina'},
            {'label': 'South Dakota', 'value': 'South Dakota'},
            {'label': 'Tennessee', 'value': 'Tennessee'},
            {'label': 'Texas', 'value': 'Texas'},
            {'label': 'Utah', 'value': 'Utah'},
            {'label': 'Vermont', 'value': 'Vermont'},
            {'label': 'Virginia', 'value': 'Virginia'},
            {'label': 'Washington', 'value': 'Washington'},
            {'label': 'West Virginia', 'value': 'West Virginia'},
            {'label': 'Wisconsin', 'value': 'Wisconsin'},
            {'label': 'Wyoming', 'value': 'Wyoming'},
        ],
        CA: [
            {'label': 'Alberta', 'value': 'Alberta'},
            {'label': 'British Columia', 'value': 'British Columia'},
            {'label': 'New Brunswick', 'value': 'New Brunswick'},
            {'label': 'Newfoundland and Labrador', 'value': 'Newfoundland and Labrador'},
            {'label': 'Nova Scotia', 'value': 'Nova Scotia'},
            {'label': 'Northwest Territories', 'value': 'Northwest Territories'},
            {'label': 'Nunavut', 'value': 'Nunavut'},
            {'label': 'Ontario', 'value': 'Ontario'},
            {'label': 'Prince Edward Island', 'value': 'Prince Edward Island'},
            {'label': 'Quebec', 'value': 'Quebec'},
            {'label': 'Saskatchewan', 'value': 'Saskatchewan'},
            {'label': 'Yukon', 'value': 'Yukon'},
        ]
    },
    countryOptions: [
        {'label': 'United States', 'value': 'US'},
        {'label': 'Canada', 'value': 'CA'},
    ],
    getProvinceOptions: function(country) {
        return this.countryProvinceMap[country];
    },
    getCountryOptions: function() {
        return this.countryOptions;
    },

    createPartnerRecord: function (cmp, event, helper) {
        console.log("Made it to the Helper");
        var account = cmp.get("v.account");
        var contact = cmp.get("v.contact");
        var opportunity = cmp.get("v.opportunity");
        console.log("acct: ", account);
        console.log("con: ", contact);
        var action = cmp.get("c.createPartnerRecordApxc");
        action.setParams({
            acct : account,
            con : contact,
            opp : opportunity,
        });
        action.setCallback(this, function (response) {
            var name = response.getState();
            if (name === "SUCCESS") {
                console.log("success!");
                $A.get('e.force:refreshView').fire();
                cmp.set("v.showSpinner", false);
                cmp.find('notifLib').showToast({
                    "title": "Success!",
                    "message": "The Account has been created successfully.",
                    "variant": "success",
                    "mode": "dismissable"
                });
            }
            else {
                cmp.set("v.showSpinner", false);
                cmp.find('notifLib').showToast({
                    "title": "Fail",
                    "message": "The Account was not successfully created. Check to make sure all fields are correct.",
                    "variant": "error",
                    "mode": "dismissable"
                });
            }
        });

        $A.enqueueAction(action);
    },
    getComList : function(component) {
        var options = [
        ];
        var action = component.get("c.getPickListValuesIntoList");
        action.setParams({
            objectType: "Opportunity",
            selectedField: "Competitor__c"
        });
        action.setCallback(this, function(response) {
            var list = response.getReturnValue();
            list.forEach(function(element) {
                options.push({ value: element, label: element });
            });
            component.set("v.comList", options);
        });
        $A.enqueueAction(action);
    },
    getPmsList: function (component, event, helper) {
        var action = component.get("c.getNonBlacklistedPms");

        action.setCallback(this, function (response) {

            console.log('PMS List Returned',response.getReturnValue());
            var name = response.getState();
            if (name === "SUCCESS") {
                component.set("v.pmsList", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);

    }

})