public with sharing class s1m_explain_presenter {
	

    public List<S1M_Explain_Item__c> getS1MExplainItems() {
    	
        return [SELECT Body_Text__c,CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,
		Name,Name__c,Order__c,S1M_Explain_Collection__c,SystemModstamp, (Select Id, ParentId, Name, ContentType From Attachments) FROM S1M_Explain_Item__c 
		WHERE S1M_Explain_Collection__c = :ApexPages.CurrentPage().getParameters().get('id') ORDER BY Order__c];
    }

    public s1m_explain_presenter(ApexPages.StandardController controller){
    }

}