public with sharing class s1m_explain_quizzer {

    public List<S1M_Explain_Item__c> getS1MExplainItems() {
    	//String recId = ApexPages.CurrentPage().getParameters().get('id');
    	
        return [SELECT Body_Text__c,CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,Quiz_Card_Answer__c,
		Name,Name__c,Order__c,S1M_Explain_Collection__c,SystemModstamp FROM S1M_Explain_Item__c 
		WHERE S1M_Explain_Collection__c = :ApexPages.currentPage().getParameters().get('id') ORDER BY Order__c];
    }

    public s1m_explain_quizzer(ApexPages.StandardController controller){
    }

}