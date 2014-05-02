// CS core
jQuery.noConflict();
if (typeof(console) === 'undefined') console = {log: function(){}};

var CS = CS || {};

Array.prototype.remove = function(from, to) {
  var rest = this.slice((to || from) + 1 || this.length);
  this.length = from < 0 ? this.length + from : from;
  // detect ie9 - native objects don't have apply method
  if (this.push.apply) return this.push.apply(this, rest); else return this.push(rest);
};

CS.namespace = function(name) {

	var	parts = (''+name).split('.'),
		parent = CS;

	if (parts[0] === 'CS') parts = parts.slice(1);

	for (var i = 0, l = parts.length; i < l; i++) {

		if (typeof(parent[parts[i]]) === 'undefined') {
			parent[parts[i]] = {};
		}

		parent = parent[parts[i]];
	}

	return parent;
}


function initCore() {
	var $ = this.$ = jQuery.noConflict();
	var ORIGINAL_OPTIONS = 'originalOptions';
	var HIDDEN = 'hidden';
	var READ_ONLY = 'readOnly';
	var RULE_LOCK = 'ruleLock';
	var LOOKUP_DATA = this.LOOKUP_DATA = 'lookupData';
	var PREVIOUS_SELECTED = 'previousSelected';
	var PREVIOUS_VALUE = 'previousValue'
	var REQUIRED_CLASS = 'requiredInput';
	var READONLY_PLACEHOLDER = 'roPlaceholder';
	var EMPTY = this.EMPTY = '';

	var FREQUENCIES = {
		'annual': 1,
		'bi-annual': 2,
		'quarterly': 4,
		'monthly': 12,
		'weekly': 52,
		'daily': 365
	}

	var FREQUENCY_NAMES = {
		'1': 'annually',
		'2': 'bi-annually',
		'4': 'quarterly',
		'12': 'monthly',
		'52': 'weekly',
		'365': 'daily'
	}

	var PERIODS = {
		'year': 1,
		'quarter': 4,
		'month': 12,
		'week': 52,
		'day': 365
	}

	var PERIOD_NAMES = {
		'1': 'year',
		'4': 'quarter',
		'12': 'month',
		'52': 'week',
		'365': 'day'
	}

	var calculations = [];
	var loggingEnabled = false;
	var loadingOverlayEnabled = true;
	var progressBarImageUrl = '';
	var infoMessages = {};
	var lookupQueryCache = this.lookupQueryCache = {};
	var executeAfterLookupQueriesQueue = this.executeAfterLookupQueriesQueue = [];
	var lookupQueryQueueTimer = this.lookupQueryQueueTimer = null;
	var cachedLookupValues = this.cachedLookupValues = {};
	var multiSelectLookups = this.multiSelectLookups = {};

	this.executeOnLookupQueriesDone = function(callback, name) {
		if (typeof(callback) != 'function') throw 'Invalid arguments: CS.executeOnLookupQueriesDone(function, [name])';
		if (!name) name = callback.name;

		if (_.filter(executeAfterLookupQueriesQueue, function(it){ return it.name == name; }).length > 0) {
			log('Function ' + name + ' already queued');
		} else {
			log('Queuing function after lookup queries');
			executeAfterLookupQueriesQueue.push(callback);
		}

		runFunctionsQueuedForLookupQueries();
	};

	function runFunctionsQueuedForLookupQueries() {
		if (lookupQueriesAreQueued()) {
			log('Waiting for lookup queries to complete...');
			if (lookupQueryQueueTimer != null) lookupQueryQueueTimer = setTimeout(runFunctionsQueuedForLookupQueries, 100);
		} else {
			log('>>> No lookup queries remain, executing function queue...');
			lookupQueryQueueTimer = null;
			if (executeAfterLookupQueriesQueue.length == 0) log('Function queue empty');
			var f;
			while (f = executeAfterLookupQueriesQueue.shift()) {
				try {
					log('Executing queued function: ' + f.name);
					f();
				} catch(e) {
					console.log(e);
				}
			}
		}
	}
	this.runFunctionsQueuedForLookupQueries = runFunctionsQueuedForLookupQueries;

	function lookupQueriesAreQueued() {
		for (query in CS.lookupQueryCache) {
			if (CS.lookupQueryCache[query].callbacks.length > 0) return true;
		}
		return false;
	}

	function setProgressBarImage(sURL) {
		//#
		//# set the url and preload the image so it's cached on the client.
		//#
		progressBarImageUrl = sURL;
		preLoadImage = new Image();
		preLoadImage.src = sURL;
	}
	this.setProgressBarImage = setProgressBarImage;
	this.getProgressBarImage = function() { return progressBarImageUrl; };

	this.enableLogging = function() {loggingEnabled = true};
	this.disableLogging = function() {loggingEnabled = false};

	this.enableLoadingOverlay = function() {loadingOverlayEnabled = true};
	this.disableLoadingOverlay = function() {loadingOverlayEnabled = false};

	function log() {
		if (loggingEnabled) {
			if (console.log.apply) {
				console.log.apply(console, arguments);
			} else {
				for (var i = 0; i < arguments.length; ++i) {
					console.log(arguments[i]);
				}
			}
		}
	};
	this.log = log;

	function getId(id) {
		return '#' + makeCssIdentifier(id);
	};
	this.getId = getId;

	function makeCssIdentifier(id) {
		return id.replace(/([:\/#;&,\.\+\*~'"!\?\^\$\[\]\(\)=>\|])/g, '\\$1');
	};

	function getAttributeField(id, fieldName) {
		if (fieldName == null) return null;

		var field = $(getId(id + ':_' + fieldName.toLowerCase()));

		if (field.size() == 0) {
			log('Cannot find attribute field: ' + fieldName + ' for attribute: ' + id);
			return null;
		}
		return field;
	}

	this.startsWith = function startsWith(str, head) {
		var headLen = head.length;
		return str.length >= headLen && str.substr(0, headLen) === head;
	}

	this.endsWith = function endsWith(str, tail) {
		var tailLen = tail.length;
		var strLen = str.length;
		return strLen >= tailLen && str.substr(strLen-tailLen, tailLen) === tail;
	};

	this.disableAttribute = function disableAttribute(id) {
		$(getId(id)).parents('.attrWrapper').data(HIDDEN, 'true').data('attributeId', id);
		$(getId(id+':_active')).val('false');
	};

	this.makeAttributeReadOnly = function makeAttributeReadOnly(id) {
		$(getId(id)).data(READ_ONLY, true).parents('.attrWrapper').data(READ_ONLY, 'true').data('attributeId', id);
	}

	function setAttribute(id, value, suppressEvent) {
		if (value && value.isCallback) {
			value.applyValue = function(data) {
				if (cachedLookupValues[id] === undefined) cachedLookupValues[id] = $(getId(id)).val();
				//var currentVal = $(getId(id)).val();
				var currentVal = cachedLookupValues[id];
				var val = data[value.fieldName];
				if (val !== 0 && val !== false && !val) val = '';
				if ('' + val != currentVal) {
					setAttribute(id, val, suppressEvent);
					cachedLookupValues[id] = val;
					log('Dynamic lookup result requires rule evaluation: ' + id + ' - ' + val + ' (' + currentVal + ')');
					CS.rules.evaluateAllRules();
				}
			}
		} else {
			var field = $(getId(id)),
				oldValue = field.val();
			field.val(value);
			log('>> Set ' + id + ': ' + value + ' (' + oldValue + ')');
			if (!suppressEvent) {
				fireChange(field);
			}
		}
	};
	this.setAttribute = setAttribute;

	function getAttributeValue(id, dataType) {

		var field = $(getId(id));
		var val;
		if (dataType == 'Integer') val = parseInt(field.val());
		if (dataType == 'Double') val = parseFloat(field.val());
		if (!val && val !==0) val = field.val();
		return val;
	}
	this.getAttributeValue = getAttributeValue;

	function setAttributeField(id, fieldName, value) {
		if (value && value.isCallback) {
			value.applyValue = function(data) {
				var currentVal = $(getId(id)).val();
				var val = data[value.fieldName];
				if (val !== 0 && val !== false && !val) val = '';
				if (val != currentVal) {
					setAttributeField(id, fieldName, val);
				}
			}
		} else {
			var field = getAttributeField(id, fieldName);
			if (!field) return;
			field.val(value);
		}
	};
	this.setAttributeField = setAttributeField;


	function setCheckbox(id, value, suppressEvent) {
		var field = $(getId(id));
		var cbField = $(getId(id + '__check'));
		if (!field || !cbField) return;
		log('found checkbox fields for : ' + id);
		log('setting value to : ' + value);
		field.val(value);


		if (value.toLowerCase() == 'yes')
			cbField.attr('checked',true);
		else
			cbField.attr('checked',false);

		if (!suppressEvent) fireChange(field);
	};
	this.setCheckbox = setCheckbox;


	function getAttributeFieldValue(id, fieldName) {
		var field = getAttributeField(id, fieldName);
		if (!field) return '';
		var val = parseFloat(field.val());
		return (val || val === 0) ? val : field.val();
	};
	this.getAttributeFieldValue = getAttributeFieldValue;

	this.getLookupValue = function getLookupValue(id, fieldName, defaultValue) {
		var field = $(getId(id));

		if (field.data(LOOKUP_DATA) == null) {
			CS.log('Lookup for ' + id + ' had no new data, using default value');
			return defaultValue;
		}

		CS.log('Lookup for ' + id + ', field ' + fieldName + ': ' + field.data(LOOKUP_DATA)[fieldName]);

		var val = field.data(LOOKUP_DATA)[fieldName];
		return (val === undefined ? null : val);
	}

	this.getDynamicLookupValue = function getDynamicLookupValue(queryID, fieldName, configurationID) {
		log('Dynamic lookup: ' + fieldName);
		var dynamicFilterMap = {};
		$(".cfgAttr").each(function(i, attr) {
			var id = getId($(attr).attr('id') + ":_name");
			var sel = $(id);
			var name = sel.val();
			dynamicFilterMap[name] = $(attr).val();
		});

		var queryProxy = {
			isCallback: true,
			fieldName: fieldName.toLowerCase(),
			applyValue: function(value) {
				console.log('Callback applyValue not defined!');
			},
			setError: function(error) {
				console.log('Could not update dynamic lookup: ' + error);
			}
		};

		var cached = lookupQueryCache[queryID];
		if (!cached) cached = lookupQueryCache[queryID] = {};

		if (cached.params && _.isEqual(cached.params, dynamicFilterMap)) {
			log('Using cached dynamic lookup value for ' + fieldName + ': ', cached.data);
			setTimeout(function() {queryProxy.applyValue(cached.data, {status: 'cached'})}, 100);
		} else {
			if (!cached.callbacks) cached.callbacks = [];
			cached.callbacks.push(queryProxy);
			if (cached.status == 'requested') {
				log('Queued callback for: ' + fieldName);
			} else {
				var queryCallback = function(result, event) {
					if (event.status) {
						var data = {};
						for (key in result) {
							data[key.toLowerCase()] = result[key];
						}
						log('Received dynamic lookup value for field ' + fieldName, data);
						cached.params = dynamicFilterMap;
						cached.data = data;
						cached.status = 'ready';
						var callback;
						while (callback = cached.callbacks.shift()) {
							callback.applyValue(data);
						}
						cached.status = 'ready';
						runFunctionsQueuedForLookupQueries();
			        } else {
			        	queryProxy.setError(event.message);
			        }
				}

				log('>> Values have changed:', cached.params, dynamicFilterMap);
				log('>> New remote request for field ' + fieldName);
				var namespace = getPackageNamespace();
		        namespace['ProductConfiguratorController'].lookupQuery(queryID, dynamicFilterMap, configurationID, queryCallback, {escape:true});
				cached.status = 'requested';
			}
		}
        return queryProxy;
	}

	function getPackageNamespace() {
		var namespaces = ['cscfga', 'cscfgc'],
			namespace,
			idx = namespaces.length;

		while(idx--) {
			namespace = window[namespaces[idx]];
			if ( namespace && namespace['ProductConfiguratorController']) return namespace;
		}

		return window;
	}

	function getFrequencyName(val) {
		return FREQUENCY_NAMES[val] || '';
	}
	this.getFrequencyName = getFrequencyName;

	function getPeriodName(val) {
		return PERIOD_NAMES[val] || '';
	}
	this.getPeriodName = getPeriodName;

	function countRelatedProducts(id) {
		if (id == null) return 0;

		return getAttributeFieldValue(id, 'count');
	}
	this.countRelatedProducts = countRelatedProducts;

	this.updateFromSelect = function updateFromSelect(id) {
		var field = $(getId(id));
		updateOptionPrice(id, field.val());
	}

	function updateOptionPrice(id, val) {
		var price = optionPrices[id][val];
		if (price != null) setAttributeField(id, 'price', price);
	}
	this.updateOptionPrice = updateOptionPrice;

	function updateCheckbox(id, checkbox) {
		log('Updating checkbox id ' + id + ': ' + $(checkbox).is(':checked'));
		$(getId(id)).val($(checkbox).is(':checked') ? 'Yes' : 'No');
	};
	this.updateCheckbox = updateCheckbox;

	function setTextDisplay(id, value) {
		if (value && value.isCallback) {
			value.applyValue = function(data) {
				var currentVal = $(getId(id)).val();
				var val = data[value.fieldName];
				if (val !== 0 && val !== false && !val) val = '';
				if ('' + val != currentVal) {
					setTextDisplay(id, val);
				}
			}
		} else {
			var el = $(getId(id));
			if (el.size() < 1) {
				log('Could not find element for ' + id);
				return;
			}
			if (el.get(0).tagName.toUpperCase() == 'INPUT') el.val(value);
			else el.html(value);
			fireChange(el);
		}
	};
	this.setTextDisplay = setTextDisplay;

	function setCalculation(id, value, suppressEvent) {
		if (value && value.isCallback) {
			value.applyValue = function(data) {
				if (cachedLookupValues[id] === undefined) cachedLookupValues[id] = $(getId(id)).val();
				//var currentVal = $(getId(id)).val();
				var currentVal = cachedLookupValues[id];
				var val = data[value.fieldName];
				if (val !== 0 && val !== false && !val) val = '';
				if ('' + val != currentVal) {
					setCalculation(id, val, suppressEvent);
					cachedLookupValues[id] = val;
					log('Dynamic lookup value requires rule evaluation: ' + id + ' - ' + val + ' (' + currentVal + ')');
					CS.rules.evaluateAllRules();
				}
			}
		} else {
			setAttribute(id, value, suppressEvent);
			var displayEl = $(getId(id)).siblings('.calcValue');
			displayEl.html('' + value);
		}
	};
	this.setCalculation = setCalculation;

	function setRecurrenceFrequency(id, value) {
		if (value && value.isCallback) {
			value.applyValue = function(data) {
				var currentVal = $(getId(id)).val();
				var val = data[value.fieldName];
				if (!val) val = '';
				if (val != currentVal) {
					setRecurrenceFrequency(id, val);
				}
			}
		} else {
			var val = null;
			if (value != null) {
				val = parseInt(value);
				if (!val && val !== 0 && value != null) val = FREQUENCIES[value.toLowerCase()];
			}
			setAttributeField(id, 'recurrence', val);
		}
	}
	this.setRecurrenceFrequency = setRecurrenceFrequency;

	function setBillingFrequency(id, value) {
		if (value && value.isCallback) {
			value.applyValue = function(data) {
				var currentVal = $(getId(id)).val();
				var val = data[value.fieldName];
				if (!val) val = '';
				if (val != currentVal) {
					setBillingFrequency(id, val);
				}
			}
		} else {
			var val = null;
			if (value != null) {

				if (isNaN(value)) val = FREQUENCIES[value.toLowerCase()];
				else val = parseInt(value);

			}
			//#
			//# Use this if we want to set a Billing Freq for each product in the config
			//# Currently we set the freqency for the entire config. ('' rather than id)
			//#
			//setAttributeField(id, 'billingFrequency', val);
			setAttributeField('', 'billingFrequency', val);
		}
	}
	this.setBillingFrequency = setBillingFrequency;

	function setContractTerm(id, value) {
		if (value && value.isCallback) {
			value.applyValue = function(data) {
				var currentVal = $(getId(id)).val();
				var val = data[value.fieldName];
				if (!val) val = '';
				if (val != currentVal) {
					setContractTerm(id, val);
				}
			}
		} else {
			var val = null;
			if (value != null) {
				val = parseInt(value);
			}
			setAttributeField(id, 'contractterm', val);
		}
	}
	this.setContractTerm = setContractTerm;

	function setContractTermPeriod(id, value) {
		if (value && value.isCallback) {
			value.applyValue = function(data) {
				var currentVal = $(getId(id)).val();
				var val = data[value.fieldName];
				if (!val) val = '';
				if (val != currentVal) {
					setContractTermPeriod(id, val);
				}
			}
		} else {
			var val = null;
			if (value != null) {
				val = parseInt(value);
				if (!val && val !== 0 && value != null) val = PERIODS[value.toLowerCase()];
			}
			setAttributeField(id, 'contracttermperiod', val);
		}
	}
	this.setContractTermPeriod = setContractTermPeriod;

	function markConfigurationInvalid(id, value) {
		if (value && value.isCallback) {
			value.applyValue = function(data) {
				var currentVal = $(getId(id)).val();
				var val = data[value.fieldName];
				if (!val && val !== false) val = '';
				if (val != currentVal) {
					markConfigurationInvalid(id, val);
				}
			}
		} else {
			var indicator = jQuery('#currentScreenValidIndicator');
			var invalidIconSrc = jQuery('#screenInvalidIcon').attr('src');
			if (indicator.data(PREVIOUS_VALUE) == null) indicator.data(PREVIOUS_VALUE, indicator.attr('src'));
			indicator.attr('src', invalidIconSrc);
			jQuery('#CSValidationMessageBox').css({display: 'block'});
			jQuery('#CSValidationMessage').html(value);
			setAttributeField(id, 'status', 'Incomplete');
			setAttributeField(id, 'validationmessage', value);
		}
	}
	this.markConfigurationInvalid = markConfigurationInvalid;

	function markConfigurationValid(id) {
		jQuery('#CSValidationMessageBox').css({display: 'none'});
		jQuery('#CSValidationMessage').html('');
		setAttributeField(id, 'status', 'Valid');
		setAttributeField(id, 'validationmessage', '');
	}
	this.markConfigurationValid = markConfigurationValid;

	function requireDataRefresh(message) {
		displayInfo(message);
		jQuery('span.CSFinishButton').hide();
		jQuery('span.CSRefreshButton').show();
	}
	this.requireDataRefresh = requireDataRefresh;

	function displayInfo(value) {
		if (value && value.isCallback) {
			value.applyValue = function(data) {
				var currentVal = $(getId(id)).val();
				var val = data[value.fieldName];
				if (val !== 0 && val !== false && !val) val = '';
				if (val != currentVal) {
					displayInfo(val);
				}
			}
		} else {
			infoMessages[value] = true;
			jQuery('#CSInfoMessageBox').css({display: 'block'});
			var html = '';
			for (var m in infoMessages) html += '<p>' + m + '</p>';
			jQuery('#CSInfoMessage').html(html);
		}
	}
	this.displayInfo = displayInfo;

	function clearInfo(message) {
		infoMessages = {};
		jQuery('#CSInfoMessageBox').css({display: 'none'});
		jQuery('#CSInfoMessage').html('');
	}
	this.clearInfo = clearInfo;

	function updateFromRadio(id, radio) {
		var field = $(getId(id));
		var value = $(radio).val();
		if (value != field.val()) {
			setAttribute(id, value);
			updateOptionPrice(id, value);
		}
	};
	this.updateFromRadio = updateFromRadio;

	function constrainList(id, options) {
		var list = jQuery(getId(id));

		if (list.size() > 0 && list.get(0).tagName == 'SELECT') {
			var selected = list.children(':selected');

			if (list.data(ORIGINAL_OPTIONS) == null) {
				list.data(ORIGINAL_OPTIONS, list.children('option'));
			}

			var html = '';
			var oneOption = '';
			for (i = 0; i < options.length; i++) {

				oneOption = '<' + 'opt' + 'ion ' + 'value="' + options[i][1] + '"';
				if (selected.attr('value') == options[i][1]) oneOption = oneOption + ' selected="selected" ';
				oneOption += '>' + options[i][0] + '</option>';

				html +=oneOption;
			}

			list.html(html).trigger("liszt:updated");
			fireChange(list);

		} else {

			var cssClass = '.' + makeCssIdentifier(id);
			list = jQuery(cssClass + '.csOptionHolder');

			if (list.size() > 0) {

				jQuery.each(list, function(i, it) {

					it = jQuery(it);
					var thisOption = it.find(cssClass + '.csOption');

					if (thisOption.size() == 0) {
						CS.log('Could not find option: ' + id + ' / ' + cssClass + '.csOption');
						return;
					}

					var available = false;
					for (i = 0; i < options.length; i++) {
						if (options[i][1] == thisOption.val()) {
							available = true;
							break;
						}
					}

					if (!available) {
						if (thisOption.is(':checked')) thisOption.attr('checked', false);
						it.data(HIDDEN, true).hide();
					}
				});
			} else {
				CS.log('Could not find list: ' + id + ' / ' + cssClass + '.csOptionHolder');
				return;
			}
			fireChange(jQuery(getId(id)));
		}
	}
	this.constrainList = constrainList;

	function updateMandatoryFields() {

		var allFields = jQuery('.attrLabel label');
		log('Updating ' + allFields.size() + ' fields for mandatory markers...');

		$.each(allFields, function(i, it) {
			var field = $(it);
			var id = field.attr('for');

			if (id != null && id.length > 8 && CS.endsWith(id,'_wrapper')) {
				id = id.substring(0, id.indexOf('_wrapper'));

				var requiredVal = $(getId(id + ':_isrequired')).val();
				var required = requiredVal != null && requiredVal.toLowerCase() == 'true';

				var wrapper = $(getId(id)).parents('.attrWrapper');
				var hidden = (wrapper.data(HIDDEN) === 'true');
				var inner = wrapper.children('div');
				//log('Checking isRequired for id ' + id + ': ' + required);

				if (!hidden && required && !inner.hasClass(REQUIRED_CLASS)) inner.addClass(REQUIRED_CLASS);
				if ((hidden || !required) && inner.hasClass(REQUIRED_CLASS)) inner.removeClass(REQUIRED_CLASS);
			}
		});
	};
	this.updateMandatoryFields = updateMandatoryFields;

	function fireChange(field) {
		if (field.data(RULE_LOCK) !== true) {
			log('Field changed: ' + field.attr('id'));
			field.data(RULE_LOCK, true);
		}
		else log('Field locked, no further changes: ' + field.attr('id'));
	};
	this.fireChange = fireChange;

	function resetAttributes() {

		jQuery("input[name$='_status']").val('Valid');
		jQuery("input[name$='_validationmessage']").val('');
		jQuery('#CSValidationMessageBox').css({display: 'none'});
		var indicator = jQuery('#currentScreenValidIndicator');
		if (indicator.data(PREVIOUS_VALUE) != null) indicator.attr('src', indicator.data(PREVIOUS_VALUE));

		//jQuery('input .csAttr').data(HIDDEN, false);

		jQuery('.attrWrapper').data(HIDDEN, 'false').data(READ_ONLY, 'false').prev('.attrLabel').data(HIDDEN, 'false');
		// Reset line items
		// _defislineitem param indicates whether the attribute is by default a line item via its definition
		// so reset the attr's state to this
		jQuery.each(jQuery("input.cfgAttr"), function(i, it) {
			jQuery(getId(it.id + ':_islineitem')).val(jQuery(getId(it.id + ':_defislineitem')).val());
		});

		jQuery.each(jQuery('.attrWrapper select'), function(i, it) {
			var select = jQuery(it);
			if (select.data(ORIGINAL_OPTIONS) != null) {
				var selectedItem 	= select.children(':selected');
				var theValue 		= selectedItem.attr('value');
				select.html('').append(select.data(ORIGINAL_OPTIONS));
				select.val(theValue);
				select.trigger("liszt:updated");
			}
		});

		jQuery.each(jQuery('.csOptionHolder'), function(i, it) {
			var option = jQuery(it);
			if (option.data(HIDDEN) == true) option.show().data(HIDDEN, false);
		});
	}
	this.resetAttributes = resetAttributes;

	function unlockAttributes() {
		jQuery('input.cfgAttr').data(RULE_LOCK, false);
	}
	this.unlockAttributes = unlockAttributes;

	function applyAttributeEffects() {

		//#
		//# remove any and all previously created hidden input fields to hold
		//# values from R/O fields
		//#
		jQuery('.' + READONLY_PLACEHOLDER).remove();

		jQuery.each(jQuery('.attrWrapper'), function(i, it) {

			var fadeAmt = 0.3;
			var wrapper = jQuery(it);
			var id = wrapper.data('attributeId');
			var el = id ? jQuery(getId(id)) : {size: function(){return 0}};

			//#
			//# HIDDEN
			//#
			if (wrapper.data(HIDDEN) == 'true') {

				wrapper.css('visibility', 'visible').fadeTo('fast', fadeAmt).prev('.attrLabel').fadeTo('fast', fadeAmt);

				if (el.size() > 0)
				{
					// standard inputs / selects
					if (el.attr("selectedIndex") != null) {
						el.data(PREVIOUS_SELECTED, el.attr('selectedIndex')).attr("selectedIndex",-1);
					} else {
						el.data(PREVIOUS_VALUE, el.val());
					}

					el.val('').attr('disabled', true);

					// related products and lookup fields
					jQuery(getId(id + '_ctrlButtons')).css({visibility: 'hidden'});
					jQuery(getId(id + '_Name')).attr('readonly', true);
					jQuery(getId(id + ':_islineitem')).val('false');

				}

				// Checkboxes
				if (jQuery(getId(id + '__check')))
					jQuery(getId(id + '__check')).val('').attr('checked',false).attr('disabled',true);

				// Radio
			 	jQuery("input[name='" + id + "-list" + "']").each(function(i) {
					jQuery(this).attr('disabled', true).attr('checked',false);
				});


			} else {

				wrapper.css('visibility', 'visible').fadeTo('fast', 1).prev('.attrLabel').fadeTo('fast', 1);
				jQuery(getId(id+':_active')).val('true');

				if (el.size() > 0) {
					var val = el.data(PREVIOUS_VALUE);
					el.data(PREVIOUS_VALUE, null);
					if (val != null) el.val(val);
				}

				try {
					if (id) {
						// inputs and selects
						if (el.size() > 0 && el.attr('disabled'))
						{
						 	el.removeAttr('disabled').attr('selectedIndex', el.data(PREVIOUS_SELECTED));

							// related products and lookup fields
							jQuery(getId(id + '_ctrlButtons')).css({visibility: 'visible'});
						}
						// checkboxes
						if (jQuery(getId(id + '__check'))) jQuery(getId(id + '__check')).removeAttr('disabled');

						// Radios
					 	jQuery("input[name='" + id + "-list" + "']").each(function(i) {
							jQuery(this).removeAttr('disabled', true);
						});
					}
				}
				 catch (e) {
				 	CS.log('ERROR' + e);
				}
			}

			//#
			//# READ ONLY
			//#
			if (wrapper.data(READ_ONLY) == 'true') {

				var encodedVal = el.val().replace(/\"/g,'&quot;');

				wrapper.append('<input type="hidden" class="' + READONLY_PLACEHOLDER +  '" name="' + id + '" value="' + encodedVal + '"> ')

				// Standard inputs / selects
				if (el.size() > 0)	{
					el.attr('readonly', true);
					el.attr('disabled', true);
					jQuery(getId(id + '_ctrlButtons')).fadeTo('fast', fadeAmt).bind('click.CSReadOnly', function(e) {e.preventDefault();});//css({visibility: 'hidden'});
					jQuery(getId(id + '_Name')).attr('readonly', true);

				}

				// Checkboxes
				if (jQuery(getId(id + '__check')))
					jQuery(getId(id + '__check')).attr('disabled',true);

				// Radio
			 	jQuery("input[name='" + id + "-list" + "']").each(function(i) {
						jQuery(this).attr('disabled', true);
				});

			} else if (wrapper.data(HIDDEN) != 'true'){


				// standard inputs / selects
				if (el.size() > 0)	{
					el.removeAttr('readonly');
					el.removeAttr('disabled');

					jQuery(getId(id + '_ctrlButtons')).fadeTo('fast', 1).unbind('click.CSReadOnly');//css({visibility: 'visible'});
					jQuery(getId(id + '_Name')).removeAttr('readonly');
				}

				// Checkboxes
				if (jQuery(getId(id + '__check')))
					jQuery(getId(id + '__check')).removeAttr('disabled');

				// Radio
			 	jQuery("input[name='" + id + "-list" + "']").each(function(i) {
					jQuery(this).removeAttr('disabled');
				});
			}
		});

	}
	this.applyAttributeEffects = applyAttributeEffects;




	//#
	//# DEPRECATED: Function to hide and enable R/O fields prior to submit so that
	//# they arrive in the RequestObject
	//#
	function createHiddenInputsForROFields()
	{
		jQuery.each(jQuery('.attrWrapper'), function(i, it) {

			var wrapper = jQuery(it);
			var id = wrapper.data('attributeId');
			var el = id ? jQuery(getId(id)) : {size: function(){return 0}};

			//#
			//# READ ONLY - SO HIDE THEM AND THEN ENBLE THEM
			//#
			if (wrapper.data(READ_ONLY) == 'true')
			{
				log('>>> SUBMIT READ-ONLY - HIDDEN INPUT FIELD FOR: ' + id);
				wrapper.append('<!-- ## RO VAL --> <input type="hidden"  name="' + id + '" value="' + el.val() + '"> ');


			}


		});


	}
	this.createHiddenInputsForROFields = createHiddenInputsForROFields;



	function registerCalculation(func) {
		calculations[calculations.length] = func;
	}
	this.registerCalculation = registerCalculation;

	function updateCalculations() {
		jQuery.each(calculations, function(i, calc) {
			try {
				calc.call(CS);
			} catch (e) {
				CS.log(e);
				CS.log(calc);
			}
		});
	}
	this.updateCalculations = updateCalculations;


	function showProgress(displayText,displayImage) {
  			hideProgress();
			if (!loadingOverlayEnabled) return;

	        jQuery("BODY").append('<div id="processing_overlay"></div>');
	            jQuery("BODY").append(
			      '<div id="processing_container">' +
			        //'<div id="processing_title">This is title</div>' +
			        '<div id="processing_content">' +
	    		            '<img src="'+displayImage+'" style="width:43px;height:11px;" alt=""/>' +
			                '<br/><br/>'+displayText+
				    '</div>' +
			      '</div>');

			var pos = (jQuery.browser.msie && parseInt(jQuery.browser.version) <= 6 ) ? 'absolute' : 'fixed';

			jQuery("#processing_container").css({
				position: pos,
				zIndex: 99999,
				padding: 0,
				margin: 0
			});

			jQuery("#processing_container").css({
				minWidth: jQuery("#processing_container").outerWidth(),
				maxWidth: jQuery("#processing_container").outerWidth()
			});

			var top = ((jQuery(window).height() / 2) - (jQuery("#processing_container").outerHeight() / 2)) + (-75);
			var left = ((jQuery(window).width() / 2) - (jQuery("#processing_container").outerWidth() / 2)) + 0;
			if( top < 0 ) top = 0;
			if( left < 0 ) left = 0;

			// IE6 fix
			if( jQuery.browser.msie && parseInt(jQuery.browser.version) <= 6 ) top = top + jQuery(window).scrollTop();

			jQuery("#processing_container").css({
				top: top + 'px',
				left: left + 'px'
			});
			jQuery("#processing_overlay").height( jQuery(document).height() );
	    }
		this.showProgress = showProgress;

  		function hideProgress() {
      		jQuery("#processing_container").css('cursor:default');
      		jQuery("#processing_container").remove();
	        jQuery("#processing_overlay").remove();
	    }
		this.hideProgress = hideProgress;

		function progressOn()
		{

			showProgress('Loading...',this.getProgressBarImage());
		}
		this.progressOn =  progressOn;


	function executePreSubmissionTasks(sOtherJSCommands)
	{
		if(sOtherJSCommands)
			eval(sOtherJSCommands);
		else
			CS.rules.evaluateAllRules();

		this.progressOn();

	}
	this.executePreSubmissionTasks = executePreSubmissionTasks;

	//#
	//# URL Encode / Decode wrappers.
	//#
 	function urlEncode(strValue) {

        return encodeURIComponent(strValue).replace(/\s/g, "+");
    }
    this.urlEncode = urlEncode;

    function urlDecode(strValue) {
        return decodeURIComponent(strValue.replace(/\+/g, " "));
    }
	this.urlDecode = urlDecode;


	function submitForm(formName, values) {
		var f = jQuery('#CS_' + formName);
		if (f.size() == 0) {
			console.log('Form CS_' + formName + ' not found');
			return;
		}

		var form = f.get(0);

		if (values) {
			for (key in values) {
				log('>>>> ' + key);
				if (key == '_action') f.attr('action', values[key]);
				else {
					if (form[key] == undefined) log('>>>> Expected form field missing: ' + key);
					else form[key].value = values[key];
				}
			}
		}

		f.submit();
	}
	this.submitForm = submitForm;

	function initMultiLookup(params) {
		var table = jQuery(getId(params.tableId)),
			tplRow = table.find('tr.dataRow').remove().removeClass('first last'),
			colKeys = [],
			colMaps = {};

		jQuery.each(tplRow.find('span.col'), function(i, it) {
			var j = jQuery(it);
			var idx = parseInt(j.attr('data-col-idx'));
			if (!isNaN(idx)) {
				colKeys[idx] = jQuery(it).text();
			}
		});

		table.css('display', 'table');
		// add column map to each record and convert keys to lower case
		for (var i = params.records.length; i--;) {
			var record = params.records[i];
			colMaps[params.lookupId] = params.columnMap;
			for (var key in record) {
				var val = record[key];
				if (typeof(val) != 'object') {
					delete record[key];
					record[key.toLowerCase()] = val;
				}
			}
		}
		this.multiSelectLookups[params.lookupId] = {
			tableId: getId(params.tableId),
			tplRow: tplRow,
			max: params.max,
			columnKeys: colKeys,
			columnMap: colMaps[params.lookupId],
			records: params.records
		}
	}
	this.initMultiLookup = initMultiLookup;

	function addLookupRecord(lookupId, data) {
		var colMap = data.columnMap,
			lookup = this.multiSelectLookups[lookupId],
			idx;

		if (!lookup) {
			log('Could not add record, lookup not found: ' + lookupId);
			return;
		}
		
		if (!lookup.columnMap || lookup.columnMap == {}) {
			lookup.columnMap = {};
			for (key in colMap) {
				lookup.columnMap[key] = colMap[key];
			}
		}
		delete data.columnMap;
		idx = lookup.records.length;
		lookup.records[idx] = data;
		updateMultiSelectLookupValue(currentLookupId);
	}
	this.addLookupRecord = addLookupRecord;

    function removeLookupRecord(lookupId, el) {
    	var idx = parseInt(jQuery(el).attr('data-lookup-idx')),
    		lookup = this.multiSelectLookups[lookupId];

    	if (!lookup || !lookup.records) {
    		CS.log('Could not find valid lookup data for ID ' + lookupId, lookup);
    		return;
    	}

    	if (isNaN(idx)) {
    		CS.log('Could not parse lookup index (' + jQuery(el).attr('data-lookup-idx') + ')');
    		return;
    	}

    	if (lookup.records.length <= idx) {
    		CS.log('Lookup index out of bounds (' + idx + ' / ' + lookup.records.length + ')');
    		return;
    	}

    	lookup.records.remove(idx,idx);
    	updateMultiSelectLookupValue(lookupId);
    	updateMultiSelectLookupDisplay(lookupId);
    }
	this.removeLookupRecord = removeLookupRecord;

	function updateMultiSelectLookupValue(lookupId) {
       	var multiSelectLookup = CS.multiSelectLookups[lookupId],
			attrVal = '',
			sep = '';

		for (var i = 0; i < multiSelectLookup.records.length; i++) {
			var record = multiSelectLookup.records[i];
			
			if (record) {
			attrVal += sep + record.id;
			sep = ',';
		}
		}

		CS.setAttribute(lookupId, attrVal);
	}
	this.updateMultiSelectLookupValue = updateMultiSelectLookupValue;

	function updateMultiSelectLookupDisplay(lookupId) {
       	var multiSelectLookup = CS.multiSelectLookups[lookupId],
			tplRow = multiSelectLookup.tplRow,
			table = jQuery(multiSelectLookup.tableId),
			colNames = [];

		table.find('tr.dataRow').remove();

		if (multiSelectLookup.records.length > 0) {
			for (var k = multiSelectLookup.columnKeys.length; k--; ) {
				var colLabel = multiSelectLookup.columnKeys[k];
				colNames[k] = multiSelectLookup.columnMap[colLabel];
			}
		}

		for (var i = 0; i < multiSelectLookup.records.length; i++) {
			var newRow = tplRow.clone(),
				record = multiSelectLookup.records[i];

			if (record) {
			for (var k = colNames.length; k--; ) {
				var value = record[colNames[k]] || '';
				newRow.find('span[data-col-idx=' + k + ']').text(value);
			}
			newRow.find('span.name').text(record.name);
			newRow.find('a.delAction').attr('data-lookup-idx', i);
			if (i == 0) newRow.addClass('first');
			if (i == multiSelectLookup.records.length - 1) newRow.addClass('last');
			table.append(newRow);
		}
	}
	}
	this.updateMultiSelectLookupDisplay = updateMultiSelectLookupDisplay;

	function updateMultiSelectLookupsDisplay() {
		for (id in CS.multiSelectLookups) {
			updateMultiSelectLookupDisplay(id);
		}
	}
	this.updateMultiSelectLookupsDisplay = updateMultiSelectLookupsDisplay;
}

initCore.call(CS);




