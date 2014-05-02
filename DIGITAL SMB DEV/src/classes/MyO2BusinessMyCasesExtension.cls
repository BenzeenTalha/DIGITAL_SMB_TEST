public with sharing class MyO2BusinessMyCasesExtension {
	public MyO2BusinessMyCasesExtension() {
		
	}
/*
TO BE REMOVE
    public MyO2BusinessMyCasesExtension(ApexPages.StandardSetController controller) {
        List<Case> cases = controller.getRecords();
        List<Case> casesSorted = new List<Case>();
        for(integer i=cases.size()-1;i>=0;i--) {
            //casesSorted.add(cases[i]);
        }
        controller.setSelected(casesSorted);
        controller= new ApexPages.StandardSetController(casesSorted);
    }
*/    
}