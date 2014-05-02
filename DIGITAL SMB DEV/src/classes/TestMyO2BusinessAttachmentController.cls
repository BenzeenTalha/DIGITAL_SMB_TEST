@isTest
private class TestMyO2BusinessAttachmentController {
	public static testmethod void testMyO2BusinessAttachmentController() {
		Test.startTest();
		Attachment attachment = new Attachment();
		attachment.Name = 'Test attachment'; 
		attachment.Description = 'Description of an attachment';
		attachment.Body = EncodingUtil.base64Decode('4321234');
		attachment.ParentId = 'a31a0000000LQz8';
		System.debug('test attachment controller, attachment parentId = ' + attachment.ParentId);
		ApexPages.Standardcontroller stdCtrl = new ApexPages.Standardcontroller(attachment);
		MyO2BusinessAttachmentController attCtrl = new MyO2BusinessAttachmentController(stdCtrl);
		attCtrl.upload();
		System.debug('test attachment controller, attCtrl = ' + attCtrl);
		Test.stopTest();
	}
}