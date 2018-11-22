public without sharing class oppSalesCreditSplit{

    private ApexPages.StandardController control;
    private Boolean wrongUser;
    private Boolean contractNotSigned;
    private String profileName;
    public Opportunity opp {get;set;}
    public Map<Id, User> esrs {get;set;}
    public Map<Id, User> isrs {get;set;}
    public Map<Id, User> osrs {get;set;}
    public Map<Id, User> ensrs {get;set;}
    public Id userid {get;set;}
    public Boolean isEnterprise {get;set;}
    public String wrongUserWarningMessage = 'A split has already been determined for this opportunity. Please contact your Sales Administrator or System Administrator.';
    public String contractNotSignedWarningMessage = 'Cannot determine split on this opportunity until "Contract Signed" is checked and a date is selected for "Contract Signed Date".';

    public oppSalesCreditSplit(ApexPages.StandardController scontrol){
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
        
        esrs = new Map<Id, User>();
        isrs = new Map<Id, User>();
        osrs = new Map<Id, User>();
        ensrs = new Map<Id, User>();

        wrongUser = true;
        contractNotSigned = false;
        if (this.opp.Contract_Signed__c == false || this.opp.RecurSoft__Contract_Signed_Date__c == null) {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, contractNotSignedWarningMessage));
            contractNotSigned = true;
        }
        if (this.opp.Split_Determined__c == true) {
            for (Profile p : profiles) {
                if (p.Id == profileId) {
                    wrongUser = false;
                }
            }
        } else {
            wrongUser = false; // This indicates that a split has not yet been determined, so any user is the correct user.
        }

        if (wrongUser) {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, wrongUserWarningMessage));
        }

        
        User u = [SELECT Id, Name, Profile.Name, ManagerId, Manager.ManagerId FROM USER Where Id = :UserInfo.getUserId()];
        profileName = u.Profile.Name;
        if(u.Profile.Name == 'Extended Sales' || u.Profile.Name == 'Inside Sales' || u.Profile.Name == 'Outside Sales' || u.Profile.Name == 'Enterprise Sales'){
            userid = u.Id;
            addUserToList();
            if(u.Profile.Name == 'Enterprise Sales'){
                isEnterprise = true;
            }
        }
    }

    @RemoteAction
    public static User[] searchUsers(String searchTerm){
        String query = 'SELECT Id, Name, Profile.Name FROM User WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' AND (Profile.Name LIKE \'%Sales\' OR UserRole.Name = \'VP Outside Sales/BD\' OR UserRole.Name = \'Outside Sales Manager\')';
        List<User> users = Database.query(query);
        return users;
    }

    public PageReference addUserToList(){
        System.debug(userid);
        User u = [SELECT Id, Name, Profile.Name, UserRole.Name, ManagerId, Manager.ManagerId FROM User WHERE Id =: userid];
        if(u.Profile.Name == 'Extended Sales'){
            esrs.put(u.Id, u);
        }else if(u.Profile.Name == 'Inside Sales'){
            isrs.put(u.Id, u);
        }else if(u.Profile.Name == 'Outside Sales' || u.UserRole.Name == 'VP Outside Sales/BD' || u.UserRole.Name == 'Outside Sales Manager'){
            osrs.put(u.Id, u);
        }else if(u.Profile.Name == 'Enterprise Sales'){
            ensrs.put(u.Id, u);
        }
        userid = null;
        return null;
    }

    public PageReference removeUser(){
        System.debug(userid);
        User u = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Id =: userid];
        if(u.Profile.Name == 'Extended Sales'){
            esrs.remove(u.Id);
        }else if(u.Profile.Name == 'Inside Sales'){
            isrs.remove(u.Id);
        }else if(u.Profile.Name == 'Outside Sales' || u.UserRole.Name == 'VP Outside Sales/BD' || u.UserRole.Name == 'Outside Sales Manager'){
            osrs.remove(u.Id);
        }else if(u.Profile.Name == 'Enterprise Sales'){
            ensrs.remove(u.Id);
        }
        userid = null;
        return null;
    }
    
    public PageReference save(){
        // Check for errors on the page
        if (opp.Partner_KOL_Affiliate_Involved__c == true && opp.Partner_KOL_At_Sale__c == '') {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Partner/KOL/Affiliate must be specified if Partner/KOL/Affiliate is involved in the sale!'));
            return null;
        }

        if (!wrongUser && !contractNotSigned) {
            Sales_Credit__c[] scs = new List<Sales_Credit__c>();
            
            Integer totalTeams = 0;
            
            if(esrs.values().size() > 0){
                totalTeams++;
            }
            if(isrs.values().size() > 0){
                totalTeams++;
            }
            if(osrs.values().size() > 0){
                totalTeams++;
            }
            if(ensrs.values().size() > 0){
                totalTeams++;
            }
            
            Double eteam = 0;
            Double iteam = 0;
            Double oteam = 0;
            Double enteam = 0;
            if(esrs.size() > 0){
                eteam = 1.0 / totalTeams / esrs.size();
            }
            if(isrs.size() > 0){
                iteam = 1.0 / totalTeams / isrs.size();
            }
            if(osrs.size() > 0){
                oteam = 1.0 / totalTeams / osrs.size();
            }
            if(ensrs.size() > 0){
                enteam = 1.0 / totalTeams / ensrs.size();
            }
            
            //enteam = 1; //This is because enterprise teams don't share.
            
            for(User u:esrs.values()){
                Sales_Credit__c sc = new Sales_Credit__c();
                sc.Opportunity__c = opp.Id;
                sc.OwnerId = u.Id;
                sc.Sales_Rep__c = u.Id;
                if(u.UserRole.Name.contains('Manager'))
                {
                    // Manager set as Sales Rep and Manager.
                    sc.Manager__c = u.Id;
                    sc.VP__c = u.ManagerId;
                }
                else
                {
                    sc.Manager__c = u.ManagerId;
                    sc.VP__c = u.Manager.ManagerId;
                }
                sc.Team_Credit_Portion__c = eteam;
                sc.Individual_Credit_Portion__c = 1.0 / esrs.values().size();
                scs.add(sc);
            }
            for(User u:isrs.values()){
                Sales_Credit__c sc = new Sales_Credit__c();
                sc.Opportunity__c = opp.Id;
                sc.OwnerId = u.Id;
                sc.Sales_Rep__c = u.Id;
                sc.Manager__c = u.ManagerId;
                sc.VP__c = u.Manager.ManagerId;
                sc.Team_Credit_Portion__c = iteam;
                sc.Individual_Credit_Portion__c = 1.0 / isrs.values().size();
                scs.add(sc);
            }
            for(User u:osrs.values()){
                Sales_Credit__c sc = new Sales_Credit__c();
                sc.Opportunity__c = opp.Id;
                sc.OwnerId = u.Id;
                sc.Sales_Rep__c = u.Id;
                if (u.UserRole.Name == 'Outside Sales Manager') {
                    // Manager set as Sales Rep and Manager.
                    sc.Manager__c = u.Id;
                    sc.VP__c = u.ManagerId;
                } else if (u.UserRole.Name == 'VP Outside Sales/BD') {
                    // VP set as Sales Rep and VP.
                    sc.Manager__c = null;
                    sc.VP__c = u.Id;
                } else {
                    // Proceed with normal hierarchy.
                    sc.Manager__c = null;
                    sc.VP__c = u.ManagerId;
                }
                sc.Team_Credit_Portion__c = oteam;
                sc.Individual_Credit_Portion__c = 1.0 / osrs.values().size();
                scs.add(sc);
            }
            for(User u:ensrs.values()){
                //scs.clear(); // This empties the list of all values because enterprise reps don't share              
                Sales_Credit__c sc = new Sales_Credit__c();
                sc.Opportunity__c = opp.Id;
                sc.OwnerId = u.Id;
                sc.Sales_Rep__c = u.Id;
                sc.Manager__c = u.ManagerId;
                sc.VP__c = u.Manager.ManagerId;
                sc.Team_Credit_Portion__c = enteam;
                sc.Individual_Credit_Portion__c = 1.0 / ensrs.values().size();
                scs.add(sc);
            }
            
            Sales_Credit__c[] oldSplits = [SELECT Id FROM Sales_Credit__c WHERE Opportunity__c = :opp.Id];
            Set<Id> oldSplitIds = new Map<Id, Sales_Credit__c>(oldSplits).keySet();
            Bonus_Commission_Credit__c[] oldBCC = [SELECT Id FROM Bonus_Commission_Credit__c WHERE Sales_Credit__c IN :oldSplitIds];

            delete oldBCC;
            delete oldSplits;
            insert scs;

            opp.Split_Determined__c = true;
            update opp;

            return new PageReference('/' + opp.Id);
        } else {
            if (contractNotSigned) {
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, contractNotSignedWarningMessage));
            }
            if (wrongUser) {
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, wrongUserWarningMessage));
            }
            return null;
        }
    }

    public List<String> oppFields {
        get {
            if (oppFields == null) {
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