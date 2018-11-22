window.coveoCustomScripts['default'] = function (promise) {
    var root = document.querySelector("#search");
    var articleFacetValueCaption = {
      "Getting_Started" : "Get Started",
      "Webinar" : "Webinar",
       "Tips_Tricks" : "Quick Tips",
       "Success_Formula" : "Success Formula"
    };
    Coveo.options(root, {
      articleFilter : {
        valueCaption : articleFacetValueCaption
      }
    });
    
    $('#search').on('duringQuery', function(e, args)
      {
          var tabId= args.query.tab.toString();
          if(tabId!='TrainingVideos'){
              var theDiv = document.getElementById("facetColumn");
              theDiv.style.setProperty('display','none', 'important');
          }
          else{
              document.getElementById("facetColumn").style.removeProperty('display');
          }
      });
    
	var isIE = window.navigator.userAgent=="Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko";
    if(isIE){
        	console.log('isIE');
    }
	
}