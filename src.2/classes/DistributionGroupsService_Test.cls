/**
 * Created by mschetselaar on 10/26/2018.
 */

@IsTest
private class DistributionGroupsService_Test
{
    @IsTest
    static void test_getNextUserId()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Distribution_Group__c distGroup = (Distribution_Group__c)TestUtilities2.newDistributionGroup()
                .setField(Distribution_Group__c.Name, 'Testing')
                .toSObject();
        
        sfab_FabricatedSObject uFab1 = TestUtilities2.newUser()
                .setField(User.FirstName, 'Test 1')
                .setField(User.LastName, 'Last 1');
        User user1 = (User)uFab1.toSObject();
        sfab_FabricatedSObject uFab2 = TestUtilities2.newUser()
                .setField(User.FirstName, 'Test 2')
                .setField(User.LastName, 'Last 2');
        User user2 = (User) uFab2.toSObject();
        
        sfab_FabricatedSObject mFab1 = TestUtilities2.newDistributionGroupMember()
                .setField(Distribution_Group_Member__c.Distribution_Group__c, distGroup.Id)
                .setParent('User__r', uFab1)
                .setField(Distribution_Group_Member__c.User__c,user1.Id)
                .setField(Distribution_Group_Member__c.Available__c, true)
                .setField(Distribution_Group_Member__c.Next_Up__c, true);
        Distribution_Group_Member__c member1 = (Distribution_Group_Member__c) mFab1.toSObject();
        
        sfab_FabricatedSObject mFab2 = TestUtilities2.newDistributionGroupMember()
                .setField(Distribution_Group_Member__c.Distribution_Group__c, distGroup.Id)
                .setField(Distribution_Group_Member__c.User__c, user2.Id)
                .setField(Distribution_Group_Member__c.Available__c, true)
                .setField(Distribution_Group_Member__c.Next_Up__c, false);
        Distribution_Group_Member__c member2 = (Distribution_Group_Member__c)mFab2.toSObject();
        
        List<Distribution_Group_Member__c> members = new List<Distribution_Group_Member__c>();
        members.add(member2);
        members.add(member1);
        
        Test.startTest();
        User user = DistributionGroupsService.getNextUserId(members,distGroup.Id,uow);
        Test.stopTest();
        
