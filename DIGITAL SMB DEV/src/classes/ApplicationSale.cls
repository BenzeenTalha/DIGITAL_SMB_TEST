/*****************************************************************************/
/* Paul Tarpey (paul.tarpey@saaspoint.com)                                   */
/* Represents XML data returned from OAR application sales call              */
/*                                                                           */
/* Revision History                                                          */
/* 0.1    14/02/2009  Initial Version                                        */
/*                                                                           */
/*                                                                           */
/*****************************************************************************/
public class ApplicationSale {
	public String id {get;set;}
	public String name {get; set;}
	public Boolean selected = false;	
	
	public Boolean getSelected() {
		return this.selected;
	}
	
	public void setSelected(Boolean pSelected) {
		this.selected = pSelected;
	}	
	

}