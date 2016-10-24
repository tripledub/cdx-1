var PatientInputName = React.createClass({
  mixins: [React.addons.LinkedStateMixin],

  getInitialState: function() {
    return { inputValue: this.props.fieldValue || '' };
  },

  checkPatientName: function() {
    if ( this.linkState('inputValue').value.length > 3 ) {
      PatientSearchActions.searchPatients(this.linkState('inputValue').value, this.props.patientsSearchUrl);
    }
  },

  render: function(){
    return (
      <div className="row">
        <div className="fieldlabel">
          <LabelTooltip labelName="patient_name" labelValue={I18n.t("active_record.attributes.patient.name")} labelTooltip={I18n.t('components.patients.form.name_tooltip')} />
        </div>
        <div className="fieldvalue">
          <input className="input-large" onBlur={this.checkPatientName()} valueLink={this.linkState('inputValue')} type="text" name="patient[name]" id="patient_name" />
        </div>
      </div>
    );
  }
});
