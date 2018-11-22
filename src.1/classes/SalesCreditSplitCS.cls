public without sharing class SalesCreditSplitCS
{
    private ApexPages.StandardController control;
    private Boolean wrongUser;
    private Boolean contractNotSigned;
    private String profileName;
    public Opportunity opp {get;set;}
    public Map<Id, User> csrs {get;set;}
    public Id userid {get;set;}
    public String wrongUserWarningMessage = 'A split has already been determined for this opportunity. Please contact your Sales Administrator or System Administrator.';
    public String contractNotSignedWarningMessage = 'Cannot determine split on this opportunity until "Contract Signed" is checked and a date is selected for "Contract Signed Date".';
    public String  upshareRolesProfiles = SR_Default_Values__c.getInstance('upshareRolesProfiles').Value__c;
    public SalesCreditSplitCS(ApexPages.StandardController scontrol)
    {
        this.control = scontrol;
        control.addFields(oppFields);
        this.opp = (Opportunity) control.getRecord();
        
        Id profileId = UserInfo.getProfileId();
        List<String> pNames = new List<String>();
        pNames.add('System Administrator');
        pNames.add('Sales Administrator');
        List<Profile> profiles = [SELECT Name, Id
                        FROM Profile
                        WHERE Name in :pNames];
        System.debug('Profiles: ' + profiles);
        System.debug('Logged User ID: ' + profileId);
        
        csrs = new Map<Id, User>();

        wrongUser = true;
        contractNotSigned = false;
        
        if (this.opp.Contract_Signed__c == false || this.opp.RecurSoft__Contract_Signed_Date__c == null) 
        {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, contractNotSignedWarningMessage));
            contractNotSigned = true;
        }
        
        if (this.opp.Split_Determined__c == true) 
        {
            for (Profile p : profiles) 
            {
                if (p.Id == profileId) 
                {
                    wrongUser = false;
                }
            }
        } 
        else 
        {
            wrongUser = false; // This indicates that a split has not yet been determined, so any user is the correct user.
        }

        if (wrongUser) 
        {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, wrongUserWarningMessage));
        }
        
        User u = [SELECT Id, Name, Profile.Name, ManagerId, Manager.ManagerId FROM USER Where Id = :UserInfo.getUserId()];
        profileName = u.Profile.Name;
        
        if(upshareRolesProfiles.contains(u.Profile.Name))
        {
            userid = u.Id;
            addUserToList();
        }
    }

    @RemoteAction
    public static User[] searchUsers(String searchTerm)
    {
        String  upshareRolesProfiles = SR_Default_Values__c.getInstance('upshareRolesProfiles').Value__c;
        List<String> listUpshareRolesProfiles = upshareRolesProfiles.split(',');

        String query = 'SELECT Id, Name, Profile.Name FROM User ' + 
        	'WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' ' +
            'AND (Profile.Name IN: listUpshareRolesProfiles)';
        List<User> users = Database.query(query);
        return users;
    }

    public PageReference addUserToList()
    {
        System.debug(userid);
        User u = [SELECT Id, Name, Profile.Name, UserRole.Name, ManagerId, Manager.ManagerId FROM User WHERE Id =: userid];
        csrs.put(u.Id, u);
        userid = null;
        return null;
    }

    public PageReference removeUser()
    {
        System.debug(userid);
        User u = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Id =: userid];
        csrs.remove(u.Id);
        userid = null;
        return null;
    }
    
    public PageReference save()
    {  
        if (!wrongUser && !contractNotSigned) 
        {
            Sales_Credit__c[] scs = new List<Sales_Credit__c>();
            
            for(User u:csrs.values())
            {
                Sales_Credit__c sc = new Sales_Credit__c();
                sc.Opportunity__c = opp.Id;
                sc.OwnerId = u.Id;
                sc.Sales_Rep__c = u.Id;
                sc.Manager__c = u.ManagerId;
                sc.VP__c = u.Manager.ManagerId;
                sc.Team_Credit_Portion__c = 1.0 / csrs.values().size();
                sc.Individual_Credit_Portion__c = 1.0 / csrs.values().size();
                scs.add(sc);
            }
            
            Sales_Credit__c[] oldSplits = [SELECT Id FROM Sales_Credit__c WHERE Opportunity__c = :opp.Id];
            delete oldSplits;
        
            insert scs;

            opp.Split_Determined__c = true;
            update opp;

            return new PageReference('/' + opp.Id);
        } 
        else 
        {
            if(contractNotSigned) 
            {
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, contractNotSignedWarningMessage));
            }
            if(wrongUser) 
            {
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, wrongUserWarningMessage));
            }
            return null;
        }
    }

    public List<String> oppFields 
    {
        get 
        {
            if (oppFields == null) 
            {
                oppFields = new List<String>();
                oppFields.add('Contract_Signed__c');
                oppFields.add('Split_Determined__c');
                oppFields.add('RecurSoft__Contract_Signed_Date__c');
                oppFields.add('AccountId');
            }
            return oppFields ;
        }

        private set;
    }
}