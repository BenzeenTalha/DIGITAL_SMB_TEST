public class TestUtilities {

	public static Company_Hierarchy__c Company;
	//public static Lead myLead;
	
	public static Company_Hierarchy__c setupCompanyNbr (string pCompanyNumber, string pParentCompany, string pUltimateParentCompany, integer pLevel) 
	{
		Company_Hierarchy__c c = new Company_Hierarchy__c(Level__c = pLevel, Company_Number__c = pCompanyNumber, Parent_Company__c = pParentCompany, Ultimate_Parent_company__c = pUltimateParentCompany, Name = 'xx Company ' + pCompanyNumber, Employees__c = 0, Employees_Indicator__c = 'Actual');
		insert c;
		return c;
	}
	public static Company_Hierarchy__c setupCompanyID (string pCompanyNumber, string pParentCompany, string pParentCompanyID, string pUltimateParentCompany, string pUltimateParentID, integer pLevel) 
	{
		Company_Hierarchy__c c = new Company_Hierarchy__c(Level__c = pLevel, Company_Number__c = pCompanyNumber, Parent_Company__c = pParentCompany, Parent_Company_Id__c = pParentCompanyID, Ultimate_Parent_company__c = pUltimateParentCompany, Ultimate_Parent_company_ID__c = pUltimateParentID, Name = 'xx Company ' + pCompanyNumber, Employees__c = 0, Employees_Indicator__c = 'Actual');
		insert c;
		return c;
	}
	public static Company_Hierarchy__c setupCompany (string pName, string pCompanyNumber, string pParentCompany, ID pParentCompanyID, string pUltimateParentCompany, ID pUltimateParentCompanyID, integer pLevel) 
	{
		Company_Hierarchy__c c = new Company_Hierarchy__c(Company_Number__c = pCompanyNumber, Parent_Company__c = pParentCompany, Parent_Company_ID__c = pParentCompanyID,Ultimate_Parent_company__c = pUltimateParentCompany, Ultimate_Parent_company_ID__c = pUltimateParentCompanyID, Name = pName, Level__c = pLevel, Employees__c = 0, Employees_Indicator__c = 'Actual');
		insert c;
		return c;
	}
/*
 	public static Lead setupLead (string pLeadLastName, string pCompany);  //, string pLeadStatus, string pLeadSource) 
	{
		//Lead myLead = new Lead(LastName = pLeadLastName, Company = pCompany, Status = 'New', LeadSource = 'MNC' );
		Lead myLead = new Lead(Status = 'New', LeadSource = 'MNC' );
		insert myLead;
		return myLead;
	}
	public static Contacts_For_Leads__c setupContactsForLeads (string pLastName, ID pLead);  //, string pLeadStatus, string pLeadSource) 
	{
		Contacts_For_Leads__c cfl = new Contacts_For_Leads__c(LastName = pLastName, Lead__c = pLead);
		insert cfl;
		return cfl;
	}
*/	
}