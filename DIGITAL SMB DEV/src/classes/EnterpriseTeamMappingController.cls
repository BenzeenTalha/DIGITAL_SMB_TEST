public class EnterpriseTeamMappingController{

    public EnterpriseTeamMappingController(ApexPages.StandardController controller){}
    
     public List<SelectOption> teamQueues{
        get{
            List<SelectOption> queues = new List<SelectOption>();
            queues.add(new SelectOption('None', 'None'));
            List<QueueSobject> queueList = new List<QueueSobject>();
            queueList = 
            [
                 Select
                         Queue.Name, Id, QueueId 
                 From 
                         QueueSobject 
                 Where 
                         SobjectType = 'CSA_Routing__c'
            ];
            
            for (QueueSobject g : queuelist){
                queues.add(new SelectOption(g.Queue.Name, g.Queue.Name));
            }
            return queues;
        }
    }

}