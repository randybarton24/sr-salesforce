({
    doInit: function(cmp, event, helper) {
        var allRecommendations = cmp.get("v.allRecommendations");
        var topOfAllRecommendation;
        var allHighestScore = 0;
        if (allRecommendations) {
            for (var i = 0; i < allRecommendations.length; i++) {
                var r = allRecommendations[i];
                if (r.score > allHighestScore) {
                    topOfAllRecommendation = r;
                    allHighestScore = topOfAllRecommendation.score;
                }
            }
            cmp.set("v.highestScore", allHighestScore);
        }

        var currentRecommendations = cmp.get("v.recommendations");
        if (currentRecommendations && currentRecommendations.length > 0) {
            var currentTopRecommendation;
            var currentHighScore = 0;

            for (var j = 0; j < currentRecommendations.length; j++) {
                var s = currentRecommendations[j];
                if (s.score > currentHighScore) {
                    currentTopRecommendation = s;
                    currentHighScore = currentTopRecommendation.score;
                }
            }

            cmp.set("v.selectedValueScore", currentTopRecommendation.score);
            cmp.set("v.selectedValue", currentTopRecommendation.value);
            cmp.set("v.selectedValueId", currentTopRecommendation.recordRecommendationId);
        }
    },

    handleSelectionChange: function(cmp, event, helper) {
        var source = event.getSource();
        if(source){
            var recommendations = cmp.get("v.allRecommendations");
            var selectedValue = source.get("v.value");
            var actualHighestScore = 0;
            var selectedScore = 0 ;
            for(var j = 0; j < recommendations.length; j++){
                var r = recommendations[j];
                if(r.value === selectedValue){
                    selectedScore = r.score;
                    cmp.set("v.selectedValueScore", r.score);
                    cmp.set("v.selectedValue", selectedValue);
                    cmp.set("v.selectedValueId", r.recordRecommendationId);
                }
                if(r.score > actualHighestScore)
                {
                    actualHighestScore = r.score;
                }
            }

            cmp.set("v.highestScore",actualHighestScore);

			// name value from aura:registerEvent
			var cmpEvent = $A.get("e.c:CRW_fieldUpdateNotification");
			if ($A.util.isUndefinedOrNull(cmpEvent)){
				console.log('did not find event');
			}else{
				cmpEvent.setParams({
					"fieldName" : cmp.get("v.fieldName"),
					"newValue"  : selectedValue });
				cmpEvent.fire();
			}
        }
    },

	handleFieldUpdateEvt: function(cmp, event, helper) {
        var evtFieldName = event.getParam("fieldName");
        var evtNewValue = event.getParam("newValue");

		var controlledBy = cmp.get("v.controlledBy");
		var fieldName = cmp.get("v.fieldName");

		//check if evtField controls me
		if (!$A.util.isUndefinedOrNull(controlledBy)) {
			var k=0;
			var isControlled= false;
			while (k<controlledBy.length && !isControlled) {
				isControlled = (evtFieldName === controlledBy[k]);
				k++;
			}

			if (isControlled) {
                // Get map to check if values exist.
                var picklistOptions = cmp.get("v.picklistOptions");

                if (picklistOptions.hasOwnProperty(evtNewValue)) {
                    var allValues = picklistOptions[evtNewValue];
                    // We need to create a new array based on the result to store it in recommendations attribute
                    var selectedValues = [];
                    for (var l = 0; l < allValues.length; l++) {
                        selectedValues.push({value: allValues[l]});
                    }

                    var allRecommendations = cmp.get("v.allRecommendations");

                    // Set aura attribute of options
					if (selectedValues.length > 0) {

                        var finalValues = [];
                        for (var m = 0; m < allRecommendations.length; m++) {
                            for (var n = 0; n < selectedValues.length; n++) {
                                if ((!$A.util.isUndefinedOrNull(allRecommendations)) && allRecommendations[m].value === selectedValues[n].value.toString()) {
                                    finalValues.push(allRecommendations[m]);
                                }
                            }
                        }

                        var highScore = 0;
                        var topRecommendation;

                        for (var o = 0; o < finalValues.length; o++) {
                            if (finalValues[o].score > highScore) {
                                topRecommendation = finalValues[o];
                                highScore = finalValues[o].score;
                            }
                        }

                        // this if fix an error that appears if not recommended values came but should appears
                        if(!$A.util.isUndefinedOrNull(topRecommendation))
                        {
                            cmp.set("v.recommendations", finalValues);
                            cmp.set("v.selectedValue", topRecommendation.value);
                            cmp.set("v.selectedValueScore", topRecommendation.score);
                            cmp.set("v.selectedValueId", topRecommendation.recordRecommendationId);
                        }
                    }

                    //we set initially the all values to null and then proceed to check for the new all values (below the line)
                    cmp.set("v.allValues",null);
                    var listForCurrentAllValues = [];
                    var listOfFinalValues = [];
                    var enterSomeValue = false;
                    var selectedValueFromAllValues;
                    for(var b in finalValues)
                    {
                        // build the list of the values to show above the line
                        listOfFinalValues.push(finalValues[b]['value']);
                    }
                    for(var bsv in selectedValues)
                    {
                        // check for those values that must appear under the line
                        if(listOfFinalValues.indexOf(selectedValues[bsv]['value'])<0)
                        {
                            enterSomeValue = true;
                            listForCurrentAllValues.push({'value': selectedValues[bsv]['value'],'score':0});
                        }
                    }
                    //if some value appears below the line we set the list
                    if(enterSomeValue)
                    {
                        cmp.set("v.allValues", listForCurrentAllValues);
                    }
                    // this fix an error that appears if not recommended values came but should appears
                    var valueToSend = "";
                    // check if exist some top recommendation
                    if(!$A.util.isUndefinedOrNull(topRecommendation))
                    {
                        valueToSend = topRecommendation.value;
                    }
                    else
                    {
                        //this is because there are not available values to recommend
                        cmp.set("v.recommendations",null);
                        if(listForCurrentAllValues.length > 0)
                        {
                            // set the first of the all values
                            valueToSend = listForCurrentAllValues[0]['value'];
                            cmp.set("v.selectedValue", listForCurrentAllValues[0]['value']);
                            cmp.set("v.selectedValueScore", listForCurrentAllValues[0]['score']);
                        }
                    }
                    // Fire event again
                    var cmpEvent = $A.get("e.c:CRW_fieldUpdateNotification");
                    if ($A.util.isUndefinedOrNull(cmpEvent)) {
                        console.log('did not find event');
                    } else {
                        cmpEvent.setParams({
                            "fieldName" : cmp.get("v.fieldName"),
                            "newValue"  : valueToSend });
                        cmpEvent.fire();
                    }
                } else {
                    // if enter to this else its because the picklistoptions are empty for this value so the dependent field must be empty
                    //and also all their dependents

                    var action = cmp.get("c.getPickListOptionsDependency");

                    action.setParams({ fieldApiName: fieldName});
                    action.setCallback(this, function(response) {
                        if (!cmp.isValid()) {
                            return;
                        }

                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var responseMap = response.getReturnValue();
                            if (responseMap.hasOwnProperty(evtNewValue)) {
                                var allValuesPL = picklistOptions[evtNewValue];
                                // We need to create a new array based on the result to store it in recommendations attribute
                                var selectedValuesPL = [];
                                for (var q = 0; q < allValuesPL.length; q++) {
                                    selectedValuesPL.push({value: allValuesPL[q]});
                                }

                                var allRecommendationsE = cmp.get("v.allRecommendations");

                                // Set aura attribute of options
            					if (selectedValuesPL.length > 0) {
                                    var finalValuesE = [];
                                    for (var r = 0; r < allRecommendationsE.length; r++) {
                                        for (var s = 0; s < selectedValuesPL.length; s++) {
                                            if (allRecommendationsE[r].value === selectedValuesPL[s].value.toString()) {
                                                finalValuesE.push(allRecommendationsE[r]);
                                            }
                                        }
                                    }

                                    var highScoreE = 0;
                                    var topRecommendationE;

                                    for (var v = 0; v < finalValuesE.length; v++) {
                                        if (finalValuesE[v].score > highScoreE) {
                                            topRecommendationE = finalValuesE[v];
                                        }
                                    }
                                    cmp.set("v.recommendations", finalValuesE);
                                    cmp.set("v.selectedValue", topRecommendationE.value);
                                    cmp.set("v.selectedValueScore", topRecommendationE.score);
                                    cmp.set("v.selectedValueId", topRecommendationE.recordRecommendationId);
                                }

                                // Fire event again
                                var cmpEventE = $A.get("e.c:CRW_fieldUpdateNotification");
                                if ($A.util.isUndefinedOrNull(cmpEventE)) {
                                    console.log('did not find event');
                                } else {
                                    cmpEventE.setParams({
                                        "fieldName" : cmp.get("v.fieldName"),
                                        "newValue"  : topRecommendationE.value });
                                    cmpEventE.fire();
                                }
                            }
                            else
                            {
                                // if enter here its because for the value of the parent didnt had any dependent value asociated
                                cmp.set('v.allValues',[]);
                                cmp.set('v.recommendations',[]);
                                cmp.set("v.selectedValue", null);
                                cmp.set("v.selectedValueScore", null);
                                cmp.set('v.showDisabled',true);
                                var cmpEventEE = $A.get("e.c:CRW_fieldUpdateNotification");
                                if ($A.util.isUndefinedOrNull(cmpEventEE)) {
                                    console.log('did not find event');
                                } else {
                                    cmpEventEE.setParams({
                                        "fieldName" : cmp.get("v.fieldName"),
                                        "newValue"  : null });
                                    cmpEventEE.fire();
                                }
                            }
                        } else {
                            console.log('error on handleFieldUpdateEvt');
                        }
                    });
                    $A.enqueueAction(action);
                }
			}
		}
    }
})