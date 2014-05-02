global with sharing class PAFLookupController {

    public String inCompanyName {get; set;}
    public String inBuildingName {get; set;}
    public String inBuildingNumber {get; set;}    
    public String inPostcode {get; set;}
    public List<AddressCheckController.Address> pafResults;
    public List<selectOption> pafList {get;set;}
    public String selectedAddress {get; set;}

    public PageReference findAddresses() {
        return null;
    }

    public PageReference searchAddress() {
        System.debug('### OUTPUT >>>>> searchAddresses: method enter: '+inBuildingName+'|'+inBuildingNumber+'|'+inPostcode);
        List<selectOption> outputOptions = new List<selectOption>();
        pafResults = findAddresses(inBuildingName, inBuildingNumber, inPostcode);
        //System.debug('### OUTPUT >>>>> searchAddresses: pafResults size is ' + pafResults.size());
        if (pafResults != null && pafResults.size() > 0) {
          //populate selectlist records from results list
          outputOptions.add(new SelectOption('', 'PLEASE SELECT'));
          for (integer i=0; i<pafResults.size(); i++) {
            String strAddr = '';
            if (pafResults[i].organisation != null && pafResults[i].organisation != '') strAddr+=pafResults[i].organisation+', ';
            if (pafResults[i].subBuildingName != null && pafResults[i].subBuildingName!='') strAddr+=pafResults[i].subBuildingName+', ';
            if (pafResults[i].buildingName != null && pafResults[i].buildingName!='') strAddr+=pafResults[i].buildingName+', ';
            if (pafResults[i].buildingNumber != null && pafResults[i].buildingNumber!='') strAddr+=pafResults[i].buildingNumber+' ';
            if (pafResults[i].street != null && pafResults[i].street!='') strAddr+=pafResults[i].street+', ';
            if (pafResults[i].postTown != null && pafResults[i].postTown != '') strAddr+=pafResults[i].postTown+', ';
            if (pafResults[i].county != null && pafResults[i].county!= '') strAddr+=pafResults[i].county+', ';
            if (pafResults[i].postcode != null && pafResults[i].postcode!= '') strAddr+=pafResults[i].postcode+', ';
            if (strAddr != '') outputOptions.add(new SelectOption(String.valueOf(i), strAddr.substring(0, strAddr.length()-2)));

          }
        }
        else {
          //populate selectlist with 'NO RESULTS' marker
          outputOptions.add(new SelectOption('NO RESULTS', 'NO RESULTS'));
        }

        pafList = outputOptions;
    
    return null;
  }
  
    @RemoteAction
    global static String AddressString(String inPostcode)
    {
        String strAddr = '';
        //System.debug('### OUTPUT >>>>> searchAddresses: method enter: '+inBuildingName+'|'+inBuildingNumber+'|'+inPostcode);
        List<selectOption> outputOptions = new List<selectOption>();
        List<AddressCheckController.Address> pafResults = new List<AddressCheckController.Address>();
        pafResults = findAddresses(null, null, inPostcode);
        System.debug('### OUTPUT >>>>> searchAddresses: pafResults size is ' + inPostcode);
        System.debug('### OUTPUT >>>>> searchAddresses: pafResults size is ' + pafResults.size());
        /*if (pafResults != null && pafResults.size() > 0) {
          //populate selectlist records from results list
          outputOptions.add(new SelectOption('', 'PLEASE SELECT'));
          for (integer i=0; i<pafResults.size(); i++) {
           
            if (pafResults[i].organisation != null && pafResults[i].organisation != '') strAddr+=pafResults[i].organisation+', ';
            if (pafResults[i].subBuildingName != null && pafResults[i].subBuildingName!='') strAddr+=pafResults[i].subBuildingName+', ';
            if (pafResults[i].buildingName != null && pafResults[i].buildingName!='') strAddr+=pafResults[i].buildingName+', ';
            if (pafResults[i].buildingNumber != null && pafResults[i].buildingNumber!='') strAddr+=pafResults[i].buildingNumber+' ';
            if (pafResults[i].street != null && pafResults[i].street!='') strAddr+=pafResults[i].street+', ';
            if (pafResults[i].postTown != null && pafResults[i].postTown != '') strAddr+=pafResults[i].postTown+', ';
            if (pafResults[i].county != null && pafResults[i].county!= '') strAddr+=pafResults[i].county+', ';
            if (pafResults[i].postcode != null && pafResults[i].postcode!= '') strAddr+=pafResults[i].postcode+', ';
            if (strAddr != '') outputOptions.add(new SelectOption(String.valueOf(i), strAddr.substring(0, strAddr.length()-2)));
            
          }
        }
        else 
        {
          //populate selectlist with 'NO RESULTS' marker
          outputOptions.add(new SelectOption('NO RESULTS', 'NO RESULTS'));
        }

        List<selectOption> pafList = outputOptions;
        */
        return strAddr;
    }
    
    
    public static List<AddressCheckController.Address> findAddresses (String pafBuildingName, String pafBuildingNumber, String pafPostcode) {
    List<AddressCheckController.Address> resAddresses;
    try {
      System.debug('### OUTPUT >>>>> findAddresses: method start');
      AddressCheckController pafcontroller = new AddressCheckController();
      if (pafBuildingName!=null) pafcontroller.buildingName = pafBuildingName;
      if (pafBuildingNumber!=null) pafcontroller.buildingNumber = pafBuildingNumber;
      if (pafPostcode!=null) pafcontroller.postcode = pafPostcode;
      if (pafcontroller.postcode!=null && pafcontroller.postcode!='') {
        PageReference resPage = pafcontroller.addressSearch();
        resAddresses = pafcontroller.addressResults;
      }
      System.debug('### OUTPUT >>>>> resAddresses: '+resAddresses);
    }
    catch (Exception e) {
        system.debug('******************>>>>>'+e);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    }
    return resAddresses;
  } 
    

}