global class BasicFormToEmailController { 
    @AuraEnabled
    public static void sendEmail(String emailDetails)
    { 
        try {
            EmailFormDetails emailDetailsObj = (EmailFormDetails) Json.deserialize(emailDetails,EmailFormDetails.class);
            if(emailDetailsObj != null)
            {    
                List<User> currentUserList = [SELECT Id,Contact.Name,Contact.AccountId, Contact.Account.Name FROM User WHERE Id = :UserInfo.getUserId() limit 1];
                if(!currentUserList.isEmpty()){   
                    Account accountObj;
                    accountObj = currentUserList[0].Contact.Account;
                    Contact contactObj;
                    contactObj = currentUserList[0].Contact;
                    BasicFormToEmail__c customSetting = BasicFormToEmail__c.getValues('EmailToAddress');
                    String sendTo = customSetting.EmailAddress__c;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new String[] {sendTo});
                    mail.setSubject('Partner Issue - Account Name :'+accountObj.Name+' || Contact Name :'+ contactObj.Name);
                    mail.setReplyTo(emailDetailsObj.emailAddress);
                    mail.setSenderDisplayName(emailDetailsObj.fullName);
                    mail.setPlainTextBody(emailDetailsObj.summaryIssue);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }    
        }
        catch (Exception e) {
            throw new AuraHandledException('Something went wrong: ' + e.getMessage());   
            // this is after second commit
            // this is my third commit  
        }
    }
}