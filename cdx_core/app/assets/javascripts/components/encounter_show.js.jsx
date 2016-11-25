var EncounterShow = React.createClass({
  getInitialState: function() {
    var user_email='';
    if (this.props.encounter["user"] != null) {
      user_email= this.props.encounter["user"].email
    };

    var disable_all_selects=false;
    if (this.props.showCancel==true || this.props.showEdit==false) {
      disable_all_selects=true;
    }
    return {
      user_email: user_email,
      error_messages:[],
      requestedTests: this.props.requestedTests,
      disable_all_selects: disable_all_selects,
      testOrderStatus: this.props.encounter.status,
    };
  },

  onUpdateStatus: function(updatedStatus) {
    this.setState({ testOrderStatus: updatedStatus['testOrderStatus'] });
  },

  componentDidMount: function() {
    this.unsubscribe = TestBatchStore.listen(this.onUpdateStatus);
  },

  componentWillUnmount: function() {
    this.unsubscribe();
  },

  render: function() {
    if (this.props.encounter.performing_site == null) {
      performing_site = "";
    } else {
      performing_site = this.props.encounter.performing_site.name;
    }

    if (this.props.encounter.coll_sample_type == "other") {
      sample_type = this.props.encounter.coll_sample_other;
    } else {
      sample_type = this.props.encounter.coll_sample_type;
    }

    if (this.props.encounter.exam_reason == "diag") {
      examreason = "Diagnosis";
    } else {
      examreason = "Follow-Up";
    }

    return (
      <div className="testflow">
        <div className="row errorMsg">
         <div className="col pe-2">
           <FlashErrorMessages messages={this.state.error_messages} />
         </div>
        </div>
        <div className="row labelHeader">
          <div className="col-6">
            <h3>{I18n.t("components.encounter_show.site_detail_heading")}</h3>
          </div>
          <div className="col-6">
          </div>
        </div>
        <div className="newTestOrder">
          <div className="panel">
            <DisplayFieldWithLabel fieldLabel={I18n.t("components.encounter_show.requesting_site_label")} fieldValue={ this.props.encounter.site.name } />
            <DisplayFieldWithLabel fieldLabel={I18n.t("components.encounter_show.performing_site_label")} fieldValue={ performing_site } />
          </div>
        </div>
        <div className="row labelHeader">
          <div className="col-6">
            <h3>{I18n.t("components.encounter_show.test_detail_heading")}</h3>
          </div>
          <div className="col-6">
          </div>
        </div>
        <div className="newTestOrder">
          <div className="panel">
            <div className="row collapse">
              <div className="col-6">
                <DisplayFieldWithLabel fieldLabel={ I18n.t("components.encounter_show.order_id_label") }    fieldValue={ this.props.encounter.batch_id } />
                <DisplayFieldWithLabel fieldLabel={ I18n.t("components.encounter_show.reason_exam_label") }    fieldValue={ examreason } />
                <DisplayFieldWithLabel fieldLabel={ I18n.t("components.encounter_show.testing_for_label") } fieldValue={ this.props.encounter.testing_for } />
                {
                  this.props.encounter.testing_for === 'TB' ?
                  this.props.encounter.culture_format != '' ?
                  <DisplayFieldWithLabel fieldLabel={ I18n.t("components.encounter_show.culture_format_label") } fieldValue={ this.props.encounter.culture_format } />
                  : null
                  : null
                }
                <DisplayFieldWithLabel fieldLabel={I18n.t("components.encounter_show.testing_for_comment_label") } fieldValue={ this.props.encounter.diag_comment } />
                {
                  this.props.encounter.exam_reason === 'follow' ?
                  <DisplayFieldWithLabel fieldLabel={ I18n.t("components.encounter_show.weeks_in_treatment_label") } fieldValue={ this.props.encounter.treatment_weeks } />
                  : null
                }
                {
                  this.props.encounter.presumptive_rr ?
                  <DisplayFieldWithLabel fieldLabel={ I18n.t("components.encounter_show.presumptive") } fieldValue={ this.props.encounter.presumptive_rr ? I18n.t('views.say_yes') : I18n.t('views.say_no') } />
                  : null
                }
                {
                  this.props.showEdit ?
                  <DisplayFieldWithLabel fieldLabel={ I18n.t("components.encounter_show.samples_id_label") }   fieldValue={ <LabSamplesList context={this.props.context} samples={this.props.encounter.samples}  /> } /> : null
                }

                <DisplayFieldWithLabel fieldLabel={ I18n.t("components.encounter_show.sample_type_label") }   fieldValue={ sample_type } />
                <div class="row">
                  <div class="col pe-4">
                    <DisplayFieldWithLabel fieldLabel={ I18n.t("components.encounter_show.samples_id_label")  }   fieldValue={ this.props.encounter.sampleIds }  />
                  </div>
                  { this.props.encounter.sampleIds ? <PrintSampleIdButton /> : null }
                </div>
                <DisplayFieldWithLabel fieldLabel={ I18n.t("components.encounter_show.test_due_date_label") } fieldValue={ this.props.encounter.testdue_date } />
                <DisplayFieldWithLabel fieldLabel={ I18n.t("components.encounter_show.status_label") } fieldValue={ I18n.t('components.test_order.' + this.state.testOrderStatus) } />
                <DisplayFieldWithLabel fieldLabel={ I18n.t("components.encounter_show.comment_label") } fieldValue={ this.props.encounter.comment } />
              </div>

              <div className="col-6 patientCard">
                <FlexFullRow>
                  <PatientCard patient={this.props.encounter.patient} />
                </FlexFullRow>
              </div>
            </div>

          </div>
        </div>

        <TestBatchList encounter={ this.props.encounter } manualSampleId={ this.props.manualSampleId } testOrderStatus={ this.state.testOrderStatus } patientResults={ this.props.patientResults } encounterRoutes={ this.props.encounterRoutes } rejectReasons={ this.props.rejectReasons } authenticityToken={ this.props.authenticityToken } />

      </div>
      );
    },
  });
