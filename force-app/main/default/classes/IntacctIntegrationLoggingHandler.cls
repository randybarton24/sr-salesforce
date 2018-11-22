/**
 * File:        IntacctIntegrationLoggingHandler.cls<br/>
 * Project:     Sererra - Subscription Billing<br/>
 * Date:        March 26, 2014<br/>
 * Created By:  Ionut Boghean<br/>
 * *************************************************************************<br/>
 * Description:  Contains a list of methods to process the exceptions caught in the revenue schedule process<br/>
 * *************************************************************************<br/>
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 */
public class IntacctIntegrationLoggingHandler 
{

    private static final String methodEntryPrefix = 'Entering: ';
    private static final String exceptionLogPrefix = 'Exception Log\n';
    private static final String exceptionInfoPrefix = 'Exception occurred on line ';
    private static final String exceptionStackTracePrefix = ' stack: ';
    private static final String hyphenSeparator = ' - ';
    private static final String pipeSeparator = ' | ';
    private static final String exceptionTraceSufix = ' |\n ';
    private static final String lineFeedCharacter = '\n';
    
    /** Holds al the information gathered from an execution context*/
    @TestVisible private static List<LogEntry> debuggingLog = new List<LogEntry>();
    /** The current log level*/
    @TestVisible private static Integer logLevel = 0;
    /** Holds all the method entries and exception messages*/
    @TestVisible private static List<String> stackTrace = new List<String>();
    /** Used to diplay/debug the stackTrace*/
    @TestVisible private static String exceptionTrace;
    
    private class LogEntry
    {
        Integer level;
        String description;
        
        public LogEntry(String entryDescription)
        {
            level = logLevel;
            description = entryDescription;
        }
    }
    
    /**
    * @author Ionut Boghean
    * @date March 20, 2014
    * @description Add an entry in the stack trace
    * @param methodName the name of the method that threw the exception
    * @see RevenueScheduleLoggingHandler.debug
    */
    public static void pushEntry(String methodName)
    {
        debug(methodEntryPrefix + methodName);
        logLevel++;
        stackTrace.add(methodName);
    }
    
    /**
    * @author Ionut Boghean
    * @date March 20, 2014
    * @description Removes an entry from the stack trace
    * @see RevenueScheduleLoggingHandler.currentLog
    * @see RevenueScheduleLoggingHandler.removeStackTraceEntry
    */
    public static void popEntry()
    {
        if(logLevel > 0)
        {
            logLevel--;
        }
        else
        {
            System.debug(LoggingLevel.INFO, exceptionLogPrefix + retrieveExceptionLog());
        }
        removeStackTraceEntry();
    }
    
    /**
    * @author Ionut Boghean
    * @date March 20, 2014
    * @description Displays the curent exception log
    * @see RevenueScheduleLoggingHandler.popEntry
    */
    public static void popAll()
    {
        logLevel = 0;
        popEntry();
        stackTrace.clear();
    }
    
    /**
    * @author Ionut Boghean
    * @date March 20, 2014
    * @description Add an entry in the debuggingLog
    * @param debugString the text of the log entry
    */
    public static void debug(String debugString)
    {
        debuggingLog.add(new LogEntry(debugString));
    }
    
    /**
    * @author Ionut Boghean
    * @date March 20, 2014
    * @description Debug exception data
    * @param ex the caught exception
    * @see RevenueScheduleLoggingHandler.debug
    */
    public static void debugException(Exception ex)
    {
        String exceptionInfo = exceptionInfoPrefix + ex.getLineNumber() + hyphenSeparator + ex.getMessage() + exceptionStackTracePrefix + ex.getStackTraceString();
        debug(exceptionInfo);
        //logic to create a custom error object entry
        exceptionTrace = exceptionInfoPrefix + ex.getLineNumber() + hyphenSeparator + ex.getMessage();
        for(String stackTraceEntry :stackTrace)
        {
            exceptionTrace += pipeSeparator + stackTraceEntry;
        }
        exceptionTrace += exceptionTraceSufix;
        //insert the custom error object entry
        System.debug(exceptionTrace);
        insert new Error_Log__c(
            Error_Message__c = exceptionTrace,
            Error_Type__c = 'IntacctIntegrationLoggingHandler Exception');
    }
    
    /**
    * @author Ionut Boghean
    * @date March 20, 2014
    * @description Retrieves the entire debug log
    * @return result The text of the debug log
    */
    public static String retrieveExceptionLog()
    {
        String spaces = '                                                                        ';
        String result = '';
        for(LogEntry currentEntry :debuggingLog)
        {
            Integer endindex = 3 * currentEntry.level;
            if(endindex >= spaces.length()) 
            {
                endindex = spaces.length()-1;
            }
            result += spaces.substring(0,endindex) + currentEntry.description + lineFeedCharacter;
        }
        return result;
    }
    
    /**
    * @author Ionut Boghean
    * @date March 20, 2014
    * @description Removes tha last entry in the stack trace
    */
    private static void removeStackTraceEntry()
    {
        if(stackTrace.size() > 0)
        {
            stackTrace.remove(stackTrace.size() - 1);
        }
    }
    
}