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
@isTest
private class s1m_metro_news_test {

    static testMethod void tests1m_metro_news() {
        // TO DO: implement unit test
        
        Account a = new Account(Name='My Account');
		insert a;
  
 		Opportunity o = new Opportunity(AccountId=a.Id, Name='My Opportunity', 
		StageName='Negotiation/Review', CloseDate=Date.today(), Probability=Decimal.valueOf('70'));
		insert o;
		
		testGetAccountFilter('', 'SELECT Id FROM Account WHERE LastViewedDate = LAST_N_DAYS:30 AND Active__c = \'Yes\' ORDER BY LastViewedDate DESC LIMIT 20');
		testGetOppFilter('thisquarter', 'Select o.AccountId From Opportunity o WHERE o.CloseDate = THIS_QUARTER');
		testGetOppFilter('prob50', 'Select o.Probability, o.AccountId From Opportunity o WHERE o.Probability > 50');
		testGetOppFilter('stagenegotiation', 'Select o.AccountId From Opportunity o WHERE o.StageName = \'Negotiation/Review\'');
		testGetAccountFilter('last90', 'SELECT Id FROM Account WHERE LastViewedDate = LAST_N_DAYS:30 AND Active__c = \'Yes\' ORDER BY LastViewedDate DESC LIMIT 20');
		testGetAccountFilter('meetingtoday', 'SELECT AccountId FROM Event WHERE ActivityDate = TODAY ORDER BY StartDateTime DESC LIMIT 20');
     
     	//String sTestId = '123';
     	s1m_metro_news.NewsAccount myNews = new s1m_metro_news.NewsAccount();
     	myNews.Id = a.Id;

		System.assertEquals(myNews.Id, a.Id); 
		     	
        
    }

    static  void testGetOppFilter(String filterval, String newsQuery) {
    	
    	Set<String> newsItems = new set<string>(); 
		
	    	for(Opportunity newsLine : Database.query(newsQuery)) {	 
			 // Check to see if the value already exists
			 if (newsItems.contains(newsLine.AccountId))
			 {
			  		
			 }
			 else {
			 	newsItems.add(newsLine.AccountId);
			 }
	  	}
		
		Set<String> matchingOpps = s1m_metro_news.getAccountFilter(filterval);
		
		System.assertEquals(matchingOpps, newsItems); 
    	
    }
    
    
    static  void testGetAccountFilter(String filterval, String newsQuery) {
    	
    	Set<String> newsItems = new set<string>(); 
		
	    	for(Account newsLine : Database.query(newsQuery)) {	 
		  	// Check to see if the value already exists
		  	if (newsItems.contains(newsLine.Id))
		  	{
		  		
		  	}
		  	else {
		  		newsItems.add(newsLine.Id);
		  	}
	  	}
		
		Set<String> matchingAccounts = s1m_metro_news.getAccountFilter(filterval);
		
		System.assertEquals(matchingAccounts, newsItems); 
    	
    }
    
}