/*****************************************************************************/
/* Paul Tarpey (paul.tarpey@saaspoint.com)                                   */
/* Controller for application sale visualforce pages                         */
/*                                                                           */
/*                                                                           */
/* Revision History                                                          */
/* 0.1    12/01/2009  Initial Version                                        */
/*                                                                           */
/*                                                                           */
/*****************************************************************************/
public class Application_Sale_Controller {

	// Controller opportunity
	public Opportunity opp {get;set;}
	public String updateStatus {get;set;}
	
	// The opportunity detail to create
	public O2_Product_Detail__c oppDet {get;set;} { oppDet = new O2_Product_Detail__c();}
	
	// List of Sales to Display
	public List<ApplicationSale> salesForDisplay {get; private set;}
	
	// List of Mobilisation Specialists for Display
	public List<MobilisationSpec> mobSpecsForDisplay {get;private set;}
	
	// Quantity
	public Integer quantity {get; set;} { this.quantity = 1;}
	
	private Integer noApplicationSales() {
		if (this.salesForDisplay == null) return 0;
		else return this.salesForDisplay.size();
	} // end noApplicationSales
	
	// Display warning message or not (no application sales returned)
	public Boolean getNoApplicationSalesExist() {
		if (this.noApplicationSales() == 0) return true;
		else return false;
	} // end getNoApplicationSalesExist

	public Boolean getApplicationSalesExist() {
		return !getNoApplicationSalesExist();
	} // end getApplicationSalesExist
		
	// Actions
	public PageReference cancelList() {
		return new PageReference('/' + this.opp.Id);
	} // end cancelList	
	
	public PageReference step1() {
		return Page.Application_Sale_Step1;
	} // end step1
		
	public PageReference step2() {
		if (this.getSelectedId() == null) return Page.No_App_Selected;
		else return Page.Application_Sale_Step2;
	} // end step2
	
	public PageReference step3() {
		return Page.Application_Sale_Step3;
	} // end step3
	
	public PageReference step4() {
		if ((this.oppDet.Length_of_Contract__c == '12 Months') || 
			(this.oppDet.Length_of_Contract__c == 'Other')){
			this.oppDet.Length_of_Contract__c.addError(Label.not_valid_for_oar);
			return null;
		}		
		if (this.opp.StageName == 'Closed Won') {
			this.oppDet.Length_of_Contract__c.replace(' Months','');
			this.updateStatus = O2_linkage_utils.CreateSale(this.opp.Id,
															this.getSelectedId(),
															this.oppDet.Application_Sale_Date__c,
															this.oppDet.Number_of_Licences__c,
															this.getMobSpecSelectedId(),
															this.oppDet.Contract_Reference__c,
															this.oppDet.Length_of_Contract__c,
															this.oppDet.OARNotes__c,
															this.opp.AccountId);
			this.oppDet.OARRegisteredDateTime__c = Datetime.now();
		}
		else {
			this.updateStatus = Label.WHEN_CLOSED_WON;
		}
		System.debug('return from create sale = ' + this.updateStatus);
		this.oppDet.Opportunity__c = this.opp.Id;
		this.oppDet.Quantity__c = this.quantity;
		//this.oppDet.Application_Sale_Date__c = this.opp.Sale_Date__c;
		this.oppDet.Product_Category__c = 'Application Partner Solution';
		this.oppDet.Product__c = this.getSelectedName();
		this.oppDet.Mobilisation_Specialist__c = this.getMobSpecSelectedName();
		this.oppDet.OARMobSpecId__c = this.getMobSpecSelectedId();
		this.oppDet.OARApplicationId__c = this.getSelectedId();

		System.debug('Inserting oppDet = ' + oppDet);
		insert oppDet;
		System.debug('Inserted oppDet = ' + oppDet);
		return Page.Application_Sale_Step4;
	} // end step4	
	
	// Get the mobilisation specialists
	public List<MobilisationSpec> getMobSpecs() {
		return this.mobSpecsForDisplay;
	} // end getModSpecs
	
	public Boolean getNoMobSpecsExist() {
		if ((this.mobSpecsForDisplay == null) || (this.mobSpecsForDisplay.size() == 0)) return true;
		else return false;
	} // end getNoMobSpecsExist
	
	public Boolean getMobSpecsExist() {
		return !getNoMobSpecsExist();
	} // end getMobSpecsExist
	
	// Pull back the id that the user has selected
	public String getSelectedId() {
		String selectedId;
		if (this.salesForDisplay != null) {
			for (ApplicationSale sale : this.salesForDisplay) {
				if (sale.getSelected()) {
					selectedId = sale.Id;
					break;
				} // end check for selected
			} // end loop through application sales
		} // end null check if
		return selectedId;
	} // end getSelectedId
	
	// Pull back the mobilisation specialist id that the user has selected
	public String getMobSpecSelectedId() {
		String selectedId;
		if (this.mobSpecsForDisplay != null) {
			for (MobilisationSpec mob : this.mobSpecsForDisplay) {
				if (mob.getSelected()) {
					selectedId = mob.Id;
					break;
				} // end check for selected
			} // end loop through application sales
		} // end null check if
		return selectedId;
	} // end getSelectedId
		
	// Pull back the name that the user has selected
	public String getSelectedName() {
		String selectedName;
		for (ApplicationSale sale : this.salesForDisplay) {
			if (sale.getSelected()) {
				selectedName = sale.Name;
				break;
			} // end check for selected
		} // end loop through application sales
		return selectedName;
	} // end getSelectedName
	
	// Pull back the name that the user has selected
	public String getMobSpecSelectedName() {
		String selectedName;
		for (MobilisationSpec mob : this.mobSpecsForDisplay) {
			if (mob.getSelected()) {
				selectedName = mob.fullname;
				break;
			} // end check for selected
		} // end loop through application sales
		return selectedName;
	} // end getSelectedName
		
	// Constructor
	//public Application_Sale_Controller(ApexPages.StandardController stdController) {
	//    this.opp = (Opportunity)stdController.getRecord();

	    // Call OAR to get back the application sales
	//	try {
	//		this.salesForDisplay = O2_linkage_utils.getApplicationSales();
	//		this.mobSpecsForDisplay = O2_linkage_utils.getMobilisationSpecialists();
	//		System.debug(this.salesForDisplay);
	//	} // end try block
	//	catch (Exception e) {
			// Do nothing - there will be no application sales and a generic
			// error will be displayed to the user
	//	} // end catch
	//} // end constructor
	
	public Application_Sale_Controller(ApexPages.StandardSetController stdController) {
		this.opp = [Select Id,AccountId,StageName From Opportunity Where Id = :ApexPages.currentPage().getParameters().get('id')];
		
	    // Call OAR to get back the application sales
		try {
			this.salesForDisplay = O2_linkage_utils.getApplicationSales();
			this.mobSpecsForDisplay = O2_linkage_utils.getMobilisationSpecialists();
			System.debug(this.salesForDisplay);
		} // end try block
		catch (Exception e) {
			// Do nothing - there will be no application sales and a generic
			// error will be displayed to the user
		} // end catch		
	} // end constructor	
} // end Controller