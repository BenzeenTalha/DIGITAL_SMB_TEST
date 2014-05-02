@isTest
public with sharing class TestMyO2BusinessForgotPasswordQAControll {
	
	private static testMethod void test_ForgotPassword() {
        final String QUESTION_1 = 'Why is the sky blue?';
        final String ANSWER_1 = 'Because it is a duck';
        User u = TestMyO2BusinessUtility.createPortalUserAccountContact('Roger', 'Roger', 'rr@rr.rr.rr.edu');
        Test.setCurrentPageReference(Page.MyO2BusinessForgotPasswordQA);

        String token =  MyO2BusinessToken.make(u.Id, MyO2BusinessToken.FORGOT_PASSWORD);
        ApexPages.currentPage().getParameters().put('tk',token);
        ApexPages.currentPage().getParameters().put('un','rr@rr.rr.rr.edu');
        System.runAs(u)
        {
            MyO2BusinessForgotPasswordQAController sqe = new MyO2BusinessForgotPasswordQAController ();
			sqe.authorize();
			sqe.getSecurityQuestion();
			sqe.getSecurityAnswerHint();
			sqe.answer = ANSWER_1;
            // he does not have a secret Q + A
            //system.assertEquals(false, sqe.getHasSecurityAnswer());

            // now he does
            TestMyO2BusinessUtility.setUserQA(u, QUESTION_1, ANSWER_1);

            system.assertEquals(QUESTION_1, u.SSO_Question__c);

            PageReference pr = sqe.checkAnswer();
            system.assert(pr.getUrl().contains('myo2businessforgotpasswordqa'));
            
			sqe.businessUser.setSecurityAnswer(ANSWER_1);
            pr = sqe.checkAnswer();
			sqe.businessUser.setSecurityAnswer('Yaba daba do');
            pr = sqe.checkAnswer();
			sqe.answer = '';
            pr = sqe.checkAnswer();

            String unsq = sqe.getUserName();
            String qsq = sqe.question;
        }
    }
}