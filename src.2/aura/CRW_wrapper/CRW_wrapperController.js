({
    recommendationsManagerStateHandler: function(cmp, event, helper){
        var state = event.getParam("state");
        if (state === "INITIALIZED") {
			cmp.set('v.recommendationsAvailable', true);
			var recommendationsManagerCmp = helper.getRecommendationsManager(cmp);
			var recommendationsMap = recommendationsManagerCmp.get("v.recommendationsMap");
            cmp.set("v.recommendationsMap", recommendationsMap);

            helper.resolveLabelsAndDependencies(cmp, event, helper);
		} else {
			cmp.set('v.recommendationsAvailable', false);
		}
	},

    applyRecommendations: function(cmp, event, helper){
        var recommendationInputs = helper.getRecommendationInputs(cmp);
        if(!recommendationInputs) return;

        var recommendationsUpdateMap = {};
        var valueToRecommendationId = cmp.get("v.valueToRecommendationId");

        // Set updateMap equal to the retrieved valueToRecommendationId
        recommendationsUpdateMap = valueToRecommendationId;

        var fieldsUpdateMap = {};
        for(var i = 0; i < recommendationInputs.length; i++){
                var recommendation = recommendationInputs[i];
                if (recommendation.get("v.recommendations.length")>0 || (!$A.util.isUndefinedOrNull(recommendation.get("v.selectedValue")))) {
                    if (!$A.util.isUndefinedOrNull(recommendation.get("v.selectedValueId")))
                        recommendationsUpdateMap[recommendation.get("v.selectedValueId")] = true;

                    fieldsUpdateMap[recommendation.get("v.fieldName")] = recommendation.get("v.selectedValue");
    			}
                else{
                    fieldsUpdateMap[recommendation.get("v.fieldName")] = "";
                }
        }
		if (JSON.stringify(fieldsUpdateMap) !== "{}"){
			helper.updateRecord(cmp, cmp.get("v.recordId"), fieldsUpdateMap, recommendationsUpdateMap);
		}else{
			var toastCmp =  cmp.find("toastNotif");
			toastCmp.set("v.title",'No fields selected for update');
			toastCmp.set("v.description",'Select at least one of the recomendations in order to apply.');
			toastCmp.set("v.className",'');
			toastCmp.set("v.severity",'warning');
		}
    }
})