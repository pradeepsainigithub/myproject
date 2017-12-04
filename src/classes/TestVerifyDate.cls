@isTest
private class TestVerifyDate {
      static testMethod void positiveUnitTest() {
          date d1 = date.today();
          date d2 = date.today().adddays(30);
          date d3 = date.today().adddays(-30);
          date d4 = date.today();
          VerifyDate.CheckDates(d1, d2);
          VerifyDate.CheckDates(d1, d3);
          VerifyDate.CheckDates(d1, d4);
      }
}