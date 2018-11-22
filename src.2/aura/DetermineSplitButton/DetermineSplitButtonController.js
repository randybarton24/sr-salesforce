({
	openActionWindow : function(component, event, helper) {
		var oppId = component.get("v.record.X18_Character_ID__c");
        var winReportDate = component.get("v.record.Win_Report_Completed_Date__c");
        var stageName = component.get("v.record.StageName");
        window.open("/apex/WinReport?Id=" + oppId + "&WinReportDate=" + winReportDate + "&Stage=" + stageName);
	}
})