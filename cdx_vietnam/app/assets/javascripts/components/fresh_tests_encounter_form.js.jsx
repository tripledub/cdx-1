var FreshTestsEncounterForm = React.createClass(_.merge({
  getDefaultProps: function() {
    return ({ sampleTestOptions: [ 'please_select', 'sputum', 'other' ] });
  },

  componentDidMount: function() {
    $('.test_for_ebola').attr('checked', false).parent().hide();
    $('.test_for_tb').attr('checked', false).parent().hide();
    $('.test_for_hiv').attr('checked', false).parent().hide();
    $('.cformatIndented').hide();
  },

  reasonClicked: function(event) {
    $('.test_for_tb').attr('checked', false).parent().show();

    this.updateEncounterField('exam_reason', event.currentTarget.value);
  },

  updateEncounterField: function(fieldName, fieldValue) {
    let encounter = this.state.encounter;
    encounter['testing_for'] = 'TB' ;
    encounter['testdue_date'] = '2020-12-01';
    encounter[fieldName] = fieldValue;
    this.setState({ encounter: encounter });
  },

  validateThenSave: function(event)
  {
    if (this.state.encounter.performing_site == undefined) { alert(I18n.t("components.fresh_tests_encounter_form.alert_performing_site")); return; }
    if (this.state.encounter.testing_for == undefined)     { alert(I18n.t("components.fresh_tests_encounter_form.alert_testing_for"));     return; }
    if (this.state.encounter.exam_reason == undefined)     { alert(I18n.t("components.fresh_tests_encounter_form.alert_exam_reason"));     return; }
    if (this.state.encounter.tests_requested == '')        { alert(I18n.t("components.fresh_tests_encounter_form.alert_tests_requested")); return; }
    if (this.state.encounter.coll_sample_type == '')       { alert(I18n.t("components.fresh_tests_encounter_form.alert_col_sample_type"));  return; }
    if ( (this.state.encounter.coll_sample_type == 'other') && (this.state.encounter.coll_sample_other == ''))       { alert(I18n.t("components.fresh_tests_encounter_form.alert_othercomment"));     return; }
    this.save();
  },

  render: function() {
    var now = new Date();
    var day = ("0" + now.getDate()).slice(-2);
    var month = ("0" + (now.getMonth() + 1)).slice(-2);
    var today = now.getFullYear() + "-" + (month) + "-" + (day);
    var cancelUrl = "javascript:history.back();";

    if (this.props.referer != null) {
      cancelUrl = this.props.referer;
    }

    return (
      <div className="newTestOrder">
        <EncounterHeader headerTitle={ I18n.t("components.fresh_tests_encounter_form.test_order_details_heading") } />
        <div className="panel">
          <EncounterTestingFor />
          <EncounterExaminationReason reasonClicked={ this.reasonClicked } encounter={ this.state.encounter } />

          { this.state.encounter.exam_reason === 'follow' ? <ReasonFollow treatmentDateChange={ this.updateEncounterField } defaultValue={ this.state.encounter.treatment_weeks }/> : null }
          { this.state.encounter.exam_reason === 'diag' ? <PresumptiveRR updatePresumptiveRR={ this.updateEncounterField } /> : null }

          <RequestedTests onChange={ this.updateEncounterField } />

          <EncounterSampleType onChange={ this.updateEncounterField } options={ this.props.sampleTestOptions } selectValue={ this.state.encounter.coll_sample_type } commentValue={ this.state.encounter.coll_sample_other } />

          <input type="hidden" name="testdue_date" value="2020-12-01" />

          <EncounterFooter cancelUrl ={ cancelUrl } validateThenSave={ this.validateThenSave } />
        </div>
      </div>
    );
  },
}, BaseEncounterForm));