        System.assertEquals(user1.Id,user.Id);
        System.assertEquals('Assigned to the next user in the Distribution Group', user.AboutMe);
    }
    //
    @IsTest
    static void test_getNextUserIdNonLoadBalanced()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Distribution_Group__c distGroup = (Distribution_Group__c)TestUtilities2.newDistributionGroup()
                .setField(Distribution_Group__c.Name, 'Testing')
                .setField(Distribution_Group__c.Distribution_Type__c, 'Linear')
                .toSObject();
        
        sfab_FabricatedSObject uFab1 = TestUtilities2.newUser()
                .setField(User.FirstName, 'Test 1')
                .setField(User.LastName, 'Last 1');
        User user1 = (User)uFab1.toSObject();
        sfab_FabricatedSObject uFab2 = TestUtilities2.newUser()
                .setField(User.FirstName, 'Test 2')
                .setField(User.LastName, 'Last 2');
        User user2 = (User) uFab2.toSObject();
        
        sfab_FabricatedSObject mFab1 = TestUtilities2.newDistributionGroupMember()
                .setField(Distribution_Group_Member__c.Distribution_Group__c, distGroup.Id)
                .setParent('User__r', uFab1)
                .setField(Distribution_Group_Member__c.User__c,user1.Id)
                .setField(Distribution_Group_Member__c.Available__c, true)
                .setField(Distribution_Group_Member__c.Next_Up__c, true);
        Distribution_Group_Member__c member1 = (Distribution_Group_Member__c) mFab1.toSObject();
        
        sfab_FabricatedSObject mFab2 = TestUtilities2.newDistributionGroupMember()
                .setField(Distribution_Group_Member__c.Distribution_Group__c, distGroup.Id)
                .setField(Distribution_Group_Member__c.User__c, user2.Id)
                .setField(Distribution_Group_Member__c.Available__c, true)
                .setField(Distribution_Group_Member__c.Next_Up__c, false);
        Distribution_Group_Member__c member2 = (Distribution_Group_Member__c)mFab2.toSObject();
        
        List<Distribution_Group_Member__c> members = new List<Distribution_Group_Member__c>();
        members.add(member1);
        members.add(member2);
        
        List<Distribution_Group__c> distGroups = (List<Distribution_Group__c>) fflib_ApexMocksUtils.makeRelationship(List<Distribution_Group__c>.class, new List<Distribution_Group__c>{distGroup},Distribution_Group_Member__c.Distribution_Group__c, new List<List<Distribution_Group_Member__c>> {members});
        
        Test.startTest();
        User user = DistributionGroupsService.getNextUserId(distGroups[0],uow);
        Test.stopTest();
        
        System.assertEquals(user1.Id,user.Id);
        System.assertEquals('Assigned to the next user in the Distribution Group', user.AboutMe);
    }
    
    @IsTest
    public static void test_getNextUserId_LoadBalanced()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Distribution_Group__c distGroup = (Distribution_Group__c)TestUtilities2.newDistributionGroup()
                .setField(Distribution_Group__c.Name, 'Testing')
                .setField(Distribution_Group__c.Distribution_Type__c, 'Load Balanced')
                .setField(Distribution_Group__c.Relationship_Criteria__c, 'IsClosed = false')
                .setField(Distribution_Group__c.ParentObject__c, 'Case')
                .setField(Distribution_Group__c.Field_to_Distribute__c, 'OwnerId')
                .toSObject();
        
        sfab_FabricatedSObject uFab1 = TestUtilities2.newUser()
                .setField(User.FirstName, 'Test 1')
                .setField(User.LastName, 'Last 1');
        User user1 = (User)uFab1.toSObject();
        sfab_FabricatedSObject uFab2 = TestUtilities2.newUser()
                .setField(User.FirstName, 'Test 2')
                .setField(User.LastName, 'Last 2');
        User user2 = (User) uFab2.toSObject();
        
        sfab_FabricatedSObject cFab = TestUtilities2.newCases()
                .setField(Case.OwnerId,user1.Id);
        Case case1 = (Case) cFab.toSObject();
        
        sfab_FabricatedSObject mFab1 = TestUtilities2.newDistributionGroupMember()
                .setField(Distribution_Group_Member__c.Distribution_Group__c, distGroup.Id)
                .setParent('User__r', uFab1)
                .setField(Distribution_Group_Member__c.User__c,user1.Id)
                .setField(Distribution_Group_Member__c.Rep_Limit__c, 5)
                .setField(Distribution_Group_Member__c.Available__c, true)
                .setField(Distribution_Group_Member__c.Next_Up__c, true);
        Distribution_Group_Member__c member1 = (Distribution_Group_Member__c) mFab1.toSObject();
        
        sfab_FabricatedSObject mFab2 = TestUtilities2.newDistributionGroupMember()
                .setField(Distribution_Group_Member__c.Distribution_Group__c, distGroup.Id)
                .setField(Distribution_Group_Member__c.User__c, user2.Id)
                .setField(Distribution_Group_Member__c.Rep_Limit__c, 5)
                .setField(Distribution_Group_Member__c.Available__c, true)
                .setField(Distribution_Group_Member__c.Next_Up__c, false);
        Distribution_Group_Member__c member2 = (Distribution_Group_Member__c)mFab2.toSObject();
        
        List<Distribution_Group_Member__c> members = new List<Distribution_Group_Member__c>();
        members.add(member2);
        members.add(member1);
        
        List<Distribution_Group__c> distGroups = (List<Distribution_Group__c>) fflib_ApexMocksUtils.makeRelationship(List<Distribution_Group__c>.class, new List<Distribution_Group__c>{distGroup},Distribution_Group_Member__c.Distribution_Group__c, new List<List<Distribution_Group_Member__c>> {members});
        
        Test.startTest();
        User user = DistributionGroupsService.getNextUserId(distGroups[0],uow);
        Test.stopTest();
        
        System.assertEquals(user2.Id,user.Id);
        System.assertEquals(1, uow.m_dirtyMapByType.get('Distribution_Group_Member__c').get(member2.Id).get('Total_Open__c'));
        System.assertEquals(2, uow.m_dirtyMapByType.get('Distribution_Group_Member__c').size());
    
    }
    
    @IsTest
    public static void test_createHistory()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Distribution_Group__c distGroup = (Distribution_Group__c) TestUtilities2.newDistributionGroup()
                .setField(Distribution_Group__c.Name, 'Testing')
                .setField(Distribution_Group__c.Distribution_Type__c, 'Load Balanced')
                .setField(Distribution_Group__c.Relationship_Criteria__c, 'IsClosed = false')
                .setField(Distribution_Group__c.ParentObject__c, 'Case')
                .setField(Distribution_Group__c.Field_to_Distribute__c, 'OwnerId')
                .toSObject();
        
        sfab_FabricatedSObject uFab1 = TestUtilities2.newUser()
                .setField(User.FirstName, 'Test 1')
                .setField(User.LastName, 'Last 1');
        User user1 = (User) uFab1.toSObject();
        sfab_FabricatedSObject uFab2 = TestUtilities2.newUser()
                .setField(User.FirstName, 'Test 2')
                .setField(User.LastName, 'Last 2');
        User user2 = (User) uFab2.toSObject();
        
        sfab_FabricatedSObject cFab = TestUtilities2.newCases()
                .setField(Case.OwnerId, user1.Id);
        Case case1 = (Case) cFab.toSObject();
        
        sfab_FabricatedSObject mFab1 = TestUtilities2.newDistributionGroupMember()
                .setField(Distribution_Group_Member__c.Distribution_Group__c, distGroup.Id)
                .setParent('User__r', uFab1)
                .setField(Distribution_Group_Member__c.User__c, user1.Id)
                .setField(Distribution_Group_Member__c.Rep_Limit__c, 5)
                .setField(Distribution_Group_Member__c.Available__c, true)
                .setField(Distribution_Group_Member__c.Next_Up__c, true);
        Distribution_Group_Member__c member1 = (Distribution_Group_Member__c) mFab1.toSObject();
        
        sfab_FabricatedSObject mFab2 = TestUtilities2.newDistributionGroupMember()
                .setField(Distribution_Group_Member__c.Distribution_Group__c, distGroup.Id)
                .setField(Distribution_Group_Member__c.User__c, user2.Id)
                .setField(Distribution_Group_Member__c.Rep_Limit__c, 5)
                .setField(Distribution_Group_Member__c.Available__c, true)
                .setField(Distribution_Group_Member__c.Next_Up__c, false);
        Distribution_Group_Member__c member2 = (Distribution_Group_Member__c) mFab2.toSObject();
        
        List<Distribution_Group_Member__c> members = new List<Distribution_Group_Member__c>();
        members.add(member2);
        members.add(member1);
        
        List<Distribution_Group__c> distGroups = (List<Distribution_Group__c>) fflib_ApexMocksUtils.makeRelationship(List<Distribution_Group__c>.class, new List<Distribution_Group__c>
        {
                distGroup
        }, Distribution_Group_Member__c.Distribution_Group__c, new List<List<Distribution_Group_Member__c>>
        {
                members
        });
        
        Test.startTest();
        DistributionGroupsService.createHistory(distGroups[0], user1, case1, uow);
        Test.stopTest();
        
        System.assertEquals(1,uow.m_newListByType.get('Distribution_Group_History__c').size());
    }
    
    @IsTest
    public static void test_updateOpenCount()
    {
        fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Distribution_Group__c distGroup = (Distribution_Group__c) TestUtilities2.newDistributionGroup()
                .setField(Distribution_Group__c.Name, 'Testing')
                .setField(Distribution_Group__c.Distribution_Type__c, 'Load Balanced')
                .setField(Distribution_Group__c.Relationship_Criteria__c, 'IsClosed = false')
                .setField(Distribution_Group__c.ParentObject__c, 'Case')
                .setField(Distribution_Group__c.Field_to_Distribute__c, 'OwnerId')
                .toSObject();
        
        sfab_FabricatedSObject uFab1 = TestUtilities2.newUser()
                .setField(User.FirstName, 'Test 1')
                .setField(User.LastName, 'Last 1');
        User user1 = (User) uFab1.toSObject();
        sfab_FabricatedSObject uFab2 = TestUtilities2.newUser()
                .setField(User.FirstName, 'Test 2')
                .setField(User.LastName, 'Last 2');
        User user2 = (User) uFab2.toSObject();
        
        sfab_FabricatedSObject cFab = TestUtilities2.newCases()
                .setField(Case.OwnerId, user1.Id);
        Case case1 = (Case) cFab.toSObject();
        
        sfab_FabricatedSObject mFab1 = TestUtilities2.newDistributionGroupMember()
                .setField(Distribution_Group_Member__c.Distribution_Group__c, distGroup.Id)
                .setParent('User__r', uFab1)
                .setField(Distribution_Group_Member__c.User__c, user1.Id)
                .setField(Distribution_Group_Member__c.Rep_Limit__c, 5)
                .setField(Distribution_Group_Member__c.Available__c, true)
                .setField(Distribution_Group_Member__c.Next_Up__c, true);
        Distribution_Group_Member__c member1 = (Distribution_Group_Member__c) mFab1.toSObject();
        
        sfab_FabricatedSObject mFab2 = TestUtilities2.newDistributionGroupMember()
                .setField(Distribution_Group_Member__c.Distribution_Group__c, distGroup.Id)
                .setField(Distribution_Group_Member__c.User__c, user2.Id)
                .setField(Distribution_Group_Member__c.Rep_Limit__c, 5)
                .setField(Distribution_Group_Member__c.Available__c, true)
                .setField(Distribution_Group_Member__c.Next_Up__c, false);
        Distribution_Group_Member__c member2 = (Distribution_Group_Member__c) mFab2.toSObject();
        
        List<Distribution_Group_Member__c> members = new List<Distribution_Group_Member__c>();
        members.add(member2);
        members.add(member1);
        
        List<Distribution_Group__c> distGroups = (List<Distribution_Group__c>) fflib_ApexMocksUtils.makeRelationship(List<Distribution_Group__c>.class, new List<Distribution_Group__c>
        {
                distGroup
        }, Distribution_Group_Member__c.Distribution_Group__c, new List<List<Distribution_Group_Member__c>>
        {
                members
        });
        
        Test.startTest();
        DistributionGroupsService.updateOpenCount(user1.Id, distGroups[0], uow);
        Test.stopTest();
        
        System.assertEquals(0,uow.m_dirtyMapByType.get('Distribution_Group_Member__c').get(member2.Id).get('Total_Open__c'));
        System.assertEquals(1,uow.m_dirtyMapByType.get('Distribution_Group_Member__c').get(member1.Id).get('Total_Open__c'));
        System.assertEquals(2,uow.m_dirtyMapByType.get('Distribution_Group_Member__c').size());
    }
}