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
private class s1m_deal_fuel_test {

    static testMethod void tests1m_deal_fuel() {


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
        testLineItem.PricebookEntryId = testPricebookEntry.Id;
        testLineItem.Quantity = 2;
        testLineItem.UnitPrice = 100;
        insert testLineItem;
        
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
        
		

		 
		// Study Material - Slide Deck / Reference Presos, etc
		S1M_Explain_Collection__c xc = new S1M_Explain_Collection__c(Title__c='Class',
        Type__c = 'Class', Time_to_Complete__c = 5, Description__c = 'Sample Class');
		insert xc; 

		// Actual slide within a deck		
		S1M_Explain_Item__c xi = new S1M_Explain_Item__c(S1M_Explain_Collection__c=xc.Id,
		Body_Text__c = 'This is blue', Name__c='Slide', Order__c = 1);
		insert xi;

		// Name is 		
		S1M_Class__c testClass = new S1M_Class__c();
		testClass.Name = 'Generator Masters';
		insert testClass;
		
		// Match Study materials to Classes
		S1M_Class_Material__c testClassMaterial = new S1M_Class_Material__c();
		testClassMaterial.Study_Material__c = xc.Id;
		testClassMaterial.Class__c = testClass.Id;
		insert testClassMaterial;
		
		// Match Badges with Classes
		S1M_Class_Badge__c testClassBadge = new S1M_Class_Badge__c();
		testClassBadge.Badge__c = testBadge.Id;
		testClassBadge.Class__c = testClass.Id;
		insert testClassBadge;
		
		S1M_Class_Material__c testMaterial = new S1M_Class_Material__c();
		testMaterial.Class__c = testClass.Id;
		testMaterial.Study_Material__c = xc.Id;
		insert testMaterial;
		
		

      System.runAs(p) {
      	
        List<List<List<String>>> myReqBadges = new List<List<List<String>>>(); //getRequiredBadges(List<String> oppIds)
        
        myReqBadges = s1m_deal_fuel.getRequiredBadges(testOppIds);
        
        System.debug('----------------');
        System.debug(myReqBadges);
		System.debug('----------------');      	
      	
      	
         // The following code runs as user 'p' 
         System.debug('Current User: ' + UserInfo.getUserName());
         System.debug('Current Profile: ' + UserInfo.getProfileId());
         
         List<Id> badgeIds = new List<Id>();
         
         badgeIds = s1m_deal_fuel.getUserBadges();
         

          
      }		
      
      
      s1m_deal_fuel.RecommendedMaterials myMaterials = new s1m_deal_fuel.RecommendedMaterials();
      myMaterials.classid = '123';
      myMaterials.description = 'desc';
      myMaterials.documentId = '123';
      myMaterials.timetocomplete = 3;
      myMaterials.title = 'title';
      myMaterials.type = 'quiz';
      
		System.assertEquals('123', myMaterials.classid);
		System.assertEquals('desc', myMaterials.description);
		System.assertEquals('123', myMaterials.documentId);
		System.assertEquals(3, myMaterials.timetocomplete);
		System.assertEquals('title', myMaterials.title);
		System.assertEquals('quiz', myMaterials.type);
      
      
      List<String> testBadgeIds = new List<String>();
      testBadgeIds.add(testBadge.Id);
      
      List<s1m_deal_fuel.RecommendedMaterials> resultClassMaterialsForBadges = new List<s1m_deal_fuel.RecommendedMaterials>();
      
      resultClassMaterialsForBadges = s1m_deal_fuel.getClassMaterialForBadges(testBadgeIds);  
      
      
      


    }
}