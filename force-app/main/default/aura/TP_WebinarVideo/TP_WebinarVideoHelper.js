({
	getParameterByName : function(cmp,event,name) {
       var url = window.location.href;
       name = name.replace(/[\[\]]/g, "\\$&");
       var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
       results = regex.exec(url);
       if (!results) return null;
       if (!results[2]) return '';
        console.log("===>"+decodeURIComponent(results[2].replace(/\+/g, " ")));
       return decodeURIComponent(results[2].replace(/\+/g, " "));
    }
})