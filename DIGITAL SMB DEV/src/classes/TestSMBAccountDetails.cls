@isTest(SeeAllData=true)
private class TestSMBAccountDetails {
   public static testMethod void unitTest() {
     
      User u = [SELECT Id, AccountId, ContactId, Name, Email FROM User where isActive = true and AccountId != null limit 1];

      System.runAs(u) {
      // The following code runs as user 'u' 
          SMBAccountDetails smcAccDetails = new SMBAccountDetails();
          smcAccDetails.getAccountDetails();
      }
  }
}