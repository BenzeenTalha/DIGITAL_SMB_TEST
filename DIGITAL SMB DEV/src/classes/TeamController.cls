public class TeamController{

    public String teamSelected {get; set;}
    public Id selectedTeamId {get;set;}
    public Boolean showTable {get; set;}
    public String selectedUser {get;set;}
    public List<PieWedgeData> workload {get;set;}
    public String availability {get;set;}
    public String caseType {get;set;}
    public Boolean editMode {get;set;}
    public String currentUser {get;set;}
    public Map<String, Decimal> teamWorkload {get;set;}
    public Map<Id, Decimal> userWorkloadMap;
    
    public TeamController(){
        if (teamWorkload == null)
            teamWorkload = new  Map<String, Decimal>();
        userWorkloadMap = new Map<Id, Decimal>();
        workload = new List<PieWedgeData>();
        showTable = false;
        editMode = false;
        availability = '';
        showTeamSummary();
    }
    
    public Boolean allowAvailabilityEdit{
        get{
            Boolean showEdit = false;
            String roleId = UserInfo.getUserRoleId();
            if (roleId != '' && roleId != null){
                String role = 
                [
                    Select 
                            name 
                    From 
                            UserRole 
                    where
                            Id = : roleId
                ].Name;
                
                if (role.tolowercase().contains('leader') || role.tolowercase().contains('admin'))
                    showEdit = true;
                
            }
            
            return showEdit;
        }
    }

    public List<SelectOption> teamQueues{
        get{
            List<SelectOption> queues = new List<SelectOption>();
            queues.add(new SelectOption('None', 'None'));
          //  List<Group> queueList = new List<Group>();
            List<QueueSobject> queueList = new List<QueueSobject>();
            queueList = 
            [
               /* Select 
                        Type, RelatedId, OwnerId, 
                        Name, Id, Email 
                 From 
                        Group 
                 Where 
                        type = 'Queue'*/
                 Select
                         Queue.Name, Id, QueueId 
                 From 
                         QueueSobject 
                 Where 
                         SobjectType = 'CSA_Routing__c'
            ];
            
            for (QueueSobject g : queuelist){
                queues.add(new SelectOption(g.QueueId, g.Queue.Name));
            }
            return queues;
        }
    }
    
    public PageReference saveUserDetails(){
        workload = new List<PieWedgeData>();

        User u = 
        [
            Select
                    id, Name,
                    firstname, lastname,
                    CSA_Available__c,
                    CSA_Case_Type_Preference__c
            From
                    User
            Where
                    Id = : currentUser
        ];
        system.debug('********************** : ' + availability);
        system.debug('********************** : ' + caseType);
        u.CSA_Available__c =  Boolean.ValueOf(availability);
        if (caseType != null && caseType != '')
            u.CSA_Case_Type_Preference__c = caseType;
        if (caseType == 'none')
            u.CSA_Case_Type_Preference__c = '';
        update u;
        return null;
    }
    
    public PageReference editUserDetails(){
        editMode = true;
        return null;
    }
    
    public PageReference retrieveTable(){
        workload = new List<PieWedgeData>();
        showTable = true;
        return null;
    }
    
    public PageReference showUserDetails(){
        String s = Apexpages.currentpage().getParameters().get('memberId');
        if (s != '') selectedUser = (Id) s;
        if (selectedUser != null){
            apexpages.addmessage(new apexpages.message(apexpages.severity.info, selectedUser));
        }
        return null;
    }
    
    public void showTeamSummary(){
        userWorkloadMap = new Map<Id, Decimal>();
        teamWorkload = new Map<String, Decimal>();
        /** Get only queues for CSA_Routing__c **/
        List<QueueSobject> queueIds = 
        [
            Select
                     Queue.Name, Id, QueueId 
            From 
                     QueueSobject 
            Where 
                     SobjectType = 'CSA_Routing__c'
                    
        ];
        List<Id> qIds = new List<Id>();
        For (QueueSobject q : queueIds){
            qIds.add(q.queueId);
        }
        
        List<AggregateResult> members =
            [
                Select max(Id), UserOrGroupId, GroupId, group.Name gName, Group.Type gType 
                From GroupMember
                Where Group.Type = 'Queue'
                And GroupId in : qIds
                Group by UserOrGroupId, GroupId, group.Name, Group.Type
            ];
        
        List<Id> caseOwnerIds = new List<Id>();
        for (AggregateResult ar1 : members){
            caseOwnerIds.add((Id)ar1.get('UserOrGroupId'));
        }     
        
        List<AggregateResult> userWorkload =
        [
            Select
                     OwnerId, owner.Name ownerName,
                     Sum(CSA_Calculated_Weighting__c) sum_calculated_weighting
             From
                     Case
             Where
                     ownerId in : caseOwnerIds
             and status != 'Closed'
             Group By
                     OwnerId, owner.Name
             //having  Sum(CSA_Calculated_Weighting__c) > 0
        ];
        
        Decimal w;
        for (AggregateResult uw : userWorkload){
            if (uw.get('sum_calculated_weighting') != null){
                w = (Decimal) uw.get('sum_calculated_weighting');
            }else{
                w = 0;
            }
            userWorkloadMap.put((Id)uw.get('OwnerId'), w);
        }
       // system.debug('QQQQQQQQQQQQQ : ' + userWorkloadMap);
        
        String aName;
        Id aValue;
        Decimal prevValue;
        Decimal uWorkload;
        for (AggregateResult g : members){
            if (g.get('gName') != null && g.get('gName') != ''){
                aName = (String) g.get('gName');
                teamWorkload.put(aName, 0);
            }
        }
        
        for (AggregateResult gm : members){
            if (gm.get('gName') != null && gm.get('gName') != '') {
                aName = (String) gm.get('gName');
                aValue = (Id)gm.get('UserOrGroupId');
                if (userWorkloadMap.get(aValue) == null)
                    uWorkload = 0;
                else
                    uWorkload = (Decimal) userWorkloadMap.get(aValue);
                
                prevValue = teamWorkload.get(aName);
                
                teamWorkload.put(aName, prevValue + uWorkload);
            }
        }
        system.debug('QQQQQQQQQQQQQ : ' + teamWorkload);
    }
    
    
    public PageReference showWorkload(){
        if ((selectedUser == '') || (selectedUser == null))
             selectedUser = (Id) apexpages.currentpage().getParameters().get('memberId');

        List<Case> userCases = new List<Case>();

        List<AggregateResult> ag = 
        [
            Select
                    count(Id) statusCount, status
            From
                    Case
            Where
                    ownerId = : selectedUser
            group by
                    status
        ];

        workload = new List<PieWedgeData>();

        if (ag.size() > 0) {
            for (AggregateResult a : ag){
                workload.add(new PieWedgeData((String) a.get('status'), (Integer) a.get('statusCount')));
            }
        }
        return null;
    }
    
    public List<User> teamUsers{
        get{
            List<User> users = new List<User>();
            List<GroupMember> gm = new List<GroupMember>();
            List<Id> memberIds = new List<Id>();
 system.debug('$$$$$$$$$$$$$$ selectedTeamID' + selectedTeamID);
            gm = 
            [
                Select
                        id, userorgroupId
                From
                        GroupMember
                Where
                        GroupId = : selectedTeamId
            ];
                        system.debug('$$$$$$$$$$$$$$ gmss' + gm);
            for (Groupmember g : gm){
                memberIds.add(g.userorgroupId);
            }
            users = 
            [
                select
                        id, Name,
                        firstname, lastname,
                        CSA_Available__c,
                        CSA_Case_Type_Preference__c
                From
                        User
                Where
                        id in : memberIds
            ];
            
            return users;
        }
    }
    
    public List<teamMember> getteamMembers(){
        List<teamMember> tm = new List<teamMember>();
        for (User u : teamUsers){
            if ( userWorkloadMap.get(u.id) == null)
                tm.add(new TeamMember(u, 0));
            else
                tm.add(new TeamMember(u, userWorkloadMap.get(u.id)));
        }
        system.debug('$$$$$$$$$$$$$$$$$$' + tm);
        return tm;
    }
    
    public class teamMember{
        public Decimal wkload {get;set;}
        public Id uId {get;set;}
        public String fName {get;set;}
        public String lName {get;set;}
        public Boolean available {get;set;}
        public String csType {get;set;}
        public String uName {get;set;}
        
        public teamMember(User u, Decimal wk){
            uId = u.Id;
            fName = u.firstname;
            lName = u.lastname;
            available = u.CSA_Available__c;
            csType = u.CSA_Case_Type_Preference__c;
            wkload = wk;
            uName = u.Name;
        }
        
    }

    public class PieWedgeData {

        public String name { get; set; }
        public Integer data { get; set; }

        public PieWedgeData(String name, Integer data) {
            this.name = name;
            this.data = data;
        }
    }
    
    public list<SelectOption> CaseTypes{
        get{
            Case aCase = new Case();
            return getPicklistValues(aCase, 'Type');
        }
    }
    
    public static list<SelectOption> getPicklistValues(SObject obj, String fld)
    {
      list<SelectOption> options = new list<SelectOption>();

      Schema.sObjectType objType = obj.getSObjectType(); 
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
      map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
      list<Schema.PicklistEntry> values =
         fieldMap.get(fld).getDescribe().getPickListValues();
      options.add(new SelectOption('casetype', 'Case Type?'));
      options.add(new SelectOption('none', ''));
      for (Schema.PicklistEntry a : values)
      { 
         options.add(new SelectOption(a.getLabel(), a.getValue())); 
      }
      return options;
   }
   
   public class TeamData{
       public String teamName {get;set;}
       public Decimal totalWorkload {get;set;}
       
       public TeamData(String tName, Decimal workld){
           teamName = tName;
           totalWorkload = workld;
       }
   }
   
}