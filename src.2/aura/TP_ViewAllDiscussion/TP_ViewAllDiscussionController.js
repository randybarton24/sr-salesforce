({
	doinit : function(component, event, helper) {
		var pageSize = component.get("v.pageSize");
        var action = component.get("c.getAllFeedItems");

        action.setCallback(this, function(data) {
        	component.set("v.c_feedItems", data.getReturnValue());   
            component.set("v.totalSize", component.get("v.c_feedItems").length);
            component.set("v.start",0);
            component.set("v.currentPage",component.get("v.start")+1);
            component.set("v.end",pageSize-1);
            component.set("v.totalPageSize",Math.ceil(component.get("v.c_feedItems").length/pageSize));
            
            var paginationList = [];
            for(var i=0; i< pageSize; i++){
                paginationList.push(data.getReturnValue()[i]);    
            }
            component.set('v.paginationList', paginationList);
        });
        $A.enqueueAction(action);
	},
    removeCss : function(component, event, helper) {
        var cmpTarget = document.getElementsByTagName("body")[0];
        $A.util.removeClass(cmpTarget, 'tab1');
    },
    next : function(component, event, helper){
     	var accountList = component.get("v.c_feedItems");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
        	if(accountList.length > end){
          		paginationList.push(accountList[i]);
                counter ++ ;
         	}
        }
        start = start + counter;
        end = end + counter;
        component.set("v.start",start);
        component.set("v.currentPage",(component.get("v.start")/component.get("v.pageSize"))+1);
        component.set("v.end",end);
        component.set('v.paginationList', paginationList);
   },
    previous : function(component, event, helper) {
     	var accountList = component.get("v.c_feedItems");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
         
        var counter = 0;
               
        for(var i= start-pageSize; i < start ; i++){
        	if(i > -1){
            	paginationList.push(accountList[i]);
             	counter ++;
            }else{
                start++;
         	}
        }
        start = start - counter;
        end = end - counter;
        component.set("v.start",start);
        component.set("v.currentPage",(component.get("v.start")/component.get("v.pageSize"))+1);
        component.set("v.end",end);
        component.set('v.paginationList', paginationList);
 	},    
	renderPage: function(component) {
		var records = component.get("v.c_feedItems"),
        pageNumber = component.get("v.pageNumber"),
        pageRecords = records.slice((pageNumber-1)*2, pageNumber*2);
        component.set("v.currentList", pageRecords);
	}
})