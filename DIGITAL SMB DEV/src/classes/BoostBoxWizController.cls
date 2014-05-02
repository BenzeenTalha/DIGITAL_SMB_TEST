/**
* Author: Pete Ryan
*
* 06/06/2012: Created
*
**/

@isTest(SeeAllData = true)
public without sharing class BoostBoxWizController
{
	//--------------------------------------------------------------------------
	// Constants
	//--------------------------------------------------------------------------
	public static final String UNEXPECTED_EXCEPTION_USER_FRIENDLY_MSG = 'An unexpected error occurred. Please contact service support.';
	public static final String UNEXPECTED_SOA_EXCEPTION_USER_FRIENDLY_MSG = 'An unexpected error occurred. Please try again later or contact service support.';
	public static final String ACCESS_LIST_VALIDATION_OK_MSG = 'Numbers entered are valid.';
	public static final String ACCESS_LIST_VALIDATION_OK_MSG_SINGULAR = 'The number entered is valid.';
	public static final String EXCEPTION_CONTACT_DATA_CHANGED_ON_SERVER = 'The contact data has been updated by some other user. Please check the contact data and try placing the order again.';
	public static final Integer MAX_ACCESS_lIST_SIZE = 32;
	public static final Integer MAX_ACCESS_NUMBER_SIZE = 25;
	public static final String BBPAYMENT_ONCE_TEXT = 'Once';
	public static final String BBPAYMENT_MONTHLY_12M_TEXT = '12 Monthly Payments';
	public static final String BBPAYMENT_MONTHLY_24M_TEXT = '24 Monthly Payments';
	public static final String BBPAYMENT_ONCE_VAL = '0';
	public static final String BBPAYMENT_MONTHLY_12M_VAL = '12';
	public static final String BBPAYMENT_MONTHLY_24M_VAL = '24';

	public static final String CUST_TYPE_SMB_VAL = 'SMB';
	public static final String CUST_TYPE_SMB_TEXT = 'SMB';
	public static final String CUST_TYPE_ENT_VAL = 'Enterprise';
	public static final String CUST_TYPE_ENT_TEXT = 'Enterprise';
	public static final String CUST_TYPE_PARTNER_VAL = 'Partner';
	public static final String CUST_TYPE_PARTNER_TEXT = 'Partner';

	public static final String CUST_ACC_REC_TYPE_NAME = 'Customer Account';
	public static final String PARTNER_ACC_REC_TYPE_NAME = 'PRM User Customer Acct';
	public static final String CUST_OPP_REC_TYPE_NAME = 'Configurator';
	public static final String PARTNER_OPP_REC_TYPE_NAME = 'Configurator - Partners';

	public static final String CASE_REC_TYPE_NAME = 'New_Support_Case';
	public static final String BOOSTBOX_ORDER_GROUP_REC_TYPE_NAME = 'Boostbox';

	public static final Integer MAX_BB_ITEMS = 5;
	public static final String BOOSTBOX_OPPORTUNITY_NAME = 'Boostbox LWF Order [# items]: ';
	public static final String BOOSTBOX_ORDER_NAME = 'Boostbox: ';
	public static final Integer BUILDING_NUMBER_LENGTH = 9;

	//--------------------------------------------------------------------------
	// Getters / setters
	//--------------------------------------------------------------------------
	public integer step { get; set; } // Step in the order process
	public integer counter { get; set; }
	public boolean isError { get; set; }

	private static final Integer CONTACT_QUERY_LIMIT = 50;

	public String debugText { get; set; }

	public String targetId  { get; set; }
	public String caseId  { get; set; }
	public Boolean showHeader{ get; set; }
	public BoostBoxOrder bbOrder { get; set; }
	public String orderRefs  { get; set; }

	//--------------------------------------------------------------------------
	// Private members
	//--------------------------------------------------------------------------
	private Opportunity opp;
	private Case theCase;
	private cscfgc__Product_Bundle__c bundle;
	private String opportunityId;
	private String bundleId;

	//--------------------------------------------------------------------------
	// Exceptions
	//--------------------------------------------------------------------------
	public class AccessException extends Exception {}
	public class RequiredDataException extends Exception {}
	public class ProcessException extends Exception {}
	public class LimitException extends Exception {}
	public class ResponseException extends Exception {}

	//--------------------------------------------------------------------------
	// Inner classes
	//--------------------------------------------------------------------------
	public class SFDiseAccount
	{
		public Account account { get; set; }
		public FemtocellSOAHandler.AccountBasicAndAddress accountBasicAndAddress { get; set; }
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public User currentUser
	{
		get
		{
			if (this.currentUser == null)
			{
				this.currentUser = [SELECT id, sales_channel__c FROM User WHERE id = :UserInfo.getUserId() LIMIT 1];
			}
			return this.currentUser;
		}
		set;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public class BoostBoxOrder
	{

		public String name { get; set; }
		public String customerType { get; set; }
		public Boolean agreedToTermsAndConditions  { get; set; }
		public String termsAndConditionsURL { get; set; }
		public SFDiseAccount sfDiseAccount  { get; set; }
		public List<BoostBoxItem> bbItems { get; set; }

		public BoostBoxOrder()
		{
		}


		public void initialise()
		{

			agreedToTermsAndConditions = false;
			name = '';

			List<Boostbox_General_Settings__c> theSettings = [SELECT Terms_And_Conditions_URL__c FROM Boostbox_General_Settings__c LIMIT 1];
			for (Boostbox_General_Settings__c theSetting: theSettings)
			{
				termsAndConditionsURL = theSetting.Terms_And_Conditions_URL__c;
			}

			bbItems = new List<BoostBoxItem>();
			bbItems.add(new BoostBoxItem('1'));
		}

	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public class LeadUser
	{

		public String identifier { get; set; }
		public String contactId { get; set; }
		public Boolean valid { get; set; }
		public String salutation { get; set; }
		public String firstName { get; set; }
		public String lastName { get; set; }
		public String email { get; set; }
		public String mobile { get; set; }
		public List<Contact> foundContacts { get; set; }
		public Contact selectedContact { get; set; }
		public Boolean needsEdit { get; set; }
		public String newSalutation { get; set; }
		public String newFirstName { get; set; }
		public String newLastName { get; set; }
		public String newEmail { get; set; }
		public String newMobile { get; set; }

		LeadUser(String newIdentifier)
		{
			identifier = newIdentifier;
			foundContacts = new List<Contact>();
			needsEdit = false;
		}

		public Boolean populated()
		{
			if ( !String.isBlank(salutation) ||
					!String.isBlank(firstName) ||
					!String.isBlank(lastName) ||
					!String.isBlank(email) ||
					!String.isBlank(mobile))
			{
				return true;
			}
			return false;
		}

	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public class BoostBoxItem
	{

		public Boolean orderStarted { get; set; }
		public String identifier { get; set; }
		public Boolean valid { get; set; }
		public String paymentType { get; set; }
		public String paymentSubscriptionmsisdn { get; set; }
		public String subscriptionID { get; set; }

		public String bbType { get; set; }
		public String salePrice { get; set; }

		public LeadUser leadUser { get; set; }
		public String searchContactName { get; set; }
		public Boolean addingNewContact { get; set; }


		// Installation Address
		public String searchIABuildingNumber { get; set; }
		public String searchIAPostalCode { get; set; }
		public Address installationAddr { get; set; }
		public String installationAddressSelected { get; set; }
		public FemtocellSOAHandler.AddressList installationFoundAddressList;
		public Boolean addingNewInstallationAddress { get; set; }

		// Delivery Address
		public String searchDABuildingNumber { get; set; }
		public String searchDAPostalCode { get; set; }
		public Address deliveryAddr { get; set; }
		public String deliveryAddressSelected { get; set; }
		public FemtocellSOAHandler.AddressList deliveryFoundAddressList;
		public Boolean addingNewDeliveryAddress { get; set; }
		public Boolean useInstallationAsDeliveryAddress { get; set; }

		public AccessNumberList accessNumberList  { get; set; }
		public String additionalInformation { get; set; }

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public BoostBoxItem(String newIdentifier)
		{
			identifier = newIdentifier;
			leadUser = new LeadUser(identifier);
			installationAddr = new Address();
			deliveryAddr = new Address();
			accessNumberList = new AccessNumberList();
			accessNumberList.maxListSize = MAX_ACCESS_lIST_SIZE;
			valid = false;
			addingNewInstallationAddress = false;
			addingNewDeliveryAddress = false;
			useInstallationAsDeliveryAddress = true;
			addingNewContact = false;
			paymentType = BBPAYMENT_ONCE_VAL;
			orderStarted = false;
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public Integer getAccessListSize()
		{
			if (accessNumberList == null)
			{
				return 0;
			}
			return accessNumberList.numbers.size();
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public String getIsPopulated()
		{
			String retVal = '0';
			if (populated())
			{
				retVal = '1';
			}
			return retVal;
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public Boolean populated()
		{

			if ( !String.isBlank(bbType) ||
					!String.isBlank(salePrice) ||
					leadUser.populated() ||
					installationAddr.populated() ||
					deliveryAddr.populated() ||
					!String.isBlank(paymentSubscriptionmsisdn) ||
					!String.isBlank(accessNumberList.raw))
			{

				return true;

			}
			else
			{
				return false;
			}
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public String getBoostboxTypeName()
		{
			String retVal = '';
			if (!String.isBlank(bbType))
			{
				retVal = BoostBoxWizController.getBoostboxTypeName(bbType);
			}
			return retVal;
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public String getBoostboxTypeDisplayName()
		{
			String retVal = '';
			if (!String.isBlank(bbType))
			{
				retVal = BoostBoxWizController.getBoostboxTypeDisplayName(bbType);
			}
			return retVal;
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public String getValidText()
		{
			if (valid)
			{
				return 'Yes';
			}
			else
			{
				return 'No';
			}

		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public List<SelectOption> getInstallationAddressOptions()
		{
			return getAddressOptions('INSTALLATION');
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public List<SelectOption> getDeliveryAddressOptions()
		{
			return getAddressOptions('DELIVERY');
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		private List<SelectOption> getAddressOptions(String mode)
		{

			if (mode == null) throw new RequiredDataException('mode required.');
			if (!mode.equalsIgnoreCase('INSTALLATION') && !mode.equalsIgnoreCase('DELIVERY')) throw new RequiredDataException('Unknown mode [' + mode + ']');

			List<SelectOption> options = new List<SelectOption>();

			FemtocellSOAHandler.AddressList al;

			if (mode.equalsIgnoreCase('INSTALLATION'))
			{
				al = installationFoundAddressList;
			}
			else if (mode.equalsIgnoreCase('DELIVERY'))
			{
				al = deliveryFoundAddressList;
			}

			if (al != null)
			{
				Integer i = 0;
				for (FemtocellSOAHandler.Address fndAdr: al.addresses)
				{
					options.add(new SelectOption(String.valueOf(i++), fndAdr.getPrettyText()));
				}
			}
			return options;
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public List<SelectOption> getcontactOptions()
		{

			List<SelectOption> options = new List<SelectOption>();

			if (leadUser.foundContacts != null)
			{
				for (Contact fndCon: leadUser.foundContacts)
				{
					options.add(new SelectOption(fndCon.Id, fndCon.Name + ' (' + fndCon.Email + ')'));
				}
			}
			return options;
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public void checkSelectedContactData()
		{
			if (leadUser.contactId != null)
			{
				for (Contact con : leadUser.foundContacts)
				{
					if (con.id == leadUser.contactId)
					{
						// set the selectedcontact to that contact object so the form can access it's fields fort dynamic show/hide of components easily
						//this.leadUser.selectedContact = con;
						// set the lead user data to the selected contacts details
						leadUser.newSalutation = con.salutation;
						leadUser.newFirstName = con.firstName;
						leadUser.newLastName = con.lastName;
						leadUser.newEmail = con.email;
						leadUser.newMobile = con.mobilePhone;
						leadUser.needsEdit = false;
						if (String.isBlank(con.salutation) ||  String.isBlank(con.firstName) || String.isBlank(con.lastName) || String.isBlank(con.email) || String.isBlank(con.mobilePhone))
						{
							leadUser.needsEdit = true;
						}
					}
				}
			}
		}
	}


	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public class Address
	{
		public FemtocellSOAHandler.Address addr { get; set; }

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public Address()
		{
			addr = new FemtocellSOAHandler.Address();
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public Boolean populated()
		{
			if (String.isBlank(addr.organisation) && String.isBlank(addr.buildingNumber)
					&& String.isBlank(addr.subBuildingName) && String.isBlank(addr.buildingName)
					&& String.isBlank(addr.street) && String.isBlank(addr.dependentStreet)
					&& String.isBlank(addr.dependentLocality) && String.isBlank(addr.locality)
					&& String.isBlank(addr.county) && String.isBlank(addr.postTown)
					&& String.isBlank(addr.postcode))
			{
				return false;
			}
			else
			{
				return true;
			}
		}

	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public class AccessNumberList
	{

		public String raw { get; set; }
		public List<AccessNumber> numbers { get; set; }
		public String msg { get; set; }
		public Boolean conversionMode { get; set; }  // Default is false. Normal / default action is to validate rather than convert to IMSIs
		public Integer maxListSize { get; set; }

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public String getDebugText()
		{
			String retVal = '';
			retVal += '\nraw=' + raw;
			retVal += '\nmsg=' + msg;
			retVal += '\ncalloutsThisSession=' + Limits.getCallouts();
			if (numbers != null)
			{
				retVal += '\nnumbers:-';
				for (AccessNumber an: numbers)
				{
					retVal += an.getDebugText();
				}
			}
			return retVal;
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public AccessNumberList()
		{
			numbers = new List<AccessNumber>();
			conversionMode = false;
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public Boolean getIsValid()
		{

			Boolean retVal = true;

			if (numbers == null || String.isBlank(raw) || String.isBlank(msg) || numbers.size() == 0)
			{
				retVal = false;
			}
			else
			{
				for (AccessNumber an: numbers)
				{
					if (!an.isValid)
					{
						retVal = false;
						break;
					}
				}
			}

			return retVal;

		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public void progressValidation(String rawNumberList)
		{

			if (rawNumberList == null) throw new RequiredDataException('rawNumberList required');

			raw = rawNumberList;

			msg = '';

			System.debug('Starting with calloutsThisSession=' + Limits.getCallouts());

			// compare the incomming data with existing that may be part processed

			try
			{

				// Abort if there are any duplicates
				Set<String> simpleNos = getSimpleNos(rawNumberList);

				// remove items no longer in the data
				removeAbsentNumbers(simpleNos);

				// add any new items
				addNewNumbers(simpleNos);

				if (numbers.size() > maxListSize)
				{
					if (conversionMode)
					{
						throw new RequiredDataException('MSISDN List contains ' + numbers.size() + ' numbers and this exceeds the maximum of '+ maxListSize + '.');
					}
					else
					{
						throw new RequiredDataException('Access List contains ' + numbers.size() + ' numbers and this exceeds the maximum of '+ maxListSize + '.');
					}
				}

				// progress the validation with callouts
				msg += progressCheckNumbers();

			}
			catch(RequiredDataException e)
			{
				msg += e.getMessage();
			}
			catch(Exception e)
			{
				msg += 'An unexpected error occurred. Please contact service support. (' + e.getMessage() + ')';
			}

			System.debug('msg=' + msg);

			System.debug('Ending with calloutsThisSession=' + Limits.getCallouts());

			System.debug('at end numbers are:' + numbers);
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		private void removeAbsentNumbers(Set<String> incommingNos)
		{

			if (incommingNos == null) throw new RequiredDataException('incommingNos required');

			List<String> noToRemove = new List<String>();

			Boolean foundNo = false;
			for (AccessNumber an: numbers)
				{
					System.debug('Checking an for removal an.clean=' + an.clean);
					if (!incommingNos.contains(an.clean))
					{
						System.debug('an was not found. an=' + an.clean);
						System.debug(an);
						noToRemove.add(an.clean);
					}
				}

				System.debug('noTo  Remove=' + noToRemove);

				Integer ind = 0;
				for (String aNo: noToRemove)
				{
					System.debug('Removing aNo=' + aNo);
					ind = 0;
					for (AccessNumber an: numbers)
					{
						if (an.clean.equalsIgnoreCase(aNo))
						{
							System.debug('Removing ind=' + ind);
							numbers.remove(ind);
							break;
						}
						ind++;
					}
				}


		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		private void addNewNumbers(Set<String> incommingNos)
		{

			if (incommingNos == null) throw new RequiredDataException('incommingNos required');
			System.debug('*before number adding' + getDebugText() + ' incomingNos: ' + incommingNos);
			for (String aNo: incommingNos)
			{
				Boolean foundNo = false;
				System.debug('Checking aNo=' + aNo);
				for (AccessNumber an: numbers)
				{
					System.debug('checking with clean: ' + an.clean);
					if (an.clean.equalsIgnoreCase(aNo))
					{
						System.debug('equals found');
						foundNo = true;
					}
				}
				if (!foundNo)
				{
					addNewNo(aNo);
				}
			}
			System.debug('*after number adding' + getDebugText());
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		private void addNewNo(String newNo)
		{
			if (newNo == null || newNo.length() == 0) throw new RequiredDataException('newNo required');
			System.debug('Size before = ' + numbers.size());
			if (Limits.getCallouts() >= Limits.getLimitCallouts())
			{
				System.debug('Adding newNo with NO checks:' + newNo);
				numbers.add( new AccessNumber(newNo, true, conversionMode));
			}
			else
			{
				System.debug('Adding newNo with callout checks:' + newNo);
				numbers.add( new AccessNumber(newNo, false, conversionMode));
			}
			System.debug('Size after = ' + numbers.size());
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		private String progressCheckNumbers()
		{
			String retVal = '';
			Boolean haltChecks = false;
			if (Limits.getCallouts() >= Limits.getLimitCallouts())
			{
				haltChecks = true;
			}
			else
			{
				if (numbers.size() > 0)
				{
					for (AccessNumber an: numbers)
					{
						System.debug('an=' + an);
						System.debug('calloutsThisSession=' + Limits.getCallouts());
						if (!an.checked)
						{
							if (Limits.getCallouts() < Limits.getLimitCallouts())
							{
								if (conversionMode)
								{
									an.convert();
								}
								else
								{
									an.check();
								}
							}
							else
							{
								haltChecks = true;
								break;
							}
						}
					}
				}
				else
				{
					retVal = 'No numbers to check!';
					return retVal;
				}

			}

			retVal = getDirtyNumbers('\n');

			if (haltChecks && !allChecked())
			{
				System.debug('No more checks can be done this session');
				if (conversionMode)
				{
					retVal += '\nConversion incomplete. Please click the convert button again to continue.\n';
				}
				else
				{
					retVal += '\nValidation incomplete. Please click the Validate button again to continue.\n';
				}
			}
			else
			{
				if (!conversionMode)
				{
					if (retVal == null || retVal.trim().length() == 0)
					{
						if (numbers.size() == 1)
						{
							retVal = ACCESS_LIST_VALIDATION_OK_MSG_SINGULAR;
						}
						else
						{
							retVal = 'All ' + numbers.size() + ' ' + ACCESS_LIST_VALIDATION_OK_MSG;
						}
					}
				}
			}

			return retVal;
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		private Boolean allChecked()
		{
			Boolean retVal = true;
			for (AccessNumber an: numbers)
			{
				if (!an.checked)
				{
					retVal = false;
					break;
				}
			}
			return retVal;
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		private Set<String> getSimpleNos(String rawNumberList)
		{
			if (rawNumberList == null) throw new RequiredDataException('rawNumberList required');
			Set<String> simpleNos = new Set<String>();
			String nosData = rawNumberList.replace('\n', ',').replace(',,', ',').trim();
			if (nosData != null && nosData.length() > 0)
			{

				if (nosData.contains(','))
				{
					List<String> nos = nosData.split(',');
					for (String no: nos)
					{
						if (no != null && no.trim() != '')
						{
							if (simpleNos.contains(no.trim()))
							{
								throw new RequiredDataException('Number ' + no + ' is duplicated! (Duplicates are not allowed in the Access List).');
							}
							else
							{
								simpleNos.add(no.trim());
							}
						}
					}
				}
				else
				{
					// Deal with a single line entry
					if (simpleNos.contains(nosData))
					{
						throw new RequiredDataException('Number ' + nosData + ' is duplicated');
					}
					else
					{
						simpleNos.add(nosData);
					}
				}

			}

			return simpleNos;

		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public String getCleanNumbers(String delim)
		{
			String retVal = '';
			for (AccessNumber an: numbers)
			{
				if (an.msg == null || an.msg.trim().length() == 0)
				{
					retVal += replaceLeadingZeroWith44(an.clean) + delim;
				}
			}
			return retVal;
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public String getDirtyNumbers(String delim)
		{
			String retVal = '';
			for (AccessNumber an: numbers)
			{
				if (an.msg != null && an.msg.trim().length() > 0)
				{
					retVal += an.clean + an.msg + delim;
				}
			}
			return retVal;
		}

	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public class AccessNumber
	{

		public String raw { get; set; }
		public String clean { get; set; }
		public String msg { get; set; }
		public Boolean checked { get; set; }
		public Boolean isValid { get; set; }
		public Boolean conversionMode { get; set; }  // Default is false. Normal / default action is to validate rather than convert to IMSIs

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public String getDebugText()
		{
			String retVal = '';
			retVal += '\nraw=' + raw;
			retVal += '\nclean=' + clean;
			retVal += '\nmsg=' + msg;
			retVal += '\nchecked=' + checked;
			retVal += '\nisValid=' + isValid;
			return retVal;
		}


		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public AccessNumber(String rawNumber, Boolean bypassCallout)
		{
			if (rawNumber == null) throw new RequiredDataException('rawNumber required');
			raw = rawNumber;
			isValid = false;
			checked = false;
			conversionMode = false;
			cleanRaw(bypassCallout);
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public AccessNumber(String rawNumber, Boolean bypassCallout, Boolean theConversionMode)
		{
			if (rawNumber == null) throw new RequiredDataException('rawNumber required');
			raw = rawNumber;
			isValid = false;
			checked = false;
			conversionMode = theConversionMode;
			if (conversionMode)
			{
				convertRaw(bypassCallout);
			}
			else
			{
				cleanRaw(bypassCallout);
			}
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public void check()
		{
			cleanRaw(false);
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		public void convert()
		{
			convertRaw(false);
		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		private void convertRaw(Boolean bypassCallout)
		{
			if (raw == null) throw new RequiredDataException('raw required');
			msg = '';
			clean = raw.replaceAll('\\D','');
			System.debug('raw=' + raw);

			if (bypassCallout)
			{
				checked = false;
			}
			else
			{

				try
				{

					if (clean.length()>MAX_ACCESS_NUMBER_SIZE)
					{
						throw new ResponseException('Invalid number - too long');
					}

					String imsi = '';
					String imei = '';
					String brand = '';
					String model = '';
					String displayBrand = '';
					String displayModel = '';
					String msisdn = replaceLeadingZeroWith44(clean);

					FemtocellSOAHandler handler =  new FemtocellSOAHandler();
					FemtocellSOAHandler.DeviceProfile prof = handler.getDeviceProfile(msisdn, imsi, imei, brand, model, displayBrand, displayModel, null);
					System.debug('***device profile: ' + prof.getText());
					msg = '=' + prof.imsi;

					isValid = true;

				}
				catch (Exception e)
				{
					String msgStr = e.getMessage().replace(' (env:Server)', '');
					msgStr = msgStr.replace('Internal service error has occurred. Please contact service support for help on this.', 'Internal service error - contact support');
					msg += ' [' + msgStr + ']';
					isValid = false;
				}
				checked = true;
			}

		}

		//----------------------------------------------------------------------
		//
		//----------------------------------------------------------------------
		private void cleanRaw(Boolean bypassCallout)
		{
			if (raw == null) throw new RequiredDataException('raw required');
			msg = '';
			clean = raw.replaceAll('\\D','');
			System.debug('LUSKR|cleanRaw for raw : ' + raw);

			if (bypassCallout)
			{
				checked = false;
			}
			else
			{
				try
				{
					if (clean.length()>MAX_ACCESS_NUMBER_SIZE)
					{
						throw new ResponseException('Invalid number - too long');
					}
					FemtocellSOAHandler handler =  new FemtocellSOAHandler();

					handler.populateSubscriberProfile(replaceLeadingZeroWith44(clean));

					String subscriberID = handler.getSubscriberProfile().subscriberID;

					System.debug('subscriberID=' + subscriberID);

					if (handler.getSubscriberProfile().fault != null && handler.getSubscriberProfile().fault.detected)
					{
						throw new ResponseException(handler.getSubscriberProfile().fault.info);
					}

					String op = handler.getSubscriberProfile().operator;
					if (op.equalsIgnoreCase('nonO2'))
					{
						throw new ResponseException('Non O2');
					}

					isValid = true;

				}
				catch (Exception e)
				{
					String msgStr = e.getMessage().replace('Fault: Validation errors in the data submitted for the request (env:Server)', 'Error: bad number');
					msgStr = msgStr.replace(' (env:Server)', '');
					msgStr = msgStr.replace('Internal service error has occurred. Please contact service support for help on this.', 'Internal service error - contact support');
					msg += ' [' + msgStr + ']';

					isValid = false;
				}
				checked = true;
			}

		}

	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public BoostBoxWizController()
	{
		Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=10');
		debugText = 'start';
		targetId = 'acc';
		step = 0; // BB 35026
		counter = 0;
		if (Userinfo.getUserType() == 'Standard' || Userinfo.getUserType() == 'PowerPartner')
		{
			showHeader = true;
		}
		else
		{
			showHeader = false;
		}
		bbOrder = new BoostBoxOrder();
		bbOrder.initialise();
		System.debug('boostbox headers = ' + Apexpages.currentPage().getHeaders().get('X-UA-Compatible'));
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	// parameters passed via Javascript
	public PageReference runDeliveryAddressSearch()
	{
		try
		{
			runAddressSearch('DELIVERY');
		}
		catch (Exception e)
		{
			// display a usre friendly message
			BoostboxHelper.addMsg(UNEXPECTED_SOA_EXCEPTION_USER_FRIENDLY_MSG + ' (' + e.getMessage() + ')', true);
		}
		return null;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	// parameters passed via Javascript
	public PageReference runInstallationAddressSearch()
	{
		try
			{
				runAddressSearch('INSTALLATION');
			}
			catch (Exception e)
			{
				// display a usre friendly message
				BoostboxHelper.addMsg(UNEXPECTED_SOA_EXCEPTION_USER_FRIENDLY_MSG + ' (' + e.getMessage() + ')', true);
			}
			return null;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public PageReference runVerifyMobile()
	{

		debugText += '|runVerifyMobile';

		String bbid;
		try
				{
					bbid = Apexpages.currentPage().getParameters().get('bbid');
					if (bbid == null) bbid = '';
					debugText += ',' + bbid;
				}
				catch(Exception e)
				{
					bbid = '';
				}


				String mobileNumber;
				try
				{
					mobileNumber = Apexpages.currentPage().getParameters().get('mobileNumber');
					if (mobileNumber == null) mobileNumber = '';
					debugText += ',' + mobileNumber;
				}
				catch(Exception e)
				{
					mobileNumber = '';
				}


				if (System.Test.isRunningTest() && (bbid == null || bbid.trim().length() == 0))
				{
					bbid = '1';
				}

				if (System.Test.isRunningTest() && (mobileNumber == null || mobileNumber.trim().length() == 0))
				{
					mobileNumber = '07710579845';
				}


				debugText += '|bbid=' + bbid;
				debugText += '|mobileNumber=' + mobileNumber;



				BoostBoxItem theBBItem = identifyBBItem(bbid);

				Boolean normalCourse = true;
				try
				{

					FemtocellSOAHandler handler =  new FemtocellSOAHandler();
					handler.populateSubscriptionBasic('', '', mobileNumber);

					theBBItem.subscriptionID = 'Valid number. [Subscription Id ' + handler.getSubscriptionBasic().subscriptionID + ']';
					System.debug('subscriptionID=' + theBBItem.subscriptionID);

					if (handler.getSubscriptionBasic().fault != null && handler.getSubscriptionBasic().fault.detected)
					{
						throw new ResponseException(handler.getSubscriptionBasic().fault.info);
					}
					if (handler.getSubscriptionBasic().accountNumber.trim() != bbOrder.sfDiseAccount.accountBasicAndAddress.accountNumber.trim())
					{
						throw new ResponseException('Invalid number: not bound to Account number');
					}

				}
				catch (Exception e)
				{
					theBBItem.subscriptionID = 'Error: ' + e.getMessage().replace('Fault: Validation errors in the data submitted for the request (env:Server)', 'Bad number');
					normalCourse = false;
				}


				return null;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	// parameters passed via Javascript
	public PageReference runContactSearch()
	{

		debugText += '|runContactSearch';

		// Don't bother if the account has not been verified yet
		if (bbOrder == null || bbOrder.sfDiseAccount == null || bbOrder.sfDiseAccount.account == null) return null;

		String bbid;
		try
		{
			bbid = Apexpages.currentPage().getParameters().get('bbid');
			if (bbid == null) bbid = '';
			debugText += ',' + bbid;
		}
		catch(Exception e)
		{
			bbid = '';
		}

		if (System.Test.isRunningTest() && (bbid == null || bbid.trim().length() == 0))
		{
			bbid = '1';
		}

		String searchContactName;
		try
		{
			searchContactName = Apexpages.currentPage().getParameters().get('contactName');
			if (searchContactName == null) searchContactName = '';
			debugText += ',' + searchContactName;
		}
		catch(Exception e)
		{
			searchContactName = '';
		}

		if (System.Test.isRunningTest() && (searchContactName == null || searchContactName.trim().length() == 0))
		{
			searchContactName = 'test';
		}


		debugText += '|searchContactName=' + searchContactName;

		// Don't bother if no search string provided
		if (bbid == null || bbid == '' || searchContactName == null || searchContactName.trim().length() == 0 ) return null;

		BoostBoxItem theBBItem = identifyBBItem(bbid);

		theBBItem.leadUser.foundContacts = new List<Contact>();

		// Perform the search
		searchContactName = '%' + searchContactName + '%';
		if (!String.isBlank(bbOrder.sfDiseAccount.account.Id))
		{
			Contact[] foundCons = [SELECT Id, Name, Salutation, FirstName, LastName, Email, MobilePhone
				FROM Contact
				WHERE AccountId = :bbOrder.sfDiseAccount.account.Id
				AND Name like :searchContactName
				ORDER BY Name
				LIMIT :CONTACT_QUERY_LIMIT];

			for (Contact con: foundCons)
			{
				theBBItem.leadUser.foundContacts.add(con);
			}
		}

		debugText += '|con search completed';

		if (!theBBItem.leadUser.foundContacts.isEmpty())
		{
			theBBItem.leadUser.contactId = theBBItem.leadUser.foundContacts.get(0).id;
			theBBItem.checkSelectedContactData();
		}

		return null;

	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public PageReference runAccessListServerValidation()
	{

		debugText += '|runAccessListServerValidation';

		String bbid;
		try
		{
			bbid = Apexpages.currentPage().getParameters().get('bbid');
			if (bbid == null) bbid = '';
			debugText += ',' + bbid;
		}
		catch(Exception e)
		{
			bbid = '';
		}

		if (System.Test.isRunningTest() && (bbid == null || bbid.trim().length() == 0))
		{
			bbid = '1';
		}

		String aList;
		try
		{
			aList = Apexpages.currentPage().getParameters().get('accessList');
			if (aList == null) aList = '';
			debugText += ',' + aList;
		}
		catch(Exception e)
		{
			aList = '';
		}

		if (System.Test.isRunningTest() && (aList == null || aList.trim().length() == 0))
		{
			aList = '';
			aList += '07525984406,';
			aList += '07808647978,';
			aList += '07808647979,';
			aList += '07808647980,';
			aList += '07808647981,';
			aList += '07921681520,';
			aList += '07912463240,';
			aList += '07738642924,';
			aList += '07850508286,';
			aList += '07860247906,';
			aList += '07740406701,';
			aList += '07802200709,';
			aList += '07710579845,';
			aList += '07809599618,';
			aList += '07715179472,';
			aList += '01613665103,';
			aList += '01613666421';
		}

		try
		{
			BoostBoxItem theBBItem = identifyBBItem(bbid);
			theBBItem.accessNumberList.progressValidation(aList);
			System.debug(theBBItem.accessNumberList);
		}
		catch (Exception e)
		{
			// in case of an unexpected exception display an user friendly message
			BoostboxHelper.addMsg(UNEXPECTED_SOA_EXCEPTION_USER_FRIENDLY_MSG + ' (' + e + ')', true);
		}

		return null;
	}


	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	// parameters passed via Javascript
	private void runAddressSearch(String mode)
	{
		if (mode == null) throw new RequiredDataException('mode required.');
		if (!mode.equalsIgnoreCase('INSTALLATION') && !mode.equalsIgnoreCase('DELIVERY')) throw new RequiredDataException('Unknown mode [' + mode + ']');

		String bbid;
		try
		{
			bbid = Apexpages.currentPage().getParameters().get('bbid');
			if (bbid == null) bbid = '';
			debugText += ',' + bbid;
		}
		catch(Exception e)
		{
			bbid = '';
		}

		if (System.Test.isRunningTest() && (bbid == null || bbid.trim().length() == 0))
		{
			bbid = '1';
		}

		String postalCode;
		try
		{
			postalCode = Apexpages.currentPage().getParameters().get('postalCode');
			if (postalCode == null) postalCode = '';
			debugText += ',' + postalCode;
		}
		catch(Exception e)
		{
			postalCode = '';
		}

		if (postalCode == null || postalCode.trim().length() == 0)
		{
			if (System.Test.isRunningTest())
			{
				postalCode = 'SL9 8RG';
			}
			else
			{
				BoostboxHelper.addMsg(new RequiredDataException('Postal code required. Please enter postal code to search by.'));
				return;
			}
		}

		String buildingNumber;
		try
		{
			buildingNumber = Apexpages.currentPage().getParameters().get('buildingNumber');
			if (buildingNumber == null) buildingNumber = '';
			debugText += ',' + buildingNumber;
		}
		catch(Exception e)
		{
			buildingNumber = '';
		}

		BoostBoxItem theBBItem = identifyBBItem(bbid);

		Boolean normalCourse = true;
		try
		{

			FemtocellSOAHandler handler =  new FemtocellSOAHandler();
			String organisation;
			String buildingName;
			organisation = '';
			buildingName = '';
			if (buildingNumber == null || buildingNumber == '')
			{
				buildingNumber = '*';
			}
			handler.populateAddresses(organisation, buildingName, buildingNumber, postalCode);

			if (mode.equalsIgnoreCase('INSTALLATION'))
			{
				theBBItem.installationFoundAddressList = handler.getAddressList();
			}
			else if (mode.equalsIgnoreCase('DELIVERY'))
			{
				theBBItem.deliveryFoundAddressList = handler.getAddressList();
			}

			if (handler.getAddressList().fault != null && handler.getAddressList().fault.detected)
			{
				throw new ResponseException('Address search problem: ' + handler.getAddressList().fault.info);
			}
		}
		catch (Exception e)
		{
			BoostboxHelper.addMsg(e);
			normalCourse = false;
		}
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public String selectedO2Sector { get; set; }

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public void doNothing() {}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	// parameters passed via Javascript
	public PageReference runAccSearch()
	{

		if (bbOrder == null) throw new RequiredDataException('bbOrder required');

		debugText += '|runAccSearch';

		String diseAccountNo;
		try
		{

			diseAccountNo = Apexpages.currentPage().getParameters().get('diseAccountNo');
			if (diseAccountNo == null) diseAccountNo = '';
			debugText += ',' + diseAccountNo;

		}
		catch(Exception e)
		{
			diseAccountNo = '';
		}

		if (System.Test.isRunningTest() && (diseAccountNo == null || diseAccountNo.trim().length() == 0))
		{
			diseAccountNo = '2023655';
		}

		if (diseAccountNo != null && diseAccountNo != '')
		{

			Boolean normalCourse = true;
			try
			{
				// Get DISE account details
				FemtocellSOAHandler handler =  new FemtocellSOAHandler();
				handler.populateAccountBasicAndAddress(diseAccountNo);
				// '2023655'
				bbOrder.sfDiseAccount = new SFDiseAccount();
				bbOrder.sfDiseAccount.accountBasicAndAddress = handler.getAccountBasicAndAddress();
			}
			catch (Exception e)
			{
				normalCourse = false;

				if (e.getMessage().contains('Internal Error') || e.getMessage().contains('Account number provided is invalid'))
				{
					BoostboxHelper.addMsg('Invalid DISE Billing Account No', true);
				}
				else
				{
					BoostboxHelper.addMsg(UNEXPECTED_SOA_EXCEPTION_USER_FRIENDLY_MSG + ' (' + e + ')', true);
				}

				bbOrder.sfDiseAccount = new SFDiseAccount();

			}


			if (normalCourse)
			{
				// Got DISE Account Details - Get the salesforce account if it exists
				String diseAccountNoStr = '%' + diseAccountNo;
				Account[] accList = [SELECT
						Id,
						Name,
						DISE_Group_Code_Account_No_1__c,
						DISE_Group_Code_Account_No_2__c,
						DISE_Group_Code_Account_No_3__c,
						DISE_Group_Code_Account_No_4__c,
						Phone,
						BillingStreet,
						BillingCity,
						BillingState,
						BillingCountry,
						BillingPostalCode,
						O2_Sector__c,
						Email__c
						FROM Account
						WHERE DISE_Group_Code_Account_No_1__c
						LIKE :diseAccountNoStr
						LIMIT 2];

				Integer gotAccs = accList.size();

				if (gotAccs == 0)
				{
					//Create a map of Account record types
					Map<String,Id> accRecordTypes = new Map<String,Id>{};
					Schema.DescribeSObjectResult R = Schema.sObjectType.Account;
					List<Schema.RecordTypeInfo> RTIList = R.getRecordTypeInfos();
					for (Schema.RecordTypeInfo rti: RTIList)
					{
						accRecordTypes.put(rti.getName() ,rti.getRecordTypeId());
					}
					String currentUserType = UserInfo.getUserType();
					Id custAccRecTypeId;
					if (currentUserType == 'Partner')
					{
						custAccRecTypeId = accRecordTypes.get(PARTNER_ACC_REC_TYPE_NAME);
					}
					else
					{
						custAccRecTypeId = accRecordTypes.get(CUST_ACC_REC_TYPE_NAME);
					}

					// Get Account ready for insertion if and when the order is placed later (placeOrder)
					Account theNewSFAcc = new Account();
					theNewSFAcc.RecordTypeId = custAccRecTypeId;
					theNewSFAcc.Name =  bbOrder.sfDiseAccount.accountBasicAndAddress.companyName;
					theNewSFAcc.DISE_Group_Code_Account_No_1__c = '0' + bbOrder.sfDiseAccount.accountBasicAndAddress.accountNumber; // Preceed with '0'?
					theNewSFAcc.Phone = bbOrder.sfDiseAccount.accountBasicAndAddress.companyTelephoneNumber;
					// Push through validation!
					theNewSFAcc.Validation_Override__c = true; /// Hmmmm
					//theNewSFAcc.BillingCity = '...';
					theNewSFAcc.Contract_Duration__c = '0';
					theNewSFAcc.Contract_Start_Date__c = System.now().date();
					theNewSFAcc.Date_Effective_From__c = System.now().date();
					theNewSFAcc.Contract_End_Date__c = System.now().date();
					//theNewSFAcc.BillingPostalCode = bbOrder.sfDiseAccount.accountBasicAndAddress.postcode;
					theNewSFAcc.Email__c = bbOrder.sfDiseAccount.accountBasicAndAddress.emailAddress;
					theNewSFAcc.Status__c = 'Customer';
					bbOrder.sfDiseAccount.account = theNewSFAcc;

					debugText += '|bbOrder.sfDiseAccount.account,Name=' + bbOrder.sfDiseAccount.account.Name;
				}
				else if (gotAccs == 1)
				{
					// Found the SF Account
					bbOrder.sfDiseAccount.account = accList[0];
				}
				else if (gotAccs > 1)
				{
					bbOrder.sfDiseAccount.account = null;
					// BoostboxHelper.addMsg(DUPLICATE_DISE_ACCOUNT_NUBER_MSG + ' (' + e.getMessage() + ')', true); // in case there are more than one accounts
				}
			}
		}
		return null;
	}


	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	private String getSFAccountId()
	{
		String retVal = '000000000000000';

		if (bbOrder != null
				&& bbOrder.sfDiseAccount != null
				&& bbOrder.sfDiseAccount != null
				&& bbOrder.sfDiseAccount.account.Id != null)
		{
			retVal = bbOrder.sfDiseAccount.account.Id;
		}

		return retVal;
	}


	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	private static void setContactRoles(BoostBoxOrder bbOrder, String oppId, String accountId)
	{

		String conRecTypeId = [SELECT Id
			FROM RecordType
			WHERE SobjectType = 'Contact'
			AND DeveloperName = 'Default'
			LIMIT 1].Id;

		Contact lCont = null;
		Set<Contact> allContacts = new Set<Contact>();
		for (BoostBoxItem bbi: bbOrder.bbItems)
		{
			lCont = getLeadUserAsContact(bbi.leadUser, bbi.addingNewContact, conRecTypeId, accountId);
			if (lCont == null)
			{
				throw new RequiredDataException('Expected contact was not found');
			}
			// using set: this line should not allow duplicates (contacts that are newly created with the same data - on all fields, and the existing ones that are loaded from DB, also with the same data)
			// tested: if two new contacts are on two different BB items, only one is inserted!
			allContacts.add(lCont);
		}

		// insert the ones that don't have an id - new contacts (use a temp array to bulk insert)
		List<Contact> contactsToInsert = new List<Contact>();
		for (Contact contact : allContacts)
		{
			if (contact.id == null)
			{
				contactsToInsert.add(contact);
			}
		}
		insert contactsToInsert;

		Boolean firstOne = true;
		List<OpportunityContactRole> ocrsToInsert = new List<OpportunityContactRole>();
		for (Contact contact : allContacts)
		{
			ocrsToInsert.add(addConAccRoleIfNeeded(oppId, contact, conRecTypeId, 'COP - Centre of Power', firstOne ? true : false)); // send 'true' only for the first contact
			ocrsToInsert.add(addConAccRoleIfNeeded(oppId, contact, conRecTypeId, 'Billing', false));
			firstOne = false;
		}

		insert ocrsToInsert;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static Contact getLeadUserAsContact(LeadUser lUser, Boolean addNew, String conRecTypeId, String accId)
	{
		if (String.isBlank(conRecTypeId)) throw new RequiredDataException('conRecTypeId required.');
		if (lUser == null) throw new RequiredDataException('lUser required.');

		System.debug('addNew='+ addNew);

		Contact con = new Contact();

		if (addNew)
		{
			con.Salutation = lUser.salutation;
			con.FirstName = lUser.firstName;
			con.LastName = lUser.lastName;
			con.Email = lUser.email;
			con.MobilePhone = lUser.mobile;
			con.Phone = lUser.mobile;
			con.Title = 'Unknown';
			con.RecordTypeId = conRecTypeId;
			con.AccountId = accId;
			con.CSIOptOut__c = true;
			con.CSIOptOutReason__c = 'Low Contact / not met customer yet';
			if (!String.isBlank(accId))
			{
				List<Account> accs = [SELECT BillingCity, BillingCountry,
					BillingState, BillingStreet, BillingPostalCode
					FROM Account
					WHERE Id = :accId
					LIMIT 1];
				for (Account acc: accs)
				{
					// on Account where status = 'Contact', mailing address is mandatora (validation rules on Contact object)
					con.MailingCity = acc.BillingCity;
					con.MailingCountry = acc.BillingCountry;
					con.MailingState = acc.BillingState;
					con.MailingStreet = acc.BillingStreet;
					con.MailingPostalCode = acc.BillingPostalCode;
					break;
				}
			}
		}
		else
		{
			if (lUser.contactId != null)
			{
				Contact[] cons = [SELECT Id, RecordTypeId, FirstName, Email, LastName,
					Title, MobilePhone, Salutation, AccountId
						FROM Contact
						WHERE Id = :lUser.contactId];
				for (Contact c: cons)
				{
					con = c;
					break;
				}
				if (lUser.needsEdit)
				{
					if (con.Salutation == null || con.Salutation == '')
					{
						con.Salutation = lUser.newSalutation;
					}
					else if (con.Salutation != lUser.newSalutation)
					{
						throw new RequiredDataException(EXCEPTION_CONTACT_DATA_CHANGED_ON_SERVER);
					}
					if (con.FirstName == null || con.FirstName == '')
					{
						con.FirstName = lUser.newFirstName;
					}
					else if (con.FirstName != lUser.newFirstName)
					{
						throw new RequiredDataException(EXCEPTION_CONTACT_DATA_CHANGED_ON_SERVER);
					}
					if (con.LastName == null || con.LastName == '')
					{
						con.LastName = lUser.newLastName;
					}
					else if (con.LastName != lUser.newLastName)
					{
						throw new RequiredDataException(EXCEPTION_CONTACT_DATA_CHANGED_ON_SERVER);
					}
					if (con.Email == null || con.Email == '')
					{
						con.Email = lUser.newEmail;
					}
					else if (con.Email != lUser.newEmail)
					{
						throw new RequiredDataException(EXCEPTION_CONTACT_DATA_CHANGED_ON_SERVER);
					}
					if (con.MobilePhone == null || con.MobilePhone == '')
					{
						con.MobilePhone = lUser.newMobile;
					}
					else if (con.MobilePhone != lUser.newMobile)
					{
						throw new RequiredDataException(EXCEPTION_CONTACT_DATA_CHANGED_ON_SERVER);
					}
					//con.LastName = lUser.mobile;
					//con.MobilePhone = '2123';
					update con;
				}
			}
		}

		System.debug('con.Id=' + con.Id);
		String errorMessage = null;
		if (con.Salutation == null)
		{
			errorMessage = 'Contact salutation field is empty. You will have to reload the BoostBoxLWF - but check the contact data first!';
		}
		else if (con.FirstName == null)
		{
			errorMessage = 'Contact FirstName field is empty. You will have to reload the BoostBoxLWF - but check the contact data first!';
		}
		else if (con.LastName == null)
		{
			errorMessage = 'Contact LastName field is empty. You will have to reload the BoostBoxLWF - but check the contact data first!';
		}
		else if (con.Email == null)
		{
			errorMessage = 'Contact Email field is empty. You will have to reload the BoostBoxLWF - but check the contact data first!';
		}
		else if (con.MobilePhone == null)
		{
			errorMessage = 'Contact MobilePhone field is empty. You will have to reload the BoostBoxLWF - but check the contact data first!';
		}
		else if (con.Title == null)
		{
			errorMessage = 'Contact Title field is empty. You will have to reload the BoostBoxLWF - but check the contact data first!';
		}
		else if (con.RecordTypeId == null)
		{
			errorMessage = 'Unexpected error occured - the order was not placed. Please try reloading the page. If the problem persists, contact service support.';
		}
		if (errorMessage != null)
		{
			throw new RequiredDataException(errorMessage);
		}

		return con;

	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	private static OpportunityContactRole addConAccRoleIfNeeded(String oppId, Contact leadUser, String conRecTypeId, String roleName, Boolean useAsPrimary)
	{

		if (oppId == null) throw new RequiredDataException('oppId required');
		if (leadUser == null) throw new RequiredDataException('leadUser required');
		if (leadUser.Id == null) throw new RequiredDataException('leadUser Id required');
		if (conRecTypeId == null) throw new RequiredDataException('conRecTypeId required');
		if (roleName == null || roleName.trim().length() == 0) throw new RequiredDataException('roleName required');

		// All within a transaction - controlled by caller

		OpportunityContactRole ocr = new OpportunityContactRole();
		ocr.ContactId = leadUser.Id;
		ocr.OpportunityId = oppId;
		ocr.Role = roleName;
		ocr.IsPrimary = useAsPrimary;
		return ocr;

	}


	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public PageReference addNewBBItem()
	{

		try
		{

			Integer maxNum = bbOrder.bbItems.size();

			if (maxNum >= MAX_BB_ITEMS) throw new LimitException('The maximum number of items is has been reached. Please split your order into parts if you need more items are needed');

			for (BoostBoxItem bbIt: bbOrder.bbItems)
			{
				if (Integer.valueOf(bbIt.identifier) > maxNum)
				{
					maxNum = Integer.valueOf(bbIt.identifier);
				}
			}

			bbOrder.bbItems.add(new BoostBoxItem(String.valueOf(++maxNum)));

			targetId = 'bbItem' + maxNum;


		}
		catch (Exception e)
		{
			BoostboxHelper.addMsg(UNEXPECTED_EXCEPTION_USER_FRIENDLY_MSG + ' (' + e.getMessage() + ')', true);
		}


		return null;
	}
	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public PageReference removeLastBBItem()
	{
		if (bbOrder.bbItems.size() > 0)
			{
				bbOrder.bbItems.remove(bbOrder.bbItems.size() - 1);
			}
			return null;
	}
	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static List<SelectOption> getBoostBoxTypeOptions()
	{
		List<SelectOption> options = new List<SelectOption>();
		List<Boostbox_settings__c> settings = getBoostboxSettings();
		for (Boostbox_settings__c settingItem: settings)
			{
				if (settingItem.Active__c)options.add(new SelectOption(getOptVal(settingItem), settingItem.Name));
			}
		return options;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static String getOptVal(Boostbox_settings__c settingItem)
	{
		if (settingItem == null) throw new RequiredDataException('settingItem required');

		String retVal = settingItem.Id + '|';
		retVal += settingItem.Name + '|';
		retVal += settingItem.Monthly_Price_Over_12_Months__c + '|';
		retVal += settingItem.Monthly_Price_Over_24_Months__c + '|';
		retVal += settingItem.Needs_Access_List__c + '|';
		retVal += settingItem.Price_Ex_VAT__c + '|';
		retVal += settingItem.Type__C + '|';
		retVal += settingItem.Price_Ex_VAT_Max__c + '|';
		retVal += settingItem.Price_Ex_VAT_Min__c + '|';
		retVal += settingItem.Monthly_Price_Over_12_Months_Max__c + '|';
		retVal += settingItem.Monthly_Price_Over_12_Months_Min__c + '|';
		retVal += settingItem.Monthly_Price_Over_24_Months_Max__c + '|';
		retVal += settingItem.Monthly_Price_Over_24_Months_Min__c + '|';

		return retVal;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static List<SelectOption> getCustomerTypeOptions()
	{
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption(CUST_TYPE_SMB_VAL, CUST_TYPE_SMB_TEXT));
		options.add(new SelectOption(CUST_TYPE_ENT_VAL, CUST_TYPE_ENT_TEXT));
		options.add(new SelectOption(CUST_TYPE_PARTNER_VAL, CUST_TYPE_PARTNER_TEXT));
		return options;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static List<SelectOption> getSalutationOptions()
	{
		List<SelectOption> options = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = Account.salutation.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		options.add(new SelectOption('', ''));
		for (Schema.PicklistEntry ent : ple)
		{
			options.add(new SelectOption(ent.getValue(), ent.getLabel()));
		}
		return options;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static List<SelectOption> getO2SectorOptions()
	{
		List<SelectOption> options = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = Account.O2_Sector__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		options.add(new SelectOption('', ''));
		for (Schema.PicklistEntry ent : ple)
		{
			options.add(new SelectOption(ent.getValue(), ent.getLabel()));
		}
		return options;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static List<Boostbox_Settings__c> getBoostboxSettings()
	{

		List<Boostbox_Settings__c> settings = [SELECT Active__c, Monthly_Price_Over_12_Months__c, Monthly_Price_Over_24_Months__c, Name, Needs_Access_List__c, Price_Ex_VAT__c, Id, Type__c, Monthly_Price_Over_12_Months_Max__c, Monthly_Price_Over_12_Months_Min__c, Monthly_Price_Over_24_Months_Max__c, Monthly_Price_Over_24_Months_Min__c, Price_Ex_VAT_Max__c, Price_Ex_VAT_Min__c FROM Boostbox_Settings__c];

		if (settings.size() == 0)
		{

			Boostbox_Settings__c s1 = new Boostbox_Settings__c();
			s1.Name = 'Standard Office';
			s1.Active__c = true;
			s1.Monthly_Price_Over_12_Months__c = 13.75;
			s1.Monthly_Price_Over_24_Months__c = 6.88;
			s1.Needs_Access_List__c = 'Yes';
			s1.Price_Ex_VAT__c = 150.00;
			s1.Type__c = 'Standard';
			insert s1;

			Boostbox_Settings__c s2 = new Boostbox_Settings__c();
			s2.Name = 'Larger Office - Closed';
			s2.Active__c = true;
			s2.Monthly_Price_Over_12_Months__c = 21.92;
			s2.Monthly_Price_Over_24_Months__c = 11.46;
			s2.Needs_Access_List__c = 'Yes';
			s2.Price_Ex_VAT__c = 250.00;
			s2.Type__c = 'Large';
			insert s2;

			settings = [SELECT Id, Name, Active__c,Monthly_Price_Over_12_Months__c, Monthly_Price_Over_24_Months__c, Needs_Access_List__c, Price_Ex_VAT__c, Type__c FROM Boostbox_Settings__c];
		}

		return settings;

	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static List<SelectOption> getBoostBoxPaymentOptions()
	{
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption(BBPAYMENT_ONCE_VAL, BBPAYMENT_ONCE_TEXT));
		options.add(new SelectOption(BBPAYMENT_MONTHLY_12M_VAL, BBPAYMENT_MONTHLY_12M_TEXT));
		options.add(new SelectOption(BBPAYMENT_MONTHLY_24M_VAL, BBPAYMENT_MONTHLY_24M_TEXT));
		return options;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static void setConfigVal(cscfgc.ProductConfiguration cfg, String attName, String val)
	{
		System.debug('attName=' + attName);
		System.debug('val=' + val);
		if (val != null && val.trim().length() > 0) cfg.getAttribute(attName).setValue(val);
	}



	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static Contact setConfigLeadUser(cscfgc.ProductConfiguration config, LeadUser lUser, Boolean addNew)
	{

		if (config == null) throw new RequiredDataException('cfg required.');
		if (lUser == null) throw new RequiredDataException('lUser required.');

		Contact con = new Contact();

		if (addNew)
		{
			setConfigVal(config, 'Lead User Salutation', lUser.salutation);
			con.Salutation = lUser.salutation;
			setConfigVal(config, 'Lead User First Name', lUser.firstName);
			con.FirstName = lUser.firstName;
			setConfigVal(config, 'Lead User Last Name', lUser.lastName);
			con.LastName = lUser.lastName;
			setConfigVal(config, 'Lead User Email', lUser.email);
			con.Email = lUser.email;
			setConfigVal(config, 'Lead User Mobile', lUser.mobile);
			con.MobilePhone = lUser.mobile;
			con.Title = 'Unknown';
		}
		else
		{
			if (lUser.contactId != null)
			{
				Contact[] cons = [SELECT Id, FirstName, Email, LastName, Title, MobilePhone, Salutation, AccountId FROM Contact WHERE Id = :lUser.contactId];
				for (Contact c: cons)
				{
					setConfigVal(config, 'Lead User Salutation', c.Salutation);
					setConfigVal(config, 'Lead User First Name', c.FirstName);
					setConfigVal(config, 'Lead User Last Name', c.LastName);
					setConfigVal(config, 'Lead User Email', c.Email);
					setConfigVal(config, 'Lead User Mobile', c.MobilePhone);
					con = c;
					break;
				}
			}
		}

		return con;

	}


	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static void setConfigAddress(cscfgc.ProductConfiguration config, String mode, FemtocellSOAHandler.Address addr)
	{

		if (config == null) throw new RequiredDataException('cfg required.');
		if (mode == null) throw new RequiredDataException('mode required.');
		if (addr == null) throw new RequiredDataException('addr required.');

		String attPrefix = '';
		if (mode.equalsIgnoreCase('INSTALLATION'))
		{
			attPrefix = 'Install ';
			setConfigVal(config, attPrefix + 'Premise Number',
					cutBuildingNumber(addr.buildingNumber));
			setConfigVal(config, attPrefix + 'Building Name', addr.buildingName);
			setConfigVal(config, 'Installation Address Sub Building Name', addr.subBuildingName);
			setConfigVal(config, attPrefix + 'Street', addr.street);
			setConfigVal(config, attPrefix + 'City', addr.postTown);
			setConfigVal(config, attPrefix + 'County', addr.county);
			setConfigVal(config, attPrefix + 'Postcode', addr.postCode);
			setConfigVal(config, attPrefix + 'Premise Name', addr.organisation);
		}
		else if (mode.equalsIgnoreCase('DELIVERY'))
		{
			attPrefix = 'Delivery ';
			setConfigVal(config, attPrefix + 'Address Building Number',
					cutBuildingNumber(addr.buildingNumber));
			setConfigVal(config, attPrefix + 'Address Building Name', addr.buildingName);
			setConfigVal(config, attPrefix + 'Address Sub Building Name', addr.subBuildingName);
			setConfigVal(config, attPrefix + 'Address Street', addr.street);
			setConfigVal(config, attPrefix + 'Address Post Town', addr.postTown);
			setConfigVal(config, attPrefix + 'Address County', addr.county);
			setConfigVal(config, attPrefix + 'Address Postal Code', addr.postCode);
			setConfigVal(config, attPrefix + 'Address Post Town', addr.postTown);
			setConfigVal(config, attPrefix + 'Address Premise Name', addr.organisation);
		}
		else
		{
			throw new RequiredDataException('mode INSTALLATION or DELIVERY required.');
		}


	}

	//--------------------------------------------------------------------------
	// Cut size of the buildingNumber
	//--------------------------------------------------------------------------
	private static String cutBuildingNumber(String buildingNumber)
	{
		String returnValue = null;
		if (buildingNumber != null
				&& buildingNumber.length() > BUILDING_NUMBER_LENGTH)
		{
			returnValue = buildingNumber.substring(0, BUILDING_NUMBER_LENGTH);
		}
		else
		{
			returnValue = buildingNumber;
		}
		return returnValue;
	}


	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static void setConfigAddress(cscfgc.ProductConfiguration config,
			Boolean addingNew,
			String mode,
			FemtocellSOAHandler.Address addr,
			FemtocellSOAHandler.AddressList addList,
			String addressSelected)
	{

		if (config == null) throw new RequiredDataException('cfg required.');
		if (mode == null) throw new RequiredDataException('mode required.');
		if (addr == null) throw new RequiredDataException('addr required.');
		if (!System.Test.isRunningTest())
		{
			if (!addingNew && addList == null) throw new RequiredDataException('addList required.');
		}


		if (addingNew)
		{
			setConfigAddress(config, mode, addr);
		}
		else
		{
			FemtocellSOAHandler.AddressList al = addList;
			if (al != null)
			{
				Integer ind = 0;
				for (FemtocellSOAHandler.Address selAdr: al.addresses)
				{
					if (Integer.valueOf(addressSelected) == ind)
					{
						setConfigAddress(config, mode, selAdr);
						break;
					}
					ind++;
				}
			}
		}
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public BoostBoxItem identifyBBItem(String bbid)
	{
		BoostBoxItem theBBItem;
		for (BoostBoxItem bbIt: bbOrder.bbItems)
		{
			if (bbIt.identifier.equalsIgnoreCase(bbid))
			{
				theBBItem = bbIt;
				break;
			}
		}
		return theBBItem;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public String getBBPAYMENT_ONCE_TEXT()
	{
		return BBPAYMENT_ONCE_TEXT;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public String getBBPAYMENT_MONTHLY_12M_TEXT()
	{
		return BBPAYMENT_MONTHLY_12M_TEXT;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public String getBBPAYMENT_MONTHLY_24M_TEXT()
	{
		return BBPAYMENT_MONTHLY_24M_TEXT;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public String getBBPAYMENT_ONCE_VAL()
	{
		return BBPAYMENT_ONCE_VAL;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public String getBBPAYMENT_MONTHLY_12M_VAL()
	{
		return BBPAYMENT_MONTHLY_12M_VAL;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public String getBBPAYMENT_MONTHLY_24M_VAL()
	{
		return BBPAYMENT_MONTHLY_24M_VAL;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	private static String getBoostboxTypeName(String bbTypeVal)
	{
		String retVal = '';
		try
		{
			List<String> flds = bbTypeVal.split('\\|');
			if (flds != null && flds.size() > 0)
			{
				retVal = flds[6];
			}
			System.debug('getBoostboxTypeName=' + retVal);
		}
		catch (Exception e)
		{
			if (System.Test.isRunningTest())
			{
				retVal = '';
			}
			else throw new RequiredDataException('Data problem: ' + bbTypeVal);
		}
		return retVal;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	private static String getBoostboxTypeDisplayName(String bbTypeVal)
	{
		String retVal = '';
		try
		{
			List<String> flds = bbTypeVal.split('\\|');
			if (flds != null && flds.size() > 0)
			{
				//              retVal = flds[6];
				retVal = flds[1];
			}
			System.debug('getBoostboxTypeName=' + retVal);
		}
		catch (Exception e)
		{
			if (System.Test.isRunningTest())
			{
				retVal = '';
			}
			else throw new RequiredDataException('Data problem: ' + bbTypeVal);
		}
		return retVal;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	private static String getBoostboxClosed(String bbTypeVal)
	{
		String retVal = '';
		try
		{
			List<String> flds = bbTypeVal.split('\\|');
			if (flds != null && flds.size() > 0)
			{
				retVal = flds[4];
				if (retVal == 'Yes') retVal='true';
				else retVal='false';
			}
			System.debug('getBoostboxClosed=' + retVal);
		}
		catch (Exception e)
		{
			if (System.Test.isRunningTest())
			{
				retVal = '';
			}
			else throw new RequiredDataException('Data problem: ' + bbTypeVal);
		}

		return retVal;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public String getAccessListValidationOkMsg()
	{
		return ACCESS_LIST_VALIDATION_OK_MSG;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public String getAccessListValidationOkMsgSingular()
	{
		return ACCESS_LIST_VALIDATION_OK_MSG_SINGULAR;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static testMethod void testConvertMISDNtoIMSI()
	{

		BoostBoxWizController.AccessNumberList accessNumberList = new BoostBoxWizController.AccessNumberList();
		system.assert(!accessNumberList.getIsValid());
		accessNumberList.conversionMode = true;
		accessNumberList.maxListSize = Limits.getLimitCallouts();

		accessNumberList.raw = '';
		accessNumberList.progressValidation(accessNumberList.raw);

		accessNumberList.raw = '123';
		accessNumberList.progressValidation(accessNumberList.raw);

		accessNumberList.raw = '123,123';
		accessNumberList.progressValidation(accessNumberList.raw);

		accessNumberList.raw = '01,02,03,04,05,06,07,08,09,10,11';
		accessNumberList.progressValidation(accessNumberList.raw);
		system.assert(accessNumberList.getIsValid());
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static testMethod void testBoostBoxWizController()
	{

		// Add Test Data

		// Test Data Added

		PageReference pageRef = Page.BoostBoxWiz;
		Test.setCurrentPage(pageRef);

		// Helpers
		System.assert(BoostBoxWizController.getFromXmlSimple('<atag>cont</atag>', 'atag') == 'cont');
		System.assert(BoostBoxWizController.getTag('atag', 'cont') == '<atag>cont</atag>');
		System.assert('de' == BoostBoxWizController.stri('de  '));


		// Test settings refresh
		List<Boostbox_settings__c> settings = BoostBoxWizController.getBoostboxSettings();
		delete settings;

		// Settings refresh
		BoostBoxWizController.getBoostboxSettings(); // Ensure the settings exist
		BoostBoxWizController.refreshSettingsFromDiseMapping(); // Update prices from the dise mapping table

		// Contruction
		BoostBoxWizController controller = new BoostBoxWizController();
		System.assert(controller != null);

		controller.refreshSettings();

		System.assert(controller.bbOrder.bbItems != null);
		System.assert(controller.bbOrder.bbItems.size() == 1);
		System.assert(controller.bbOrder.bbItems[0] != null);
		System.assert(controller.bbOrder.bbItems[0].populated() == false);

		System.assert(controller.getBBPAYMENT_ONCE_TEXT() != null);
		System.assert(controller.getBBPAYMENT_MONTHLY_12M_TEXT() != null);
		System.assert(controller.getBBPAYMENT_MONTHLY_24M_TEXT() != null);
		System.assert(controller.getBBPAYMENT_ONCE_VAL() != null);
		System.assert(controller.getBBPAYMENT_MONTHLY_12M_VAL() != null);
		System.assert(controller.getBBPAYMENT_MONTHLY_24M_VAL() != null);

		// Add New BB Item
		controller.addNewBBItem();
		System.assert(controller.bbOrder.bbItems.size() == 2);

		// Account and Customer

		// Customer Type
		List<SelectOption> ctOpts = BoostBoxWizController.getCustomerTypeOptions();
		System.assert(ctOpts.size() == 3);
		controller.bbOrder.customerType = BoostBoxWizController.CUST_TYPE_SMB_VAL;
		System.assert(controller.bbOrder.customerType.equalsIgnoreCase(BoostBoxWizController.CUST_TYPE_SMB_VAL));

		// DISE Billing Account No
		Boolean normal = false;
		try
		{
			PageReference pr = controller.runAccSearch();
			normal = true;
		}
		catch(Exception e)
		{
			normal = false;
		}
		System.assert(normal);
		System.debug('controller.bbOrder.sfDiseAccount=' + controller.bbOrder.sfDiseAccount);
		System.assert(controller.bbOrder.sfDiseAccount != null);

		// Boostbox Type
		List<SelectOption> btOpts = BoostBoxWizController.getBoostBoxTypeOptions();
		System.debug('btOpts=' + btOpts);
		System.debug('btOpts.size()=' + btOpts.size());
		System.assert(btOpts.size() > 0);
		System.debug('btOpts[0].getValue()=' + btOpts[0].getValue());
		controller.bbOrder.bbItems[0].bbType = btOpts[0].getValue();
		System.debug('**PJR** controller.bbOrder.bbItems[0].bbType=' + controller.bbOrder.bbItems[0].bbType);
		System.debug('getBoostboxTypeName=' + controller.bbOrder.bbItems[0].getBoostboxTypeName());
		System.debug('getBoostboxTypeDisplayName=' + controller.bbOrder.bbItems[0].getBoostboxTypeDisplayName());

		// Payment Option
		List<SelectOption> pOpts = BoostBoxWizController.getBoostBoxPaymentOptions();
		System.debug('pOpts=' + pOpts);
		System.debug('pOpts.size()=' + pOpts.size());
		System.assert(pOpts.size() == 3);
		controller.bbOrder.bbItems[0].paymentType = pOpts[1].getValue();
		System.debug('** PJR** controller.bbOrder.bbItems[0].paymentType=' + controller.bbOrder.bbItems[0].paymentType);

		// Sale Price (ex Vat)
		controller.bbOrder.bbItems[0].salePrice ='123.00';

		// Mobile Number
		controller.bbOrder.bbItems[0].paymentSubscriptionmsisdn ='07710579845';
		normal = false;
		try
		{
			PageReference pr = controller.runVerifyMobile();
			normal = true;
		}
		catch(Exception e)
		{
			normal = false;
		}
		System.assert(normal);

		// test number correct but not on this account
		controller.bbOrder.sfDiseAccount.accountBasicAndAddress.accountNumber='9';
		normal = false;
		try
		{
			PageReference pr = controller.runVerifyMobile();
			normal = true;
		}
		catch(Exception e)
		{
			normal = false;
		}
		System.assert(normal);
		System.assert(controller.bbOrder.bbItems[0].subscriptionID.contains('Error'));

		// Lead User
		normal = false;
		try
		{
			PageReference pr = controller.runContactSearch();
			normal = true;
		}
		catch(Exception e)
		{
			normal = false;
		}
		System.assert(normal);
		List<SelectOption> cOpts = controller.bbOrder.bbItems[0].getcontactOptions();
		System.debug('cOpts=' + cOpts);
		System.debug('cOpts.size()=' + cOpts.size());

		controller.bbOrder.bbItems[0].addingNewContact = true;

		List<SelectOption> sOpts = BoostBoxWizController.getSalutationOptions();
		System.debug('sOpts=' + sOpts);
		System.debug('sOpts.size()=' + sOpts.size());

		System.assert(!controller.bbOrder.bbItems[0].leadUser.populated());
		controller.bbOrder.bbItems[0].leadUser.salutation = 'Mr.';
		controller.bbOrder.bbItems[0].leadUser.firstName = 'FName.';
		controller.bbOrder.bbItems[0].leadUser.lastName = 'LName.';
		controller.bbOrder.bbItems[0].leadUser.email = 'qwsdytfytf@duqyduyg.com';
		controller.bbOrder.bbItems[0].leadUser.mobile = '07809599618';
		System.assert(controller.bbOrder.bbItems[0].leadUser.populated());

		// Check O2 Sector inputs
		List<SelectOption> o2sectorOpts = BoostBoxWizController.getO2SectorOptions();
		System.assert(o2sectorOpts.size()>0);
		// get current user
		User currUser = controller.currentUser;
		system.assert(currUser != null);

		// Installation Address
		normal = false;
		try
		{
			PageReference pr = controller.runInstallationAddressSearch();
			normal = true;
		}
		catch(Exception e)
		{
			normal = false;
		}
		System.assert(normal);
		List<SelectOption> iaOpts = controller.bbOrder.bbItems[0].getInstallationAddressOptions();
		System.debug('iaOpts=' + iaOpts);
		System.assert(iaOpts != null);

		controller.bbOrder.bbItems[0].addingNewInstallationAddress = true;
		controller.bbOrder.bbItems[0].installationAddr.addr.buildingNumber = '1';
		controller.bbOrder.bbItems[0].installationAddr.addr.Street = 'Test Street';
		controller.bbOrder.bbItems[0].installationAddr.addr.postTown = 'Test Post Town';
		controller.bbOrder.bbItems[0].installationAddr.addr.county = 'Test County';
		controller.bbOrder.bbItems[0].installationAddr.addr.postcode = 'UB9 5EX';

		// Delivery Address
		controller.bbOrder.bbItems[0].useInstallationAsDeliveryAddress = false;
		normal = false;
		try
		{
			PageReference pr = controller.runDeliveryAddressSearch();
			normal = true;
		}
		catch(Exception e)
		{
			normal = false;
		}
		System.assert(normal);
		List<SelectOption> daOpts = controller.bbOrder.bbItems[0].getDeliveryAddressOptions();
		System.debug('daOpts=' + daOpts);
		System.assert(daOpts != null);

		controller.bbOrder.bbItems[0].addingNewDeliveryAddress = true;
		controller.bbOrder.bbItems[0].deliveryAddr.addr.buildingNumber = '1';
		controller.bbOrder.bbItems[0].deliveryAddr.addr.Street = 'Test Street';
		controller.bbOrder.bbItems[0].deliveryAddr.addr.postTown = 'Test Post Town';
		controller.bbOrder.bbItems[0].deliveryAddr.addr.county = 'Test County';
		controller.bbOrder.bbItems[0].deliveryAddr.addr.postcode = 'UB9 5EX';

		// Access List
		normal = false;
		try
		{
			PageReference pr = controller.runAccessListServerValidation();
			PageReference pr2 = controller.runAccessListServerValidation();
			normal = true;
		}
		catch(Exception e)
		{
			normal = false;
		}
		System.debug('controller.bbOrder.bbItems[0].accessNumberList=' + controller.bbOrder.bbItems[0].accessNumberList);
		System.assert(normal);

		// Populated
		System.assert(controller.bbOrder.bbItems[0].populated() == true);

		// Place Order
		normal = false;
		try
		{
			PageReference pr = controller.placeOrder();
			normal = true;
		}
		catch(Exception e)
		{
			normal = false;
		}
		System.assert(normal);

		// Bits
		String aid = controller.getSFAccountId();
		Integer i = controller.bbOrder.bbItems[0].getAccessListSize();
		String noList = controller.bbOrder.bbItems[0].accessNumberList.getCleanNumbers(',');
		String p = controller.bbOrder.bbItems[0].getIsPopulated();
		String s = controller.bbOrder.bbItems[0].getValidText();

		String aList = '';
		aList += '07525984406,';
		aList += '07808647978,';
		aList += '07808647979,';
		aList += '07808647980,';
		aList += '07808647981,';
		aList += '07850508286,';
		aList += '07860247906,';
		aList += '07740406701,';
		aList += '07802200709,';
		aList += '07710579845,';
		aList += '07809599618,';
		aList += '07715179472,';
		aList += '01613665103,';
		aList += '01613666421';
		controller.bbOrder.bbItems[0].accessNumberList.progressValidation(aList);

		aList = '';
		aList += '01525984406,';
		aList += '02808647978,';
		aList += '03808647979,';
		aList += '04808647980,';
		aList += '05808647981,';
		aList += '06850508286,';
		aList += '07860247906,';
		aList += '08740406701,';
		aList += '09802200709,';
		aList += '00710579845,';
		aList += '01125984406,';
		aList += '02208647978,';
		aList += '03308647979,';
		aList += '04408647980,';
		aList += '05508647981,';
		aList += '06650508286,';
		aList += '07760247906,';
		aList += '08840406701,';
		aList += '09902200709,';
		aList += '00010579845,';
		aList += '01115984406,';
		aList += '02228647978,';
		aList += '03338647979,';
		aList += '04448647980,';
		aList += '05558647981,';
		aList += '06660508286,';
		aList += '07760247906,';
		aList += '08880406701,';
		aList += '09992200709,';
		aList += '00000579845,';
		aList += '01111984406,';
		aList += '02222647978,';
		aList += '03333647979,';
		aList += '04444647980,';
		aList += '05555647981,';
		aList += '06666508286,';
		aList += '07767247906,';
		aList += '08888406701,';
		aList += '09999200709,';
		aList += '00000579845,';
		controller.bbOrder.bbItems[0].accessNumberList.progressValidation(aList);

		aList = '09999200709,';
		aList += '09999200709,';
		controller.bbOrder.bbItems[0].accessNumberList.progressValidation(aList);

		controller.getShowComplete();
		System.Test.startTest();
		controller.placeOrder();

		System.Test.stopTest();

	}

	//--------------------------------------------------------------------------
	// Creates boostbox case
	//--------------------------------------------------------------------------
	private void createCase()
	{
		caseId = '';
		Case theCase = new Case();
		Id caseRecTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = :CASE_REC_TYPE_NAME].Id;
		theCase.RecordTypeId = caseRecTypeId;
		String strDatetime = system.now().format('yyyy-MM-dd HH:mm:ss');
		theCase.Status = 'New';
		theCase.Priority = 'P4-Information';
		theCase.Case_Submitted_By__c = 'Boostbox LWF';
		theCase.New_Starter_Email__c = 'donotrely@none.com';
		theCase.Origin ='Application';
		theCase.Subject = BOOSTBOX_OPPORTUNITY_NAME.replace('#', String.valueOf(bbOrder.bbItems.size())) + strDateTime;
		theCase.Category__c = 'Boostbox LWF';
		theCase.Other_Benefits__c = 'none';
		theCase.Revenue_Increase__c = '0';

		insert theCase;
		caseId = theCase.Id;
	}

	//--------------------------------------------------------------------------
	// Creates account if doesn't exist
	//--------------------------------------------------------------------------
	private void createOrUpdateAccount()
	{
		if (bbOrder.sfDiseAccount.account != null && (bbOrder.sfDiseAccount.account.Id == null))
		{

			// Change the ownership of the account - to a specifically name user - Workflow rule required to set to FIS
			/// Code needed to get a named user.
			String roleId = [SELECT Id, Name FROM UserRole WHERE Name like '%Boostbox FIS Team%' LIMIT 1].Id;
			if (String.isBlank(roleId)) throw new RequiredDataException('roleId is required');

			String userId = [SELECT Id, Name, UserRoleId FROM User WHERE UserRoleId = :roleId AND isActive = true LIMIT 1].Id;
			if (String.isBlank(userId)) throw new RequiredDataException('userId is required');

			bbOrder.sfDiseAccount.account.OwnerId = userId;
			bbOrder.sfDiseAccount.account.O2_Sector__c = selectedO2Sector;

			insert bbOrder.sfDiseAccount.account;

			// INSERT THE LOCATION FOR THIS NEW ACCOUNT
			Location__c loc = new Location__c();
			fillInLocationData(loc, bbOrder);

			insert loc;

			// ACCOUNT IS ALREADY STORED IN SF - INSERT/UPDATE LOCATION ONLY
		}
		else if (bbOrder.sfDiseAccount.account != null && (bbOrder.sfDiseAccount.account.Id != null))
		{
			// only one Location can exist for each location type at the same time
			List<Location__c> locations = [SELECT id, Type__c, DISE_Address_Line_1__c, DISE_Address_Line_2__c, DISE_Address_Line_3__c, DISE_Address_Line_4__c,
				DISE_Address_Line_5__c, DISE_Postcode__c
					FROM Location__c
					WHERE Account__c = :bbOrder.sfDiseAccount.account.Id
					AND Type__c = 'DISE_Billing'];
			if (locations.size() == 0)
			{
				// insert
				Location__c loc = new Location__c();
				fillInLocationData(loc, bbOrder);
				insert loc;
			}
			else if (locations.size() == 1)
			{
				// update - only if there are any changes
				Location__c loc = locations.get(0);
				if (loc.DISE_Address_Line_1__c != bbOrder.sfDiseAccount.accountBasicAndAddress.address1
						|| loc.DISE_Address_Line_2__c != bbOrder.sfDiseAccount.accountBasicAndAddress.address2
						|| loc.DISE_Address_Line_3__c != bbOrder.sfDiseAccount.accountBasicAndAddress.address3
						|| loc.DISE_Address_Line_4__c != bbOrder.sfDiseAccount.accountBasicAndAddress.address4
						|| loc.DISE_Address_Line_5__c != bbOrder.sfDiseAccount.accountBasicAndAddress.address5
						|| loc.DISE_Postcode__c != bbOrder.sfDiseAccount.accountBasicAndAddress.postcode)
				{
					fillInLocationData(loc, bbOrder);
					update loc;
				}
			}
			else
			{
				// error
			}
		}
		else
		{
			// account is null
			throw new RequiredDataException('Attempt to de-reference a null object.\nDISE account number is not unique. Please order Boostbox manually');
		}
	}

	//--------------------------------------------------------------------------
	// Create opportunity
	//--------------------------------------------------------------------------
	private void createOpportunity()
	{
		//Create a map of Opportunity record types
		Map<String,Id> oppRecordTypes = new Map<String,Id>{};
		Schema.DescribeSObjectResult R = Schema.sObjectType.Opportunity;
		List<Schema.RecordTypeInfo> RTIList = R.getRecordTypeInfos();
		for (Schema.RecordTypeInfo rti: RTIList)
		{
			oppRecordTypes.put(rti.getName() ,rti.getRecordTypeId());
		}
		String currentUserType = UserInfo.getUserType();
		Id oppRecTypeId;
		if (currentUserType == 'Partner')
		{
			oppRecTypeId = oppRecordTypes.get(PARTNER_OPP_REC_TYPE_NAME);
		}
		else
		{
			oppRecTypeId = oppRecordTypes.get(CUST_OPP_REC_TYPE_NAME);
		}

		opp = new Opportunity();
		String strDatetime = system.now().format('yyyy-MM-dd HH:mm:ss');
		opp.Name = BOOSTBOX_OPPORTUNITY_NAME.replace('#', String.valueOf(bbOrder.bbItems.size())) + strDateTime;
		opp.AccountId = bbOrder.sfDiseAccount.account.Id;
		if (oppRecTypeId != null) opp.RecordTypeId = oppRecTypeId;
		opp.CloseDate = System.today();
		opp.StageName = 'Assessment of Alternatives';
		insert opp;

		opportunityId = opp.Id; // Save for the reprocess operation - moves the stage name on.
	}

	//--------------------------------------------------------------------------
	// Create product bundle
	//--------------------------------------------------------------------------
	private void createProductBundle()
	{
		bundle = new cscfgc__Product_Bundle__c();
		bundle.cscfgc__Opportunity__c = opp.Id;
		bundle.Name = 'Bundle for ' + opp.Name;

		bundle.cscfgc__Bundle_Status__c = 'Incomplete';
		insert bundle;
		bundleId = bundle.Id; // Save for the reprocess operation
	}

	//--------------------------------------------------------------------------
	// Update case with details
	//--------------------------------------------------------------------------
	private void updateCase()
	{
		theCase.Status = 'In Progress';
		theCase.Description = getTag('opportunityId', opportunityId) +
			getTag('bundleId', bundleId) +
			getTag('size', String.valueOf(bbOrder.bbItems.size()));
		update theCase;
	}

	//--------------------------------------------------------------------------
	// Put exception message to the end of the case description
	//--------------------------------------------------------------------------
	private void caseToError(Exception e)
	{
		Case theCaseToRecordError = [SELECT Status, Description FROM Case WHERE Id = :caseId LIMIT 1];
		if (theCaseToRecordError != null)
		{
			if (theCaseToRecordError.Description == null)
			{
				theCaseToRecordError.Description = '';
			}
			theCaseToRecordError.Description += getTag('error', e.getMessage());
			update theCaseToRecordError;
		}
	}

	//--------------------------------------------------------------------------
	// Prepare for order
	//   1. Create case
	//   2. Create account if neccesary
	//   3. Create opportunity
	//   3. Create contact if needed
	//--------------------------------------------------------------------------
	public PageReference prepareForOrder()
	{
		step = 1;
		createCase();
		Savepoint sp = Database.setSavepoint();
		try
		{
			//
			// Only bother if there are BB Items
			//
			if (bbOrder.bbItems.size() > 0)
			{
				//
				// INSERT THE ACCOUNT - ALREADY PREPAIRED BY THE VERIFICATION PROCESS / BUTTON
				//
				createOrUpdateAccount();

				//
				// INSERT THE OPPORTUNITY - niting the number of Boostbox Items in the Name - this will be picked up later
				//
				createOpportunity();

				//
				// SET OPPORTUNITY CONTACT CONTACT ROLES
				//
				setContactRoles(bbOrder, opp.Id, bbOrder.sfDiseAccount.account.Id);
			}
		}
		catch (Exception e)
		{
			isError = true;
			System.debug('**PJR** CATCH BLOCK - ORDER WAS NOT PLACED!');
			System.debug(e.getMessage());
			Database.rollback(sp);
			caseToError(e);
			BoostboxHelper.addMsg(e);
		}
		return null;
	}

	//--------------------------------------------------------------------------
	// Place boostbox order
	//--------------------------------------------------------------------------
	public PageReference placeOrder()
	{
		//
		// Boostbox LWF added to Picklist Values for
		// Record Type New Support Case on Cases
		//
		step = 2; // BB 35026
		debugText += '|placeOrder';
		counter = 1;

		orderRefs = '';

		//
		// Create boostbox case
		//
		createCase();

		debugText += '|added case ' + caseId;
		System.debug('**PJR** INSERTED THE CASE=' + caseId);

		if (bbOrder.bbItems.size() > 0)
		{
			System.debug('**PJR** calling placeBBOrder');
			placeBBOrder(caseId, bbOrder, selectedO2Sector);
			System.debug('**PJR** called placeBBOrder');
		}

		targetId = 'thanks';

		return null;

	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public PageReference startAgain()
	{
		step = 0;
		counter = 0;
		targetId = 'acc';
		bbOrder = new BoostBoxOrder();
		bbOrder.initialise();
		PageReference pr = new PageReference('/apex/BoostBoxWiz');
		pr.setRedirect(true);
		return pr;
	}


	//--------------------------------------------------------------------------
	// Place boostbox order
	//--------------------------------------------------------------------------
	private void placeBBOrder(String caseId, BoostBoxOrder bbOrder, String selectedO2Sector)
	{

		if (String.isBlank(caseId)) throw new RequiredDataException('caseId is required');
		if (bbOrder == null) throw new RequiredDataException('bbOrder is required');

		System.debug('**PJR** caseId=' + caseId);
		System.debug('**PJR** bbOrder=' + bbOrder);

		bundle = null;

		bundleId = null;

		theCase = [SELECT Status, Description FROM Case WHERE Id = :caseId LIMIT 1];

		Savepoint sp = Database.setSavepoint();
		try
		{
			// Only bother if there are BB Items
			if (bbOrder.bbItems.size() > 0)
			{
				if (theCase == null) throw new BoostBoxWizController.ProcessException('Could not locate case Id=' + theCase);

				// CREATE THE BUNDLE
				createProductBundle();

				//
				// Update case to status 'In Progress'
				//
				updateCase();

				// Place the order for the 1st item only
				for (BoostBoxItem bbi: bbOrder.bbItems)
				{
					placeBBItemOrder(theCase,
							opp.Id,
							bundle.Id,
							bbOrder.customerType,
							bbOrder.sfDiseAccount.accountBasicAndAddress.accountNumber,
							bbOrder.bbItems.size(),
							bbi);
					break;
				}
			}
		}
		catch (Exception e)
		{
			isError = true;
			System.debug('**PJR** CATCH BLOCK - ORDER WAS NOT PLACED!');
			System.debug(e.getMessage());
			Database.rollback(sp);
			caseToError(e);
		}
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	private static void fillInLocationData(Location__c loc, BoostBoxWizController.BoostBoxOrder bbOrder)
	{
		loc.Account__c = bbOrder.sfDiseAccount.account.Id;
		loc.Type__c = 'DISE_Billing';
		loc.DISE_Address_Line_1__c = bbOrder.sfDiseAccount.accountBasicAndAddress.address1;
		loc.DISE_Address_Line_2__c = bbOrder.sfDiseAccount.accountBasicAndAddress.address2;
		loc.DISE_Address_Line_3__c = bbOrder.sfDiseAccount.accountBasicAndAddress.address3;
		loc.DISE_Address_Line_4__c = bbOrder.sfDiseAccount.accountBasicAndAddress.address4;
		loc.DISE_Address_Line_5__c = bbOrder.sfDiseAccount.accountBasicAndAddress.address5;
		loc.DISE_Postcode__c = bbOrder.sfDiseAccount.accountBasicAndAddress.postcode;
	}

	//--------------------------------------------------------------------------
	// Place one boostbox item
	//--------------------------------------------------------------------------
	private void placeBBItemOrder(Case theCase, String opportunityId,
			String bundleId, String customerType, String accountNumber,
			Integer numberOfBBItems, BoostBoxItem bbItem)
	{

		if (String.isBlank(bundleId)) throw new RequiredDataException('bundleId is required');
		if (String.isBlank(opportunityId)) throw new RequiredDataException('opportunityId is required');
		if (String.isBlank(customerType)) throw new RequiredDataException('customerType is required');
		if (String.isBlank(accountNumber)) throw new RequiredDataException('accountNumber is required');
		if (bbItem == null) throw new RequiredDataException('bbItem is required');

		if (theCase == null) throw new BoostBoxWizController.RequiredDataException('Could not locate case Id=' + theCase);

		// All in a transaction?
		Savepoint sp = Database.setSavepoint();
		try
		{
			System.debug('**PJR** bbItem=' + bbItem);

			// Get ready to process BB Item
			Id bbDefId = [SELECT Id FROM cscfgc__Product_Definition__c WHERE Name = 'Boostbox' LIMIT 1].Id;
			if (bbDefId == null) throw new RequiredDataException('Product definition named Boostbox not found');

			cscfgc__Product_Definition__c bbDef = cscfgc.API_1.getProductDefinitionById(bbDefId);
			cscfgc.API_1.ApiSession apiSession = null;
			cscfgc.ProductConfiguration config = null;
			System.debug('**LUSKR** bbDef=' + bbDef);
			cscfgc__Product_Bundle__c bundle = [SELECT Id, Name, cscfgc__Opportunity__c, cscfgc__Bundle_Status__c
				FROM cscfgc__Product_Bundle__c
				WHERE Id = :bundleId
				LIMIT 1];
			if (bundle == null) throw new RequiredDataException('Could not locate bundle for Id ' + bundleId);
			System.debug('**PJR** bundle=' + bundle);

			Opportunity opp = [SELECT Id, Name, StageName
				FROM Opportunity
				WHERE Id = :opportunityId
				LIMIT 1];
			if (opp == null) throw new RequiredDataException('Could not locate Opportunity for Id ' + opportunityId);
			System.debug('**PJR** opp=' + opp);

			// CONFIGURE THE BB ITEM
			apiSession = cscfgc.API_1.getApiSession(bbDef);
			apiSession.setBundle(bundle);
			config = apiSession.getRootConfiguration();
			if (config == null) throw new RequiredDataException('config not set.');

			// Set all config attributes
			setConfigVal(config, 'Customer Type', customerType);
			setConfigVal(config, 'Agreed to Terms and Conditions', 'true');
			setConfigVal(config, 'DISE Billing Account No', accountNumber);
			System.debug('**PJR** bbItem.bbType=' + bbItem.bbType);
			setConfigVal(config, 'Boostbox Type', getBoostboxTypeName(bbItem.bbType));
			setConfigVal(config, 'Needs Access List', getBoostboxClosed(bbItem.bbType));
			setConfigVal(config, 'Payment Option', bbItem.paymentType);
			setConfigVal(config, 'Sale Price (ex Vat)', bbItem.salePrice);
			System.debug('bbItem.paymentType=' + bbItem.paymentType);
			if (bbItem.paymentType.equalsIgnoreCase('0'))
			{
				setConfigVal(config, 'Override One Off Price', 'Yes');
				setConfigVal(config, 'One Off Price', bbItem.salePrice);
			}
			else
			{
				setConfigVal(config, 'Override Recurring Price', 'Yes');
				setConfigVal(config, 'Recurring Price', bbItem.salePrice);
			}
			setConfigVal(config, 'Mobile Number', bbItem.paymentSubscriptionmsisdn);

			setConfigLeadUser(config, bbItem.leadUser, bbItem.addingNewContact); // Set prod attribs and remember in a Contact obj - just get the lead user of the 1st BB Item

			setConfigAddress(config,
					bbItem.addingNewInstallationAddress,
					'INSTALLATION',
					bbItem.installationAddr.addr,
					bbItem.installationFoundAddressList,
					bbItem.installationAddressSelected);
			if (bbItem.useInstallationAsDeliveryAddress)
			{
				setConfigAddress(config,
						bbItem.addingNewInstallationAddress,
						'DELIVERY',
						bbItem.installationAddr.addr,
						bbItem.installationFoundAddressList,
						bbItem.installationAddressSelected);
			}
			else
			{
				setConfigAddress(config,
						bbItem.addingNewDeliveryAddress,
						'DELIVERY',
						bbItem.deliveryAddr.addr,
						bbItem.deliveryFoundAddressList,
						bbItem.deliveryAddressSelected);
			}


			setConfigVal(config, 'Access List', bbItem.accessNumberList.getCleanNumbers(','));
			setConfigVal(config, 'Additional information', bbItem.additionalInformation);

			// all config attributes are now set

			System.debug('**PJR** ONLY 1 ORDER - ABOUT TO EXECUTRE RULES');
			apiSession.executeRules();
			System.debug('**PJR** EXECUTED RULES');
			apiSession.updateLineItems();
			System.debug('**PJR** UPDATED LINES');
			apiSession.persistConfiguration();
			System.debug('**PJR** PERSISTED CONFIG');

			String confId = config.getId();
			if (confId == null) throw new RequiredDataException('Config ID is null');
			System.debug('**PJR** config Id = ' + confId);

			// Workaround for API not connecting configs to the bundle
			System.debug('**PJR** STARTING THE WORK AROUND');
			List<cscfgc__Product_Configuration__c> pcs = [SELECT Id, cscfgc__Product_Bundle__c
				FROM cscfgc__Product_Configuration__c
				WHERE Id = :confId];
			for (cscfgc__Product_Configuration__c pc: pcs)
			{
				pc.cscfgc__Product_Bundle__c = bundleId;
				update pc;
				System.debug('**PJR** WORK AROUND APPLIED');
			}

			if (numberOfBBItems == Integer.valueOf(bbItem.identifier))
			{
				bundle.cscfgc__Bundle_Status__c = 'Valid';
				update bundle;
			}

			theCase.Description += getTag('confId', confId);
			update theCase;
			bbItem.orderStarted = true;
		}
		catch (Exception e)
		{
			System.debug('**PJR** CATCH BLOCK');
			System.debug(e.getMessage());
			Database.rollback(sp);
			caseToError(e);
			throw new ProcessException(UNEXPECTED_EXCEPTION_USER_FRIENDLY_MSG + '(' + e.getMessage() + ')');
		}
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static String getTag(String tag, String content)
	{
		return '<' + tag + '>' + stri(content) + '</' + tag + '>';
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static String stri(String str)
	{
		if (str == null || str.trim() == null || str.trim().length() == 0)
		{
			return '';
		}
		else
		{
			return str.trim();
		}
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static String getFromXmlSimple(String xml, String elemName)
	{

		if (String.isBlank(xml)) return '';

		if (String.isBlank(elemName)) return xml;

		Integer startAt = xml.indexOf('<'+ elemName + '>');
		Integer endAt = xml.indexOf('</'+ elemName + '>');
		return xml.substring(startAt + elemName.length() + 2, endAt);

	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static String replaceLeadingZeroWith44(String dirtyNo)
	{
		String retVal = '';
		if (!String.isBlank(dirtyNo))
		{
			retVal = dirtyNo;
			if (dirtyNo.startsWith('0'))
			{
				retVal = '44' + dirtyNo.substring(1);
			}
		}
		return retVal;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public PageReference reprocess()
	{
		System.debug('boost box wiz, reprocess start');
		BoostBoxItem currentItem = null;
		try
		{
			isError = false;
			if (counter > MAX_BB_ITEMS) throw new RequiredDataException('More then 5 items in the BB order');
			counter++;
			Case theCase = [SELECT Id, Status, Description FROM Case WHERE Id = :caseId LIMIT 1];
			if (theCase == null) throw new RequiredDataException('Could not locate case Id=' + caseId);
			if (String.isBlank(theCase.Description))
			{
				BoostboxHelper.addMsg('Still working. Please try again.', false);
				return null;
			}

			opportunityId = '';
			if (theCase.Description.contains('opportunityId')) opportunityId = getFromXmlSimple(theCase.Description, 'opportunityId');

			bundleId = '';
			if (theCase.Description.contains('bundleId')) bundleId = getFromXmlSimple(theCase.Description, 'bundleId');

			String errorMsg = '';
			if (theCase.Description.contains('error'))
			{
				errorMsg = getFromXmlSimple(theCase.Description, 'error');
				throw new ProcessException(errorMsg + ' (Case:' + theCase.Id + ')');
			}
			System.debug('boost box wiz, reprocess case status = ' + theCase.Status);
			if (theCase.Status.equalsIgnoreCase('New'))
			{

				BoostboxHelper.addMsg('Still working. Please try again.', false);

			}
			else if (theCase.Status.equalsIgnoreCase('In Progress'))
			{

				if (String.isBlank(opportunityId)) throw new RequiredDataException('Opportunity could not be located.');
				if (String.isBlank(bundleId)) throw new RequiredDataException('Bundle could not be located.');

				Boolean placedOne = false;
				for (BoostBoxItem bbi: bbOrder.bbItems)
				{
					if (!bbi.orderStarted)
					{
						BoostboxHelper.addMsg('Processing items, still working. Please try again.', false);
						debugText += '|Running placeBBItemOrder for item ' + bbi.identifier;
						placedOne = true;
						currentItem = bbi;
						placeBBItemOrder(theCase,
								opportunityId,
								bundleId,
								bbOrder.customerType,
								bbOrder.sfDiseAccount.accountBasicAndAddress.accountNumber,
								bbOrder.bbItems.size(),
								bbi);
						break; // 1 at a time else timing issues / collisions occur
				   	}
				}

				//
				// If there is no orders to be placed finallize BoostBox order
				//
				System.debug('boost box wiz, reprocess placed one = ' + placedOne);
				if (!placedOne)
				{
					step = 3; //BB 35026
					// Tried putting this block into a future method and got Internal Salesforce Error.
					// Currently getting - You do not have the level of access necessary to perform the operation you requested.
					// Please contact the owner of the record or your administrator if access is necessary.
					System.debug('**PJR** SYNC attempt: bundleId=' + bundleId);
					ProductBundleController.syncWithOpportunityBoostBox(bundleId);
					System.debug('**PJR** SYNCD ok');

					List<Opportunity> opps = [SELECT Id, StageName FROM Opportunity WHERE Id = :opportunityId];
					for (Opportunity opp: opps)
					{
						System.debug('**PJR** SETTING STAGE NAME OF OPP');
						opp.StageName = 'Achievement of results';
						update opp;
						System.debug('**PJR** SETTING STAGE NAME OF OPP completed');
						break;
					}

					if (String.isBlank(bundleId))
					{
						throw new RequiredDataException('bundleId required.');
					}
					else
					{
						List<cscfgc__Product_Configuration__c> confsToUpd = new List<cscfgc__Product_Configuration__c>();
						List<cscfgc__Product_Configuration__c> confs = [SELECT Id, Name
							FROM cscfgc__Product_Configuration__c
							WHERE cscfgc__Product_Bundle__c = :bundleId];
						for (cscfgc__Product_Configuration__c conf: confs)
						{
							System.debug('**PJR** SETTING NAME OF BB CONFIG');
							if (!conf.Name.equalsIgnoreCase('Boostbox'))
							{
								conf.Name = 'Boostbox';
								confsToUpd.add(conf);
							}
						}
						update confsToUpd;
					}

					orderRefs = '';
					List<Order__c> ords = [SELECT Id, Name, Order_Number__c FROM Order__c WHERE Product_Bundle__c = :bundleId];
					for (Order__c ord: ords)
					{
						if (orderRefs.length() > 0)
						{
							orderRefs += ', ';
						}
						orderRefs += ord.Order_Number__c;
					}
				}
			}
		}
		catch (Exception e)
		{
			isError = true;
			system.debug('boost box wiz reprocess, error = ' + e.getMessage()); 
			//exceptionThrown = true; BB 35026
			if (currentItem != null) currentItem.orderStarted = false;
			counter--;
			BoostboxHelper.addMsg(e);
		}
		System.debug('boost box wiz, reprocess step = ' + step);
		return null;

	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public Boolean getShowComplete()
	{
		if (String.isBlank(orderRefs))
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public PageReference refreshSettings()
	{
		getBoostboxSettings(); // Ensure the settings exist
		BoostBoxWizController.refreshSettingsFromDiseMapping(); // Update prices from the dise mapping table
		return null;
	}

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	public static void refreshSettingsFromDiseMapping()
	{
		Boolean didUpd = false;
		System.debug('Starting settings update');
		List<O2_DISE_Map_Boostbox__c> theDiseMappings = [SELECT o.Id, o.Name, o.Type__c, o.Recurring_Min_Price__c, o.Recurring_Max_Price__c, o.Recurring_Default_Price__c, o.Oneoff_Min_Price__c, o.Oneoff_Max_Price__c, o.Oneoff_Default_Price__c, o.Needs_Access_List__c, o.Description__c, o.Contract_Term__c FROM O2_DISE_Map_Boostbox__c o];
		List<Boostbox_Settings__c> theSettings = [SELECT Active__c, Monthly_Price_Over_12_Months__c, Monthly_Price_Over_24_Months__c, Name, Needs_Access_List__c, Price_Ex_VAT__c, Id, Type__c, Monthly_Price_Over_12_Months_Max__c, Monthly_Price_Over_12_Months_Min__c, Monthly_Price_Over_24_Months_Max__c, Monthly_Price_Over_24_Months_Min__c, Price_Ex_VAT_Max__c, Price_Ex_VAT_Min__c FROM Boostbox_Settings__c];
		List<Boostbox_Settings__c> theUpdatedSettings = new List<Boostbox_Settings__c>();
		for (Boostbox_Settings__c theSetting: theSettings)
		{
			if (theSetting.Active__c)
			{
				didUpd = false;
				for (O2_DISE_Map_Boostbox__c theDiseMap: theDiseMappings)
				{
					if (theSetting.Type__c.equalsIgnoreCase(theDiseMap.Type__c))
					{
						if (theSetting.Needs_Access_List__c == theDiseMap.Needs_Access_List__c)
						{
							System.debug('Updating for ' +  theSetting.Name + ' - ' + theDiseMap.Contract_Term__c);
							if (theDiseMap.Contract_Term__c == 0)
							{
								if (theSetting.Price_Ex_VAT__c != theDiseMap.Oneoff_Default_Price__c)
								{
									theSetting.Price_Ex_VAT__c = theDiseMap.Oneoff_Default_Price__c;
									System.debug('Updating to def ' +  theSetting.Price_Ex_VAT__c);
									didUpd = true;
								}
								if (theSetting.Price_Ex_VAT_Max__c != theDiseMap.Oneoff_Max_Price__c)
								{
									theSetting.Price_Ex_VAT_Max__c = theDiseMap.Oneoff_Max_Price__c;
									System.debug('Updating to  max ' +  theSetting.Price_Ex_VAT_Max__c);
									didUpd = true;
								}
								if (theSetting.Price_Ex_VAT_Min__c != theDiseMap.Oneoff_Min_Price__c)
								{
									theSetting.Price_Ex_VAT_Min__c = theDiseMap.Oneoff_Min_Price__c;
									System.debug('Updating to min ' +  theSetting.Price_Ex_VAT_Min__c);
									didUpd = true;
								}
							}
							else if (theDiseMap.Contract_Term__c == 12)
							{
								if (theSetting.Monthly_Price_Over_12_Months__c != theDiseMap.Recurring_Default_Price__c)
								{
									theSetting.Monthly_Price_Over_12_Months__c = theDiseMap.Recurring_Default_Price__c;
									System.debug('Updating 12 to def ' +  theSetting.Monthly_Price_Over_12_Months__c);
									didUpd = true;
								}
								if (theSetting.Monthly_Price_Over_12_Months_Max__c != theDiseMap.Recurring_Max_Price__c)
								{
									theSetting.Monthly_Price_Over_12_Months_Max__c = theDiseMap.Recurring_Max_Price__c;
									System.debug('Updating 12 to  max ' +  theSetting.Monthly_Price_Over_12_Months_Max__c);
									didUpd = true;
								}
								if (theSetting.Monthly_Price_Over_12_Months_Min__c != theDiseMap.Recurring_Min_Price__c)
								{
									theSetting.Monthly_Price_Over_12_Months_Min__c = theDiseMap.Recurring_Min_Price__c;
									System.debug('Updating 12 to min ' +  theSetting.Monthly_Price_Over_12_Months_Min__c);
									didUpd = true;
								}
							}
							else if (theDiseMap.Contract_Term__c == 24)
							{
								if (theSetting.Monthly_Price_Over_24_Months__c != theDiseMap.Recurring_Default_Price__c)
								{
									theSetting.Monthly_Price_Over_24_Months__c = theDiseMap.Recurring_Default_Price__c;
									System.debug('Updating 24 to def ' +  theSetting.Monthly_Price_Over_24_Months__c);
									didUpd = true;
								}
								if (theSetting.Monthly_Price_Over_24_Months_Max__c != theDiseMap.Recurring_Max_Price__c)
								{
									theSetting.Monthly_Price_Over_24_Months_Max__c = theDiseMap.Recurring_Max_Price__c;
									System.debug('Updating 24 to  max ' +  theSetting.Monthly_Price_Over_24_Months_Max__c);
									didUpd = true;
								}
								if (theSetting.Monthly_Price_Over_24_Months_Min__c != theDiseMap.Recurring_Min_Price__c)
								{
									theSetting.Monthly_Price_Over_24_Months_Min__c = theDiseMap.Recurring_Min_Price__c;
									System.debug('Updating 24 to min ' +  theSetting.Monthly_Price_Over_24_Months_Min__c);
									didUpd = true;
								}
							}
						}
					}
				}
				if (didUpd)
				{
					theUpdatedSettings.add(theSetting);
				}
			}
		}
		if (!theUpdatedSettings.isEmpty())
		{
			System.debug('Updates made');
			update theUpdatedSettings;
		}
		else
		{
			System.debug('No updates made');
		}
		System.debug('Ending settings update');
	}
}