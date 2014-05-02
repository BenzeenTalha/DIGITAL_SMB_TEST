public class MobilisationSpec {
	public String id {get;set;}
	public String fullname {get;set;}
	private Boolean selected = false;	
	
	public Boolean getSelected() {
		return this.selected;
	}
	
	public void setSelected(Boolean pSelected) {
		this.selected = pSelected;
	}	
	
	
}