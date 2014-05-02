// This class reads the Parent Lead based on an external Id (Tree Parent Org Reg No) and populates 
//  a Custon Lookup field (Tree_Parent_ID) to build a link between the two records
// based on the Lead passed to it. This allows a Related list of dependents to be displayed
// Note that the Company Number of the Parent is the field linking the Leads.
// 
public class cBuildHierarchy 
{
	/*
	public static void buildHierarchyV2(Company_Hierarchy__c[] currentHierarchies, Company_Hierarchy__c[] previousHierarchies) {
		List<Id> parentCompanyIds = new List<Id>();
		List<String> parentCompanyNumbers = new List<String>();
		Map<Id, Company_Hierarchy__c> parentCompanyIdsMap = new Map<Id, Company_Hierarchy__c>();
		Map<Id, Company_Hierarchy__c> parentCompanyNumbersMap = new Map<Id, Company_Hierarchy__c>();
		
		for (Company_Hierarchy__c ch : currentHierarchies) {
			if (ch.Parent_Company__c != null && ch.Parent_Company__c != ch.Company_Number__c) {
				parentCompanyNumbers.add(ch.Parent_Company__c);
			}
			
			if (ch.Parent_Company_Id__c != null && ch.Parent_Company_Id__c != ch.Id) {
				parentCompanyIds.add(ch.Parent_Company_Id__c);
			}
		}
		
		parentCompanyNumbersMap = new Map<Id, Company_Hierarchy__c>([select ID, Company_Number__c, Ultimate_Parent_Company__c, Ultimate_Parent_Company_Id__c, Parent_Company__c, Parent_Company_Id__c, Level__c from Company_Hierarchy__c where Company_Number__c in :parentCompanyNumbers]);
		parentCompanyIdsMap = new Map<Id, Company_Hierarchy__c>([select ID, Company_Number__c, Ultimate_Parent_Company__c, Ultimate_Parent_Company_Id__c, Parent_Company__c, Parent_Company_Id__c, level__c from Company_Hierarchy__c where ID in :parentCompanyIds]);
		
		Id parentCompanyId, ultimateParentCompanyId;
		String parentCompany, ultimateParentCompany;
		Double level;
		Company_Hierarchy__c parentCH;
		
		for (Company_Hierarchy__c ch : currentHierarchies) {
			// Condition 1
			if (ch.Parent_Company__c != null && ch.Parent_Company__c != ch.Company_Number__c) {
				parentCH = parentCompanyNumbersMap.get(ch.Parent_Company__c);
				
			}
			// Condition 2
			else if (ch.Parent_Company_Id__c != null && ch.Parent_Company_Id__c != ch.Id) {
				parentCH = parentCompanyIdsMap.get(ch.Parent_Company_Id__c);
			}
			// Condition 3
			else if (ch.Parent_Company_ID__c != null && ch.Parent_Company__c != null) {
				ch.addError('Both Parent Company Id and Parent Company Number were entered, but do not correspond');
				break;
			}
			else {
				// Generic Exception
				ch.addError('General Exception');
				break;
			}
			
			parentCompanyId         = parentCH.Id; 
            parentCompany           = parentCH.Company_Number__c; 
            level                   = parentCH.Level__c + 1;
            ultimateParentCompanyId = parentCH.Ultimate_Parent_Company_Id__c;
            ultimateParentCompany   = parentCH.Ultimate_Parent_Company__c;
			if (ultimateParentCompanyId == null || ultimateParentCompany == null) {
				ultimateParentCompany   = parentCompany;
             	ultimateParentCompanyId = parentCompanyId;
			}  
		}	
	}
	*/
   
