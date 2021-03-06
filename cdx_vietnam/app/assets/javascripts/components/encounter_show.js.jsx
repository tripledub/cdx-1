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

  submitError: function(errorArray) {
    this.setState({
      error_messages: errorArray
    });
    $('body').scrollTop(0);
  },

  EncounterDeleteHandler: function() {
    if (this.props.referer != null) {
      successUrl = this.props.referer;
    } else {
      successUrl = '/test_orders';
    }

    var  urlParam = this.props.encounter.id
    EncounterActions.deleteEncounter(urlParam, successUrl, this.submitError);
  },

  render: function() {
    if (this.props.can_update && this.props.showCancel) {
      actionButton = <EncounterDelete showEdit={true} onChangeParentLevel={this.EncounterDeleteHandler} encounter={this.props.encounter} />;
    } else if (this.props.can_update && this.props.showEdit) {
      actionButton = <EncounterUpdate onChangeParentLevel={this.EncounterUpdateHandler} />;
    } else {
      actionButton = <ShowNoButton />;
    }

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
                <DisplayFieldWithLabel fieldLabel={I18n.t("components.encounter_show.order_id_label")}    fieldValue={ this.props.encounter.batch_id } />
                <DisplayFieldWithLabel fieldLabel={I18n.t("components.encounter_show.reason_exam_label")}    fieldValue={ examreason } />
                <DisplayFieldWithLabel fieldLabel={I18n.t("components.encounter_show.testing_for_label")} fieldValue={ this.props.encounter.testing_for } />
                {
                  this.props.encounter.testing_for === 'TB' ?
                  this.props.encounter.culture_format != '' ?
                  <DisplayFieldWithLabel fieldLabel={I18n.t("components.encounter_show.culture_format_label")} fieldValue={ this.props.encounter.culture_format } />
                  : null
                  : null
                }
                <DisplayFieldWithLabel fieldLabel={ I18n.t("components.encounter_show.testing_for_comment_label") } fieldValue={ this.props.encounter.diag_comment } />
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
                <DisplayFieldWithLabel fieldLabel={ I18n.t("components.encounter_show.sample_type_label") } fieldValue={ sample_type } />
                <div className="row">
                  <div className="col pe-5">
                    <DisplayFieldWithLabel fieldLabel={ I18n.t("components.encounter_show.samples_id_label")  }   fieldValue={ this.props.encounter.sampleIds }  />
                  </div>
                  { this.props.encounter.sampleIds ? <PrintSampleIdButton /> : null }
                </div>
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


var EncounterUpdate = React.createClass({
  clickHandler: function() {
    this.props.onChangeParentLevel();
  },

  render: function() {
    return(
      <div><a className="btn-secondary" onClick={this.clickHandler} id="update_encounter" href="#">{I18n.t("components.encounter_show.update_btn")}</a></div>
    );
  }
});

var ShowNoButton = React.createClass({
  render: function() {
    return(
      <div></div>
     );
    }
});

var EncounterDelete = React.createClass({
  getInitialState: function() {
    return {
      displayConfirm: false
    };
  },

  clickHandler: function(e) {
    e.preventDefault()
    this.setState({
      displayConfirm: true
    });
  },

  cancelDeleteClickHandler: function() {
    this.setState({
      displayConfirm: false
    });
  },

  confirmClickHandler: function() {
    this.props.onChangeParentLevel();
  },

  render: function() {
    if (this.state.displayConfirm == true) {
      return (
        <ConfirmationModalEncounter message= {I18n.t("components.encounter_show.cancel_confirm_msg")} title= {I18n.t("components.encounter_show.cancel_confirm_title")} cancelTarget= {this.cancelDeleteClickHandler} target={this.confirmClickHandler} hideOuterEvent={this.cancelDeleteClickHandler} deletion= {true} hideCancel= {false} confirmMessage= {I18n.t("components.encounter_show.delete_btn")} />
      );
    }
    else if (this.props.showEdit && (this.props.encounter.status != 'inprogress')) {
      return (
        <div>
          <a className = "btn-secondary pull-right" onClick={this.clickHandler} id="delete_encounter" href="#">{I18n.t("components.encounter_show.cancel_test_order_btn")}</a>
        </div>
      );
    } else {
      return null;
    }
  }
});

var ConfirmationModalEncounter = React.createClass({
  modalTitle: function() {
    return this.props.title || (this.props.deletion ? I18n.t("components.encounter_show.cancel_confirmation_btn") : I18n.t("components.encounter_show.confirmation_btn"));
  },

  cancelMessage: function() {
   return this.props.cancelMessage || I18n.t("components.encounter_show.cancel_btn");
  },

  confirmMessage: function() {
    return this.props.confirmMessage || (this.props.deletion ? I18n.t("components.encounter_show.cancel_btn") : I18n.t("components.encounter_show.confirm_btn"));
  },

  componentDidMount: function() {
    this.refs.confirmationModal.show();
  },

  onCancel: function() {
    this.refs.confirmationModal.hide();
    if (this.props.target instanceof Function ) {
     this.props.cancelTarget();
    }
  },

  onConfirm: function() {
    if (this.props.target instanceof Function ) {
     this.props.target();
    } else {
    window[this.props.target]();
    }
    this.refs.confirmationModal.hide();
  },

  hideOuterEvent: function() {
    this.props.hideOuterEvent();
  },

  confirmButtonClass: function() {
    return this.props.deletion ? "btn-primary btn-danger" : "btn-primary";
  },

  showCancelButton: function() {
    return this.props.hideCancel != true;
  },

  render: function() {
    var cancelButton = null;
    if (this.showCancelButton()) {
      cancelButton = <button type="button" className="btn-link" onClick={this.onCancel}>{this.cancelMessage()}</button>
    }

    return (
      <Modal ref="confirmationModal" show="true" hideOuterEvent={this.hideOuterEvent}>
        <h1>{this.modalTitle()}</h1>
        <div className="modal-content">
          {this.props.message}
        </div>

        <div className="modal-footer button-actions">
          <button type="button" className={this.confirmButtonClass()} onClick={this.onConfirm}>{this.confirmMessage()}</button>
          { cancelButton }
        </div>
      </Modal>
    );
  }
 });
