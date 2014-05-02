/*****************************************************************************/
/* Paul Tarpey (paul.tarpey@saaspoint.com)                                   */
/* Represents XML data returned from OAR user info call                      */
/*                                                                           */
/* Revision History                                                          */
/* 0.1    04/02/2009  Initial Version                                        */
/*                                                                           */
/*                                                                           */
/*****************************************************************************/

// XML Response from user list request - global as used in webservice
// return
global class OARUserListItem {
	public String userId {get;set;}
	public String firstName {get;set;}
	public String lastName {get;set;}
	public String email {get;set;}
	public String telephone {get;set;}
	public Boolean selected {get;set;} {this.selected = false;}
	public String salesforceUserName {get;set;}
	public String salesforceFlag {get;set;} {this.salesforceFlag = 'No';}
	

} // end class OARUserList