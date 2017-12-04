public with sharing class s1m_scout {
 
    public s1m_scout() { } // empty constructor

	public class LocalOpp {
	   public String AccountName {
	      get { return AccountName; }
	      set { AccountName = value; }
	   }
	   public Id Id {
	      get { return Id; }
	      set { Id = value; }
	   }	
	   public String Type {
	      get { return Type; }
	      set { Type = value; }
	   }	
	   public String Interest {
	      get { return Interest; }
	      set { Interest = value; }
	   }		   	      
	   public String OpportunityId {
	      get { return OpportunityId; }
	      set { OpportunityId = value; }
	   }
	   public List<Opportunity> Opp {
	      get { return Opp; }
	      set { Opp = value; }	   	
	   }
	   public Double Latitude {
	   		get { return Latitude; }
	   		set { Latitude = value; }
	   }
	   public Double Longitude {
	   		get { return Longitude; }
	   		set { Longitude = value; }
	   }
	   public String PersonName {
	   		get { return PersonName; }
	   		set { PersonName = value;}
	   }
	   public String PersonPhone {
	   		get { return PersonPhone; }
	   		set { PersonPhone = value;}
	   }
	   public String PersonEmail {
	   		get { return PersonEmail; }
	   		set { PersonEmail = value;}
	   }
	   	   	   
	}


	@RemoteAction
	public static List<Id> getUserBadges() {
		
		Id uId = UserInfo.getUserId();

		List<Id> badgeIds = new List<Id>(new Map<Id, S1M_Badge__c>([Select s.Id From S1M_Badge__c s 
		WHERE s.Id IN (SELECT Badge__c FROM S1M_User_Badges__c WHERE User__c = :uId)]).keySet());
	
		return badgeIds;		
	}
	
	

    @RemoteAction
	public static List<List<List<String>>> getRequiredBadges(List<String> oppIds)
	{
		
		List<List<List<String>>> finalList = new List<List<List<String>>>();
		List<id> listSingleProductIds = new List<id>();
		List<List<String>> listProductIds = new List<List<String>>();
		
		for(OpportunityLineItem opptyLine : [Select o.OpportunityId, o.PricebookEntry.Product2Id 
		From OpportunityLineItem o WHERE o.OpportunityId IN :oppIds]) {
		    listSingleProductIds.add(opptyLine.PricebookEntry.Product2Id);
		    listProductIds.add(new String[]{opptyLine.OpportunityId, opptyLine.PricebookEntry.Product2Id});
		}
		
		List<List<String>> listBadgeIds = new List<List<String>>();
		for(S1M_Product_Badge__c badge : [SELECT Badge__c, Product__c FROM S1M_Product_Badge__c WHERE 
		Product__c IN :listSingleProductIds]) {
		  listBadgeIds.add(new String[]{badge.Badge__c, badge.Product__c});
		}
		
		finalList.add(listProductIds);
		finalList.add(listBadgeIds);
		
		// Final output here
		return finalList;
	}



    @RemoteAction
    public static List<LocalOpp> getLocalOpportunities(Decimal clat, Decimal clong, String dist, String sIndustry, String sRating) {
    	
    	List<LocalOpp> LocalOpps = new List<LocalOpp>();

    	String sLat = String.escapeSingleQuotes(String.valueOf(clat));
    	String sLon = String.escapeSingleQuotes(String.valueOf(clong));

		String sFilter = '';
		
		if (sRating != '' && sRating != 'none')
		{
			sFilter += ' Rating = \'' + String.escapeSingleQuotes(sRating) + '\' AND ';
		}

		if (sIndustry != '' && sIndustry != 'none')
		{
			sFilter += ' Industry = \'' + String.escapeSingleQuotes(sIndustry) + '\' AND ';
		}
		
		//sIndustry

		String oppQuery = 'Select a.Id, a.Name, a.S1M_Location__Latitude__s, a.S1M_Location__Longitude__s, ' +
			'(Select Id, Name, Description, CloseDate, StageName, Amount,' + 
    		'Probability From Opportunities WHERE IsWon = false AND IsClosed = false) From Account a WHERE ' +
    		sFilter +
    		' DISTANCE(a.S1M_Location__c,' +
			'GEOLOCATION(' + sLat + ' , ' + sLon + '), \'mi\') < ' + dist +
    		'ORDER BY DISTANCE(a.S1M_Location__c, GEOLOCATION(' + sLat + ' , ' + sLon + '), \'mi\') ' + 
    		' LIMIT 20';

    	for(Account accntLine : Database.query(oppQuery)) {
	    	
		  	LocalOpp myLocalOpp = new LocalOpp();
		  	myLocalOpp.Id = accntLine.Id;
		  	myLocalOpp.AccountName = accntLine.Name; 
		  	myLocalOpp.Opp = accntLine.Opportunities;
		  	
		  	myLocalOpp.Latitude = accntLine.S1M_Location__Latitude__s;
		  	myLocalOpp.Longitude = accntLine.S1M_Location__Longitude__s;
		  	LocalOpps.add(myLocalOpp);
	  	}

	  	return LocalOpps;		
    }



}