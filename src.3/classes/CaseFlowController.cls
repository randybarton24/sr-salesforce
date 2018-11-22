public with sharing class CaseFlowController {

    public Flow.Interview.Create_New_Case_with_Contact caseFlowInterview { get; set; }

    public PageReference getNewCaseID() {
        PageReference p = new PageReference('/' + getmyID());
        p.setRedirect(true);
        return p;
    }

    public String getmyID() {
        if (this.caseFlowInterview == null) return '';
        else return this.caseFlowInterview.NewCaseID;
    }
}