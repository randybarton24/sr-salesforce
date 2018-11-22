({
	doinit : function(component, event, helper) {        
		var pageSize = component.get("v.pageSize");
        var action = component.get("c.getTopics");
        
        action.setCallback(this, function(data) {
            component.set("v.pTopics",data.getReturnValue());
            component.set("v.totalSize", component.get("v.pTopics").length);
            component.set("v.start",0);
            component.set("v.end",pageSize-1);
            component.set("v.currentPage",component.get("v.start")+1);
            component.set("v.totalPageSize",Math.ceil(component.get("v.pTopics").length/pageSize));
            var paginationList = [];
            for(var i=0; i< pageSize; i++){
                paginationList.push(data.getReturnValue()[i]);    
            }
            component.set('v.paginationList', paginationList);
        });
        $A.enqueueAction(action);
	},
    next : function(component, event, helper){
     	var accountList = component.get("v.pTopics");
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
     	var accountList = component.get("v.pTopics");
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
 	}
})