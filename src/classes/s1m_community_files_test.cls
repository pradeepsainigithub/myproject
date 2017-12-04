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
private class s1m_community_files_test {

    static testMethod void tests1m_community_files() {
        
		
		s1m_community_files.CommunityDoc myTestDoc = new s1m_community_files.CommunityDoc();
		myTestDoc.ContentDescription = 'desc';
		myTestDoc.ContentFileName = 'name';
		myTestDoc.ContentSize = 123;
		myTestDoc.ContentType = 'WORD';
		myTestDoc.Id = '123';
		myTestDoc.RelatedRecordId = '456';
		myTestDoc.Title = 'title';
		
		System.assertEquals('desc', myTestDoc.ContentDescription);
		System.assertEquals('name', myTestDoc.ContentFileName);
		System.assertEquals(123, myTestDoc.ContentSize);
		System.assertEquals('WORD', myTestDoc.ContentType);
		System.assertEquals('123', myTestDoc.Id);
		System.assertEquals('456', myTestDoc.RelatedRecordId);
		System.assertEquals('title', myTestDoc.Title);
		
		
		Account acct = new Account(name='Polygram Records');
		insert acct;
		
		Contact ct = new Contact(AccountId=acct.Id,lastname='Fresh',firstname='Douge',
		email='john.brunswick@gmail.com');
		insert ct;
		
			
		S1M_Community_Collateral_Share__c myShare = new S1M_Community_Collateral_Share__c();
		myShare.Contact__c = ct.Id;
		insert myShare;
		
		
		// CONNECT API tests...
	    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
	    feedItemInput.body = new ConnectApi.MessageBodyInput();
	    
	    // add the text segment
	    ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
	    feedItemInput.body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
	    textSegment.text = 'test';
	    feedItemInput.body.messageSegments.add(textSegment);
	    
	    // add the attachment
	    ConnectApi.LinkAttachmentInput linkIn = new ConnectApi.LinkAttachmentInput();
	    linkIn.urlName = 'salesforce';
	    linkIn.url = 'www.salesforce.com';
	    feedItemInput.attachment = linkIn;
	    
	    // post it!
		ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, myShare.Id, feedItemInput, null);
		
		
		PageReference pg1 = new PageReference('s1m_community_files');
		System.test.setCurrentpage(pg1);

		// Fire up the Controller
		//ApexPages.StandardController ctrl = new ApexPages.StandardController();
		s1m_community_files ctrl = new s1m_community_files();	

		List<s1m_community_files.CommunityDoc> testFeedItems = ctrl.getFeedItems();


    }
}