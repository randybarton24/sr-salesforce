global class ScheduledDispatcher Implements Schedulable {
	
	public Interface IScheduleDispatched {

        void execute(SchedulableContext sc); 
    } 
    
    global void execute(SchedulableContext sc) {

        Type targetType = Type.forName('AsyncMain.ScheduleHandler');

        if(targetType != null) {

            IScheduleDispatched obj = (IScheduleDispatched)targetType.NewInstance();
            obj.execute(sc);   
        } 
    } 
}