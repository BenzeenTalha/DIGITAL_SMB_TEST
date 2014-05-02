public with sharing class SOASendMessage
{
	static final String ENDPOINT = SOA_Integration_Settings__c.getValues('Send_Message').Endpoint__c;
	static final String ENVELOPE_XML_SENDSMS = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sen="http://soa.o2.co.uk/sendmessagedata_1">';
	static final String ENV_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
	public static final String SEN_NS = 'http://soa.o2.co.uk/sendmessagedata_1';
	static final String COR_NS = 'http://soa.o2.co.uk/coredata_1';
	static final String DEFAULT_MT_PROFILE = 'o2/salesforce/juc';

	public class ResponseException extends Exception {}
	public class RequiredDataException extends Exception {}

	public class SOAFault
	{
		public String faultcode{ get; set; }
		public String faultstring { get; set; }
		public String info { get; set; }
		public String detail {get; set; }
		public Boolean detected { get; set; }

		public SOAFault(Dom.XMLNode bodyElem)
		{
			Dom.XMLNode faultElem = bodyElem.getChildElement('Fault', ENV_NS);
			if (faultElem == null)
			{
				faultcode = null;
				faultstring = null;
				detail = null;
				detected = false;
				info = '';
			}
			else
			{
				faultcode = getElemText(faultElem, null, 'faultcode');
				faultstring = getElemText(faultElem, null, 'faultstring');
				info = sTrim(faultstring) + ' (' + faultcode + ')';
						detail = sTrim(getElemText(faultElem, null, 'sendSMSFault'));
						detected = true;
			}
		}
	}

	//-----------------------------------------------------------------------------
	// throws ResponseException on SOAP fault
	//-----------------------------------------------------------------------------
	public static string sendSMS(String mtProfile, String msisdn, String message)
	{
		SOAServicesBase soaBase = new SOAServicesBase();
		msisdn = SOAUtils.cleanDirectoryNumber(msisdn);
		//
		// If no mtProfile use the default
		//
		if (mtProfile == null)
		{
			mtProfile = DEFAULT_MT_PROFILE;
		}
       
       // TTL updated from 3 to 604800 By UP. quite short and if a handset is off or otherwise out of reach for a minute or so, the message will still get expired and won’t be delivered. Most SMS are valid for 7 days, which is 604800 seconds
       
		String innerXML = '' +
					'<sen:sendSMS>' +
					'<sen:mtProfile>' + mtProfile + '</sen:mtProfile>' +
					'<sen:msisdnList>' +
					'<sen:msisdn>' + msisdn + '</sen:msisdn>' +
					'</sen:msisdnList>' +
					'<sen:message>' + message + '</sen:message>' +
					'<sen:messageType>TXT</sen:messageType>' +
					'<sen:ttl>604800</sen:ttl>' +
					'</sen:sendSMS>';
				String resXml = soaBase.sendRequest(ENDPOINT,ENVELOPE_XML_SENDSMS,innerXML);
				Dom.XMLNode sendSMSResponseElem = getMainDataElem(resXml);
				system.debug('response xml is :' + resXml);
				return resXml;
	}
	
	public static string bulkSendSMS(String mtProfile, List<String> msisdns, String message)
	{
		SOAServicesBase soaBase = new SOAServicesBase();
		//
		// If no mtProfile use the default
		//
		if (mtProfile == null)
		{
			mtProfile = DEFAULT_MT_PROFILE;
		}
       
       // TTL updated from 3 to 604800 By UP. quite short and if a handset is off or otherwise out of reach for a minute or so, the message will still get expired and won’t be delivered. Most SMS are valid for 7 days, which is 604800 seconds
       
		String innerXML = '' +
					'<sen:sendSMS>' +
					'<sen:mtProfile>' + mtProfile + '</sen:mtProfile>' +
					'<sen:msisdnList>';
		for (String msisdn:msisdns) {
			msisdn = SOAUtils.cleanDirectoryNumber(msisdn);
			innerXML += '<sen:msisdn>' + msisdn + '</sen:msisdn>';
		}
		innerXML += '</sen:msisdnList>' +
					'<sen:message>' + message + '</sen:message>' +
					'<sen:messageType>TXT</sen:messageType>' +
					'<sen:ttl>604800</sen:ttl>' +
					'</sen:sendSMS>';
				system.debug('bulkSendSMS, sending XML:' + innerXML);
				String resXml = soaBase.sendRequest(ENDPOINT,ENVELOPE_XML_SENDSMS,innerXML);
				Dom.XMLNode sendSMSResponseElem = getMainDataElem(resXml);
				system.debug('response xml is :' + resXml);
				return resXml;
	}
	
	

	//-----------------------------------------------------------------------------
	// Get main response element and SOAP fault check
	//-----------------------------------------------------------------------------
	public static Dom.XMLNode getMainDataElem(String xml)
	{
		Dom.XMLNode bodyElem = getBodyElem(xml);
		if (bodyElem == null)
		{
			throw new ResponseException('Failed to process response. Empty bodyElem!');
		}
		SOAFault fault = new SOAFault(bodyElem);
		if (fault.detected)
		{
			throw new ResponseException('Fault: '+ fault.info + ' xml: ' + fault.detail);
		}
		Dom.XMLNode sendSMSResponseElem = bodyElem.getChildElement('sendSMSResponse', SEN_NS);
		if (sendSMSResponseElem == null)
		{
			throw new ResponseException('Failed to process response. Empty sendSMSResponse!');
		}
		return sendSMSResponseElem;
	}

	//-----------------------------------------------------------------------------
	// String trim - returns blank if null
	//-----------------------------------------------------------------------------
	static String sTrim(String str)
	{
		if (str == null)
		{
			return '';
		}
		else
		{
			return str.trim();
		}
	}
	//-----------------------------------------------------------------------------
	// Get element text - return blank if null
	//-----------------------------------------------------------------------------
	static String getElemText(Dom.XMLNode node, String nameSapce, String tag)
	{
		Dom.XMLNode childNode = node.getChildElement(tag, nameSapce);
		if (childNode == null)
		{
			return '';
		}
		else
		{
			return childNode.getText();
		}
	}

	//-----------------------------------------------------------------------------
	// Get Body element from xml response - throws ResponseException if not found
	//-----------------------------------------------------------------------------
	static Dom.XMLNode getBodyElem(String xml)
	{
		if (String.isBlank(xml))
		{
		   throw new RequiredDataException('xml is required!');
		}
		Dom.Document doc = new Dom.Document();
		doc.load(xml);
		Dom.XMLNode rootElem = doc.getRootElement();
		if (rootElem == null)
		{
			throw new ResponseException('Failed to process response. Empty rootElem!');
		}
		Dom.XMLNode bodyElem = rootElem.getChildElement('Body', ENV_NS);
		return bodyElem;
	}
}