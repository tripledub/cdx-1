var SocialSecurityCode = React.createClass({
  mixins: [React.addons.LinkedStateMixin],

  getInitialState: function() {
    return { inputValue: this.props.fieldValue || '' };
  },

  invalidValue: function(ssdValue) {
    return ((ssdValue.length > 0) && ((ssdValue.length < 9 ) || (ssdValue.length > 15 )));
  },

  validateSocialSecurityCode: function() {
    if (this.invalidValue(this.linkState('inputValue').value.trim())) {
      if (confirm(I18n.t("patients.form.wrong_social_security_number"))) {
        //
      } else {
        this.refs.ssnInput.getDOMNode().focus();
      };
    }
  },

  render: function(){
    return (
      <div className="fieldrow#cmnd">
        <div className="fieldlabel">
          <LabelTooltip labelName="patient_social_security_code" labelValue={I18n.t("patients.form.social_security_code")} labelTooltip={I18n.t('patients.form.social_security_code_tooltip')} />
        </div>
        <div className="fieldvalue">
          <input className="input-large" ref="ssnInput" onBlur={this.validateSocialSecurityCode} valueLink={this.linkState('inputValue')} type="text" name="patient[social_security_code]" id="patient_social_security_code" />
        </div>
      </div>
    );
  }
});
