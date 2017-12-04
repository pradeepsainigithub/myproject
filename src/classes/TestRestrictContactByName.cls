@isTest
private class TestRestrictContactByName {
    static testMethod void positiveUnitTest() {
      contact con = new contact(LastName = 'INVALIDNAME');
            insert con;
    }
}