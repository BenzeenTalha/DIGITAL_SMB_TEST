@isTest
public class TestUnifyPartnerAPI {

	/* mock responses for tested WebService callouts */
	public class convertLead_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.convertLeadResponse_element respElement = new PartnerAPI.convertLeadResponse_element();
           respElement.result = new List<PartnerAPI.LeadConvertResult>();
           response.put('response_x', respElement); 
	   }
	}
	
	public class describeDataCategoryGroupStructures_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.describeDataCategoryGroupStructuresResponse_element respElement = new PartnerAPI.describeDataCategoryGroupStructuresResponse_element();
           respElement.result = new List<PartnerAPI.DescribeDataCategoryGroupStructureResult>();
           response.put('response_x', respElement); 
	   }
	}	
	
	public class sendEmail_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.sendEmailResponse_element respElement = new PartnerAPI.sendEmailResponse_element();
           respElement.result = new List<PartnerAPI.SendEmailResult>();
           response.put('response_x', respElement); 
	   }
	}
	
	public class describeGlobal_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.describeGlobalResponse_element respElement = new PartnerAPI.describeGlobalResponse_element();
           respElement.result = new PartnerAPI.DescribeGlobalResult();
           response.put('response_x', respElement); 
	   }
	}

	public class describeLayout_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.describeLayoutResponse_element respElement = new PartnerAPI.describeLayoutResponse_element();
           respElement.result = new PartnerAPI.DescribeLayoutResult();
           response.put('response_x', respElement); 
	   }
	}
	
	public class emptyRecycleBin_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.emptyRecycleBinResponse_element respElement = new PartnerAPI.emptyRecycleBinResponse_element();
           respElement.result = new List<PartnerAPI.EmptyRecycleBinResult>();
           response.put('response_x', respElement); 
	   }
	}
	
	public class process_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.processResponse_element respElement = new PartnerAPI.processResponse_element();
           respElement.result = new List<PartnerAPI.ProcessResult>();
           response.put('response_x', respElement); 
	   }
	}
	
	public class create_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.createResponse_element respElement = new PartnerAPI.createResponse_element();
           respElement.result = new List<PartnerAPI.SaveResult>();
           response.put('response_x', respElement); 
	   }
	}
	
	public class invalidateSessions_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.invalidateSessionsResponse_element respElement = new PartnerAPI.invalidateSessionsResponse_element();
           respElement.result = new List<PartnerAPI.InvalidateSessionsResult>();
           response.put('response_x', respElement); 
	   }
	}
	
	public class getUserInfo_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.getUserInfoResponse_element respElement = new PartnerAPI.getUserInfoResponse_element();
           respElement.result = new PartnerAPI.GetUserInfoResult();
           response.put('response_x', respElement); 
	   }
	}
	
	public class getServerTimestamp_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.getServerTimestampResponse_element respElement = new PartnerAPI.getServerTimestampResponse_element();
           respElement.result = new PartnerAPI.GetServerTimestampResult();
           response.put('response_x', respElement); 
	   }
	}
	
	public class getDeleted_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.getDeletedResponse_element respElement = new PartnerAPI.getDeletedResponse_element();
           respElement.result = new PartnerAPI.GetDeletedResult();
           response.put('response_x', respElement); 
	   }
	}
	
	public class setPassword_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.setPasswordResponse_element respElement = new PartnerAPI.setPasswordResponse_element();
           respElement.result = new PartnerAPI.SetPasswordResult();
           response.put('response_x', respElement); 
	   }
	}
	
	public class sendEmailMessage_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.sendEmailMessageResponse_element respElement = new PartnerAPI.sendEmailMessageResponse_element();
           respElement.result = new List<PartnerAPI.SendEmailResult>();
           response.put('response_x', respElement); 
	   }
	}
	
	public class describeTabs_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.describeTabsResponse_element respElement = new PartnerAPI.describeTabsResponse_element();
           respElement.result = new List<PartnerAPI.DescribeTabSetResult>();
           response.put('response_x', respElement); 
	   }
	}
	
	public class login_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.loginResponse_element respElement = new PartnerAPI.loginResponse_element();
           respElement.result = new PartnerAPI.LoginResult();
           response.put('response_x', respElement); 
	   }
	}
	
	public class search_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.searchResponse_element respElement = new PartnerAPI.searchResponse_element();
           respElement.result = new PartnerAPI.SearchResult();
           response.put('response_x', respElement); 
	   }
	}
	
	public class queryMore_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.queryMoreResponse_element respElement = new PartnerAPI.queryMoreResponse_element();
           respElement.result = new PartnerAPI.QueryResult();
           response.put('response_x', respElement); 
	   }
	}
	
	public class describeSearchScopeOrder_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.describeSearchScopeOrderResponse_element respElement = new PartnerAPI.describeSearchScopeOrderResponse_element();
           respElement.result = new List<PartnerAPI.DescribeSearchScopeOrderResult>();
           response.put('response_x', respElement); 
	   }
	}
	
	public class describeDataCategoryGroups_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.describeDataCategoryGroupsResponse_element respElement = new PartnerAPI.describeDataCategoryGroupsResponse_element();
           respElement.result = new List<PartnerAPI.DescribeDataCategoryGroupResult>();
           response.put('response_x', respElement); 
	   }
	}
	
	public class describeSoftphoneLayout_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.describeSoftphoneLayoutResponse_element respElement = new PartnerAPI.describeSoftphoneLayoutResponse_element();
           respElement.result = new PartnerAPI.DescribeSoftphoneLayoutResult();
           response.put('response_x', respElement); 
	   }
	}
	
	public class describeSObject_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.describeSObjectResponse_element respElement = new PartnerAPI.describeSObjectResponse_element();
           respElement.result = new PartnerAPI.DescribeSObjectResult();
           response.put('response_x', respElement); 
	   }
	}
	
	public class describeSObjects_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.describeSObjectsResponse_element respElement = new PartnerAPI.describeSObjectsResponse_element();
           respElement.result = new List<PartnerAPI.DescribeSObjectResult>();
           response.put('response_x', respElement); 
	   }
	}
	
	public class getUpdated_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.getUpdatedResponse_element respElement = new PartnerAPI.getUpdatedResponse_element();
           respElement.result = new PartnerAPI.GetUpdatedResult();
           response.put('response_x', respElement); 
	   }
	}
	
	public class upsertSobject_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.upsertResponse_element respElement = new PartnerAPI.upsertResponse_element();
           respElement.result = new List<PartnerAPI.UpsertResult>();
           response.put('response_x', respElement); 
	   }
	}
	
	public class queryAll_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.queryAllResponse_element respElement = new PartnerAPI.queryAllResponse_element();
           respElement.result = new PartnerAPI.QueryResult();
           response.put('response_x', respElement); 
	   }
	}
	
	public class resetPassword_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.resetPasswordResponse_element respElement = new PartnerAPI.resetPasswordResponse_element();
           respElement.result = new PartnerAPI.ResetPasswordResult();
           response.put('response_x', respElement); 
	   }
	}
	
	public class mergeSobject_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.mergeResponse_element respElement = new PartnerAPI.mergeResponse_element();
           respElement.result = new List<PartnerAPI.MergeResult>();
           response.put('response_x', respElement); 
	   }
	}
	
	public class query_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.queryResponse_element respElement = new PartnerAPI.queryResponse_element();
           respElement.result = new PartnerAPI.QueryResult();
           response.put('response_x', respElement); 
	   }
	}
	
	public class updateSobject_MockImpl implements WebServiceMock {
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.updateResponse_element respElement = new PartnerAPI.updateResponse_element();
           respElement.result = new List<PartnerAPI.SaveResult>();
           response.put('response_x', respElement); 
	   }
	}
	
	public class undeleteSobject_MockImpl implements WebServiceMock {	
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.undeleteResponse_element respElement = new PartnerAPI.undeleteResponse_element();
           respElement.result = new List<PartnerAPI.UndeleteResult>();
           response.put('response_x', respElement); 
	   }
	}
	
	public class retrieve_MockImpl implements WebServiceMock {	
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.retrieveResponse_element respElement = new PartnerAPI.retrieveResponse_element();
           respElement.result = new List<PartnerAPIsObject.sObject_x>();
           response.put('response_x', respElement); 
	   }
	}	

	public class logout_MockImpl implements WebServiceMock {	
	   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           
           PartnerAPI.logoutResponse_element respElement = new PartnerAPI.logoutResponse_element();
           response.put('response_x', respElement); 
	   }
	}	
	
	/* tests for PartnerAPI class */
    static testMethod void test1() {
        PartnerAPI p = new PartnerAPI();
        PartnerAPI.getUserInfo_element a00001 = new PartnerAPI.getUserInfo_element();
        PartnerAPI.LoginResult a00002 = new PartnerAPI.LoginResult();
        PartnerAPI.DescribeSoftphoneLayoutResult a00003 = new PartnerAPI.DescribeSoftphoneLayoutResult();
        PartnerAPI.ProcessResult a00004 = new PartnerAPI.ProcessResult();
        PartnerAPI.queryMore_element a00005 = new PartnerAPI.queryMore_element();
        PartnerAPI.DescribeSoftphoneLayoutItem a00006 = new PartnerAPI.DescribeSoftphoneLayoutItem();
        PartnerAPI.logout_element a00007 = new PartnerAPI.logout_element();
        PartnerAPI.DescribeSoftphoneLayoutSection a00008 = new PartnerAPI.DescribeSoftphoneLayoutSection();
        PartnerAPI.describeDataCategoryGroupsResponse_element a00009 = new PartnerAPI.describeDataCategoryGroupsResponse_element();
        PartnerAPI.ResetPasswordResult a00010 = new PartnerAPI.ResetPasswordResult();
        PartnerAPI.merge_element a00011 = new PartnerAPI.merge_element();
        PartnerAPI.describeSoftphoneLayoutResponse_element a00012 = new PartnerAPI.describeSoftphoneLayoutResponse_element();
        PartnerAPI.describeGlobal_element a00013 = new PartnerAPI.describeGlobal_element();
        PartnerAPI.RecordTypeInfo a00014 = new PartnerAPI.RecordTypeInfo();
        PartnerAPI.queryResponse_element a00015 = new PartnerAPI.queryResponse_element();
        PartnerAPI.emptyRecycleBinResponse_element a00016 = new PartnerAPI.emptyRecycleBinResponse_element();
        PartnerAPI.EmptyRecycleBinResult a00017 = new PartnerAPI.EmptyRecycleBinResult();
        PartnerAPI.loginResponse_element a00018 = new PartnerAPI.loginResponse_element();
        PartnerAPI.describeDataCategoryGroupStructures_element a00019 = new PartnerAPI.describeDataCategoryGroupStructures_element();
        PartnerAPI.Email a00020 = new PartnerAPI.Email();
        PartnerAPI.describeSoftphoneLayout_element a00021 = new PartnerAPI.describeSoftphoneLayout_element();
        PartnerAPI.getServerTimestamp_element a00022 = new PartnerAPI.getServerTimestamp_element();
        PartnerAPI.GetUserInfoResult a00023 = new PartnerAPI.GetUserInfoResult();
        PartnerAPI.ChildRelationship a00024 = new PartnerAPI.ChildRelationship();
        PartnerAPI.process_element a00025 = new PartnerAPI.process_element();
        PartnerAPI.DescribeLayoutComponent a00026 = new PartnerAPI.DescribeLayoutComponent();
        PartnerAPI.QueryResult a00027 = new PartnerAPI.QueryResult();
        PartnerAPI.QueryOptions_element a00028 = new PartnerAPI.QueryOptions_element();
        PartnerAPI.LeadConvertResult a00029 = new PartnerAPI.LeadConvertResult();
        PartnerAPI.CallOptions_element a00030 = new PartnerAPI.CallOptions_element();
        PartnerAPI.sendEmailMessage_element a00031 = new PartnerAPI.sendEmailMessage_element();
        PartnerAPI.processResponse_element a00032 = new PartnerAPI.processResponse_element();
        PartnerAPI.MruHeader_element a00033 = new PartnerAPI.MruHeader_element();
        PartnerAPI.DescribeSearchScopeOrderResult a00034 = new PartnerAPI.DescribeSearchScopeOrderResult();
        PartnerAPI.Soap a00035 = new PartnerAPI.Soap();      
		PartnerAPI.ProcessWorkitemRequest a00036 = new PartnerAPI.ProcessWorkitemRequest();
		PartnerAPI.SessionHeader_element a00037 = new PartnerAPI.SessionHeader_element();
		PartnerAPI.AllOrNoneHeader_element a00038 = new PartnerAPI.AllOrNoneHeader_element();
		PartnerAPI.DescribeDataCategoryGroupStructureResult a00039 = new PartnerAPI.DescribeDataCategoryGroupStructureResult();
		PartnerAPI.DescribeSoftphoneLayoutInfoField a00040 = new PartnerAPI.DescribeSoftphoneLayoutInfoField();
		PartnerAPI.describeTabsResponse_element a00041 = new PartnerAPI.describeTabsResponse_element();
		PartnerAPI.describeTabs_element a00042 = new PartnerAPI.describeTabs_element();
		PartnerAPI.describeDataCategoryGroups_element a00043 = new PartnerAPI.describeDataCategoryGroups_element();
		PartnerAPI.describeGlobalResponse_element a00044 = new PartnerAPI.describeGlobalResponse_element();
		PartnerAPI.DescribeLayoutButton a00045 = new PartnerAPI.DescribeLayoutButton();
		PartnerAPI.SendEmailError a00046 = new PartnerAPI.SendEmailError();
		PartnerAPI.DescribeLayoutItem a00047 = new PartnerAPI.DescribeLayoutItem();
		PartnerAPI.AllowFieldTruncationHeader_element a00048 = new PartnerAPI.AllowFieldTruncationHeader_element();
		PartnerAPI.SaveResult a00049 = new PartnerAPI.SaveResult();
		PartnerAPI.getDeletedResponse_element a00050 = new PartnerAPI.getDeletedResponse_element();
		PartnerAPI.convertLead_element a00051 = new PartnerAPI.convertLead_element();
		PartnerAPI.describeSObjects_element a00052 = new PartnerAPI.describeSObjects_element();
		PartnerAPI.describeDataCategoryGroupStructuresResponse_element a00053 = new PartnerAPI.describeDataCategoryGroupStructuresResponse_element();
		PartnerAPI.emptyRecycleBin_element a00054 = new PartnerAPI.emptyRecycleBin_element();
		PartnerAPI.update_element a00055 = new PartnerAPI.update_element();
		PartnerAPI.DisableFeedTrackingHeader_element a00056 = new PartnerAPI.DisableFeedTrackingHeader_element();
		PartnerAPI.search_element a00057 = new PartnerAPI.search_element();
		PartnerAPI.searchResponse_element a00058 = new PartnerAPI.searchResponse_element();
		PartnerAPI.MergeResult a00059 = new PartnerAPI.MergeResult();
		PartnerAPI.RelatedListSort a00060 = new PartnerAPI.RelatedListSort();
		PartnerAPI.describeSObject_element a00061 = new PartnerAPI.describeSObject_element();
		PartnerAPI.invalidateSessionsResponse_element a00062 = new PartnerAPI.invalidateSessionsResponse_element();
		PartnerAPI.LoginScopeHeader_element a00063 = new PartnerAPI.LoginScopeHeader_element();
		PartnerAPI.EmailFileAttachment a00064 = new PartnerAPI.EmailFileAttachment();
		PartnerAPI.convertLeadResponse_element a00065 = new PartnerAPI.convertLeadResponse_element();
		PartnerAPI.sendEmail_element a00066 = new PartnerAPI.sendEmail_element();
		PartnerAPI.DescribeLayoutButtonSection a00067 = new PartnerAPI.DescribeLayoutButtonSection();
		PartnerAPI.updateResponse_element a00068 = new PartnerAPI.updateResponse_element();
		PartnerAPI.queryAll_element a00069 = new PartnerAPI.queryAll_element();
		PartnerAPI.retrieve_element a00070 = new PartnerAPI.retrieve_element();
		PartnerAPI.GetServerTimestampResult a00071 = new PartnerAPI.GetServerTimestampResult();
		PartnerAPI.RelatedList a00072 = new PartnerAPI.RelatedList();
		PartnerAPI.describeSearchScopeOrderResponse_element a00073 = new PartnerAPI.describeSearchScopeOrderResponse_element();
		PartnerAPI.retrieveResponse_element a00074 = new PartnerAPI.retrieveResponse_element();
		PartnerAPI.queryAllResponse_element a00075 = new PartnerAPI.queryAllResponse_element();
		PartnerAPI.invalidateSessions_element a00076 = new PartnerAPI.invalidateSessions_element();
		PartnerAPI.create_element a00077 = new PartnerAPI.create_element();
		PartnerAPI.ProcessSubmitRequest a00078 = new PartnerAPI.ProcessSubmitRequest();
		PartnerAPI.describeLayoutResponse_element a00079 = new PartnerAPI.describeLayoutResponse_element();
		PartnerAPI.createResponse_element a00080 = new PartnerAPI.createResponse_element();
		PartnerAPI.ProcessRequest a00081 = new PartnerAPI.ProcessRequest();
		PartnerAPI.LeadConvert a00082 = new PartnerAPI.LeadConvert();
		PartnerAPI.getServerTimestampResponse_element a00083 = new PartnerAPI.getServerTimestampResponse_element();
		PartnerAPI.DeletedRecord a00084 = new PartnerAPI.DeletedRecord();
		PartnerAPI.LocaleOptions_element a00085 = new PartnerAPI.LocaleOptions_element();
		PartnerAPI.SearchResult a00086 = new PartnerAPI.SearchResult();
		PartnerAPI.DescribeSoftphoneScreenPopOption a00087 = new PartnerAPI.DescribeSoftphoneScreenPopOption();
		PartnerAPI.getUpdatedResponse_element a00088 = new PartnerAPI.getUpdatedResponse_element();
		PartnerAPI.StreamingEnabledHeader_element a00089 = new PartnerAPI.StreamingEnabledHeader_element();
		PartnerAPI.query_element a00090 = new PartnerAPI.query_element();
		PartnerAPI.getDeleted_element a00091 = new PartnerAPI.getDeleted_element();
		PartnerAPI.DataCategoryGroupSobjectTypePair a00092 = new PartnerAPI.DataCategoryGroupSobjectTypePair();
		PartnerAPI.DescribeDataCategoryGroupResult a00093 = new PartnerAPI.DescribeDataCategoryGroupResult();
		PartnerAPI.PackageVersion a00094 = new PartnerAPI.PackageVersion();
		PartnerAPI.DataCategory a00095 = new PartnerAPI.DataCategory();
		PartnerAPI.DescribeLayoutResult a00096 = new PartnerAPI.DescribeLayoutResult();
		PartnerAPI.DescribeGlobalResult a00097 = new PartnerAPI.DescribeGlobalResult();
		PartnerAPI.GetDeletedResult a00098 = new PartnerAPI.GetDeletedResult();
		PartnerAPI.DescribeLayoutSection a00099 = new PartnerAPI.DescribeLayoutSection();
		PartnerAPI.AssignmentRuleHeader_element a00100 = new PartnerAPI.AssignmentRuleHeader_element();
		PartnerAPI.PackageVersionHeader_element a00101 = new PartnerAPI.PackageVersionHeader_element();
		PartnerAPI.SingleEmailMessage a00102 = new PartnerAPI.SingleEmailMessage();
		PartnerAPI.login_element a00103 = new PartnerAPI.login_element();
		PartnerAPI.MassEmailMessage a00104 = new PartnerAPI.MassEmailMessage();
		PartnerAPI.SendEmailResult a00105 = new PartnerAPI.SendEmailResult();
		PartnerAPI.mergeResponse_element a00106 = new PartnerAPI.mergeResponse_element();
		PartnerAPI.PicklistForRecordType a00107 = new PartnerAPI.PicklistForRecordType();
		PartnerAPI.getUpdated_element a00108 = new PartnerAPI.getUpdated_element();
		PartnerAPI.DescribeTabSetResult a00109 = new PartnerAPI.DescribeTabSetResult();
		PartnerAPI.upsertResponse_element a00110 = new PartnerAPI.upsertResponse_element();
		PartnerAPI.Field a00111 = new PartnerAPI.Field();
		PartnerAPI.describeSObjectsResponse_element a00112 = new PartnerAPI.describeSObjectsResponse_element();
		PartnerAPI.getUserInfoResponse_element a00113 = new PartnerAPI.getUserInfoResponse_element();
		PartnerAPI.undeleteResponse_element a00114 = new PartnerAPI.undeleteResponse_element();
		PartnerAPI.UpsertResult a00115 = new PartnerAPI.UpsertResult();
		PartnerAPI.setPasswordResponse_element a00116 = new PartnerAPI.setPasswordResponse_element();
		PartnerAPI.DescribeSObjectResult a00117 = new PartnerAPI.DescribeSObjectResult();
		PartnerAPI.logoutResponse_element a00118 = new PartnerAPI.logoutResponse_element();
		PartnerAPI.InvalidateSessionsResult a00119 = new PartnerAPI.InvalidateSessionsResult();
		PartnerAPI.describeLayout_element a00120 = new PartnerAPI.describeLayout_element();
		PartnerAPI.DescribeLayout a00121 = new PartnerAPI.DescribeLayout();
		PartnerAPI.RecordTypeMapping a00122 = new PartnerAPI.RecordTypeMapping();
		PartnerAPI.DescribeGlobalSObjectResult a00123 = new PartnerAPI.DescribeGlobalSObjectResult();
		PartnerAPI.sendEmailResponse_element a00124 = new PartnerAPI.sendEmailResponse_element();
		PartnerAPI.PicklistEntry a00125 = new PartnerAPI.PicklistEntry();
		PartnerAPI.UserTerritoryDeleteHeader_element a00126 = new PartnerAPI.UserTerritoryDeleteHeader_element();
		PartnerAPI.DebuggingInfo_element a00127 = new PartnerAPI.DebuggingInfo_element();
		PartnerAPI.SearchRecord a00128 = new PartnerAPI.SearchRecord();
		PartnerAPI.describeSObjectResponse_element a00129 = new PartnerAPI.describeSObjectResponse_element();
		PartnerAPI.undelete_element a00130 = new PartnerAPI.undelete_element();
		PartnerAPI.RelatedListColumn a00131 = new PartnerAPI.RelatedListColumn();
		PartnerAPI.DeleteResult a00132 = new PartnerAPI.DeleteResult();
		PartnerAPI.GetUpdatedResult a00133 = new PartnerAPI.GetUpdatedResult();
		PartnerAPI.EmailHeader_element a00134 = new PartnerAPI.EmailHeader_element();
		PartnerAPI.queryMoreResponse_element a00135 = new PartnerAPI.queryMoreResponse_element();
		PartnerAPI.upsert_element a00136 = new PartnerAPI.upsert_element();
		PartnerAPI.DescribeLayoutRow a00137 = new PartnerAPI.DescribeLayoutRow();
		PartnerAPI.UndeleteResult a00138 = new PartnerAPI.UndeleteResult();
		PartnerAPI.DescribeSoftphoneLayoutCallType a00139 = new PartnerAPI.DescribeSoftphoneLayoutCallType();
		PartnerAPI.setPassword_element a00140 = new PartnerAPI.setPassword_element();
		PartnerAPI.resetPassword_element a00141 = new PartnerAPI.resetPassword_element();
		PartnerAPI.Error a00142 = new PartnerAPI.Error();
		PartnerAPI.SetPasswordResult a00143 = new PartnerAPI.SetPasswordResult();
		PartnerAPI.DebuggingHeader_element a00144 = new PartnerAPI.DebuggingHeader_element();
		PartnerAPI.sendEmailMessageResponse_element a00145 = new PartnerAPI.sendEmailMessageResponse_element();
		PartnerAPI.resetPasswordResponse_element a00146 = new PartnerAPI.resetPasswordResponse_element();
		PartnerAPI.MergeRequest a00147 = new PartnerAPI.MergeRequest();
		PartnerAPI.describeSearchScopeOrder_element a00148 = new PartnerAPI.describeSearchScopeOrder_element();
		PartnerAPI.DescribeTab a00149 = new PartnerAPI.DescribeTab();
    }
    
    /* tests for PartnerAPI.Soap class 1*/
    static testMethod void test2() {
    	PartnerAPI p = new PartnerAPI();
    	PartnerAPI.Soap soap = new PartnerAPI.Soap();      

		Test.setMock(WebServiceMock.class, new convertLead_MockImpl());
		PartnerAPI.LeadConvert[] leadConverts = new List<PartnerAPI.LeadConvert>();
		PartnerAPI.LeadConvertResult[] b0001 = soap.convertLead(leadConverts);
		
		Test.setMock(WebServiceMock.class, new describeDataCategoryGroupStructures_MockImpl());
		PartnerAPI.DataCategoryGroupSobjectTypePair[] pairs = new List<PartnerAPI.DataCategoryGroupSobjectTypePair>();
		Boolean topCategoriesOnly = true;
		PartnerAPI.DescribeDataCategoryGroupStructureResult[] b0002 = soap.describeDataCategoryGroupStructures(pairs, topCategoriesOnly);
		
		Test.setMock(WebServiceMock.class, new sendEmail_MockImpl());
		PartnerAPI.Email[] messages = new List<PartnerAPI.Email>();
		PartnerAPI.SendEmailResult[] b0003 = soap.sendEmail(messages);
		
		Test.setMock(WebServiceMock.class, new describeGlobal_MockImpl());
		PartnerAPI.DescribeGlobalResult b0004 = soap.describeGlobal();
		
		Test.setMock(WebServiceMock.class, new describeLayout_MockImpl());
		String sObjectType2 = 'Account';
		String[] recordTypeIds = new List<String>();
		PartnerAPI.DescribeLayoutResult b0005 = soap.describeLayout(sObjectType2, recordTypeIds);
		
		Test.setMock(WebServiceMock.class, new emptyRecycleBin_MockImpl());
		String[] ids = new List<String>();
		PartnerAPI.EmptyRecycleBinResult[] b0006 = soap.emptyRecycleBin(ids);
		
		Test.setMock(WebServiceMock.class, new process_MockImpl());
		PartnerAPI.ProcessRequest[] actions = new List<PartnerAPI.ProcessRequest>();
		PartnerAPI.ProcessResult[] b0007 = soap.process(actions);
		
		Test.setMock(WebServiceMock.class, new create_MockImpl());
		PartnerAPIsObject.sObject_x[] sObjects = new List<PartnerAPIsObject.sObject_x>();
		PartnerAPI.SaveResult[] b0008 = soap.create(sObjects);
		
		Test.setMock(WebServiceMock.class, new invalidateSessions_MockImpl());
		String[] sessionIds = new List<String>();
		PartnerAPI.InvalidateSessionsResult[] b0009 = soap.invalidateSessions(sessionIds);
		
		Test.setMock(WebServiceMock.class, new getUserInfo_MockImpl());
		PartnerAPI.GetUserInfoResult b0010 = soap.getUserInfo();
    }
    
    /* tests for PartnerAPI.Soap class 2*/
    static testMethod void test3() {
    	PartnerAPI p = new PartnerAPI();
    	PartnerAPI.Soap soap = new PartnerAPI.Soap();  
    	
		Test.setMock(WebServiceMock.class, new getServerTimestamp_MockImpl());
		PartnerAPI.GetServerTimestampResult b0011 = soap.getServerTimestamp();
		
		Test.setMock(WebServiceMock.class, new getDeleted_MockImpl());
		String sObjectType2 = 'Account';
		DateTime startDate = System.now();
		DateTime endDate = System.now();
		PartnerAPI.GetDeletedResult b0012 = soap.getDeleted(sObjectType2, startDate, endDate);
		
		Test.setMock(WebServiceMock.class, new setPassword_MockImpl());
		String userId = UserInfo.getUserId();
		String password = 'test';
		PartnerAPI.SetPasswordResult b0013 = soap.setPassword(userId, password);
		
		Test.setMock(WebServiceMock.class, new sendEmailMessage_MockImpl());
		List<String> ids = new List<String>();
		PartnerAPI.SendEmailResult[] b0014 = soap.sendEmailMessage(ids);
		
		Test.setMock(WebServiceMock.class, new describeTabs_MockImpl());
		PartnerAPI.DescribeTabSetResult[] b0015 = soap.describeTabs();
		
		Test.setMock(WebServiceMock.class, new login_MockImpl());
		String username = UserInfo.getUserId();
		password = 'test';
		PartnerAPI.LoginResult b0016 = soap.login(username, password);
		
		Test.setMock(WebServiceMock.class, new search_MockImpl());
		String searchString = '';
		PartnerAPI.SearchResult b0017 = soap.search(searchString);
		
		Test.setMock(WebServiceMock.class, new queryMore_MockImpl());
		String queryLocator = '';
		PartnerAPI.QueryResult b0018 = soap.queryMore(queryLocator);
		
		Test.setMock(WebServiceMock.class, new describeSearchScopeOrder_MockImpl());
		PartnerAPI.DescribeSearchScopeOrderResult[] b0019 = soap.describeSearchScopeOrder();
		
		Test.setMock(WebServiceMock.class, new describeDataCategoryGroups_MockImpl());
		String[] sObjectType = new List<String>();
		PartnerAPI.DescribeDataCategoryGroupResult[] b0020 = soap.describeDataCategoryGroups(sObjectType);

    }
    
    /* tests for PartnerAPI.Soap class 3*/
    static testMethod void test4() {
    	PartnerAPI p = new PartnerAPI();
    	PartnerAPI.Soap soap = new PartnerAPI.Soap();  
		
		Test.setMock(WebServiceMock.class, new describeSoftphoneLayout_MockImpl());
		PartnerAPI.DescribeSoftphoneLayoutResult b0021 = soap.describeSoftphoneLayout();
		
		Test.setMock(WebServiceMock.class, new describeSObject_MockImpl());
		String sObjectType2 = 'Account';
		PartnerAPI.DescribeSObjectResult b0022 = soap.describeSObject(sObjectType2);
		
		Test.setMock(WebServiceMock.class, new describeSObjects_MockImpl());
		List<String> sObjectType = new List<String>();
		PartnerAPI.DescribeSObjectResult[] b0023 = soap.describeSObjects(sObjectType);
		
		Test.setMock(WebServiceMock.class, new getUpdated_MockImpl());
		sObjectType2 = 'Account';
		DateTime startDate = System.now();
		DateTime endDate = System.now();
		PartnerAPI.GetUpdatedResult b0024 = soap.getUpdated(sObjectType2, startDate, endDate);
		
		Test.setMock(WebServiceMock.class, new upsertSobject_MockImpl());
		String externalIDFieldName = '';
		List<PartnerAPIsObject.sObject_x> sObjects = new List<PartnerAPIsObject.sObject_x>();
		PartnerAPI.UpsertResult[] b0025 = soap.upsertSobject(externalIDFieldName, sObjects);
		
		Test.setMock(WebServiceMock.class, new queryAll_MockImpl());
		String queryString = '';
		PartnerAPI.QueryResult b0026 = soap.queryAll(queryString);
		
		Test.setMock(WebServiceMock.class, new resetPassword_MockImpl());
		String userId = UserInfo.getUserId();
		PartnerAPI.ResetPasswordResult b0027 = soap.resetPassword(userId);
		
		Test.setMock(WebServiceMock.class, new mergeSobject_MockImpl());
		PartnerAPI.MergeRequest[] request = new List<PartnerAPI.MergeRequest>();
		PartnerAPI.MergeResult[] b0028 = soap.mergeSobject(request);
		
		Test.setMock(WebServiceMock.class, new query_MockImpl());
		queryString = '';
		PartnerAPI.QueryResult b0029 = soap.query(queryString);
		
		Test.setMock(WebServiceMock.class, new updateSobject_MockImpl());
		sObjects = new List<PartnerAPIsObject.sObject_x>();
		PartnerAPI.SaveResult[] b0030 = soap.updateSobject(sObjects);
    }
    
    /* tests for PartnerAPI.Soap class 4*/
    static testMethod void test5() {
    	PartnerAPI p = new PartnerAPI();
    	PartnerAPI.Soap soap = new PartnerAPI.Soap();
    			
		Test.setMock(WebServiceMock.class, new undeleteSobject_MockImpl());
		List<String> ids = new List<String>();
		PartnerAPI.UndeleteResult[] b0031 = soap.undeleteSobject(ids);    	
		
		Test.setMock(WebServiceMock.class, new retrieve_MockImpl());
		String fieldList = '';
		String sObjectType = 'Accoount';
		ids = new List<String>();
		PartnerAPIsObject.sObject_x[] b00032 = soap.retrieve(fieldList, sObjectType, ids);		
		
		Test.setMock(WebServiceMock.class, new logout_MockImpl());
		soap.logout();
    }    
    
    /* tests for PartnerAPIFault class */
    static testMethod void test6() {
    	PartnerAPIFault obj = new PartnerAPIFault();
        PartnerAPIFault.ApiFault a = new PartnerAPIFault.ApiFault();
        PartnerAPIFault.InvalidSObjectFault b = new PartnerAPIFault.InvalidSObjectFault();
        PartnerAPIFault.MalformedQueryFault c = new PartnerAPIFault.MalformedQueryFault();
        PartnerAPIFault.InvalidIdFault d = new PartnerAPIFault.InvalidIdFault();
        PartnerAPIFault.InvalidFieldFault e = new PartnerAPIFault.InvalidFieldFault();
        PartnerAPIFault.MalformedSearchFault f = new PartnerAPIFault.MalformedSearchFault();
        PartnerAPIFault.ApiQueryFault g = new PartnerAPIFault.ApiQueryFault();
        PartnerAPIFault.UnexpectedErrorFault h = new PartnerAPIFault.UnexpectedErrorFault();
        PartnerAPIFault.LoginFault i = new PartnerAPIFault.LoginFault();
        PartnerAPIFault.InvalidQueryLocatorFault j = new PartnerAPIFault.InvalidQueryLocatorFault();
        PartnerAPIFault.InvalidNewPasswordFault k = new PartnerAPIFault.InvalidNewPasswordFault();
    }
    
    /* tests for PartnerAPIsObject class */
    static testMethod void test7() {
    	PartnerAPIsObject obj = new PartnerAPIsObject();
        PartnerAPIsObject.sObject_x a = new PartnerAPIsObject.sObject_x();
        PartnerAPIsObject.orchestrationProcessSobject b = new PartnerAPIsObject.orchestrationProcessSobject();
    }
}