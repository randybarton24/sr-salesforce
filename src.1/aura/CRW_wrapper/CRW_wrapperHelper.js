({
    getRecommendationsManager : function(cmp) {
        return cmp.find("recommendationsManager");
    },

    getRecommendationInputs : function(cmp) {
        return cmp.find("fieldsContainer").find({instancesOf: "c:CRW_inputField"})
    },

    hasOwnPropertyCaseInsensitive : function(object1, property1) {
        var props = [];
        for (var i in object1) if (object1.hasOwnProperty(i)) props.push(i);
        var prop;
        while (prop = props.pop()) if (prop.toString().toLowerCase() === property1.toString().toLowerCase()) return prop;
        return '';
    },

    createRecommendationInputs: function(cmp, fieldNames, recommendationsMap, fieldControllingMap, recommendationCustomSettings, fieldsAllValues, fieldTypes, allPickListOptions, actualValuesByField) {
        if(!recommendationsMap) return;

        var fieldToTopValue = new Map();
	    var fieldsSorted = cmp.get("v.fieldSortedByKey");
        var customFieldForAggregate = 0;
        var customFieldForValueAbove = 0;
        var customFieldForAutomaticSelection = 0;

        if(!$A.util.isUndefinedOrNull(recommendationCustomSettings) )
        {
            customFieldForAggregate = recommendationCustomSettings['Recommend_if_aggregate_score_above__c'];
            customFieldForValueAbove = recommendationCustomSettings['Recommend_if_single_score_above__c'];
            customFieldForAutomaticSelection = recommendationCustomSettings['Top_value_badge_if_score_above__c'];
        }
        var inputComponents = [];
		var fieldLabel;

        for (var fieldName in fieldsSorted) {
            fieldName = this.hasOwnPropertyCaseInsensitive(recommendationsMap,fieldsSorted[fieldName]);

			if (fieldName !== '') {
				var fKey = fieldName.toLowerCase();
				fieldLabel = fieldNames[fKey]!== undefined ? fieldNames[fKey]  : fieldName;
                var actualSum = 0;
                var highestScoreActual = 0;
                var listId = [];
                var listRecommendedValues = new Set();
                var listRecommendedValuesBelowDep = new Set();

                for (var i = recommendationsMap[fieldName].length -1; i >= 0 ; i--) {
                    var addToSet = true;
                    if(recommendationsMap[fieldName][i].score > highestScoreActual)
                    {
                        highestScoreActual = recommendationsMap[fieldName][i].score;
                    }

                    if(customFieldForValueAbove > 0 && recommendationsMap[fieldName][i].score <= customFieldForValueAbove)
                    {
                        addToSet = false;
                        listRecommendedValuesBelowDep.add(recommendationsMap[fieldName][i].value);
                        recommendationsMap[fieldName].splice(i,1);
                    }
                    else{
                        actualSum += recommendationsMap[fieldName][i].score;
                    }

                    if(addToSet){
                        listRecommendedValues.add(recommendationsMap[fieldName][i].value);
                    }
                }

                var showDisabled = false;
                var allRecommendations = recommendationsMap[fieldName];
                var recommendationsToSend = allRecommendations;
                if(customFieldForAggregate === 0  || customFieldForAggregate > 0 && actualSum > customFieldForAggregate && recommendationsMap[fieldName].length !== 0){
                    showDisabled = false;
                }
                else
                {
                    showDisabled = true;
                    allRecommendations = '';
                }

                var showImg = false;
                if(customFieldForAutomaticSelection > 0 && highestScoreActual > customFieldForAutomaticSelection)
                {
                    showImg = true && !showDisabled;
                }

                // resolve controlling fields for this input
				var controlledBy = fieldControllingMap[fKey];

                //resolve all values for this fields
				var allValues=[];
                var mapValueScore = {};
				if ($A.util.isUndefinedOrNull(controlledBy)) {
                    var recoValues = new Set();
                    for(var r in allRecommendations) {
                        mapValueScore[allRecommendations[r].value] = allRecommendations[r].score;
                        recoValues.add(allRecommendations[r].value);
                    }

                    var allValuesTMP = fieldsAllValues[fKey];
                    for(var k in allValuesTMP) {
                        if (!listRecommendedValues.has(k)){
							var currentScore = (mapValueScore[allValuesTMP[k]] != undefined) ? mapValueScore[allValuesTMP[k]] : 0;
						    allValues.push({'value': allValuesTMP[k],'score':currentScore});
						}
                    }

                    // Store highest value to use in dependent fields.
                    var highestValue;
                    var highestscore = -1;
                    var rec = recommendationsMap[fieldName];
                    if(rec.length > 0 ) {
                        for (var j = 0; j < rec.length; j++) {
                            if (rec[j].score > highestscore) {
                                highestValue = rec[j].value;
                                highestscore = rec[j].score;
                            }
                        }
                    }
                    else
                    {
                        recommendationsToSend = null;
                        for (var p = 0; p < allValues.length; p++) {
                            if (allValues[p].score > highestscore) {
                                highestValue = allValues[p].value;
                                highestscore = allValues[p].score;
                            }
                        }
                    }

                    fieldToTopValue.set(fieldName, highestValue);
				} else {
                    if (!$A.util.isUndefinedOrNull(fieldToTopValue.get(controlledBy.toString()))) {
                        var highestControllingValue = fieldToTopValue.get(controlledBy.toString());
                        //---------------- get the picklist values for the parent value selected to filter later -------------//
                        var listOfFieldsForControllerValue = [];
                        for ( var kee in allPickListOptions[fieldName.toLowerCase()][highestControllingValue])
                        {
                            listOfFieldsForControllerValue[allPickListOptions[fieldName.toLowerCase()][highestControllingValue][kee]] = "";
                        }
                        var controlledValues = [];
                        var thisPickListOptions = allPickListOptions[fieldName.toLowerCase()];
                        for (var key in thisPickListOptions) {
                            if (key === highestControllingValue) {
                                var valueOption = thisPickListOptions[key].toString();
                                var splitted = valueOption.split(',');

                                if (splitted.length > 0) {
                                    for (var l = 0; l < splitted.length; l++) {
                                        controlledValues.push(splitted[l]);
                                    }
                                } else {
                                    controlledValues.push(valueOption);
                                }
                            }
                        }

                        var finalValues = [];
                        for (var m = 0; m < allRecommendations.length; m++) {
                            for (var n = 0; n < controlledValues.length; n++) {
                                if (allRecommendations[m].value === controlledValues[n].toString()) {
                                    finalValues.push(allRecommendations[m]);
                                }
                            }
                        }

                        //----------Logic to set the correct dependent values on load -----------------//
                        if(!$A.util.isUndefinedOrNull(finalValues))
                        {
                            var finalTopList = [];
                            for(var keyFV in finalValues)
                            {
                                finalTopList.push(finalValues[keyFV].value);
                            }

                            for (var valueCV in listOfFieldsForControllerValue) {
                                if(finalTopList.indexOf(valueCV) <0 ){
                                    allValues.push({'value': valueCV,'score':0});
                                }
                            }
                        }
                        else{
                            for (var valueCVE in listOfFieldsForControllerValue) {
                                allValues.push({'value': valueCVE,'score':0});
                            }
                        }

                        //--------------------------------------------------------//
                        recommendationsToSend = finalValues;

                        var highestValueE;
                        var highestscoreE =-1;
                        for (var o = 0; o < finalValues.length; o++) {
                            if (finalValues[o].score > highestscoreE) {
                                highestValueE = finalValues[o].value;
                                highestscoreE = finalValues[o].score;
                            }
                        }
                        //----------in case of only exist allvalues and not any recommended value we must set the selectedvalue for the next field-----
                        if(highestscoreE <= 0 && allValues.length > 0){
                            fieldToTopValue.set(fieldName, allValues[0].value);

                        }
                        else
                        {
                            fieldToTopValue.set(fieldName,highestValueE);
                        }
                    }
                    else
                    {
                        if($A.util.isUndefinedOrNull(allPickListOptions[fieldName.toLowerCase()][fieldToTopValue.get(controlledBy.toString())]))
                        {
                            recommendationsToSend = [];

                            allValues = [];
                            showDisabled = true;
                        }
                    }
                }

                var fieldType = fieldTypes[fKey];

                var selectedValueForThisField = actualValuesByField[fieldName];
                var inputCmp = [
                   "c:CRW_inputField",
                   {"aura:id": fieldName,
                    "fieldName": fieldName,
                    "fieldLabel": fieldLabel,
					"fieldType" :fieldType,
					"controlledBy" : controlledBy,
                    "recommendations": recommendationsToSend,
                    "allRecommendations": allRecommendations,
					"allValues" : allValues,
                    "showDisabled" : showDisabled,
                    "showImg" : showImg,
                    "picklistOptions" : allPickListOptions[fieldName.toLowerCase()],
                    "selectedValueOnTheOrg" : selectedValueForThisField
                    }
                 ];
                 inputComponents.push(inputCmp);
            }
        }

        var recommendationsAvailable = cmp.get("v.recommendationsAvailable");
        console.log('recommendationsAvailable: ' + recommendationsAvailable);
        if(recommendationsAvailable){
            $A.createComponents(inputComponents,
                function(components, status, statusMessagesList){
                    if(status === "SUCCESS"){
                        var fieldsContainer = cmp.find("fieldsContainer");
                        if (fieldsContainer.isValid()){
                            var body = fieldsContainer.get("v.body");
                            Array.prototype.push.apply(body, components);
                            fieldsContainer.set("v.body", body);
                        }
                    }
                }
            );
        }
    },

    updateRecord: function(cmp, recordId, fieldsUpdateMap, recommendationsUpdateMap){
        if(!fieldsUpdateMap) return;

        var helper = this;
        var action = cmp.get("c.updateRecord");

        action.setParams({ updatedRecordId: recordId, valuesMap: fieldsUpdateMap});
        action.setCallback(this, function(response) {
            if(!cmp.isValid()) return;
            var state = response.getState();

            if (state === "SUCCESS") {
                //Consume recommendations
                if (recommendationsUpdateMap) {
                    var recommendationsManagerCmp = helper.getRecommendationsManager(cmp);
                    recommendationsManagerCmp && recommendationsManagerCmp.updateRecommendations(recommendationsUpdateMap);
                }

                //Fire updated event
                var responseMap = response.getReturnValue();
				if (responseMap.success === "true"){
					var updatedEvent = $A.get("e."+responseMap.namespace+":CRW_recommendationsUpdated");
	                updatedEvent.setParams({recordId : responseMap.recordId});
	                updatedEvent.fire();

					var toastCmp =  cmp.find("toastNotif");
	 				toastCmp.set("v.title",'Fields Succesfully updated');
	 				toastCmp.set("v.description",'the case was updated');
					toastCmp.set("v.className",'');
					toastCmp.set("v.severity",'info');
				}else{
					var toastCmpE =  cmp.find("toastNotif");
				   	toastCmpE.set("v.title",'Error while updating fields');
				   	toastCmpE.set("v.description",responseMap.errorMsg);
					toastCmpE.set("v.className",'');
					toastCmpE.set("v.severity",'error');
				}

            }
			else if (state === "INCOMPLETE") {
			   // do something
		   }
		   else if (state === "ERROR") {
			   var errors = response.getError();
			   var errrorMsg = '';
			   if (errors) {
				   if (errors[0] && errors[0].message) {
					   errrorMsg += "Error message: " +
								errors[0].message;
				   }
			   } else {
				   console.log("Unknown error");
			   }

				//TODO: We probably want to show a success message
				var toastCmpEI =  cmp.find("toastNotif");
				toastCmpEI.set("v.title",'Error while updating fields');
				toastCmpEI.set("v.description",errrorMsg);
				toastCmpEI.set("v.className",'');
				toastCmpEI.set("v.severity",'Error');
		   }
        });
        $A.enqueueAction(action);
    },

	resolveLabelsAndDependencies: function(cmp, event, helper){
        var helperRLD = this;
        var act = cmp.get("c.resolveLabelsAndDependencies");
		var recommendationsMap = cmp.get("v.recommendationsMap");
		var fieldList = [];

        act.setParams({ "recordId" : cmp.get("v.recordId") , "recommendationsMap": JSON.stringify(recommendationsMap) });

        act.setCallback(this, function(response) {
            if(!cmp.isValid()) return;
            var state = response.getState();
            if (state === "SUCCESS") {
                //Fire updated event
                var responseMap = response.getReturnValue();
				var fieldControllingMap = JSON.parse(responseMap.fieldControllingMap);
				var recommendationCustomSettings = JSON.parse(responseMap.recommendationCustomSettings);
				var fieldNames = JSON.parse(responseMap.fieldNames);
				var fieldsAllValues = JSON.parse(responseMap.fieldsAllValues);
				var fieldTypes = JSON.parse(responseMap.fieldTypes);
                var fieldSortedByKey = JSON.parse(responseMap.fieldSortedByKey);
                var allPickListOptions = JSON.parse(responseMap.allPickListOptions);
                var actualValuesByField = JSON.parse(responseMap.actualValuesByField);
                var valueToRecommendationId = JSON.parse(responseMap.valueToRecommendationId);
                cmp.set("v.fieldSortedByKey", fieldSortedByKey);
                cmp.set("v.valueToRecommendationId", valueToRecommendationId);
				//when there are no fields to display show No recomendations available
                if ( !$A.util.isUndefinedOrNull(fieldSortedByKey) && fieldSortedByKey.length > 0 ){
                    cmp.set('v.showApply',true);
            		helperRLD.createRecommendationInputs(cmp, fieldNames, recommendationsMap, fieldControllingMap, recommendationCustomSettings, fieldsAllValues, fieldTypes, allPickListOptions, actualValuesByField);
			    }else{
                    cmp.set('v.recommendationsAvailable', false);
                }
			} else {
            }
        });
        $A.enqueueAction(act);
    }
})