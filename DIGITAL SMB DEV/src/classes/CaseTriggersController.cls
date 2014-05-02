Public class CaseTriggersController{
    
    public final Case thisCase {get; set;}
    
     public CaseWrapper caseWrapper {get; set;}
    
    public CaseTriggersController(ApexPages.standardController controller){
        
        thisCase = (Case) controller.getRecord();        
    }
    
    public CaseWrapper getNewOwner(){
        
    Case caselist =  [Select OwnerId__c, OwnerId from case where Id = :thisCase.Id];
   
        
        if(caselist.OwnerId__c != null){
            
            
              if (String.ValueOf(caselist.OwnerId__c).substring(0,3) == '00G'){
                
                  Group g = [Select Id, Name from Group where Id =: caselist.OwnerId__c];
                  caseWrapper = new CaseWrapper(g.Id, g.Name);
                  return caseWrapper;
             
             }
             else {
                
                 User u =  [Select Id, Name from User where Id = :caselist.OwnerId__c];
                  caseWrapper = new CaseWrapper(u.Id, u.Name);
                  return caseWrapper;
             
             }
        
        }
        else {
             
                User u = [Select Id, Name from User where Id = :caselist.OwnerId];
                caseWrapper = new CaseWrapper(u.Id, u.Name);
                  return caseWrapper;
        
        }
        
       
    }
    
    
    
     // Wrapper class to store id and name
    public class CaseWrapper {
        
        public String Id {get;set;}
        public String Name {get;set;}
        
         public CaseWrapper(String id,String name){
            
            this.Id = id;
            this.Name = name;
            
         }
    
    }
    
  
}