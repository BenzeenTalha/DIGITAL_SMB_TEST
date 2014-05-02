public with sharing class MyO2BusinessTokenException extends Exception {
	public enum Reason {CONFIG, BADSEP, LENGTH, INVALID, EXPIRED, CRC}
	  
	private Reason reason;
	  
	public Reason getReason() {
	    return reason;
	}
	  
	public MyO2BusinessTokenException(Reason r, String s) {
	    this.setMessage(s);
	    reason = r;    
	}
	  
	private static final Reason TEST_REASON = Reason.CONFIG;
	private static final String TEST_MSG = 'keyboard too hot';
	
	private static testMethod void test() {
		MyO2BusinessTokenException te1 = new MyO2BusinessTokenException(TEST_REASON, TEST_MSG);
		try {
			throw te1;
		} catch (MyO2BusinessTokenException te2) {
			system.assertEquals(TEST_REASON, te2.getReason());
			system.assertEquals(TEST_MSG, te2.getMessage());
		}
	}
}