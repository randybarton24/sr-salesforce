public with sharing class ICUTargetController{

    public Flow.Interview.Request_ICU_Target icuFlowInterview { get; set; }
  
  public PageReference getvarTargetID() {
      PageReference p = new PageReference('/' + getmyID());
      p.setRedirect(true);
      return p;
  }
  
    public String getmyID() {
      if (this.icuFlowInterview == null) return '';
      else return this.icuFlowInterview.varTargetID;
  }
}