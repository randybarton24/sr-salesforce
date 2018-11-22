public class ProviderUtilities {

	public static Map<Id, Account> getRelatedAccounts(Provider__c[] newProviders) {

    	Set<ID> acctIds = new Set<ID>();

    	for(Provider__c p : newProviders) {
    		acctIds.add(p.Bill_to_Account__c);
    	}

    	Map<Id, Account> results = new Map<Id, Account>([SELECT Id,
	    	Industry, 
	    	Sub_vertical__c 
	    	FROM Account
	   		WHERE Id IN: acctIds]);

    	return results;
	}

	public static void newHealthgradesCase(Map<Id,Provider__c> oldProviderMap, Provider__c[] updatedProviders) {

		String HG_QUEUE_ID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Healthgrades Onboarding Queue'].Id;
		Map<Id, SObject> mapInsertSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapUpdateSObject = new Map<Id, SObject>();
      	Map<Id, SObject> mapDeleteSObject = new Map<Id, SObject>();

		for(Provider__c p : updatedProviders) {

			if(oldProviderMap.get(p.Id).Premium_Member__c == false && p.Premium_Member__c == true) {

				Case newCase = new Case(Subject = 'Healthgrades Implementation: ' + p.Name,
					AccountId = p.Bill_to_Account__c,
					ContactId = p.Related_Contact__c,
					RecordTypeId = SRUtilities.getRecordTypeMap('Case').get('Support').getRecordTypeId(),
					Product__c = 'Healthgrades',
					Origin = 'Web',
					Category__c = 'Training',
					Topics__c = 'General Training',
					Description = 'Healthgrades URL: ' + p.Healthgrades_ID__c + '\n' + 'Provider NPI: ' + p.NPI__c,
					OwnerId = HG_QUEUE_ID);

				mapInsertSObject.put(p.Id, newCase);
			}
		}

		SRUtilities.runDml(mapInsertSObject, mapUpdateSObject, mapDeleteSObject, 'ProviderUtilities.newHealthgradesCase');
	}

	public static void syncOnPremiumChange(Map<Id,Provider__c> oldProviderMap, Provider__c[] updatedProviders) {

		Set<Id> providerIds = new Set<Id>();

		for(Provider__c p : updatedProviders) {

			if(oldProviderMap.get(p.Id).Premium_Member__c != p.Premium_Member__c) {

				providerIds.add(p.Id);
			}
		}

		if(!providerIds.isEmpty()) { 
			AppAdminAPIClass.postHealthgradesStatus(providerIds); 
		}
	}

	public static void cleanHealthgradesUrl(Provider__c[] newProviders) {

		for(Provider__c p : newProviders) {

			if(p.Healthgrades_ID__c.contains('?')) {

				p.Healthgrades_ID__c = p.Healthgrades_ID__c.split('\\?')[0];
			}
		}
	}

	public static void setRecordType(Provider__c[] updatedProviders, Map<Id, Account> relatedAccountMap) {

		for(Provider__c p : updatedProviders) {

			if(p.RecordType_Override__c) continue;

			Account a = relatedAccountMap.get(p.Bill_to_Account__c);

			if(a.Industry == 'Dental' && a.Sub_vertical__c != 'Orthodontistry') {

				p.RecordTypeId = SRUtilities.getRecordTypeMap('Provider__c').get('Dentistry').getRecordTypeId();
			
			} else if(a.Sub_vertical__c == 'Dermatology') {

				p.RecordTypeId = SRUtilities.getRecordTypeMap('Provider__c').get('Dermatology').getRecordTypeId();
			
			} else if(a.Sub_vertical__c == 'Ophthalmology') {

				p.RecordTypeId = SRUtilities.getRecordTypeMap('Provider__c').get('Ophthalmology').getRecordTypeId();
			
			} else if(a.Sub_vertical__c == 'Optometry') {

				p.RecordTypeId = SRUtilities.getRecordTypeMap('Provider__c').get('Optometry').getRecordTypeId();
			
			} else if(a.Sub_vertical__c == 'Orthodontistry') {

				p.RecordTypeId = SRUtilities.getRecordTypeMap('Provider__c').get('Orthodontics').getRecordTypeId();
			
			} else if(a.Sub_vertical__c == 'Cosmetic Surgery') {

				p.RecordTypeId = SRUtilities.getRecordTypeMap('Provider__c').get('Plastic Surgery').getRecordTypeId();
                
            } else if(a.Sub_Vertical__c == 'Podiatry') {
                
                p.RecordTypeId = SRUtilities.getRecordTypeMap('Provider__c').get('Podiatry').getRecordTypeId();
            
            }
		}
	}
}