'use strict';
'require form';
'require network';

network.registerPatternVirtual(/^zt-.+$/);

return network.registerProtocol('zerotier', {
	getI18n: function() {
		return _('ZeroTier');
	},

	getIfname: function() {
		return this._ubus('l3_device') || 'zt-%s'.format(this.sid);
	},

	getOpkgPackage: function() {
		return 'zerotier-one';
	},

	isFloating: function() {
		return true;
	},

	isVirtual: function() {
		return true;
	},

	getDevices: function() {
		return null;
	},

	containsDevice: function(ifname) {
		return (network.getIfnameOf(ifname) == this.getIfname());
	},

	renderFormOptions: function(s) {
		var o;

		o = s.taboption('general', form.Value, 'networkid', _('ZeroTier Network ID'));
		o.optional = false;

		o = s.taboption('general', form.Flag, 'allowmanaged', _('Allow Managed'));
		o.default = true;

		o = s.taboption('general', form.Flag, 'allowglobal', _('Allow Global'));

		o = s.taboption('general', form.Flag, 'allowdefault', _('Allow Default'));

		o = s.taboption('advanced', form.Value, 'mtu', _('Override MTU'), _('Specify an MTU (Maximum Transmission Unit) other than the default (2800 bytes).'));
		o.optional = true;
		o.placeholder = 2800;
		o.datatype = 'range(68, 9200)';
	}
});
