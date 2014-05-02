//------------------------------------------------------------------------------
// Email confirmation email
//------------------------------------------------------------------------------
public with sharing class MyO2BusinessEmailConfirmationTemplate implements MyO2BusinessEmailTemplate
{
	//--------------------------------------------------------------------------
	// Constants
	//--------------------------------------------------------------------------
	private static final String HTML_TEMPLATE = ''
	+ '<html>'
		+ '<head>'
		+ '</head>'
    	+ '<body>'
        + '<center>'
            + '<table id="toptable" cellspacing="0" cellpadding="0" width="500">'
                + '<tr valign="top">'
                    + '<td height="100" style="text-align: left; background-color: #ffffff; vertical-align: top; blabel: header; beditid: r1st1">'
                        + '<img id="r1sp1" border="0" src="https://o2--SSO--c.cs13.content.force.com/servlet/servlet.ImageServer?id=015W00000008tdz&oid=00DW00000004Zol" blabel="headerimage" beditid="r1sp1"></img>'
                    + '</td>'
                + '</tr>'
                + '<tr valign="top">'
                    + '<td height="5" style="background-color: #aaaaff; blabel: accent1; beditid: r2st1"></td>'
                + '</tr>'
                + '<tr valign="top">'
                    + '<td styleInsert="1" style="color:#000000; font-size:12pt; background-color:#FFFFFF; font-family:arial; bLabel:main; bEditID:r3st1; padding: 10px">'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 20px;"><span>'
							+ 'Confirm your Business Portal email address'
						+ '</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: right; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>'
							+ 'Your mobile number:&nbsp;{!mobilePhone}'
						+ '</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>&nbsp;</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>Hello {!name}</span></p>'
						+ '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>&nbsp;</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>'
							+ 'You recently asked us to change the email address associated with your O2 Business Portal on {!emailDateTime}.'
						+ '</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>&nbsp;</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>'
							+ 'To change the email address to {!newEmail}, you need to '
							+ '<a href="{!link}">confirm your email address</a>. '
							+ 'You can still use your current email address until you have confirmed your new email address.'
						+ '</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>&nbsp;</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>'
							+ 'If you have any problems using this URL link, try copying and pasting the following link into your browser:'
						+ '</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>&nbsp;</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>'
							+ '{!link}</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>&nbsp;</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>'
							+ 'To keep your details safe, this link will only work for 48 hours from the time it was sent.'
						+ '</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>&nbsp;</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>'
							+ 'If this wasn\'t you, please contact your account team or email O2 Business Support.'
						+ '</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>&nbsp;</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>&nbsp;</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>Thanks,</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span><a href="http://service.o2.co.uk">O2 Business Support</a></span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 13px;"><span>&nbsp;</span></p>'
                        + '<p style="margin: 0px; color: rgb(51, 51, 51); text-align: left; font-family: Verdana, Helvetica, sans-serif; font-size: 11px;"><span>'
							+ 'This email is sent from an address that is not checked. please do not reply to this email address. '
							+ 'If you have any questions regarding this email, please contact o2 support via the url above.'
						+ '</span></p>'
                   	+ '</td>'
                + '</tr>'
                + '<tr valign="top">'
                    + '<td style="background-color: #aaaaff; height: 0px; blabel: accent2; beditid: r4st1"></td>'
                + '</tr>'
                + '<tr valign="top">'
                    + '<td style="text-align: left; background-color: #ffffff; height: 0px; vertical-align: top; blabel: footer; beditid: r5st1"></td>'
                + '</tr>'
                + '<tr valign="top">'
                    + '<td style="background-color: #aaaaff; height: 0px; blabel: accent3; beditid: r6st1"></td>'
                + '</tr>'
            + '</table>'
        + '</center><br/><br/>'
    	+ '</body>'
	+ '</html>';

	private static final String PLAIN_TEXT_TEMPLATE = ''
		+ 'Activate your business portal account\n'
		+ 'Your mobile number: {!mobilePhone}\n'
		+ '\n'
		+ 'Dear {!name}\n'
		+ '\n'
		+ 'You recently asked us to change the email address associated with your O2 Business Portal on 12 Feb 2013 at 13:15.\n'
		+ '\n'
		+ 'To change the email address to {!newEmail}, you need to confirm your email adress.\n'
		+ 'You can still use your current email address until you have confirmed your new email address.\n'
		+ '\n'
		+ '{!link}\n'
		+ '\n'
		+ 'To keep your details safe, this link will only work for 48 hours from the time it was sent.\n'
		+ '\n'
		+ 'If this wasn\'t you, please contact your account team or email O2 Business Support.\n'
		+ '\n'
		+ '\n'
		+ 'Thanks,\n'
		+ 'O2 Business Support\n'
		+ 'http://service.o2.co.uk\n'
		+ '\n'
		+ '\n'
		+ 'This email is sent from an address that is not checked. Please do not reply to this email address. If you have any questions regarding this email, please contact O2 Support via the URL above.\n';

	//--------------------------------------------------------------------------
	// Members
	//--------------------------------------------------------------------------
	private MyO2BusinessUser businessUser;
	private String link;
	private String mobilePhone;
	private String name;

	//--------------------------------------------------------------------------
	// Set target object id
	//--------------------------------------------------------------------------
	public void setTargetId(Id targetId)
	{
		try
		{
			businessUser = new MyO2BusinessUser(targetId);
		}
		catch (Exception e)
		{
			// Do nothing
		}
	}

	//--------------------------------------------------------------------------
	// Get html body
	//--------------------------------------------------------------------------
	public String getHtmlBody()
	{
		String htmlBody = '<h1>HTML body</h1>';
		if (businessUser != null)
		{
			htmlBody = format(HTML_TEMPLATE);
		}
		system.debug('htmlBody: ' + htmlBody);
		return htmlBody;
	}

	//--------------------------------------------------------------------------
	// Get plain text body
	//--------------------------------------------------------------------------
	public String getPlainTextBody()
	{
		String plainTextBody = 'Plain text body';
		if (businessUser != null)
		{
			plainTextBody = format(PLAIN_TEXT_TEMPLATE);
		}
		system.debug('plainTextBody: ' + plainTextBody);
		return plainTextBody;
	}

	//--------------------------------------------------------------------------
	// Format body from template
	//--------------------------------------------------------------------------
	private String format(String template)
	{
		String returnValue = template;
		returnValue = returnValue.replaceAll('\\{!mobilePhone\\}', getMobilePhone());
		returnValue = returnValue.replaceAll('\\{!name\\}', getName());
		returnValue = returnValue.replaceAll('\\{!newEmail\\}', businessUser.getNewEmail());
		returnValue = returnValue.replaceAll('\\{!link\\}', getLink());
		returnValue = returnValue.replaceAll('\\{!emailDateTime\\}', system.now().format());
		return returnValue;
	}

	//--------------------------------------------------------------------------
	// Get email confirmation link
	//--------------------------------------------------------------------------
	private String getLink()
	{
		if (link == null && businessUser != null)
		{
			MyO2BusinessTokenGeneration tokenGeneration = 
				new MyO2BusinessTokenGeneration();
			tokenGeneration.configuration = MyO2BusinessToken.EMAIL_CONFIRMATION;
			tokenGeneration.userId = businessUser.getUserId();
			link = ''
				+ MyO2BusinessTokenGeneration.siteURL + 'MyO2BusinessEmailConfirmation?tk='
				+ EncodingUtil.urlEncode(tokenGeneration.token, 'UTF-8');
		}
		return link;
	}

	//--------------------------------------------------------------------------
	// Get phone number
	//--------------------------------------------------------------------------
	private String getMobilePhone()
	{
		if (mobilePhone == null && businessUser != null)
		{
			mobilePhone =
				MyO2BusinessSignOnUtils.maskMobilePhone
					(
						businessUser.getMobilePhone(), 
						MyO2BusinessEmailController.LAST_DIGITS
					);
		}
		return mobilePhone;
	}

	//--------------------------------------------------------------------------
	// Get name
	//--------------------------------------------------------------------------
	private String getName()
	{
		if (name == null && businessUser != null)
		{
			name = '';
			if (businessUser.getTitle() != null)
			{
				name += businessUser.getTitle() + ' ';
			}
			name += businessUser.getFirstName() + ' ' + businessUser.getLastName();
		}
		return name;
	}
}