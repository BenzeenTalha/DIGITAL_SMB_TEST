// Delete a record from the company hierarchy 
// Get a full map of all records with the same Ultimate Parent as the current Record 
// Create a delete map of records to be deleted, initially containing just the current record
// From the delete map find the children in the full map and add them to the delete map too
// Keep reading the delete map until no more records exist. Remove the original ID from the DeleteMap
// as this will get deleted by the screen action anyway. Then delete the DeleteMap keys
//
public class cDeleteFromHierarchy 
{
   public static void DeleteFromHierarchy(Company_Hierarchy__c[] CurrentCompany)
   {
      boolean Finished = false, debugit = true, logit;
      string strErrorAction, strParentID, strUltimateParentID;
      logit = true;
      //
      Map<Id, Company_Hierarchy__c> DeleteMap = new Map<Id, Company_Hierarchy__c>(); 
      //
      try
      {
         for (Company_Hierarchy__c CC:CurrentCompany) 
         { 
            
            // This record could be the Ultimate Parent, in which case we need to use the Company_Number field for the SOQL read
            // instead of the Ultimate Parent field because salesforce does not allow a record to be related to itself
            // 
            if(CC.Ultimate_Parent_Company_Id__c == null)
            {
               strUltimateParentID = CC.ID;
            }
            else
            {
               strUltimateParentID = CC.Ultimate_Parent_Company_Id__c;
            }      	
            // Query the hierarchy entries
            //
            DeleteMap.put(CC.ID, new Company_Hierarchy__c(Id = CC.ID, Company_Number__c = CC.Company_Number__c));
            //
            // Check that the hierarchy we will pull out is not more than 1000 rows
            //
            integer iHierarchySize = [select count() from Company_Hierarchy__c where Ultimate_Parent_Company_Id__c = :strUltimateParentID and Level__c > :CC.Level__c]; 
            if (iHierarchySize > 1000)
            {
            	CC.Name.adderror('Error - Hierarchy too large to delete from this level');
            }
            //
            // Pull out the whole hierarchy for this company from the current level down
            //
            Company_Hierarchy__c[] CH = [select  
                          ID 
                         ,Company_Number__c
                         ,Ultimate_Parent_Company__c
                         ,Ultimate_Parent_Company_Id__c
                         ,Parent_Company__c
                         ,Parent_Company_Id__c
                         ,Level__c 
                         from Company_Hierarchy__c 
                         where Ultimate_Parent_Company_Id__c = :strUltimateParentId 
                         and   Level__c > :CC.Level__c
                         ORDER BY Level__c]; 
            //             
            // Now we have a list of all the companies in the hierarchy with the same ultimate parent as the trigger record
            // we can build a map of company ID's to delete based on the descendents. 
            //
            for (Integer i = 0; i < CH.size(); i++) 
            {
               //See if this CH record's parent is in the DeleteMap. If it is, add this CH record too.
               // 
               if (DeleteMap.containsKey(CH[i].Parent_Company_Id__c)) // && !DeleteMap.containsKey(CH[i].ID))
               { 
                  DeleteMap.put(CH[i].ID, new Company_Hierarchy__c(Id = CH[i].ID, Company_Number__c = CH[i].Company_Number__c));
               }
            }
            // 
            //  Now we need to remove the original ID from the map as this is about to be deleted anyway
            //
            DeleteMap.remove(CC.ID);
            //
            if (DeleteMap.size() > 0) 
            {
            	delete DeleteMap.values();
            }	
         }
      }                                   // End of try
      catch (Exception e) {
         if (logit) {
            Error_Log__c err = new Error_Log__c (
                Error_Message__c = e.getMessage()
              , Error_Type__c = e.getTypeName()
              , Error_Action__c = strErrorAction
            ); 
            insert err;
         }
      }                                   // catch
   }                                      // End of CheckParentFireld
   

 }                                         // End of Class MyLeadValidation