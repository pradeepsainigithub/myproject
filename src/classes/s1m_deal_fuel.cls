public with sharing class s1m_deal_fuel {
	
	private final Opportunity myOppty;

	public s1m_deal_fuel(ApexPages.StandardController controller) {
		this.myOppty = (Opportunity)controller.getRecord();
	}

	public List<Id> listOfRequiredBadges(Id oppId) {

		List<Id> prodIds = new List<Id>(new Map<Id, OpportunityLineItem>([Select PricebookEntry.Product2Id 
		From OpportunityLineItem WHERE OpportunityId = :oppId]).keySet());
	
		return prodIds;
	}

	
	@RemoteAction
	public static List<Id> getUserBadges() {
		
		Id uId = UserInfo.getUserId();

		List<Id> badgeIds = new List<Id>(new Map<Id, S1M_Badge__c>([Select s.Id From S1M_Badge__c s 
		WHERE s.Id IN (SELECT Badge__c FROM S1M_User_Badges__c WHERE User__c = :uId)]).keySet());
	
		return badgeIds;
		
	}
	
	
	public class RecommendedMaterials {
	   public String type {
	      get { return type; }
	      set { type = value; }
	   }
	   public String title {
	      get { return title; }
	      set { title = value; }
	   }
	   public String description {
	      get { return description; }
	      set { description = value; }
	   }
	   public Decimal timetocomplete {
	      get { return timetocomplete; }
	      set { timetocomplete = value; }
	   }
	   public String materialid {
	      get { return materialid; }
	      set { materialid = value; }
	   }
	   public String classid {
	      get { return classid; }
	      set { classid = value; }
	   }
	   public String documentId {
	   	  get { return documentId; }
	   	  set { documentId = value; }
	   }
	}

	

    @RemoteAction
	public static List<RecommendedMaterials> getClassMaterialForBadges(List<String> badgeIds)
	{		
		List<id> listSingleClassIds = new List<id>();	
		
		for(S1M_Class_Badge__c classLine : [Select Class__c, Badge__c From S1M_Class_Badge__c WHERE Badge__c IN :badgeIds]) {
		    listSingleClassIds.add(classLine.Class__c);
		}
		
		List<RecommendedMaterials> classMaterials = new List<RecommendedMaterials>();
		
		for(S1M_Class_Material__c materialLine : [Select s.Study_Material__r.Type__c, s.Study_Material__r.Description__c, 
		s.Study_Material__r.Title__c, s.Study_Material__r.Time_to_Complete__c, s.Study_Material__c, s.Name, 
		s.Class__c From S1M_Class_Material__c s WHERE s.Class__c IN :listSingleClassIds ORDER BY 
		s.Study_Material__r.Type__c ASC]) {
		  	
		  	RecommendedMaterials myMaterials = new RecommendedMaterials();
		  	myMaterials.type = materialLine.Study_Material__r.Type__c;
		  	myMaterials.title = materialLine.Study_Material__r.Title__c;
		  	myMaterials.description = materialLine.Study_Material__r.Description__c;
		  	myMaterials.timetocomplete = materialLine.Study_Material__r.Time_to_Complete__c;
		  	myMaterials.materialid = materialLine.Study_Material__c;
		  	myMaterials.classid = materialLine.Class__c;
		  	
		  	if (myMaterials.type == 'Document')
		  	{
		  		String docLinkId = [SELECT RelatedRecordId FROM FeedItem WHERE ParentId = :myMaterials.materialid LIMIT 1].RelatedRecordId;
		  		myMaterials.documentId = docLinkId;
		  	}
		  	
		  	classMaterials.add(myMaterials);
		}
		
		return classMaterials;
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

		for(S1M_Product_Badge__c badge : [SELECT s.Badge__c, s.Badge__r.Icon__c, s.Badge__r.Name, s.Product__c FROM S1M_Product_Badge__c s WHERE 
		s.Product__c IN :listSingleProductIds]) {
		  listBadgeIds.add(new String[]{badge.Badge__c, badge.Product__c, badge.Badge__r.Icon__c, badge.Badge__r.Name});
		}
		
		finalList.add(listProductIds);
		finalList.add(listBadgeIds);
		
		// Final output here
		return finalList;
	}

}