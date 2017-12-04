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

// JMB - needed due to Connect API... 

@IsTest(SeeAllData=true)
private class s1m_postboy_test {

    static testMethod void tests1m_postboy() {
        
        // getWorkspaces method start
        List<ContentWorkspace> actualWorkspaces = [SELECT Id,Name FROM ContentWorkspace ORDER BY Name ASC NULLS FIRST]; 
        List<ContentWorkspace> testWorkspaces = s1m_postboy.getWorkspaces();
        System.assertEquals(testWorkspaces, actualWorkspaces);
        // getWorkspaces method end
        
        
        // getDocuments method start 
        // ... Create content for test
		ContentVersion testContentInsert = new ContentVersion(); 
		testContentInsert.ContentURL='http://www.google.com/'; 
		testContentInsert.Title = 'Google.com'; 
		testContentInsert.Description = 'Test doc';
		insert testContentInsert;
				
		ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :testContentInsert.Id]; 		
		
		ContentWorkspace testGDWorkspace = [SELECT Id,Name FROM ContentWorkspace][0]; 
		ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc(); 
		
		newWorkspaceDoc.ContentWorkspaceId = testGDWorkspace.Id; 
		newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId; 
		insert newWorkspaceDoc;		


		// ... End create content for test

		String sAllLibraryId =  'all';
        Integer offsetcounter = 100;
        String sAllSearchTerm = '';
        Integer list_size = 100;
       
		// Test - All Documents		        
        List<ContentVersion> testAllDocs = s1m_postboy.getDocuments(sAllLibraryId, sAllSearchTerm, offsetcounter);
		
		List<ContentVersion> actualAllDocs = [SELECT ContentDocumentId,ContentSize,ContentUrl, CreatedDate,Description,FileType,Id,IsDeleted,IsLatest,
        				PathOnClient,TagCsv,Title,VersionNumber FROM ContentVersion WHERE 
        				IsLatest = true AND IsDeleted = false ORDER BY Title LIMIT 100 OFFSET :offsetcounter];        		
		
		System.assertEquals(testAllDocs, actualAllDocs);

		
		// Test - Recent Documents
		String sRecentLibraryId =  'recent';

		List<id> recentlyViewedDocIds = new List<id>();

		for(RecentlyViewed recentView : [SELECT Id FROM RecentlyViewed WHERE Type = 'ContentDocument' 
			ORDER BY LastViewedDate DESC NULLS FIRST LIMIT :list_size])
			{
		    	recentlyViewedDocIds.add(recentView.Id);
			}
		
		List<ContentVersion> actualRecentDocs = [SELECT ContentDocumentId,ContentSize,ContentUrl,
        		CreatedDate,Description,FileType,Id,IsDeleted,IsLatest,
        		PathOnClient, TagCsv,Title,VersionNumber FROM ContentVersion 
		        WHERE IsLatest = true AND IsDeleted = false AND ContentDocumentId IN :recentlyViewedDocIds 
		        LIMIT :list_size OFFSET :offsetcounter];
				        
        List<ContentVersion> testRecentDocs = s1m_postboy.getDocuments(sRecentLibraryId, sAllSearchTerm, offsetcounter);
				
		System.assertEquals(testRecentDocs, actualRecentDocs);
		
        List<ContentVersion> testWorkspaceDocs = s1m_postboy.getDocuments(testGDWorkspace.Id, sAllSearchTerm, offsetcounter);
		
		List<ContentVersion> testSearchWorkspaceDocs = s1m_postboy.getDocuments('all', 'someterm', offsetcounter);
		
		
		// Doc Sending
		Account acct = new Account(name='Polygram Records');
		insert acct;


		Contact ct = new Contact(AccountId=acct.Id,lastname='Fresh',firstname='Douge',
		email='john.brunswick@gmail.com');
		insert ct;
		
	
		
		
		String sSendMethod = 'community';
		
