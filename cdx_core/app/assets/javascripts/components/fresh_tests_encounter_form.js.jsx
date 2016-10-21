var FreshTestsEncounterForm = React.createClass(_.merge({
  getDefaultProps: function() {
    return ({ sampleTestOptions: [ 'please_select', 'sputum', 'blood', 'other' ] });
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
    encounter[fieldName] = fieldValue;
    this.setState({ encounter: encounter });
  },

  validateAndSetManualEntry: function (event) {
    var sampleId    = React.findDOMNode(this.refs.manualSampleEntry).value;
    if (this.state.encounter.new_samples.filter(function(el){ return el.entity_id == sampleId }).length > 0) {
      // Error handling as done in the ajax responses
      alert(I18n.t("components.fresh_tests_encounter_form.alert_new_sample"));
    } else {
      this._ajax_put('/encounters/add/manual_sample_entry', function() {
        this.refs.addNewSamplesModal.hide();
      }, {entity_id: sampleId});
    }
    event.preventDefault();
  },

  validateThenSave: function(event)
  {
    if (this.state.encounter.performing_site == undefined) { alert(I18n.t("components.fresh_tests_encounter_form.alert_performing_site"));  return; }
    if (this.state.encounter.testing_for == undefined)     { alert(I18n.t("components.fresh_tests_encounter_form.alert_testing_for"));     return; }
    if (this.state.encounter.exam_reason == undefined)     { alert(I18n.t("components.fresh_tests_encounter_form.alert_exam_reason"));     return; }
    if (this.state.encounter.tests_requested == '')        { alert(I18n.t("components.fresh_tests_encounter_form.alert_tests_requested")); return; }
    if (this.state.encounter.new_samples == [])            { alert(I18n.t("components.fresh_tests_encounter_form.alert_add_samples"));     return; }
    if (this.state.encounter.coll_sample_type == '')       { alert(I18n.t("components.fresh_tests_encounter_form.alert_col_sample_type"));  return; }
    if ( (this.state.encounter.coll_sample_type == 'other') && (this.state.encounter.coll_sample_other == ''))       { alert(I18n.t("components.fresh_tests_encounter_form.alert_othercomment"));     return; }
    this.save();
  },

  render: function() {
    var show_auto_sample = '';
    var show_manual_sample = '';
    var cancelUrl = "javascript:history.back();";

    if (this.props.referer != null) {
      cancelUrl = this.props.referer;
    }

    if (this.props.allows_manual_entry == true) {
      show_auto_sample = "hidden";
      show_manual_sample = "";
    } else {
      show_auto_sample = "";
      show_manual_sample = "hidden";
    }

    return (
      <div className="newTestOrder">
        <div className="row labelHeader">
          <div className="col-6">
            <h3>{I18n.t("components.fresh_tests_encounter_form.test_order_details_heading")}</h3>
          </div>
          <div className="col-6">
          </div>
        </div>
        <div className="panel">
          <div className="row">
            <div className="col-6">
              <label>{I18n.t("components.fresh_tests_encounter_form.testing_for_label")}</label>
            </div>
            <div className="col-6">
              <label>
                <select className="input-large" id="testing_for" name="testing_for" onChange={this.testingForChange} datavalue={this.state.encounter.testing_for}>
                  <option value="">{I18n.t("components.fresh_tests_encounter_form.please_select_option")}</option>
                  <option value="TB">{I18n.t("components.fresh_tests_encounter_form.TB_option")}</option>
                  <option value="HIV">{I18n.t("components.fresh_tests_encounter_form.HIV_option")}</option>
                  <option value="Ebola">{I18n.t("components.fresh_tests_encounter_form.Ebola_option")}</option>
                </select>
              </label>
            </div>
          </div>
          <EncounterExaminationReason reasonClicked={ this.reasonClicked } encounter={ this.state.encounter } />
          { this.state.encounter.exam_reason === 'follow' ? <ReasonFollow treatmentDateChange={ this.updateEncounterField } defaultValue={ parseInt(this.state.encounter.treatment_weeks) } /> : null }
          { this.state.encounter.exam_reason === 'diag' ? <PresumptiveRR checked={ false } updatePresumptiveRR={ this.updateEncounterField } /> : null }
          <RequestedTests onChange={ this.updateEncounterField } />
          <EncounterSampleType onChange={ this.updateEncounterField } options={ this.props.sampleTestOptions } selectValue={ this.state.encounter.coll_sample_type } commentValue={ this.state.encounter.coll_sample_other } />
          <EncounterDueDate onChange={ this.updateEncounterField } defaultValue={ this.state.encounter.testdue_date } />
          <EncounterComment defaultValue={ this.state.encounter.diag_comment } diagCommentChange={ this.updateEncounterField } />
          <EncounterFooter cancelUrl ={ cancelUrl } validateThenSave={ this.validateThenSave } />
          <Modal ref="addNewSamplesModal">
            <h1>
              <a href="#" className="modal-back" onClick={this.closeAddNewSamplesModal}></a>
              {I18n.t("components.fresh_tests_encounter_form.add_sample")}
            </h1>
            <p><input type="text" className="input-block" placeholder={I18n.t("components.fresh_tests_encounter_form.sample_id_placeholder")} ref="manualSampleEntry"/></p>
            <p><button type="button" className="btn-primary pull-right" onClick={this.validateAndSetManualEntry}>OK</button></p>
          </Modal>
        </div>
      </div>
    );
  },

  testingForChange: function() {
    var testingFor = $('#testing_for').val();
    this.setState(React.addons.update(this.state, {
      encounter: {
        testing_for: {
          $set: testingFor
        }
      }
    }));

    $('.test_for_ebola').attr('checked', false).parent().hide();
    $('.test_for_tb').attr('checked', false).parent().hide();
    $('.test_for_hiv').attr('checked', false).parent().hide();

    switch(testingFor)
    {
      case 'TB':
        $('.test_for_tb').parent().show();
        break;
      case 'Ebola':
        $('.test_for_ebola').parent().show();
        break;
      case 'HIV':
        $('.test_for_hiv').parent().show();
        break;

      default:
        $('.test_for_tb').parent().show();
        $('.test_for_ebola').parent().show();
        $('.test_for_hiv').parent().show();
    }
  },

}, BaseEncounterForm));
