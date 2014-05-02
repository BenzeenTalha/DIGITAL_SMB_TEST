public class Cache 
{
	private static Map<String,String> mRecordTypes;
    
    static
    {
    	string Key;
    	string Value;
    	
    	if (mRecordTypes==null)
    	{
    		List<RecordType>  rtlist=[select Id,Name,SObjectType from RecordType];
    		
    		mRecordTypes = new Map<String,String>();
    		
    		for (RecordType rt : rtlist)
    		{
    			Key = rt.SObjectType + '.' + rt.Name;
    			Value=rt.Id;
    			
    			mRecordTypes.put(Key ,Value );
    		}	
    	}
    }
    
    public static string RecordTypeId(string RecordTypeName)
    {
    	string result='';
    	
    	if (mRecordTypes.containsKey(RecordTypeName))
    	{
    		result=mRecordTypes.get(RecordTypeName);
    	}
    	
    	return 	result;
    }
}