   public static void BuildHierarchy(Company_Hierarchy__c[] CurrentCompany, Company_Hierarchy__c[] OldCompany)
   {
      //
      //Company_Hierarchy__c ParentCompany;
      boolean Finished = false,  debugit = true,  logit=true, allok = true;
      string strErrorAction;
      double iLevel = 1, iIDLevel, iLevelAdjuster;
      string strParentCompany,   strParentCompanyID,   strUltimateParentCompany,   strUltimateParentCompanyId;
      string strIDParentCompany, strIDParentCompanyID, strIDUltimateParentCompany, strIDUltimateParentCompanyId; 
      //
      try
      {
         for (Company_Hierarchy__c CC:CurrentCompany) 
         {
            if (cStaticClass.myID == null)
            {
               cStaticClass.myId = CC.ID;
            }   
            if (CC.Level__c == null)
            {
               CC.Level__c = 0;
            }   
            // Base the hierarchy on the Company Number if it is specified AND there is no Parent ID specified
            // This means that the company record is being loaded from an external system
            // If the Parent ID is specified then base the hierarchy on the Id and not on the company number
            // This means the company is being set up on-line
            //         
            if (CC.Parent_Company__c != null && CC.Parent_Company__c != CC.Company_Number__c)
            {
               // Look for the Parent Company by Company Number to get it's ID
               //
               strErrorAction = '=== Company_Hierarchy__c[] PC = [select ID, Company_Number__c, Ultimate_Parent_Company__c, Ultimate_Parent_Company_Id__c, Parent_Company__c, Parent_Company_Id__c, Level__c from Company_Hierarchy__c where Company_Number__c = :' + CC.Parent_Company__c + ' limit 1];';
               Company_Hierarchy__c[] PC = [select ID, Company_Number__c, Ultimate_Parent_Company__c, Ultimate_Parent_Company_Id__c, Parent_Company__c, Parent_Company_Id__c, Level__c from Company_Hierarchy__c where Company_Number__c = :CC.Parent_Company__c limit 1];
               // Company_Hierarchy__c[] PC = [select ID, Company_Number__c,  Level__c from Company_Hierarchy__c where Company_Number__c = :CC.Parent_Company__c limit 1];
               //
               if (PC.size() > 0)
               {
                  strParentCompanyId         = (PC[0].ID); 
                  strParentCompany           = (PC[0].Company_Number__c); 
                  iLevel                     = PC[0].Level__c + 1;
                  strUltimateParentCompanyId = PC[0].Ultimate_Parent_Company_Id__c;
                  strUltimateParentCompany   = PC[0].Ultimate_Parent_Company__c;
                  //
               }   
            }                                                // if (CC.Parent_Company__c != null

            // =====================================================================================  
            //
            // if the parent company Id was entered, got to drive the hierarchy off the Id..  
            //
            if (CC.Parent_Company_Id__c != null && CC.Parent_Company_Id__c != CC.Id)
            {
               // Look for the Parent Company by Company Number
               //
               strErrorAction = '=== Company_Hierarchy__c[] PC = [select ID, Company_Number__c, Ultimate_Parent_Company__c, Ultimate_Parent_Company_Id__c, Parent_Company__c, Parent_Company_Id__c, Level__c from Company_Hierarchy__c where ID = :' + CC.Parent_Company_Id__c + ' limit 1];';
               Company_Hierarchy__c[] PC = [select ID, Company_Number__c, Ultimate_Parent_Company__c, Ultimate_Parent_Company_Id__c, Parent_Company__c, Parent_Company_Id__c, level__c from Company_Hierarchy__c where ID = :CC.Parent_Company_Id__c limit 1];
               //
               if (PC.size() > 0)
               {
                  strIDParentCompanyId       = PC[0].ID; 
                  strIDParentCompany         = PC[0].Company_Number__c; 
                  iLevel                     = PC[0].Level__c + 1;
                  strUltimateParentCompanyId = PC[0].Ultimate_Parent_Company_Id__c;
                  strUltimateParentCompany   = PC[0].Ultimate_Parent_Company__c;
                  //
                  if (strUltimateParentCompanyId == null || strUltimateParentCompany == null)
                  {  
                  	 // This can happen when the Parent is the Ultimate Parent
                     strUltimateParentCompany   = strIDParentCompany;
                     strUltimateParentCompanyId = strIDParentCompanyId;
                  }
                  
               }
            }                                  // if (CC.Parent_Company_Id__c != null)  
            //
            // Common processing for if company ID or company Number was entered. 
            //
            // If the Parent Company Number AND Parent Company ID are both specified and don't agree
            // Then raise an error...
            //
            if (CC.Parent_Company_ID__c != null && CC.Parent_Company__c != null)
            {
               // Both Id and company number were specified. 
               if (strParentCompanyId != strIDParentCompanyId && allok)
               {
                  // error You entered both company number and company Id, but they don't match
                  CC.Parent_Company_ID__c.adderror('Both Parent Company Id and Parent Company Number were entered, but do not correspond');
                  allok = false;
               }
            } 
            // Make sure the keys are held in strParentCompanyId and strParentCompany regardless of the route taken above
            //
            if (strParentCompanyId == null && strIDParentCompanyId != null)
            {
               strParentCompanyId = strIDParentCompanyId;
            }
            //
            if (strParentCompany == null && strIDParentCompany != null)
            {
               strParentCompany = strIDParentCompany;
            }
            //
            if (debugit){system.debug('=== b4 finding UP strParentCompanyId = ' + strParentCompanyId + ' strIDParentCompanyId = ' + strIDParentCompanyId + ' strParentCompany =  ' + strParentCompany);}
            //
            // ========================================================
            // Find the Ultimate Parent if a Parent record was found
            // ========================================================
            //
            if (strUltimateParentCompanyId == null || strUltimateParentCompany == null)
            {  
               // This can happen when the Parent is the Ultimate Parent
               strUltimateParentCompany   = strParentCompany;
               strUltimateParentCompanyId = strParentCompanyId;
            }
            if (strParentCompanyId != null || strParentCompany != null) 
            {
               // Check that Ultimate Parent matches with the Parents Ultimate Parent 
               //
               if (strUltimateParentCompany != CC.Ultimate_Parent_Company__c && strUltimateParentCompany != null && CC.Ultimate_Parent_Company__c != null && allok)
               {
                  CC.Ultimate_Parent_Company__c.adderror('Ultimate Parent Company Must correspond with Parent\'s Ultimate Parent');
                  allok = false;  
               }
               
               if (strUltimateParentCompanyID != CC.Ultimate_Parent_Company_Id__c && strUltimateParentCompanyID != null && CC.Ultimate_Parent_Company_Id__c != null && allok)
               {
                  CC.Ultimate_Parent_Company_Id__c.adderror('Ultimate Parent Company Id Must correspond with Parent\'s Ultimate Parent Id');
                  allok = false;  
               }
               // Check that Ultimate Parent Number & ID relate to the same record. 
               //
               // If we still don't have an Ultimate Parent, use the Parent as the Ultimate Parent
               // 
               if (strUltimateParentCompany == null)
               {
                  strUltimateParentCompany   = strParentCompany;
               }
               //
               if (Trigger.isUpdate && (strParentCompanyId != null || strParentCompany != null))
               {
                  if (strParentCompanyId != CC.Parent_Company__c || strParentCompany != CC.Ultimate_Parent_Company_Id__c)	
                  {
                     // ==============================================================================================
                     //
                     // If the parent changed, we need to update all the children... 
                     //
                     iLevelAdjuster = iLevel - OldCompany[0].Level__c;  
                     //
                     // Get the children
                     // Pull out the hierarchy for this company from the current level down
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
                         where Ultimate_Parent_Company_Id__c = :OldCompany[0].Ultimate_Parent_Company_Id__c // Trigger.old[0].Ultimate_Parent_Company_Id__c //CC.Ultimate_Parent_Company_Id__c  //strUltimateParentCompanyId 
                         and   Level__c > :OldCompany[0].Level__c  // CC.Level__c
                         ORDER BY Level__c]; 
                     //             
                     // Now we have a list of all the companies in the hierarchy with the same ultimate parent as the trigger record
                     // we can build a map of company ID's to update based on the descendents. 
                     //
                     Map<Id, Company_Hierarchy__c> UpdateMap = new Map<Id, Company_Hierarchy__c>(); 
                     //
                     // Put the original (old) company to the Map so we can use the 'contains' verb later to get the children
                     UpdateMap.put(OldCompany[0].ID, new Company_Hierarchy__c(Id = OldCompany[0].ID, Company_Number__c = OldCompany[0].Company_Number__c));
                     //
                     for (Integer i = 0; i < CH.size(); i++) 
                     {
                        //See if this CH record's parent is in the UpdateMap. If it is, add this CH record too.
                        // 
                        if (UpdateMap.containsKey(CH[i].Parent_Company_Id__c)) 
                        { 
                           UpdateMap.put(CH[i].ID, new Company_Hierarchy__c(Id = CH[i].ID, Company_Number__c = CH[i].Company_Number__c, Level__c = CH[i].Level__c));
                        }
                     }
                     // 
                     //  Now we need to remove the original ID from the map as this is about to be updated anyway
                     //
                     UpdateMap.remove(CC.ID);
                     //
                     // UpdateMap contains all (and only) the descendents of the current record 
                     //
                     if (UpdateMap.size() > 0) 
                     {
                        // Check that the new values will not cause an inconsistency in the hierarchy (a loop)
            	        //
            	        if (UpdateMap.containsKey(strParentCompanyId))
            	        {
            	           // The map of the current records descendents contains the current records new parent
            	           // This would cause an inconsistency in the hieratrchy and a loop
            	           if (CC.Parent_Company_Id__c == null)
            	           {
            	              CC.Parent_Company__c.adderror('This company is a subsidiary of ' + CC.Company_Number__c);
            	           }
            	           else
            	           {
            	              CC.Parent_Company_Id__c.adderror('This company is a subsidiary of ' + CC.Company_Number__c);
            	           }   
            	        }
                     	
            	        // Now we need to update the descendents in this map (Level, and Ultimate Parent) and update it
            	        // To iterate through the members of the map, we need then put into a list and drive it off that
            	        //
            	        list<Company_Hierarchy__c> aUpdateList = new List<Company_Hierarchy__c>();
            	        aUpdateList = UpdateMap.values();
            	        for (Integer i = 0; i < aUpdateList.size(); i++)
            	        {            	  
            	           UpdateMap.get(aUpdateList[i].ID).Level__c = UpdateMap.get(aUpdateList[i].ID).Level__c + iLevelAdjuster;
            	           UpdateMap.get(aUpdateList[i].ID).Ultimate_Parent_Company__c = strUltimateParentCompany;
            	           UpdateMap.get(aUpdateList[i].ID).Ultimate_Parent_Company_Id__c = strUltimateParentCompanyID;
                 	    } 
            	        Update UpdateMap.values();  
                     }
                  }
               }	
               //
               // Set the values we figured out making sure we don't link a record to itself. 
               //
               if (strUltimateParentCompany == CC.Company_Number__c || strParentCompany == CC.Company_Number__c)
               {  
                  strIDParentCompanyId = null;
                  strIDParentCompany = null;
                  strIDUltimateParentCompanyId = null;
                  strIDUltimateParentCompany = null;
               } 
               CC.Parent_Company_Id__c          = strParentCompanyId;
               CC.Parent_Company__c             = strParentCompany;
               CC.Ultimate_Parent_Company_Id__c = strUltimateParentCompanyId;
               CC.Ultimate_Parent_Company__c    = strUltimateParentCompany;
               //
               // verify the Level
               if (CC.Level__c == 0)
               {
               	   CC.Level__c = iLevel;
               }	
               
               // SHOULD BE UNCOMMENTED
               //if (CC.Level__c != iLevel && allok)
               //{
               //   CC.Level__c.adderror('Level is inconsistent with Parent\'s level');
               //   allok = false;  
               //}
               // ==============================================================================================
            }
            if (CC.Level__c == null || CC.Level__c == 0)
            {
                 CC.Level__c  = 1;        // 0;
            }
         }                                // End of For
      }                                   // End of try
      catch (Exception e) {
         if (logit) 
         {
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