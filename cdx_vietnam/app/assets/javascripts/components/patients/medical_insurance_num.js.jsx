var MedicalInsuranceNum = React.createClass({
  mixins: [React.addons.LinkedStateMixin],

  getInitialState: function() {
    return {
      inputValue: this.props.fieldValue || ''
    };
  },

  invalidValue: function(fieldValue) {
    var matches = fieldValue.match(/^[a-zA-Z]{2}[0-9]{13}$/iug);
    return !(matches && !matches.length);
  },

  validateMedicalInsuranceNum: function() {
    var inputValue = this.linkState('inputValue').value.trim();
    if (inputValue.length && this.invalidValue(inputValue)) {
      if (!confirm(I18n.t("patients.form.wrong_medical_insurance_num"))) {
        this.setState({ inputValue: '' });
      }
    }
  },

  render: function(){
    return (
      <div className="fieldrow#pmis">
        <div className="fieldlabel">
          <LabelTooltip labelName="patient_medical_insurance_num" labelValue={ I18n.t("activerecord.attributes.patient.medical_insurance_num") } labelTooltip={ I18n.t('patients.form.medical_insurance_num_tooltip') } />
        </div>
        <div className="fieldvalue">
          <input className="input-large" onBlur={ this.validateMedicalInsuranceNum } valueLink={ this.linkState('inputValue') } type="text" name="patient[medical_insurance_num]" id="patient_medical_insurance_num" />
        </div>
      </div>
    );
  }
});
