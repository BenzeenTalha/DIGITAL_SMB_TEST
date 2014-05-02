global class RSS2Chatter_ScheduleCleanup implements Schedulable{
    public string getRSSPostQuery = '';
    public string getRSSChatterQuery = '';
    
    global void execute(SchedulableContext SC) {
        RSS2Chatter_CleanupRSSPosts removeRSSPosts = new RSS2Chatter_CleanupRSSPosts() ;
        if([Select Id From AsyncApexJob Where Status In ('Queued', 'Processing')].size()<5)
        	Database.executeBatch(removeRSSPosts);          
		
        RSS2Chatter_CleanupChatterPosts removeFromChatter = new RSS2Chatter_CleanupChatterPosts() ;
        if([Select Id From AsyncApexJob Where Status In ('Queued', 'Processing')].size()<5)
        	Database.executeBatch(removeFromChatter);
    } 
        
  
}