		String[] docIds = new List<String>();
		Set<Id> records = new Set<Id>();
		
    	for(ContentVersion docLine : [SELECT ContentDocumentId,ContentSize,ContentUrl, CreatedDate,Description,
    			FileType,Id,IsDeleted,IsLatest, PathOnClient,TagCsv,Title,VersionNumber 
    			FROM ContentVersion WHERE IsLatest = true AND IsDeleted = false AND ContentDocumentId = :testContent.ContentDocumentId
    			ORDER BY Title LIMIT 100])
        {
        	// Need to emulate what happens on the client side with an array of IDs
		  	docIds.add(String.valueOf(docLine.ContentDocumentId));
		  	records.add(docLine.ContentDocumentId);
	  	}
	  	
	  	
	  	
		String[] docBinaryIds = new List<String>();
		Set<Id> recordsBinary = new Set<Id>();
		
    	for(ContentVersion docLineBinary : [SELECT ContentDocumentId,ContentSize,ContentUrl, CreatedDate,Description,
    			FileType,Id,IsDeleted,IsLatest, PathOnClient,TagCsv,Title,VersionNumber 
    			FROM ContentVersion WHERE IsLatest = true AND IsDeleted = false AND ContentDocumentId != :testContent.ContentDocumentId
    			ORDER BY Title LIMIT 1])
        {
        	// Need to emulate what happens on the client side with an array of IDs
		  	docBinaryIds.add(String.valueOf(docLineBinary.ContentDocumentId));
		  	recordsBinary.add(docLineBinary.ContentDocumentId);
	  	}	  	
	  	
		
		String sEmailResult = s1m_postboy.sendEmailDocs(ct.Email , docIds, ct.Id, sSendMethod);
		System.assertEquals(sEmailResult, s1m_postboy.sendEmailDocs(ct.Email , docIds, ct.Id, sSendMethod));
		
		sSendMethod = 'email';
		System.assertEquals('cannot attach link', s1m_postboy.sendEmailDocs(ct.Email , docIds, ct.Id, sSendMethod));
		

		String sEmailResultBinary = s1m_postboy.sendEmailDocs(ct.Email , docBinaryIds, ct.Id, sSendMethod);
		System.assertEquals(sEmailResultBinary, s1m_postboy.sendEmailDocs(ct.Email , docBinaryIds, ct.Id, sSendMethod));
		
		
		
		// With Community Share...
		S1M_Community_Collateral_Share__c myShare = new S1M_Community_Collateral_Share__c(Contact__c=ct.Id);
		insert myShare;
		
		sSendMethod = 'community';
		
		String[] docCSIds = new List<String>();
		Set<Id> recordsCS = new Set<Id>();
		
    	for(ContentVersion docLine : [SELECT ContentDocumentId,ContentSize,ContentUrl, CreatedDate,Description,
    			FileType,Id,IsDeleted,IsLatest, PathOnClient,TagCsv,Title,VersionNumber 
    			FROM ContentVersion WHERE IsLatest = true AND IsDeleted = false AND ContentDocumentId = :testContent.ContentDocumentId
    			ORDER BY Title LIMIT 100])
        {
        	// Need to emulate what happens on the client side with an array of IDs
		  	docCSIds.add(String.valueOf(docLine.ContentDocumentId));
		  	recordsCS.add(docLine.ContentDocumentId);
	  	}
		
		String sResult = s1m_postboy.sendEmailDocs(ct.Email , docIds, ct.Id, sSendMethod);
		
		System.assertEquals(sResult, s1m_postboy.sendEmailDocs(ct.Email , docIds, ct.Id, sSendMethod));
		
		Boolean bResult = s1m_postboy.communitySendPermission();
		
		System.assertEquals(bResult, s1m_postboy.communitySendPermission());
		
		ApexPages.StandardController controller; // = new ApexPages.StandardController(); 
		s1m_postboy customController = new s1m_postboy(controller);
		
		
        
    }
}