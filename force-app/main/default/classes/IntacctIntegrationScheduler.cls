global class IntacctIntegrationScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        System.debug('JOB ID: ' + ctx.getTriggerId());
        IntacctIntegrationSyncHandler.startAsynchronousIntegration(String.valueOf(ctx.getTriggerId()));
    }
}