public with sharing class AttachQuoteToOppController {
    Quote currentQuote;
    Opportunity currentOpp;
    //
    public AttachQuoteToOppController(ApexPages.StandardController c) {
        currentQuote = [select Id, OpportunityId from Quote where Id = :c.getRecord().id];
    }
    //
    public Boolean getQuoteAvailable() {
        try {
            QuoteDocument quoteDoc = [SELECT Document, Name FROM QuoteDocument where QuoteId = :currentQuote.Id order by CreatedDate DESC limit 1];
            return True;
        } catch(QueryException ex) {
            return false;
        }
    }
    //
    public PageReference AttachQuoteToOpp() {
        try {
            QuoteDocument quoteDoc = [SELECT Document, Name FROM QuoteDocument where QuoteId = :currentQuote.Id order by CreatedDate DESC limit 1];
        
            Attachment a = new Attachment(parentId = currentQuote.opportunityId, name=quoteDoc.Name, body = quoteDoc.Document);
            insert a;
        } catch(Exception ex) {
            
        }
        PageReference p = new PageReference('/' + currentQuote.opportunityId);
        p.setRedirect(true);

        return p;
    }
}