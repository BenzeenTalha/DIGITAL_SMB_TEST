public with sharing class OrderAvailabilityCheckController {
    private Order__c order;
    //
    // Controller
    public OrderAvailabilityCheckController(ApexPages.StandardController stdController) {
        this.order = (Order__c)stdController.getRecord();
        order = [select Id, Line_Availability_Check_Result__r.Directory_Number__c, Line_Availability_Check_Result__r.Post_Code__c,
                        Line_Availability_Check_Result__c from Order__c where id = :this.order.Id];
    }
    //
    // Get a new Availability Check for this order
    public PageReference getNewAvailabilityCheckForOrder() {
        List<Line_Availability__c> lineAvailabilityRequests = new List<Line_Availability__c>();
        Batch_Job__c batchJob = new Batch_Job__c();
        //
        String dirNumber = order.Line_Availability_Check_Result__r.Directory_Number__c;
        String postCode  = order.Line_Availability_Check_Result__r.Post_Code__c;
        //
        if (order.Line_Availability_Check_Result__c != null && postCode != null && dirNumber != null) {
            lineAvailabilityRequests.add(new Line_Availability__c(Directory_Number__c = dirNumber, 
                                                                      Post_Code__c = postCode));
        }
        
        // Check that the user has entered data
        if (lineAvailabilityRequests == null || lineAvailabilityRequests.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + 'Please enter at least one directory number and postcode.'));
            return null;
        }
        Savepoint sp = Database.setSavepoint();
        try {
            //AvailabilityCheckInputProcessor inputProcessor = new AvailabilityCheckInputProcessor();
            batchJob = AvailabilityCheckInputProcessor.processLineAvailablityArray(lineAvailabilityRequests, AvailabilityCheckUtils.SCREEN_INPUT,AvailabilityCheckUtils.TYPE_LINE);
            //
            Map<String,String> lineAvailabilityRequestMap = getLineAvailabilityRequestsMap(batchJob.Id);
            // update the order with the availability check results Id 
            if (dirNumber != null && dirNumber.startsWith('0')) {
                dirNumber = '44' + dirNumber.substring(1);
            }
            //
            if (lineAvailabilityRequestMap.containsKey(dirNumber+'-'+postCode+'-'+batchJob.Id)) {
                order.Line_Availability_Check_Result__c = lineAvailabilityRequestMap.get(dirNumber+'-'+postCode+'-'+batchJob.Id);
            }
            update order;
        } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
            return null;
        }
        // 
        //AvailabilityCheckUtils util = new AvailabilityCheckUtils();
        AvailabilityCheckUtils.processAvailabilityCheck(new List<Id>{batchJob.Id});
        //
        // ---------------------------------------------------------------
        //
        // Go back to the order
        PageReference orderDetailsPage = new PageReference('/'+order.Id);
        orderDetailsPage.setRedirect(true);
        return orderDetailsPage;  
    }
    
    //
    // Get a Map of line availability requests keyed on the phone number and post code
    private Map<String,String> getLineAvailabilityRequestsMap(String batchId) {
        Map<String,String> lineAvailabilityRequestMap = new  Map<String,String>();
        for (Line_Availability__c rec : [Select Id, Post_Code__c, Directory_Number__c, batch_Job__c From Line_Availability__c Where Batch_Job__c = :batchId]) {
            lineAvailabilityRequestMap.put(rec.Directory_Number__c+'-'+rec.Post_Code__c+'-'+rec.batch_Job__c,rec.Id);
        }
        //
        return lineAvailabilityRequestMap;
    }
}