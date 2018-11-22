public class WorkRequest_Controller 
{
    public Flow.Interview.WorkRequest workRequest { get; set; }

	public PageReference getFinishLocation()
    {
	  	String finishLocation;
		if(workRequest != null) 
        {
			finishLocation = (String) workRequest.getVariableValue('varWorkID');
		}
		PageReference newWork = new PageReference('/' + finishLocation);
		newWork.setRedirect(true);
		return newWork;
	}
}