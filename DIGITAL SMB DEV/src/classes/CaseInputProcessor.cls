public class CaseInputProcessor 
{
    public static Case processCase(Case batchJobCase) 
    {
        batchJobCase.Callout_Status__c = CaseUtils.IN_PROGRESS;
        
        update batchJobCase;
        
        return batchJobCase;
    }
    
}