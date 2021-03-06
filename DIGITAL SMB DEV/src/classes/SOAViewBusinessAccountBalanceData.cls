//Generated by wsdl2apex

public class SOAViewBusinessAccountBalanceData {
    public class getAccountBalance {
        public String accountNumber;
        private String[] accountNumber_type_info = new String[]{'accountNumber','http://soa.o2.co.uk/dise/pscommondisedata_1','accountIdentifier','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soa.o2.co.uk/viewbusinessaccountbalancedata_1','true','false'};
        private String[] field_order_type_info = new String[]{'accountNumber'};
    }
    public class getAccountBalanceResponse {
        public Integer balance;
        public Integer amountOverdue;
        public Integer amountInQuery;
        private String[] balance_type_info = new String[]{'balance','http://www.w3.org/2001/XMLSchema','integer','1','1','false'};
        private String[] amountOverdue_type_info = new String[]{'amountOverdue','http://www.w3.org/2001/XMLSchema','integer','1','1','false'};
        private String[] amountInQuery_type_info = new String[]{'amountInQuery','http://www.w3.org/2001/XMLSchema','integer','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soa.o2.co.uk/viewbusinessaccountbalancedata_1','true','false'};
        private String[] field_order_type_info = new String[]{'balance','amountOverdue','amountInQuery'};
    }
	//--------------------------------------------------------------------------
    // Test method - wsdl2apex generated (execute only)
    //--------------------------------------------------------------------------
    @isTest(SeeAllData=false)
    private static void testCodeCoverage()
    {
	    Object instance = new getAccountBalance();
	    instance = new getAccountBalanceResponse();
    }    
}