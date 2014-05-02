/*
	R.Clark		4th July 2011	Refactored from AvailabilityCheckInputProcessor  
*/
public with sharing class CSVUtils {

	private static final Integer MAX_FILE_SIZE = 300000; 
	
	public static Integer getFileSize(Blob file) {
        String fileString = file.toString();

        // split the string on carriage returns
		Integer maxSize = MAX_FILE_SIZE > fileString.length()? fileString.length():MAX_FILE_SIZE;
        Pattern nonWordChar = Pattern.compile('[^\\w\\s,]');
        fileString = fileString.substring(0,maxSize);
        fileString = nonWordChar.matcher(fileString).replaceAll('');
        List<String> tmpRowList = fileString.split('\n|\r', -1);

		return tmpRowList.size();		
	}


	// Given a CSV file processes the lines and returns a list of strings for each record
	// Use parseCSVLine to process an individual line
	public static List<String> parseCSVFileRecord(Blob file) {
        String fileString = file.toString(); 
		
		Integer maxSize = MAX_FILE_SIZE > fileString.length()? fileString.length():MAX_FILE_SIZE;
        fileString = fileString.substring(0,maxSize);
        // remove non word characters (0-9, a-z, A-Z, ',' space, newline, carriage return)
        Pattern nonWordChar = Pattern.compile('[^\\w\\s,]');
        fileString = nonWordChar.matcher(fileString).replaceAll('');
        List<String> rowList = fileString.split('\n|\r', -1);
        
        return rowList;
	}

	// Given an individual line return the CSV strings within in
	public static List<String> parseCSVLine(String record) {
        List<String> rowValues = new List<String>();

        if (record.length() > 0) {
            rowValues = record.split(',', -1);
        }
		
		return rowValues;
	}


	// Create a list of string lists for each value in the CSV file
    public static List<List<String>> parseCSVFile(Blob file) {
    	
        List<List<String>> rowList = new List<List<String>>();
        List<String> rowValues = new List<String>();
        String fileString = file.toString();
                
        // split the string on carriage returns
        // List<String> tmpRowList = fileString.split('\n', -1);
        // Need to limit the size, if not we get a "Regex too complicated" governor limit 
        // 300k allows up to 10k line checks as each line will be less than 30 characters long
        // and Assume up to 1K Bulk Orders
        //fileString = fileString.replaceAll('[:;+=-_!$£&()*\'?<>|/\\]','');

        Integer maxSize = MAX_FILE_SIZE > fileString.length()? fileString.length():MAX_FILE_SIZE;
        fileString = fileString.substring(0,maxSize);
        // remove non word characters (0-9, a-z, A-Z, ',' space, newline, carriage return)
        Pattern nonWordChar = Pattern.compile('[^\\w\\s,]');
        fileString = nonWordChar.matcher(fileString).replaceAll('');
        List<String> tmpRowList = fileString.split('\n|\r', -1);
        
        Boolean firstRow = true;
        for (String row : tmpRowList) {
            if (! firstRow) {
                if (row.length() > 0) {
                    rowValues = row.split(',', -1);
                    rowList.add(rowValues);
                }
            } else {
                firstRow = false;
            }
        }
        return rowList;
    }
    
    // This method inserts the CSV file records into intermediate bulk order object.
    public static List<Id> insertCSVRecordsIntoIntermediateObject(List<List<String>> records){
		String csvFieldVal= '';
		List<Id> bulkOrderObjList = new List<Id>();
		List<Bulk_Order_Intermediate__c> bulkOrderObjs = new List<Bulk_Order_Intermediate__c>();
			
		for (List<String> fields : records) {
			Bulk_Order_Intermediate__c bulkOrderIntermediateObj = new Bulk_Order_Intermediate__c();
			
			for(Integer i=0 ; i<=fields.size() -1; i++){
				if(i == 0){
					csvFieldVal = fields[i];
				}
				else{
					if(fields[i] == ''){
						csvFieldVal += ','+null;
					}
					else{
						csvFieldVal +=','+fields[i];
					}
				}
			}
			
			bulkOrderIntermediateObj.bulkOrderFieldValue__c = csvFieldVal;
			bulkOrderObjs.add(bulkOrderIntermediateObj);
		}
		
	
		insert bulkOrderObjs;
				
		for(Bulk_Order_Intermediate__c bulkOrder :bulkOrderObjs){
			bulkOrderObjList.add(bulkOrder.Id);
		}		
		return bulkOrderObjList;		   
	}
}