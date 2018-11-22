public with sharing class PCUTargetController{

    public Flow.Interview.PCU_Creation pcuFlowInterview { get; set; }
  
  public PageReference getvarTargetID() {
      PageReference p = new PageReference('/' + getmyID());
      p.setRedirect(true);
      return p;
  }
  
    public String getmyID() {
      if (this.pcuFlowInterview == null) return '';
      else return this.pcuFlowInterview.varTargetID;
  }
}