global with sharing class QuoteController {

    global class ContractValidationException extends Exception {}

    Quote q;

    global QuoteController(ApexPages.StandardController c) {

        q = [select
                id,
                quoteNumber,
                opportunity.name,
                opportunity.id,
                opportunity.account.name,
                opportunity.account.billingStreet,
                opportunity.account.billingCity,
                opportunity.account.billingState,
                opportunity.account.billingPostalCode,
                opportunity.account.billingCountry,
                opportunity.Credit_Ref_Number__c,
                opportunity.RecordTypeId
                from Quote
                where id = :c.getRecord().id
        ];
    }

    global PageReference generateQuote() {
        String quoteType = ApexPages.currentPage().getParameters().get('quoteType');
        String pageName = 'O2ProposalPDF';
        if (quoteType == 'Proposal') {
            pageName = 'O2ProposalPDF';
            if(q.Opportunity.RecordTypeId == UnifyConfiguration__c.getInstance('UnifyOpportunityRecordTypeId').Value__c){
                pageName = 'O2UnifyProposalPDF';
            }
        }
        if (quoteType == 'Contract') {
            // Validate Credit Ref has been completed
            if (q.opportunity.credit_ref_number__c != null )
                pageName = 'O2ContractPDF';
            else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please complete Credit Ref details for the Opportunity before creating the Contract'));
                //throw new ContractValidationException('Please complete Credit Ref details for the Opportunity before creating the Contract');
                return null;
            }
        }

        PageReference pdf = new PageReference('/apex/'+pageName+'?id='+q.id);
        pdf.getParameters().put('p','p');
        pdf.setRedirect(true);

        //Get locale time zone not GMT
        Datetime d = system.now();
        String strDatetime = d.format('yyyy-MM-dd HH:mm:ss');

        //If it's Unify, create Quote PDF
        Attachment a = null;
        if (!Test.isRunningTest()) {
            a = new Attachment(parentId = q.opportunity.id, name=q.opportunity.account.name+'_'+quoteType+'_FixedServices_'+strDatetime + '.pdf', body = pdf.getContent());
        } else {
            Blob myBlob = Blob.valueOf('c3VyZS4=');
            a = new Attachment(parentId = q.opportunity.id, name=q.opportunity.account.name+'_'+quoteType+'_FixedServices_'+strDatetime + '.pdf', body = myBlob);
        }
        if(q.Opportunity.RecordTypeId == UnifyConfiguration__c.getInstance('UnifyOpportunityRecordTypeId').Value__c){
            a.parentId = q.Id;
            a.Name = q.opportunity.account.name + '_Quote_' + q.quoteNumber + '_' + strDatetime + '.pdf';
        }
        insert a;
        

        //
        Opportunity opptoUpdate = [select Id, name, SyncedQuoteId from Opportunity where id =:q.opportunity.id];
        opptoUpdate.SyncedQuoteId = q.Id;
        update opptoUpdate;
        //
        PageReference p = new PageReference('/' + q.opportunity.id);
        p.setRedirect(true);

        if(q.Opportunity.RecordTypeId == UnifyConfiguration__c.getInstance('UnifyOpportunityRecordTypeId').Value__c){
            p = new PageReference('/' + q.id);
        }
        return p;
    }

}