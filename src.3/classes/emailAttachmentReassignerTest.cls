/*
Test the emailAttachmentReassigner Trigger


3/22/2018 Matt Schetselaar - Updated the API Version  

*/

@IsTest
public class emailAttachmentReassignerTest {
    // tests when an attachment is associated with a case
    @isTest static void attachmentTester() {
        Case c = new Case();
        insert c;
        
        EmailMessage em = new EmailMessage();
        em.parentId = c.id;
        em.MessageDate = Date.today();
        em.FromAddress = 'test@from.com';
        em.ToAddress = 'test@to.com';
        em.Subject = 'test subject';
        em.TextBody = 'heres a text body.';
        insert em;
        
        
        Attachment a = new Attachment();
        a.name = 'test attachment';
        a.body = blob.valueof('attachment body');
        a.parentid = em.id;
        insert a;   
        
        List<Attachment> attachments = [Select Id From Attachment Where parentId = :c.id];
        
        System.assert(attachments.size() == 1, 'Wrong number of attachments (( ' + attachments.size() );
    }
/*    // tests if an attachment is not associated with an email
    @isTest static void attachmentTesterNull() {
        Attachment a = new Attachment();
        a.name = 'test attachment';
        a.body = blob.valueof('attachment body');
        insert a; 
        
        List<Attachment> attachments = [SELECT Id FROM Attachment WHERE ParentId = null];
        System.assert(attachments.size() == 1, 'Wrong number of Attachments ((' + attachments.size() );
    }*/
}