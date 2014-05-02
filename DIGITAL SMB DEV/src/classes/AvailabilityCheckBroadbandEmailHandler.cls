global class AvailabilityCheckBroadbandEmailHandler extends AvailabilityCheckEmailHandlerBase implements Messaging.InboundEmailHandler {    
        
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {    
        return handleInboundEmail(email, envelope, AvailabilityCheckUtils.TYPE_BROADBAND);
    }
    
    
    
}