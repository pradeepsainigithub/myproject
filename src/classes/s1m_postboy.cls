public with sharing class s1m_postboy {

	@RemoteAction
	public static List<ContentWorkspace> getWorkspaces()
	{
		return [SELECT Id,Name FROM ContentWorkspace ORDER BY Name ASC NULLS FIRST LIMIT 100];
	}
		

    @RemoteAction
    public static List<ContentVersion> getDocuments(String sLibraryId, String sSearchTerm, Integer offsetcounter) {
    	
    	// Default list size for documents to be sent to S1 in list - paging will happen client side
    	Integer list_size = 100;
        
        // If getting from a Library
        if (sLibraryId != 'all' && sLibraryId != 'recent')
        {
        	ID workspaceId = Id.valueOf(sLibraryId);
			List <ContentVersion> allDocuments = [SELECT ContentDocumentId, ContentSize,ContentUrl,
        		CreatedDate,Description,FileType,Id,IsDeleted,IsLatest,	PathOnClient,
        		TagCsv,Title,VersionNumber FROM ContentVersion 
        		WHERE IsLatest = true AND PublishStatus = 'P' AND IsDeleted = false AND ContentDocument.ParentId = :workspaceId LIMIT :list_size OFFSET :offsetcounter];
        	return allDocuments; 
        }
        else
        {
        	if (sLibraryId == 'recent') { 
        		List<id> recentlyViewedDocIds = new List<id>();

				for(RecentlyViewed recentView : [SELECT Id FROM RecentlyViewed WHERE Type = 'ContentDocument' ORDER BY LastViewedDate DESC NULLS FIRST LIMIT :list_size]) {
				    recentlyViewedDocIds.add(recentView.Id);
				}
				return [SELECT ContentDocumentId,ContentSize,ContentUrl,
        				CreatedDate,Description,FileType,Id,IsDeleted,IsLatest,
        				PathOnClient,
        				TagCsv,Title,VersionNumber FROM ContentVersion 
				        		WHERE IsLatest = true AND PublishStatus = 'P' AND IsDeleted = false AND ContentDocumentId IN :recentlyViewedDocIds LIMIT :list_size OFFSET :offsetcounter];
        		
        	}
        	else {
	        	if (sSearchTerm != '')
	        	{
	        		List<ContentVersion> searchResults = New List<ContentVersion>();
					List<List<ContentVersion>> docsMatched = [FIND :sSearchTerm IN ALL FIELDS RETURNING ContentVersion(ContentDocumentId,
						ContentSize,ContentUrl, CreatedDate,Description,FileType,Id,IsDeleted,IsLatest,
        				PathOnClient, TagCsv,Title,VersionNumber ORDER BY Title)];
					searchResults = ((List<ContentVersion>)docsMatched[0]);
					return searchResults;
	        			
	        	}
	        	else
	        	{
		        	return [SELECT ContentDocumentId,ContentSize,ContentUrl, CreatedDate,Description,FileType,Id,IsDeleted,IsLatest,
        				PathOnClient,TagCsv,Title,VersionNumber FROM ContentVersion WHERE 
        				IsLatest = true AND PublishStatus = 'P' AND IsDeleted = false ORDER BY Title LIMIT :list_size OFFSET :offsetcounter];
	        	}
        	}
        }
    }

    public s1m_postboy(ApexPages.StandardController controller){
    } 
    
    @RemoteAction
    public static Boolean communitySendPermission() {
		if (Schema.sObjectType.User.isCreateable() && Schema.sObjectType.Profile.fields.Id.isAccessible() && Schema.sObjectType.S1M_Community_Collateral_Share__c.isCreateable()) {
			return true;
		}
		else {
			return false;
		}
    }
    
    @RemoteAction
    public static String sendEmailDocs(String emailAddress, List<String> docIds, String contactId, String sendMethod) {
        
        Contact selectedContact = [select Id, Name, Email, FirstName, LastName from Contact where Id=:contactId];
                
		List<String> values = new List<String>(docIds);
		
		Set<Id> docIdSet = new Set<Id>();
		
		for (String docId : values) {
		    docIdSet.add(Id.valueOf(docId));
		}
		
		List<ContentVersion> allAttachment = [SELECT ContentDocumentId,ContentSize,ContentUrl, CreatedDate,Description,FileType,Id,IsDeleted, IsLatest,PathOnClient, VersionData, TagCsv,Title,VersionNumber FROM ContentVersion WHERE ContentDocumentId IN :docIdSet];
                        
        Integer numAtts = docIds.size();
                 
        if (sendMethod == 'community')
        {
        	
        	// Check that the user is a Community User - if not, we will create the community user for them
        	List<User> userMatches = [SELECT Username FROM User WHERE Username = :selectedContact.Email LIMIT 1];
        	
        	if(userMatches.size() > 0 ){
				System.debug('User with ID found: ' + userMatches[0].id);
			}
			else {
				
				// Check to see if the active user can create a user object and the Id field in the profile object
				if (Schema.sObjectType.User.isCreateable() && Schema.sObjectType.Profile.fields.Id.isAccessible()) {
		
					// Get the correct Profile ID for the community user type - customize here for name that has been setup
					Profile[] profiles = [Select id FROM Profile p WHERE p.Name LIKE '%Customer Community User Extended%'];
					String sSelectedProfileId = profiles[0].id;
			
					String sUsername = selectedContact.Email;
					String sFirstName = selectedContact.FirstName;
					String sLastName = selectedContact.LastName;
					String sFullName = sFirstName + ' ' + sLastName;
					
					// Ensure that the last name has enough charaters, so as to not create index exception with substring
					String sLastNameAlias = sLastName + '       ';
					String sAlias = sFirstName.substring(0, 1) + sLastNameAlias.substring(0,7).trim();
			
					Database.DMLOptions dmo = new Database.DMLOptions();
					dmo.EmailHeader.triggerUserEmail = true;
					User u = new User(alias = sAlias, email=sUsername, emailencodingkey='UTF-8', lastname=sLastName, languagelocalekey='en_US',  localesidkey='en_US', profileid = sSelectedProfileId, contactId=selectedContact.Id, timezonesidkey='America/Los_Angeles', username=sUsername);
					u.setOptions(dmo);
					insert u;
				}
				else
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient access - cannot create User'));
					return 'error';
				}
			}
        	// ** End user check / creation process
        	
			// *** Community - Post Documents to Feed for Object Shared with Contact
	        if(numAtts > 0)
	        {	
	        		// Check to see if a Community Share object exists
	                String postRecordTarget = '';
	                    
	                List<S1M_Community_Collateral_Share__c> communityShare = [SELECT Id FROM S1M_Community_Collateral_Share__c WHERE Contact__c = :contactId LIMIT 1];
	                    
	                if (communityShare.size() < 1)
	                {
	                	if (Schema.sObjectType.S1M_Community_Collateral_Share__c.isCreateable()) {
		                 	// Create a new Community Share object and assign it to the Contact
		                   	S1M_Community_Collateral_Share__c newCommunityShare = new S1M_Community_Collateral_Share__c ();
							newCommunityShare.Contact__c = selectedContact.Id;
							insert newCommunityShare;
							postRecordTarget = newCommunityShare.Id;
	                	}
	                	else {
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient access - cannot create Community Share'));
							return 'error';	                		
	                	}
	                }
	                else
	                {
	                 	postRecordTarget = communityShare[0].Id;
	                }
	        		// Done with check for Community Share object
	        	
	                for (Integer i = 0; i < numAtts; i++)
					{
	                    
	                    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
						ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
						ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
						messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
												
						if (allAttachment[i].Description != null)
						{
							textSegmentInput.text = allAttachment[i].Description;
						}
						else
						{
							textSegmentInput.text = 'For review';
						}

						messageBodyInput.messageSegments.add(textSegmentInput);
						feedItemInput.body = messageBodyInput;

						if (allAttachment[i].FileType != 'LINK')
						{
							ConnectApi.ContentAttachmentInput attachmentInput = new ConnectApi.ContentAttachmentInput();
							attachmentInput.contentDocumentId = allAttachment[i].ContentDocumentId;
							feedItemInput.attachment = attachmentInput;
							feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
		                    ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, postRecordTarget, feedItemInput, null);
						}    
	            }
        	
        	}
        	
        	return 'ok';
        }
        else	
        {        	
	        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
    	    List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
	
			Integer iLinkAttach = 0;
	
	        if(numAtts > 0)	
	        {
	                for (Integer i = 0; i < numAtts; i++)	
	                {	
						if (allAttachment[i].FileType != 'LINK')
						{
		                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
		                    efa.setFileName(allAttachment[i].PathOnClient);
		                    efa.setBody(allAttachment[i].VersionData);
		                    efa.setContentType('application/vnd.openxmlformats-officedocument.wordprocessingml.template');
		                    efaList.add(efa);
						}
						else
						{
							iLinkAttach += 1;
						}
	                }
		
		        String addresses = selectedContact.Email;
				        
		        String[] toAddresses = addresses.split(':', 0);
		
		        email.setSubject('Documents Requested');
		        email.setToAddresses(toAddresses);
		        email.setPlainTextBody('Please see attached.');
		        
		        if (iLinkAttach == 0) {
			        if(numAtts > 0)
			        {
			            email.setFileAttachments(efaList);
				        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
			        }
		        }
		        else
		        {
		        	return 'cannot attach link';
		        }
		
	        }
	        return 'ok';
	    }
	    
    }
    
}