trigger Surveys on Survey__c (after delete, after insert, after update, 
  before delete, before insert, before update) 
{
   // Creates Domain class instance and calls appropriate methods
   fflib_SObjectDomain.triggerHandler(Surveys.class);
}