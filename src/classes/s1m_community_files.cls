public with sharing class s1m_community_files {

	public User myUser;

    public s1m_community_files(){
    }
    
    public class CommunityDoc {
	   public String Id {
	      get { return Id; }
	      set { Id = value; }
	   }
	   public String ContentFileName {
	   		get { return ContentFileName; }
	   		set {ContentFileName = value; }
	   }
	   public String ContentDescription {
	   		get {return ContentDescription;}
	   		set {ContentDescription = value;}
	   }
	   public Integer ContentSize {
	   		get {return ContentSize; }
	   		set {ContentSize = value; }
	   }
	   public String ContentType {
	   		get {return ContentType;}
	   		set {ContentType = value;}
	   }
	   public String Title {
	   		get {return Title;}
	   		set {Title = value;}
	   }
	   public String RelatedRecordId {
	   		get {return RelatedRecordId;}
	   		set {RelatedRecordId = value;}
	   }
	}
    
    public List<CommunityDoc> getFeedItems() {
		
    	List<CommunityDoc> CommunityDocList = new List<CommunityDoc>();

		String oppQuery = 'Select Parent.Id, CommentCount,ContentDescription,ContentFileName,ContentSize, ' +
		'ContentType,CreatedById,CreatedDate,Id,InsertedById,IsDeleted,LastModifiedDate,LikeCount,LinkUrl,' +
		'ParentId,RelatedRecordId,SystemModstamp,Title,Type,Visibility From CollaborationGroupFeed';

    	for(CollaborationGroupFeed docLine : Database.query(oppQuery)) {
	    	
	    	// Must be an actual file
	    	if (docLine.ContentSize > 0) {
			  	CommunityDoc myCommunityDoc = new CommunityDoc();
			  	myCommunityDoc.Id = docLine.Id;
			  	myCommunityDoc.ContentFileName = docLine.ContentFileName;
			  	myCommunityDoc.ContentDescription = docLine.ContentDescription;
			  	myCommunityDoc.ContentSize = docLine.ContentSize;
			  	myCommunityDoc.ContentType = docLine.ContentType;
			  	myCommunityDoc.Title = docLine.Title;
			  	myCommunityDoc.RelatedRecordId = docLine.RelatedRecordId;
			  	CommunityDocList.add(myCommunityDoc);
	    	}
	  	}
	  	
	  	return CommunityDocList;
	}
	
	
	public List<S1M_Community_Collateral_Share__Feed> getChatterFeedItems() {		
		return [SELECT ContentDescription,ContentFileName,ContentSize,ContentType,CreatedById,CreatedDate,Id,
		InsertedById,IsDeleted,LastModifiedDate,LikeCount,LinkUrl,ParentId,RelatedRecordId,
		SystemModstamp,Title,Type FROM S1M_Community_Collateral_Share__Feed LIMIT 100];
	}	
	
    public User getMyUser() {
    	String ownerId = [SELECT CreatedById FROM S1M_Community_Collateral_Share__c LIMIT 1].CreatedById;    	
        User myUser = [SELECT Email, Name, MobilePhone, FullPhotoUrl FROM User WHERE User.ID = :ownerId LIMIT 1];
        return myUser;
    }
	

}