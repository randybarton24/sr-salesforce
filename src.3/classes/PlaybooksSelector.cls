public class PlaybooksSelector extends fflib_SObjectSelector 
{
    public Schema.SObjectField[] getSObjectFieldList() 
    {
        return new List<Schema.SObjectField> {
            Playbook__c.Id,
            Playbook__c.Active__c,
            Playbook__c.Name,
            Playbook__c.Survey_to_be_Sent__c        
             };
    }

    public Schema.SObjectType getSObjectType()
    {
        return Playbook__c.SObjectType;
    }

    public static PlaybooksSelector newInstance()
    {
        return (PlaybooksSelector) Application.Selector.newInstance(Playbook__c.SObjectType);
    }

    public Playbook__c[] selectByIdWithTasks(Set<Id> ids)
    {
        fflib_QueryFactory playbookQueryFactory = newQueryFactory();

        fflib_QueryFactory taskQueryFactory = playbookQueryFactory.subselectQuery('Tasks')
            .selectFields(new TasksSelector().getSObjectFieldList());

        return (Playbook__c[]) Database.query(
            playbookQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Id IN :ids').toSOQL());
    }

    public Playbook__c[] selectAllActivePlaybooks()
    {
        fflib_QueryFactory playbookQueryFactory = newQueryFactory();

        return (Playbook__c[]) Database.query(
            playbookQueryFactory.selectFields(new Set<Schema.SObjectField>(this.getSObjectFieldList())).setCondition('Active__c = true').toSOQL());
    }
}