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
private class s1m_explain_quizzer_test {

    static testMethod void tests1m_explain_quizzer() {
        
        S1M_Explain_Collection__c xc = new S1M_Explain_Collection__c(Title__c='Card Quiz',
        Type__c = 'Quiz', Time_to_Complete__c = 5, Description__c = 'Sample quiz');
		insert xc; 
		
		S1M_Explain_Item__c xi = new S1M_Explain_Item__c(S1M_Explain_Collection__c=xc.Id,
		Body_Text__c = 'What is blue', Order__c = 1, Quiz_Card_Answer__c = 'True');
		insert xi;
		
		PageReference pg1 = new PageReference('/apex/s1m_explain_quizzer?id='+xc.Id);
		System.test.setCurrentpage(pg1);

		// Fire up the Controller
		ApexPages.StandardController ctrl = new ApexPages.StandardController(xc);	

		s1m_explain_quizzer eqCon = new s1m_explain_quizzer(ctrl);
		
		// Execute the controller method
		List<S1M_Explain_Item__c> myList = eqCon.getS1MExplainItems();	
		
		// Check list isn't null
		System.assert(myList!=null);
				
		// Check list is expected size
		System.assertEquals(1, myList.size());
		
		// Check contents of list are as expected
		System.assertEquals(myList[0].S1M_Explain_Collection__c, xi.S1M_Explain_Collection__c);		
		        
    }
}