/*
Class Name :SMBTariffRenewalDetailsController
Page name :SMBTariffRenewalDetailsController
Date: 16-Sep-2013
Requirement : SMB Customer Portal
Description: This class is used to display tariff renewal information related to logged in user  
*/
public with sharing class SMBTariffRenewalDetailsController{ 
    public boolean IsSubscriptionRefreshed{get; set;}
    
    public List<AC_Subscription__c> selectedSubscriptions {get; set;}
     public List<AC_Subscription__c> finalSelectedSubscriptions {get; set;}
    
    Map<Id,AC_Subscription_Extra__c> mapACSubscSubscrExtra = new  Map<Id,AC_Subscription_Extra__c>();
    Map<String,Account_Validation_Table__c> mapDISEAccntFlag = new  Map<String,Account_Validation_Table__c>();
    
    List<Id> acExtraToBeUpdated = new List<Id>();
    List<AC_Subscription__c> subscriptionToBeUpdated = new List<AC_Subscription__c>();
    List<AC_Subscription_Extra__c> subscripExtraToBeUpdated = new List<AC_Subscription_Extra__c>();
    
    Set<Id> listACExtraIdToBeUpdated =  new Set<Id>();
    
    //Added newly for displaying all details
    public String allDetailsCtxt{get; set;}
    public List<AC_Subscription__c> mobileSubscriptions {get; set;}
    public List<AC_Subscription__c> broadBandSubscriptions {get; set;}
    public List<AC_Subscription__c> fixedSubscriptions {get; set;}
    
    public List<TarrifMobileSubscriptionsItem> tariffMobileSubscItems{get; set;}
    public List<TarrifMobileSubscriptionsItem> tariffBroadbandSubscItems{get; set;}
    public List<TarrifMobileSubscriptionsItem> tariffFixedSubscItems{get; set;}
    
    MyO2BusinessSubscriptionsController busnsSubscCntrller;
    
    public SMBTariffRenewalDetailsController(MyO2BusinessSubscriptionsController controller) {
        busnsSubscCntrller = (MyO2BusinessSubscriptionsController)controller;
        busnsSubscCntrller.stepNumber = 2;
        busnsSubscCntrller.IsEditMode = true;
        //allDetailsCtxt = ApexPages.currentPage().getParameters().get('allDetailsCtxt');
        IsSubscriptionRefreshed = false;
    }

    public void RefreshExtras(){
        IsSubscriptionRefreshed = false;
        allDetailsCtxt = ApexPages.currentPage().getParameters().get('allDetailsCtxt');
        selectedSubscriptions = new List<AC_Subscription__c>();	
        fixedSubscriptions = new List<AC_Subscription__c>();
        mobileSubscriptions = new List<AC_Subscription__c>();
        broadBandSubscriptions = new List<AC_Subscription__c>();	
        finalSelectedSubscriptions = new List<AC_Subscription__c>();
        String tariffSearchFunc = ApexPages.currentPage().getParameters().get('tariffSearchFunc');
        system.debug('RefreshExtras  tariffSearchFunc value----'+tariffSearchFunc);
        system.debug('RefreshExtras  allDetailsCtxt value----'+allDetailsCtxt);
	    tariffMobileSubscItems =  new List<TarrifMobileSubscriptionsItem>();
	    
        if(allDetailsCtxt != null){
		     //  busnsSubscCntrller.getTariffSubscriptionsDetails();
		       fixedSubscriptions = busnsSubscCntrller.fixedSubscriptions;
		       mobileSubscriptions = busnsSubscCntrller.mobileSubscriptions;
		       broadBandSubscriptions = busnsSubscCntrller.broadBandSubscriptions;	
	           	
	           tariffMobileSubscItems = getSubscriptionsItems(mobileSubscriptions,true);
	           
	           tariffBroadbandSubscItems = new List<TarrifMobileSubscriptionsItem>();
	           tariffBroadbandSubscItems = getSubscriptionsItems(broadBandSubscriptions,false);
	           
	           tariffFixedSubscItems = new List<TarrifMobileSubscriptionsItem>();
	           tariffFixedSubscItems = getSubscriptionsItems(fixedSubscriptions,false);
           
               IsSubscriptionRefreshed = true;
        }else{
           if(tariffSearchFunc != null){
           	  if(busnsSubscCntrller.selectedSubscriptions != null){
           	   selectedSubscriptions = busnsSubscCntrller.selectedSubscriptions;
           	  }
           }else{
             if(busnsSubscCntrller.selectedTariffSubscriptions != null){
                selectedSubscriptions = busnsSubscCntrller.selectedTariffSubscriptions;
           	 }
           }
           //tariffMobileSubscItems = getSubscriptionsItems(selectedSubscriptions,true);
           
             // For less than 10 subscription scenario
               
		       mobileSubscriptions = busnsSubscCntrller.mobileSubscriptions;
		     
		       if(mobileSubscriptions.size() > Integer.valueOf(System.label.Subscription_Limit)){
	              tariffMobileSubscItems = getSubscriptionsItems(selectedSubscriptions,true);
		       	
		       }else{
		       	
	              tariffMobileSubscItems = getSubscriptionsItems(mobileSubscriptions,true);
		       }	
	           	
	         
	           
	           //tariffBroadbandSubscItems = new List<TarrifMobileSubscriptionsItem>();
	           //tariffBroadbandSubscItems = getSubscriptionsItems(broadBandSubscriptions,false);
	           
	           //tariffFixedSubscItems = new List<TarrifMobileSubscriptionsItem>();
	           //tariffFixedSubscItems = getSubscriptionsItems(fixedSubscriptions,false);
           
           
           IsSubscriptionRefreshed = true;
        }
        if ((tariffMobileSubscItems.size() == 0) && (allDetailsCtxt == null)) {
	        System.debug('view renewal eligibility, refresh extras - no subs');
        	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.MO2B_NO_SUBSCRIPTIONS_AVAILABLE));
        }
    }
    
    public List<TarrifMobileSubscriptionsItem> getSubscriptionsItems(List<AC_Subscription__c> subscriptionItems,Boolean acSubscExtraFlag){
        Id acSubscExtraId;
        //Map is for storing the Account Validation Table information corresponding to DISE Account of AC Container field corresponding to AC Subscription
        mapDISEAccntFlag = new  Map<String,Account_Validation_Table__c>();
        
        //Map is for storing the acSubscription Extra information corresponding to AC Subscription
        mapACSubscSubscrExtra = new  Map<Id,AC_Subscription_Extra__c>();
        
        //List only for storing the AC subscription extra datas based on the changed value (only stores the Fast track fee, Fast track flag, Eligibilty date and Eligibility status)
        //used in BACK action while updating the corresponding datas of record
        subscripExtraToBeUpdated = new List<AC_Subscription_Extra__c>();
        
      
        List<String> diseAccountList = new List<String>();
        
        for(AC_Subscription__c subs :subscriptionItems){
        	
        	diseAccountList.add(subs.AC_Container__r.DISE_Account_No__c);
        
        }
        
        
        //Below query will be executed only based on DISAccount Id of AC Container coming from controller SMBTariffsDetailsController
        if(diseAccountList != null && diseAccountList.size() > 0 ){
         for(Account_Validation_Table__c accntValidationDetail : [Select a.Manager__c, a.Flag__c, a.Account__c From Account_Validation_Table__c a 
                                                                 where a.Account__c in: (diseAccountList)]){
            mapDISEAccntFlag.put(accntValidationDetail.Account__c,accntValidationDetail);
            system.debug('account name is :' + accntValidationDetail.Account__c );
            system.debug('account validation details is :' + accntValidationDetail );
         }
        }
        //Below query will be executed only based on subscriptions coming from controller SMBTariffsDetailsController
        if(acSubscExtraFlag && subscriptionItems != null && subscriptionItems.size() > 0){
         for(AC_Subscription_Extra__c subscriptionExtra : [Select id, AC_Subscription__c,Able_to_fast_track__c,Renewal_Eligibility_Date__c,
                                                          Account_Type__c,ContractTerm__c, Next_Invoice_Date__c,Upgrade_Notes__c,
                                                          Fast_track_fee__c,Renewal_Eligibility_Status__c,Account_Name__c  
                                                          From AC_Subscription_Extra__c a where AC_Subscription__c in: (subscriptionItems)]){
            
            mapACSubscSubscrExtra.put(subscriptionExtra.AC_Subscription__c,subscriptionExtra);
         }
        }
        system.debug('$$$$$$mapACSubscSubscrExtra----------------'+mapACSubscSubscrExtra.size());
        AC_Subscription_Extra__c acSubscripExtraRecord =  new AC_Subscription_Extra__c();
        Account_Validation_Table__c accntValidationRecord = new Account_Validation_Table__c();
        
        TarrifMobileSubscriptionsItem tariffSubscriptnItem = null;
        
        List<TarrifMobileSubscriptionsItem> tariffSubscriptionItems = new List<TarrifMobileSubscriptionsItem>();
        
        AC_Subscription_Extra__c acSubExtraRec =  new AC_Subscription_Extra__c();
        
        system.debug('subscriptionItems---size-'+subscriptionItems.size());
        //Below query will be executed only based on Subscriptions coming from controller SMBTariffsDetailsController
        if(subscriptionItems != null && subscriptionItems.size() > 0){
        	system.debug('inside if condition subscriptionItems--&&&&&---'+subscriptionItems);
         for(AC_Subscription__c smbSubscriptions : [ select a.Name,a.Network_Serial_No__c,a.Tariff_Description__c,a.Start_Date__c,a.End_Date__c,
                                                   Term__c,a.AC_Container__r.DISE_Account_No__c,a.AC_Container__r.CT_Organisation_Container__c,
                                                   a.Tariff_Type__c,a.Tariff_Package_MRR__c,Subscription_Name__c,Tariff_Package_Line_Rent__c, a.AC_Container__r.CT_Organisation_Container__r.Type 
                                                   from AC_Subscription__c a where a.id in: (subscriptionItems)]){
           
           date contractStartDate  = smbSubscriptions.Start_Date__c ;
           date contractEndDate  = smbSubscriptions.End_Date__c ;
           accntValidationRecord = new Account_Validation_Table__c();
           acSubscripExtraRecord =  new AC_Subscription_Extra__c();
           
           //Below variable is only for storing the changed data related to fast track flag, fast track fee, eligibility date, eligibility status , Upgrade notes of AC Subscription Extra object
           acSubExtraRec =  new AC_Subscription_Extra__c();
           
           system.debug('mapDISEAccntFlag.size()----'+mapDISEAccntFlag.size());
           //Below code will be executed only if Account Validation table contains information based on DISE Account of AC Container object 
           if(mapDISEAccntFlag.size() > 0 && mapDISEAccntFlag.get(smbSubscriptions.AC_Container__r.DISE_Account_No__c) != null){
             
               //Below variable stores the Account  validation record  of that DISE Account 
               accntValidationRecord = mapDISEAccntFlag.get(smbSubscriptions.AC_Container__r.DISE_Account_No__c);
               
               //Below code will check for AC Subscription Extra Record based on AC Subscription 
               if(mapACSubscSubscrExtra.size() > 0 && mapACSubscSubscrExtra.get(smbSubscriptions.id) != null){ 
                    //Below is for storing the AC Subscription Extra based on the AC Subscription id
                    acSubscripExtraRecord =  mapACSubscSubscrExtra.get(smbSubscriptions.id);
                    tariffSubscriptnItem = new TarrifMobileSubscriptionsItem(smbSubscriptions,mapDISEAccntFlag.get(smbSubscriptions.AC_Container__r.DISE_Account_No__c),mapACSubscSubscrExtra.get(smbSubscriptions.id));
               }else{
                   tariffSubscriptnItem = new TarrifMobileSubscriptionsItem(smbSubscriptions,mapDISEAccntFlag.get(smbSubscriptions.AC_Container__r.DISE_Account_No__c));    
               }    
               
               
               //Below code will be executed for populating Customer Type from Account Validation table 
               if(accntValidationRecord.Flag__c != null && accntValidationRecord.Flag__c == Label.MY_O2_BUSINESS_O2DIRECT_CT){
                  if(accntValidationRecord.Manager__c != null){
                      tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_ACCOUNT_MANAGED_CT;
                  }else{
                      tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2DIRECT_CT;
                  }
               }else if(accntValidationRecord.Flag__c != null &&  accntValidationRecord.Flag__c == Label.MY_O2_BUSINESS_O2INDIRECT_CT ){
               		tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2PARTNER_CT;
               }else{
               	tariffSubscriptnItem.customerType = accntValidationRecord.Flag__c ;
               }
               
          }else{
          	system.debug('inside else part&&&&&');
            //Below code will be executed if we dont have any Account Validation Record for DISE Account of AC Container present on AC Subscription object 
            if(mapACSubscSubscrExtra.size() > 0 && mapACSubscSubscrExtra.get(smbSubscriptions.id) != null){
                 //Below is for storing the AC Subscription Extra Record based on AC Subscription id
                 acSubscripExtraRecord =  mapACSubscSubscrExtra.get(smbSubscriptions.id);
                 tariffSubscriptnItem = new TarrifMobileSubscriptionsItem(smbSubscriptions,mapACSubscSubscrExtra.get(smbSubscriptions.id));
            }else{
                //Below code will be executed if we don't have either Account Validation Record and AC Subscription Extra Record
                 tariffSubscriptnItem = new TarrifMobileSubscriptionsItem(smbSubscriptions);
                 system.debug('Inside else - else cndtn-tariffSubscriptnItem---'+tariffSubscriptnItem);
            } 
          }
           system.debug('account type is :' +  acSubscripExtraRecord.Account_Type__c);
           system.debug('customer type is ----:' +  tariffSubscriptnItem.customerType);
           
          //Below code is for populating Customer Type information based on the comparison of Customer Type of Account Validation Table
          if(acSubscripExtraRecord.Account_Type__c != null){
          	
          	 system.debug('account type is :' +  acSubscripExtraRecord.Account_Type__c);
          	
              if(tariffSubscriptnItem.customerType != null){
              	
              	system.debug('customer type is :' +  tariffSubscriptnItem.customerType);
              	
              		if( acSubscripExtraRecord.Account_Type__c == Label.MY_O2_BUSINESS_O2DIRECT_CT){
              			
              			if(tariffSubscriptnItem.customerType  == Label.MY_O2_BUSINESS_O2DIRECT_CT){
              				tariffSubscriptnItem.customerType = acSubscripExtraRecord.Account_Type__c;
              			}else if(tariffSubscriptnItem.customerType  ==  Label.MY_O2_BUSINESS_O2INDIRECT_CT   || tariffSubscriptnItem.customerType  ==  Label.MY_O2_BUSINESS_O2PARTNER_CT ){
              				tariffSubscriptnItem.customerType =  Label.MY_O2_BUSINESS_O2PARTNER_CT;
              			}else if(tariffSubscriptnItem.customerType  ==  Label.MY_O2_BUSINESS_O2ACCOUNTMANGED_CT){
              				tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2ACCOUNTMANGED_CT;
              			}
              		
              		}else if(acSubscripExtraRecord.Account_Type__c == Label.MY_O2_BUSINESS_O2FRANCHISE_CT){
              			
              			if(tariffSubscriptnItem.customerType  ==  Label.MY_O2_BUSINESS_O2DIRECT_CT){
              				tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2DIRECT_CT;
              			}else if(tariffSubscriptnItem.customerType  ==  Label.MY_O2_BUSINESS_O2INDIRECT_CT  || tariffSubscriptnItem.customerType  ==   Label.MY_O2_BUSINESS_O2PARTNER_CT ){
              				tariffSubscriptnItem.customerType =  Label.MY_O2_BUSINESS_O2PARTNER_CT;
              			}else if(tariffSubscriptnItem.customerType  ==  Label.MY_O2_BUSINESS_O2ACCOUNTMANGED_CT){
              				tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2ACCOUNTMANGED_CT;
              			}
              			
              		}else if (acSubscripExtraRecord.Account_Type__c ==  Label.MY_O2_BUSINESS_O2PARTNER_CT){
              			tariffSubscriptnItem.customerType =  Label.MY_O2_BUSINESS_O2PARTNER_CT;
              			
              		}else if(acSubscripExtraRecord.Account_Type__c == Label.MY_O2_BUSINESS_O2ACCOUNTMANGED_CT){
              			
              			if(tariffSubscriptnItem.customerType  ==  Label.MY_O2_BUSINESS_O2DIRECT_CT){
              				tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2ACCOUNTMANGED_CT;
              			}else if(tariffSubscriptnItem.customerType  ==  Label.MY_O2_BUSINESS_O2INDIRECT_CT   || tariffSubscriptnItem.customerType  ==   Label.MY_O2_BUSINESS_O2PARTNER_CT ){
              				tariffSubscriptnItem.customerType =  Label.MY_O2_BUSINESS_O2PARTNER_CT;
              			}else if(tariffSubscriptnItem.customerType  ==  Label.MY_O2_BUSINESS_O2ACCOUNTMANGED_CT){
              				tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2ACCOUNTMANGED_CT;
              			}
              			
              		}
              	
              }else{
              	
              	//tariffSubscriptnItem.customerType = acSubscripExtraRecord.Account_Type__c;
              	
              	system.debug('Inside check - new conditions');
              	//Added priyanka 
              	
              	if(acSubscripExtraRecord.Account_Type__c != null){
              	   if(acSubscripExtraRecord.Account_Type__c == Label.MY_O2_BUSINESS_O2DIRECT_CT){
              	   	  tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2DIRECT_CT;
              	   	  system.debug('first if--'+tariffSubscriptnItem.customerType);
              	   }else if(acSubscripExtraRecord.Account_Type__c == Label.MY_O2_BUSINESS_O2FRANCHISE_CT){
              	   	  tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2FRANCHISE_CT;
              	   	  system.debug('second if--'+tariffSubscriptnItem.customerType);
              	   	
              	   }else if(acSubscripExtraRecord.Account_Type__c ==  Label.MY_O2_BUSINESS_O2PARTNER_CT){
              	   	tariffSubscriptnItem.customerType =  Label.MY_O2_BUSINESS_O2PARTNER_CT;
              	   	  system.debug('second if--'+tariffSubscriptnItem.customerType);
              	   	
              	   }else if(acSubscripExtraRecord.Account_Type__c == Label.MY_O2_BUSINESS_O2ACCOUNTMANGED_CT){
              	   	  tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2ACCOUNTMANGED_CT;
              	   	  system.debug('third if--'+tariffSubscriptnItem.customerType);
              	   }else{
              	   	 tariffSubscriptnItem.customerType =  Label.MY_O2_BUSINESS_O2PARTNER_CT;
              	   }
              	}else{
              		tariffSubscriptnItem.customerType =  Label.MY_O2_BUSINESS_O2PARTNER_CT;
              	}
              }
             //
              	
              /**  if(acSubscripExtraRecord.Account_Type__c == tariffSubscriptnItem.customerType){
                    tariffSubscriptnItem.customerType = acSubscripExtraRecord.Account_Type__c;
                }else if(tariffSubscriptnItem.customerType == Label.MY_O2_BUSINESS_O2DIRECT_CT){
                    tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2DIRECT_CT;
                }else{
                    tariffSubscriptnItem.customerType = acSubscripExtraRecord.Account_Type__c;
                }
            }else{
                tariffSubscriptnItem.customerType = acSubscripExtraRecord.Account_Type__c;
            }*/
          }
         else if(tariffSubscriptnItem.customerType  ==  Label.MY_O2_BUSINESS_O2DIRECT_CT) {
              	 
              	   tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2DIRECT_CT;
              }
              else if(tariffSubscriptnItem.customerType  == Label.MY_O2_BUSINESS_O2INDIRECT_CT  || tariffSubscriptnItem.customerType  ==  Label.MY_O2_BUSINESS_O2PARTNER_CT ){
              		tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2PARTNER_CT;
              }else if(tariffSubscriptnItem.customerType  ==  Label.MY_O2_BUSINESS_O2ACCOUNTMANGED_CT){
              		tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2ACCOUNTMANGED_CT;
              }else{
              		//tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2ACCOUNTMANGED_CT;
              		tariffSubscriptnItem.customerType = Label.MY_O2_BUSINESS_O2PARTNER_CT;
              }
              	
          
          //Below code is for calculating "Renewal Eligibility Date" (Next Upgrade Date) and “Renewal Eligibility Status”.
          if(smbSubscriptions.Tariff_Type__c != null){
              if(smbSubscriptions.Tariff_Type__c == Label.MY_O2_BUSINESS_SIMONLY_TARIFFTYPE){
                   
                   if(contractStartDate != null){
                   	   tariffSubscriptnItem.renewalEligibilityDate = contractStartDate.addMonths(Integer.valueOf(Label.MY_O2_BUSINESS_MONTHS_ELIGIBILTY_DATE));
                   	   //CHECKING IF cUSTOMER TYPE IS pARTNER OR aCCOUNT Managed then only status and date should be calculated
                   	  //if(tariffSubscriptnItem.customerType != Label.MY_O2_BUSINESS_ACCOUNT_MANAGED_CT || tariffSubscriptnItem.customerType != Label.MY_O2_BUSINESS_PARTNER_CUSTTYPE) {     
                           
                           system.debug('-----tariffSubscriptnItem.customerType-----------------'+tariffSubscriptnItem.customerType);
                           if(tariffSubscriptnItem.renewalEligibilityDate != null &&  tariffSubscriptnItem.renewalEligibilityDate >= System.Today()){
                             tariffSubscriptnItem.upgradeEligibilityStatus = Label.MY_O2_BUSINESS_NOT_ELIGIBLE_STATUS;
                           }else {
                             tariffSubscriptnItem.upgradeEligibilityStatus = Label.MY_O2_BUSINESS_ELIGIBLE_STATUS;
                           }
                            
                   	 //}
                   }  
                     
                   
              }else if(smbSubscriptions.Tariff_Type__c == Label.MY_O2_BUSINESS_SIMPLICITY_TARIFFTYPE){
              	
              	 tariffSubscriptnItem.upgradeEligibilityStatus = Label.MY_O2_BUSINESS_ELIGIBLE_STATUS;
              	 tariffSubscriptnItem.fastTrackFlag = false;
           		 tariffSubscriptnItem.fastTrackFee =null;
              }
              else if(smbSubscriptions.Tariff_Type__c == Label.MY_O2_BUSINESS_HARDWARE_TARIFFTYPE){
                    system.debug('Inside else if condtn hardware tariff type->>>>>--'+tariffSubscriptnItem.customerType);
                    //Block for - ElseIf Tariff Type is anything else other than “Sim only” or “Simplicity” and has RRP Tariff 
                    
                   
                    
                   
                    //CHECKING IF cUSTOMER TYPE IS pARTNER OR aCCOUNT Managed then only status and date should be calculated
                   	//if(tariffSubscriptnItem.customerType != Label.MY_O2_BUSINESS_ACCOUNT_MANAGED_CT || tariffSubscriptnItem.customerType != Label.MY_O2_BUSINESS_PARTNER_CUSTTYPE) { 
                   		
                   		
                   		 if(smbSubscriptions.End_Date__c != null){
                    	
                    	tariffSubscriptnItem.renewalEligibilityDate = (smbSubscriptions.End_Date__c).addMonths(-1);
                    	}
                        
		               if(tariffSubscriptnItem.renewalEligibilityDate < System.today()){
		                   tariffSubscriptnItem.upgradeEligibilityStatus = Label.MY_O2_BUSINESS_ELIGIBLE_STATUS;
		               }else {
		                   tariffSubscriptnItem.upgradeEligibilityStatus = Label.MY_O2_BUSINESS_NOT_ELIGIBLE_STATUS;
		               }
                   //	}
              }
          }
          
          //Below code is for displaying Upgrade Notes
         if((tariffSubscriptnItem.customerType == Label.MY_O2_BUSINESS_PARTNER_CUSTTYPE 
                                 || tariffSubscriptnItem.customerType == Label.MY_O2_BUSINESS_ACCOUNT_MANAGED_CT)){
              // if(tariffSubscriptnItem.renewalEligibilityDate > System.today()){
               	//  tariffSubscriptnItem.upgradeNotes = Label.MY_O2_BUSINESS_TEXT_UPGRADE_PARTA + ' '+acSubscripExtraRecord.Account_Name__c + ' ' + Label.MY_O2_BUSINESS_TEXT_UPGRADE_PARTB;
               //}else{
               	  tariffSubscriptnItem.upgradeNotes = Label.MY_O2_BUSINESS_TEXT_SALESREP_UPGRADENOTES;
               //}
               
               if(acSubExtraRec.id == null){
                  if(acSubscripExtraRecord.id != null){
                     acSubscExtraId = acSubscripExtraRecord.id;
                  }
                  acSubExtraRec.id = acSubscripExtraRecord.id;
                }
                acSubExtraRec.Upgrade_Notes__c = tariffSubscriptnItem.upgradeNotes;
            }
          
          //Record to be updated on ac subs extra object
          if(acSubscripExtraRecord.id != null && tariffSubscriptnItem.renewalEligibilityDate  != null 
                                  && acSubscripExtraRecord.Renewal_Eligibility_Date__c != tariffSubscriptnItem.renewalEligibilityDate){
             if(acSubExtraRec.id == null){
                if(acSubscripExtraRecord.id != null){
                   acSubscExtraId = acSubscripExtraRecord.id;
                }
                 acSubExtraRec.id = acSubscripExtraRecord.id;
              }
             acSubExtraRec.Renewal_Eligibility_Date__c = tariffSubscriptnItem.renewalEligibilityDate;
             system.debug('<<acSubExtraRec.Renewal_Eligibility_Date__c>>>---'+acSubExtraRec.Renewal_Eligibility_Date__c);
          }
          
          if(acSubscripExtraRecord.id != null && tariffSubscriptnItem.upgradeEligibilityStatus  != null
                                  && acSubscripExtraRecord.Renewal_Eligibility_Status__c != tariffSubscriptnItem.upgradeEligibilityStatus){
             if(acSubExtraRec.id == null){
                if(acSubscripExtraRecord.id != null){
                   acSubscExtraId = acSubscripExtraRecord.id;
                }
                 acSubExtraRec.id = acSubscripExtraRecord.id;
             }
             acSubExtraRec.Renewal_Eligibility_Status__c = tariffSubscriptnItem.upgradeEligibilityStatus;
          }
          //acSubExtraRec.id = acSubscripExtraRecord.Id;
          
          //Logic for Able to fast track logic
          if(smbSubscriptions != null && smbSubscriptions.Tariff_Type__c == Label.MY_O2_BUSINESS_HARDWARE_TARIFFTYPE){
          	  
          	  system.debug('inside if condtn - Able to fast track logic calculation----fastTrackFlag--'+tariffSubscriptnItem.fastTrackFlag);
	          if(contractStartDate.addMonths(Integer.valueOf(Label.MY_O2_BUSINESS_MONTHS_FASTTRACK_DATE)) < System.Today()){
	            tariffSubscriptnItem.fastTrackFlag = true;
	            
	            //Setting "Able_to_fast_track__c" field value to be updated on AC Subscription Extra record
	            if(acSubscripExtraRecord.id != null && acSubscripExtraRecord.Able_to_fast_track__c != null 
	                                                && acSubscripExtraRecord.Able_to_fast_track__c != tariffSubscriptnItem.fastTrackFlag){
	                system.debug('Inside debug check of Able_to_fast_track__c');
	                if(acSubExtraRec.id == null){
	                    if(acSubscripExtraRecord.id != null){
	                       acSubscExtraId = acSubscripExtraRecord.id;
	                    }
	                    acSubExtraRec.id = acSubscripExtraRecord.id;
	                 }
	               acSubExtraRec.Able_to_fast_track__c = tariffSubscriptnItem.fastTrackFlag;
	            }
	            system.debug('Final&& Able to fast track logic calculation------'+tariffSubscriptnItem.fastTrackFlag);
	          }
          }
          
           	
                   		
           
           //Possible values- tariff type - SIM /Simplicity/Hardware/DvcLeasing 
          //Logic for calculating Fast track fee 
          if(smbSubscriptions != null && (smbSubscriptions.Tariff_Type__c == Label.MY_O2_BUSINESS_HARDWARE_TARIFFTYPE && tariffSubscriptnItem.fastTrackFlag)
                                                   || smbSubscriptions.Tariff_Type__c == Label.MY_O2_BUSINESS_DVCLEASING_TARIFF){
            
            system.debug('tariffSubscriptnItem.fastTrackFlag-----------$$$$$$$$$$'+tariffSubscriptnItem.fastTrackFlag);
            if(acSubscripExtraRecord != null){
          
	            Decimal rentalCostInfo;
	            Decimal constntNo = Decimal.valueOf(Label.MY_O2_BUSINESS_TARIFF_FEE_CONST);
	            Integer contractTerm, contractElapsedPerd;
	            Integer contractStartDay;
	            Integer presentDay;
	            
	            Date todayDate = System.today();
	            
	            if(smbSubscriptions.Tariff_Package_Line_Rent__c != null){
	              rentalCostInfo = smbSubscriptions.Tariff_Package_Line_Rent__c;
	              
	            }
	            
	            if(contractEndDate != null){
	            
	             //contractElapsedPerd = contractStartDate.monthsBetween(todayDate);
	
	             contractElapsedPerd =   todayDate.monthsBetween(contractEndDate);
	             
            //
            // If the day of the month of first is bigger than the second
            //
	            if (todayDate.day() > contractEndDate.day())
	            {
	                contractElapsedPerd--;
	            }
	             system.debug('elapse period is :' + contractElapsedPerd);
	           
	               
	            }
	            
	            if(smbSubscriptions.Term__c != null){
	              contractTerm = integer.ValueOf(smbSubscriptions.Term__c);
	             }
          
	            if(contractTerm != null && contractElapsedPerd != null && rentalCostInfo != null){
	             
		               if(smbSubscriptions.Tariff_Type__c == Label.MY_O2_BUSINESS_HARDWARE_TARIFFTYPE){
		                   //tariffSubscriptnItem.fastTrackFee = (contractTerm - contractElapsedPerd)* rentalCostInfo * constntNo;
		                    tariffSubscriptnItem.fastTrackFee = ( contractElapsedPerd)* rentalCostInfo * constntNo;
		                    system.debug('tariffSubscriptnItem.fastTrackFlag fee -----------$$$$$$$$$$'+tariffSubscriptnItem.fastTrackFee);
		                   
		               }else{
		               	   tariffSubscriptnItem.fastTrackFee = (contractTerm - contractElapsedPerd)* rentalCostInfo;
		               }
                  
                   
                   if(tariffSubscriptnItem.fastTrackFee <0){
                   	
                   	 tariffSubscriptnItem.fastTrackFee = 0.00;
                   }
                   
	               if(acSubscripExtraRecord.id != null && tariffSubscriptnItem.fastTrackFee != null
	                                                   && acSubscripExtraRecord.Fast_track_fee__c != tariffSubscriptnItem.fastTrackFee){
	                
	                 if(acSubExtraRec.id == null){
	                    if(acSubscripExtraRecord.id != null){
	                      acSubscExtraId = acSubscripExtraRecord.id;
	                    }
	                    //Below is for storing the id in the variable for comparing the id at the time of updating in BACK action for avoiding any duplicacy
	                    acSubExtraRec.id = acSubscripExtraRecord.id;
	                 }
	                 
	                 acSubExtraRec.Fast_track_fee__c = tariffSubscriptnItem.fastTrackFee;
	                 system.debug('ac subscription fee -----------$$$$$$$$$$'+acSubExtraRec.Fast_track_fee__c);
	                 
	              }
	            }
          }
         }//End of if condition SIM / SIMPLICITY Tariff Type
         
         
         if(tariffSubscriptnItem.customerType == Label.MY_O2_BUSINESS_ACCOUNT_MANAGED_CT || tariffSubscriptnItem.customerType == Label.MY_O2_BUSINESS_PARTNER_CUSTTYPE) { 
           		tariffSubscriptnItem.fastTrackFlag = false;
           		tariffSubscriptnItem.upgradeEligibilityStatus='';
           		tariffSubscriptnItem.renewalEligibilityDate =null;
           		tariffSubscriptnItem.fastTrackFee =null;
           	
           	}
          
          //Logic for Leased Device DvcLeasing
          //if (smbSubscriptions.Tariff_Type__c == Label.MY_O2_BUSINESS_LEASING_TARIFF)
          /*if (smbSubscriptions.Tariff_Type__c == Label.MY_O2_BUSINESS_DVCLEASING_TARIFF){
            tariffSubscriptnItem.leasedDeviceInfo = true;
          }*/
          if(acSubExtraRec.id != null){
              if(acSubscExtraId != null){
                 //Below list is for storing the AC Subscription Extra id that needs to be updated from Back button only in case of any new changes
                 listACExtraIdToBeUpdated.add(acSubscExtraId);
              }
              system.debug('subscripExtraToBeUpdated------'+subscripExtraToBeUpdated);
              subscripExtraToBeUpdated.add(acSubExtraRec);      
          }
          //Storing the records in list 
          tariffSubscriptionItems.add(tariffSubscriptnItem);
        }
      }
        system.debug('tariffSubscriptionItems---->'+tariffSubscriptionItems);
        system.debug('tariffSubscriptionItems-size--->'+tariffSubscriptionItems.size());
        return tariffSubscriptionItems;
    }
 
    public PageReference Back() {
        system.debug('subscripExtraToBeUpdated-size--'+subscripExtraToBeUpdated.size());
        List<AC_Subscription_Extra__c> subsExtraList =  new List<AC_Subscription_Extra__c>();
        
        if(listACExtraIdToBeUpdated.size() > 0){
            for(AC_Subscription_Extra__c listACEXtra :[select Able_to_fast_track__c,Renewal_Eligibility_Status__c, Fast_track_fee__c,
                                                       Renewal_Eligibility_Date__c,Upgrade_Notes__c from AC_Subscription_Extra__c 
                                                       where id in: listACExtraIdToBeUpdated]){
                if(subscripExtraToBeUpdated.size() > 0){
                    for(AC_Subscription_Extra__c acext: subscripExtraToBeUpdated){
                        if(listACEXtra.id == acext.id){
                           listACEXtra.Able_to_fast_track__c = acext.Able_to_fast_track__c;
                           listACEXtra.Renewal_Eligibility_Status__c = acext.Renewal_Eligibility_Status__c;
                           listACEXtra.Fast_track_fee__c = acext.Fast_track_fee__c;
                           listACEXtra.Renewal_Eligibility_Date__c = acext.Renewal_Eligibility_Date__c;
                           listACEXtra.Upgrade_Notes__c = acext.Upgrade_Notes__c;
                           
                           subsExtraList.add(listACEXtra);
                        }
                    }
                }
            }
        }
        try{
            system.debug('subsExtraList-----'+subsExtraList);
          if(subsExtraList.size() > 0){
            update subsExtraList;
          }
        }catch(Exception e){
            System.debug('subsExtraList%%% exception----'+e.getMessage());
        }
       return Page.smbhome;   
     
    }
    
    /*public void updateACSubscExtra(List<TarrifMobileSubscriptionsItem> tariffitems){
      system.debug('inside method called');
    }
    */
    public class TarrifMobileSubscriptionsItem {

        public Boolean fastTrackFlag{get; set;}
        public String customerType {get; set;} 
        public Decimal fastTrackFee {get; set;}
        public Boolean leasedDeviceInfo {get; set;} 
        public Date renewalEligibilityDate {get;set;}
        public Date nextInvoiceDate {get;set;}
        public String upgradeEligibilityStatus {get; set;}
        public Date nextUpgradeDate {get;set;}
        public String upgradeNotes {get; set;}
       
        public AC_Subscription__c subscription{get; set;}
        public AC_Subscription_Extra__c SubscriptionExtra{get; set;}
        public Account_Validation_Table__c subscAccountValidFlag {get;set;}
         
        //Called in case of not having both AC Subscription Extra, Account Validation Record  
        public TarrifMobileSubscriptionsItem(AC_Subscription__c mobileSubscription){
          this.fastTrackFlag = false;
          this.subscription = mobileSubscription;
        }
        
        //Called In case of not having the Account Validation Record
        public TarrifMobileSubscriptionsItem(AC_Subscription__c mobileSubscription,AC_Subscription_Extra__c subscriptionExtra){
          this.fastTrackFlag = false;
          this.subscription = mobileSubscription;
          this.SubscriptionExtra = subscriptionExtra;
        }
        
        //Called In case of not having AC Subscription Extra Record
        public TarrifMobileSubscriptionsItem(AC_Subscription__c mobileSubscription,Account_Validation_Table__c accntValidDetail){
          this.fastTrackFlag = false;
          this.subscription = mobileSubscription;
          this.subscAccountValidFlag = accntValidDetail;
        }
        
        //Called in case of having AC Subscription, AC Subscription Extra, Account Validation Record
        public TarrifMobileSubscriptionsItem(AC_Subscription__c mobileSubscription,Account_Validation_Table__c accntValidDetail,AC_Subscription_Extra__c subscriptionExtra){
          this.fastTrackFlag = false;
          this.subscription = mobileSubscription;
          this.subscAccountValidFlag = accntValidDetail;
          this.SubscriptionExtra = subscriptionExtra;
        }
    } 
            
    public List<TarrifMobileSubscriptionsItem> getTariffMobileSubscItems() {
      return tariffMobileSubscItems;
    }
    
     
    
}