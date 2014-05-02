public with sharing class UnifyAddMassHardwareItemsController {

    private final ApexPages.StandardController theController;
    public final Unify_Hardware__c hb {get; set;}
    public string tarea {get;set;}

    public UnifyAddMassHardwareItemsController(ApexPages.StandardController stdController) {
        theController = stdController;
        hb = (Unify_Hardware__c)stdController.getRecord();
    }
    
    public Pagereference Exit(){
        Pagereference pr = new Pagereference('/' + hb.Id);
        pr.setRedirect(true);
        return pr;
    }
    
    public Pagereference Add(){
        string contents = tarea;
        string lineDelimiter;
        Unify_Hardware_Item__c[] his = [select Id, Name from Unify_Hardware_Item__c where Unify_Hardware_Bundle__c = :hb.Id];
        
        Map<String, Id> mName2Id = new Map<String, Id>();
        
        for(Unify_Hardware_Item__c h1 : his){
            mName2Id.put(h1.Name, h1.Id);
        }
         
        lineDelimiter = UnifyCommonMethods.setLineDelimeter(contents);
         
        String[] lines = contents.split(lineDelimiter);
        
        Unify_Hardware_Item__c[] toInsert = new Unify_Hardware_Item__c[]{};
        
        String[] lineFields = new String[]{};
        
        for(String s : lines){
            Unify_Hardware_Item__c in1 = new Unify_Hardware_Item__c();
            if(s.contains('\t')){
                lineFields = s.split('\t');
                if(mName2Id.containsKey(lineFields[0])){
                    in1 = new Unify_Hardware_Item__c(Id = mName2Id.get(lineFields[0]));
                } else {
                  in1.Unify_Hardware_Bundle__c = hb.Id; 
                }
                in1.Name = lineFields[0];
                in1.Description__c = lineFields[1];
                in1.Quantity__c = Double.valueOf(lineFields[2]);
                in1.Unit_Cost__c = Double.valueOf(lineFields[3].replace('£','').replace(',','.').replace(' ',''));
                toInsert.add(in1);
            } 
        }
        if(toInsert.size() > 0)
            upsert toInsert;
        
        Pagereference pr = new Pagereference('/apex/UnifyAddMassHardwareItems?id=' + hb.Id);
        pr.setRedirect(true);
        return pr;
    } 
}