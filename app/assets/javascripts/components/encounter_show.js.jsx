var EncounterShow = React.createClass({
  getInitialState: function() {
    var user_email='';
    if (this.props.encounter["user"] != null) {
      user_email= this.props.encounter["user"].email
    };

    var disable_all_selects=false;
    if (this.props.show_cancel==true || this.props.show_edit==false) {
      disable_all_selects=true;
    }

    return {
      user_email: user_email,
      error_messages:[],
      requested_tests: this.props.requested_tests,
      disable_all_selects: disable_all_selects
    };
  },

  submit_error: function(errorArray) {
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
    EncounterActions.deleteEncounter(urlParam, successUrl, this.submit_error);
  },

  EncounterUpdateHandler: function() {
    if (this.props.referer != null) {
     successUrl = this.props.referer;
    } else {
     successUrl = '/test_orders';
    }

    if (this.props.requested_tests.length>0) {
      var urlParam = '/requested_tests';
      urlParam = urlParam + '/' + this.props.encounter.id;
      requested_tests = this.props.requested_tests;
      EncounterRequestTestActions.update(urlParam, requested_tests, successUrl, this.submit_error);
    } else {
      window.location.href = successUrl;
    }
  },

  onTestChanged: function(new_test) {
    var len = this.state.requested_tests.length;
    for (var i=0; i<len; i++) {
      if (this.state.requested_tests[i].id == new_test.id) {
        temp_requested_tests    = this.state.requested_tests;
        temp_requested_tests[i] = new_test;
        this.setState({
          requested_tests: temp_requested_tests
        });
      }
    }
  },

  render: function() {
    if (this.props.can_update && this.props.show_cancel) {
      actionButton = <EncounterDelete show_edit={true} onChangeParentLevel={this.EncounterDeleteHandler} encounter={this.props.encounter} />;
    } else if (this.props.can_update && this.props.show_edit) {
      actionButton = <EncounterUpdate onChangeParentLevel={this.EncounterUpdateHandler} />;
   } else {
      actionButton = <ShowNoButton />;
    }

    if (this.props.encounter.performing_site == null) {
      performing_site = "";
    } else {
      performing_site = this.props.encounter.performing_site.name;
    }
    return (
      <div>
        <div className="row">
         <div className="col pe-2">
           <FlashErrorMessages messages={this.state.error_messages} />
         </div>
        </div>

        <DisplayFieldWithLabel fieldLabel='Requested site:' fieldValue={ this.props.encounter.site.name } />
        <DisplayFieldWithLabel fieldLabel='Performing site:' fieldValue={ performing_site } />
        <DisplayFieldWithLabel fieldLabel='Order Id:' fieldValue={ this.props.encounter.uuid } />
        <DisplayFieldWithLabel fieldLabel='Testing for:' fieldValue={ this.props.encounter.testing_for } />
        {
          this.props.encounter.testing_for === 'TB' ?
          <DisplayFieldWithLabel fieldLabel='Culture format:' fieldValue={ this.props.encounter.culture_format } /> : null
        }
        <DisplayFieldWithLabel fieldLabel='Comment:' fieldValue={ this.props.encounter.diag_comment } />
        {
          this.props.encounter.exam_reason === 'diag' ?
          <DisplayFieldWithLabel fieldLabel='Weeks in treatment:' fieldValue={ this.props.encounter.treatment_weeks } /> : null
        }
        <DisplayFieldWithLabel fieldLabel='Samples Id:' fieldValue={ <SamplesList samples={this.props.encounter.samples}  /> } />
        <DisplayFieldWithLabel fieldLabel='Sample type:' fieldValue={ this.props.encounter.coll_sample_type } />
        <DisplayFieldWithLabel fieldLabel='Test due date:' fieldValue={ this.props.encounter.testdue_date } />
        <DisplayFieldWithLabel fieldLabel='Status:' fieldValue={ this.props.encounter.status } />

        <FlexFullRow>
          <PatientCard patient={this.props.encounter.patient} />
        </FlexFullRow>

        <div className="row">
          <RequestedTestsIndexTable encounter={this.props.encounter} requested_tests={this.state.requested_tests} requested_by={this.props.requested_by}
           status_types={this.props.status_types} edit={this.props.show_edit} onTestChanged={this.onTestChanged} associated_tests_to_results={this.props.associated_tests_to_results}/>
        </div>
        <br />
        <div className="row">
          <div className="col pe-2">
            {actionButton}
          </div>
        </div>
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
      <div><a className = "btn-secondary pull-right" onClick={this.clickHandler} id="update_encounter" href="#">Update Test Order</a></div>
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
  clickHandler: function() {
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
    if (this.state.displayConfirm==true) {
      return (
        <ConfirmationModalEncounter message= {'You are about to permanently cancel this test order. Are you sure you want to proceed?'} title= {'Cancel confirmation'} cancel_target= {this.cancelDeleteClickHandler} target= {this.confirmClickHandler} deletion= {true} hideCancel= {false} confirmMessage= {'Delete'} />
      );
    }
    else
    if (this.props.show_edit && (this.props.encounter.status != 'inprogress')) {
    return (
      <div>
        <a className = "btn-secondary pull-right" onClick={this.clickHandler} id="delete_encounter" href="#">Cancel Test Order</a>
     </div>
     );
    } else {
      return null;
    }
  }
});

var ConfirmationModalEncounter = React.createClass({
  modalTitle: function() {
    return this.props.title || (this.props.deletion ? "Cancel confirmation" : "Confirmation");
  },
  cancelMessage: function() {
   return this.props.cancelMessage || "Cancel";
  },
  confirmMessage: function() {
    return this.props.confirmMessage || (this.props.deletion ? "Cancel" : "Confirm");
  },
  componentDidMount: function() {
    this.refs.confirmationModal.show();
  },
  onCancel: function() {
   this.refs.confirmationModal.hide();
   if (this.props.target instanceof Function ) {
     this.props.cancel_target();
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
    message: function() {
      return {__html: this.props.message};
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
        <Modal ref="confirmationModal" show="true">
          <h1>{this.modalTitle()}</h1>
          <div className="modal-content" dangerouslySetInnerHTML={this.message()}>
          </div>
          <div className="modal-footer button-actions">
            <button type="button" className={this.confirmButtonClass()} onClick={this.onConfirm}>{this.confirmMessage()}</button>
            { cancelButton }
          </div>
        </Modal>
      );
    }
 });
