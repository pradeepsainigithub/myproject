public with sharing class s1m_metro_news {
	
	private final Account myAccount;

	public s1m_metro_news(ApexPages.StandardController controller) {
		this.myAccount = (Account)controller.getRecord();
	}

	public class NewsAccount {
	   public Id Id {
	      get { return Id; }
	      set { Id = value; }
	   }
	} 

	@RemoteAction
    public static Set<String> getAccountFilter(String sFilter) {
    	    	
    	String newsQuery = '';    	
    	Set<String> newsItems = new set<string>(); 
    	
    	sFilter = String.escapeSingleQuotes(sFilter);
        	
    	if (sFilter == 'thisquarter')
    	{	
    		newsQuery = 'Select o.AccountId From Opportunity o WHERE o.CloseDate = THIS_QUARTER';
	    	for(Opportunity newsLine : Database.query(newsQuery)) {	    	
				// Check to see if the value already exists
			  	if (newsItems.contains(newsLine.AccountId))
			  	{
			  		
			  	}
			  	else {
			  		newsItems.add(newsLine.AccountId);
			  	}
		  	}
		  	return newsItems;
    	} 
    	else if (sFilter == 'prob50')
    	{
    		newsQuery = 'Select o.Probability, o.AccountId From Opportunity o WHERE o.Probability > 50';
	    	for(Opportunity newsLine : Database.query(newsQuery)) {	    	
			  	// Check to see if the value already exists
			  	if (newsItems.contains(newsLine.AccountId))
			  	{
			  		
			  	}
			  	else {
			  		newsItems.add(newsLine.AccountId);
			  	}
		  	}
		  	return newsItems;    		
    	}
    	else if (sFilter == 'stagenegotiation')
    	{
    		newsQuery = 'Select o.AccountId From Opportunity o WHERE o.StageName = \'Negotiation/Review\'';
	    	for(Opportunity newsLine : Database.query(newsQuery)) {	    	
			  	// Check to see if the value already exists
			  	if (newsItems.contains(newsLine.AccountId))
			  	{
			  		
			  	}
			  	else {
			  		newsItems.add(newsLine.AccountId);
			  	}
		  	}
		  	return newsItems;    		
    	}
    	else if (sFilter == 'meetingtoday')
    	{
    		newsQuery = 'SELECT AccountId FROM Event WHERE ActivityDate = TODAY ORDER BY StartDateTime DESC LIMIT 20';
	    	for(Event newsLine : Database.query(newsQuery)) {	    	
			  	// Check to see if the value already exists
			  	if (newsItems.contains(newsLine.AccountId))
			  	{
			  		
			  	}
			  	else {
			  		newsItems.add(newsLine.AccountId);
			  	}
		  	}
		  	return newsItems;    		
    	}
    	else if (sFilter == 'last90')
    	{
    		newsQuery = 'SELECT Id FROM Account WHERE LastViewedDate = LAST_N_DAYS:30 AND Active__c = \'Yes\' ORDER BY LastViewedDate DESC LIMIT 20';
	    	for(Account newsLine : Database.query(newsQuery)) {	    	
			  	// Check to see if the value already exists
			  	if (newsItems.contains(newsLine.Id))
			  	{
			  		
			  	}
			  	else {
			  		newsItems.add(newsLine.Id);
			  	}
		  	}
		  	return newsItems;    		
    	}
    	else {
			newsQuery = 'SELECT Id FROM Account WHERE LastViewedDate = LAST_N_DAYS:30 AND Active__c = \'Yes\' ORDER BY LastViewedDate DESC LIMIT 20';    
	    	for(Account newsLine : Database.query(newsQuery)) {	    	
			  	// Check to see if the value already exists
			  	if (newsItems.contains(newsLine.Id))
			  	{
			  		
			  	}
			  	else {
			  		newsItems.add(newsLine.Id);
			  	}
		  	}
		  	return newsItems;
    	}		    
    	
    	
    }

}