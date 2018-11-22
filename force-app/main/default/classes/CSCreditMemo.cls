/**
 * Created by abishop on 11/12/18.
 */

public with sharing class CSCreditMemo {
    public class OutputData
    {
        @InvocableVariable(label='Limit Remaining')
        public Double limitRemaining;

    }

    @InvocableMethod
    public static List<OutputData> getCreditLimit() {
        Id UserId = UserInfo.getUserId();
        CSCreditMemoLimits__c userLimit = CSCreditMemoLimits__c.getInstance(UserId);
        Date cmDate = Date.today().toStartOfMonth();
        System.debug(userLimit);
        AggregateResult[] currentCreditMemoLimit = [SELECT SUM(Credit_Memo_Amount__c) FROM Case WHERE CreatedDate >= :cmDate AND CreatedById = :UserId GROUP BY CreatedById];
        List<OutputData> results = new List<OutputData>();
        system.debug(currentCreditMemoLimit);
        If (currentCreditMemoLimit.isEmpty() ||
                currentCreditMemoLimit[0].get('expr0') == null)
        {
            OutputData output = new OutputData();
            output.limitRemaining = (Double) userLimit.Limit__c;
            System.debug('Output Limit: ' + output);
            results.add(output);
            return results;
        }
        OutputData output = new OutputData();
        System.debug(currentCreditMemoLimit);
        output.limitRemaining = userLimit.Limit__c - (Double) currentCreditMemoLimit[0].get('expr0');
        results.add(output);
        return results;
}


}