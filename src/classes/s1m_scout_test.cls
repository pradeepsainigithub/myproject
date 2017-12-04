/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest (seeAllData=true)
private class s1m_scout_test {


    static testMethod void tests1m_scout_test() {

        Profile pro = [select id from profile where name='Standard User'];
		User p = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8', lastname='Testing', 
		languagelocalekey='en_US',localesidkey='en_US', profileid = pro.Id,timezonesidkey='America/Los_Angeles', Phone='555-123-1234',
		username='standarduser@testorg2.com');
		insert p;


        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;

        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = testAccount.Id;
        testOpp.Name = 'Test Opp';
        testOpp.StageName = 'Prospecting';
        testOpp.CloseDate = System.today() + 5;
        insert testOpp;

        Product2 testProduct = new Product2();
        testProduct.Name = 'Test Product';
        testProduct.ProductCode = 'TestP1';
        insert testProduct;

        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsActive=true AND IsStandard=true LIMIT 1];

        PricebookEntry testPricebookEntry = new PricebookEntry();
        testPricebookEntry.Pricebook2Id = standardPricebook.Id;
        testPricebookEntry.Product2Id = testProduct.Id;
        testPricebookEntry.UnitPrice = 100;
        testPricebookEntry.IsActive = true;
        insert testPricebookEntry;

        OpportunityLineItem testLineItem = new OpportunityLineItem();
        testLineItem.OpportunityId = testOpp.Id;
        testLineItem.PricebookEntryId = testPricebookEntry.Product2Id; //testPricebookEntry.Id;
        testLineItem.Quantity = 2;
        testLineItem.UnitPrice = 100;
        
        // Our test badge
        S1M_Badge__c testBadge = new S1M_Badge__c();
        testBadge.Name = 'Expert Badge for Test Product';
        insert testBadge;

		// Bind our badbge in the junciton table...        
        S1M_Product_Badge__c testProdBadge = new S1M_Product_Badge__c();
        testProdBadge.Badge__c = testBadge.Id;
        testProdBadge.Product__c = testProduct.Id; //testPricebookEntry.Product2Id;
        insert testProdBadge;
        
        // Bind user to badge
        S1M_User_Badges__c testUserBadge = new S1M_User_Badges__c();
        testUserBadge.Badge__c = testBadge.Id;
        testUserBadge.User__c = p.Id;
        insert testUserBadge;
        
        List<String> testOppIds = new List<String>();
        testOppIds.add(testOpp.Id);
        
        List<List<List<String>>> myReqBadges = new List<List<List<String>>>(); //getRequiredBadges(List<String> oppIds)
        
        myReqBadges = s1m_scout.getRequiredBadges(testOppIds);
        
        System.debug('----------------');
        System.debug(myReqBadges);
		System.debug('----------------');


		Double myLatd = Double.valueOf('42.350468');
		Double myLond = Double.valueOf('-71.074126');

		
		s1m_scout.LocalOpp myLocalOpp = new s1m_scout.LocalOpp();
		
		myLocalOpp.AccountName = 'account';
		myLocalOpp.Interest = 'prod';
		myLocalOpp.OpportunityId = '123';
		myLocalOpp.PersonEmail = 'doug@aol.com';
		myLocalOpp.PersonName = 'doug';
		myLocalOpp.PersonPhone = '555';
		myLocalOpp.Type = 'type';
		myLocalOpp.Latitude = myLatd;
		myLocalOpp.Longitude = myLond;
		
		System.assertEquals('account', myLocalOpp.AccountName);
		System.assertEquals('prod', myLocalOpp.Interest);
		System.assertEquals('123', myLocalOpp.OpportunityId);
		System.assertEquals('doug@aol.com', myLocalOpp.PersonEmail);
		System.assertEquals('doug', myLocalOpp.PersonName);
		System.assertEquals('555', myLocalOpp.PersonPhone);
		System.assertEquals('type', myLocalOpp.Type);
		System.assertEquals(myLatd, myLocalOpp.Latitude);
		System.assertEquals(myLond, myLocalOpp.Longitude);
		
		
		Decimal myLatdec = Decimal.valueOf('42.350468');
		Decimal myLondec = Decimal.valueOf('-71.074126');				
		
		List<s1m_scout.LocalOpp> testOpps = s1m_scout.getLocalOpportunities(myLatdec, myLondec, '50', '', '');
		
		

    }
}