public with sharing class MyO2BusinessSecurityQuestionExtension {
	public MyO2BusinessSecurityQuestionExtension() {		
	}
/* TODO - retire
    public User user {get; private set;}
    public String question {get; set;}  
    public String answer {get; set;}    
    public String smsCode {get; set;}
    
    private List<SSO_Stock_Questions__c> stockQuestionsObjects;
    private MyO2BusinessChangePasswordController controller;
    
    public MyO2BusinessSecurityQuestionExtension () {}
    
    public MyO2BusinessSecurityQuestionExtension (MyO2BusinessChangePasswordController controller) {
            this.controller = controller;
            user = doQuery();
    }    

	public User doQuery() {
    	user = [SELECT Id, UserName, SSO_question__c, SSO_answer__c FROM USER WHERE Id=:userinfo.getUserId() LIMIT 1];		
		return user;
	}

    public boolean getHasSecurityAnswer() {
        return user!=null && user.SSO_answer__c!=null && user.SSO_answer__c!='';
    }
    
    public List<SelectOption> getstockQuestions() {
        List<SelectOption> stockQuestions = new List<SelectOption>();
        if(stockQuestionsObjects ==null) {
            stockQuestionsObjects = [SELECT s.Question__c, s.Name FROM SSO_Stock_Questions__c s WHERE s.active__c = true ORDER BY s.ranking__c ASC]; 
        }
        stockQuestions.add(new SelectOption('','--None--'));
        for (SSO_Stock_Questions__c q:stockQuestionsObjects){
            stockQuestions.add(new SelectOption(q.question__c,q.question__c));
        }        
        return stockQuestions;
    }

    public PageReference setSecurityQAAndPassword() {
       PageReference pr = null;
       if (question!='' && answer!='') {
        user.SSO_question__c = question;
        user.SSO_answer__c = answer;
        update user;
       } 
       if (Test.isRunningTest() == false) {
           pr = Site.changePassword(controller.newPassword, controller.verifyNewPassword, controller.oldPassword);
           if(pr!=null) pr = Page.MyO2BusinessHome;           
       }
       return pr;            
    } 
       
    
    private boolean checkSMSCode() {
        return MyO2BusinessCrypto.validateSMSCode(token,smsCode);
    }
   
    
    // ******** TEST CODE ***********
    
    private static testMethod void test() {
        MyO2BusinessChangePasswordController cpc = new MyO2BusinessChangePasswordController ();
        MyO2BusinessSecurityQuestionExtension sqe = new MyO2BusinessSecurityQuestionExtension (cpc);
 
                // get the questions
                List<SelectOption> so = sqe.getstockQuestions();
                system.assert(so != null);
                system.assert(so.size() > 0);
                
                // check the properties
                system.assert(sqe.user.Id != null);
                
                sqe.question = so[0].getValue();
                sqe.answer = 'red';
                //sqe.setSecurityQA();
                
                sqe.answer = 'blue';
                //system.assert(sqe.checkAnswerHelper() == false);                
                //sqe.answer = 'red';
                //system.assert(sqe.checkAnswerHelper() == true);                 
                
                //sqe.doUseOwnQuestion();
                //system.assertEquals(sqe.useOwnQuestion, 'yes');

                //sqe.doUseStockQuestion();
                //system.assertEquals(sqe.useOwnQuestion, 'no');
                
                //String sQuestion = sqe.questionSQ;
    }
    
    private static testMethod void testForgotPasswordNoPageNoToken() {
        MyO2BusinessSecurityQuestionExtension sqe = new MyO2BusinessSecurityQuestionExtension ();
		system.assert(sqe != null);
        system.assert(ApexPages.hasMessages()==false);         
    }
    
    private static testMethod void test_ForgotPassword() {
        final String QUESTION_1 = 'Why is the sky blue?';
        final String ANSWER_1 = 'Because it is a duck';
        User u = TestMyO2BusinessUtility.createPortalUserAccountContact('Roger', 'Roger', 'rr@rr.rr.rr.edu');
        Test.setCurrentPageReference(Page.MyO2BusinessForgotPasswordQA);
        MyO2BusinessCrypto crypto = new MyO2BusinessCrypto();
        String token =  MyO2BusinessCrypto.getToken(u.Id);
        ApexPages.currentPage().getParameters().put('tk',token);
        ApexPages.currentPage().getParameters().put('un','rr@rr.rr.rr.edu');
        System.runAs(u) {
            MyO2BusinessSecurityQuestionExtension sqe = new MyO2BusinessSecurityQuestionExtension ();

            // he does not have a secret Q+A
            system.assertEquals(false, sqe.getHasSecurityAnswer());         
            
            // now he does
            TestMyO2BusinessUtility.setUserQA(u, QUESTION_1, ANSWER_1);
            sqe.doQuery();
            system.assertEquals(true, sqe.getHasSecurityAnswer());          
        
            //sqe.userNameSQ = 'rr@rr.rr.rr.edu'; 
            //String question = sqe.userNameSQ;
            system.assertEquals(QUESTION_1, u.SSO_Question__c);     
            
            //sqe.getUserByUserName();
            
            PageReference pr = sqe.setSecurityQAAndPassword();
            system.assertEquals(null, pr);
            
            //sqe.startForgetFlow();
            
            //pr = sqe.checkAnswer();
            //system.assert(pr.getUrl().contains('myo2businessforgotpasswordqa'));
            
            //String s1 = sqe.questionSQ;
            //sqe.questionSQ = 'test';
            //system.assertEquals(s1, sqe.questionSQ);
            
        }
     }
     */
     private static testmethod void test_it() {
     	MyO2BusinessSecurityQuestionExtension sqe = new MyO2BusinessSecurityQuestionExtension();
     }
}