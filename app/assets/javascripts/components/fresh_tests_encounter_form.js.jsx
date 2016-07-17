var FreshTestsEncounterForm = React.createClass(_.merge({
  componentDidMount: function() {
    $('#sample_other').hide();
    $('.test_for_ebola').attr('checked', false).parent().hide();
    $('.test_for_tb').attr('checked', false).parent().hide();
    $('.test_for_hiv').attr('checked', false).parent().hide();
  },

  reasonClicked: function(clk) {
    var foo = '';

    if (clk === 0) { foo = 'diag'; }

    if (clk === 1) { foo = 'follow'; }

    this.setState(React.addons.update(this.state, {
      encounter: {
        exam_reason: {
          $set: foo
        }
      }
    }));
  },

  validateAndSetManualEntry: function (event) {
    var sampleId = React.findDOMNode(this.refs.manualSampleEntry).value;
    if (this.state.encounter.new_samples.filter(function(el){return el.entity_id == sampleId}).length > 0) {
      // Error handling as done in the ajax responses
      alert("This sample has already been added");
    } else {
      this._ajax_put('/encounters/add/manual_sample_entry', function() {
        this.refs.addNewSamplesModal.hide();
      }, {entity_id: sampleId});
    }
    event.preventDefault();
  },

  render: function() {
    var now = new Date();
    var day = ("0" + now.getDate()).slice(-2);
    var month = ("0" + (now.getMonth() + 1)).slice(-2);
    var today = now.getFullYear() + "-" + (month) + "-" + (day);
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
            <h3>Test Order Details</h3>
          </div>
          <div className="col-6">
          </div>
        </div>
        <div className="panel">
          <div className="row">
            <div className="col-6">
              <label>Testing For</label>
            </div>
            <div className="col-6">
              <label>
                <select className="input-large" id="testing_for" name="testing_for" onChange={this.testingForChange} datavalue={this.state.encounter.testing_for}>
                  <option value="">Please Select...</option>
                  <option value="TB">TB</option>
                  <option value="HIV">HIV</option>
                  <option value="Ebola">Ebola</option>
                </select>
              </label>
            </div>
          </div>

          <div className="row">
            <div className="col-6">
              <label>Reason for Examination</label>
            </div>
            <div className="col-6">
              <input type="radio" onChange={this.reasonClicked.bind(this, 0)} checked={this.state.encounter.exam_reason == 'diag'} name="exam_reason" id="exam_reason_diag" value="diag"/>
              <label htmlFor="exam_reason_diag">Diagnosis</label>
              <input type="radio" onChange={this.reasonClicked.bind(this, 1)} checked={this.state.encounter.exam_reason == 'follow'} name="exam_reason" id="exam_reason_follow" value="follow"/>
              <label htmlFor="exam_reason_follow">Follow-Up</label>
            </div>
          </div>

          <div className="row">
            <div className="col-6">
              <label>Samples</label>
            </div>
            <div className="col-6">
              <SamplesList samples={this.state.encounter.samples}  />
              <NewSamplesList samples={this.state.encounter.new_samples} onRemoveSample={this.removeNewSample}/>
              <p className={show_auto_sample}>
                <a className="btn-add-link" href='#' onClick={this.addNewSamples}>
                  <span className="icon-circle-plus icon-blue"></span>
                  Add sample
                </a>
              </p>
              <p className={show_manual_sample}><input type="text" size="54" placeholder="Sample ID" ref="manualSampleEntry" />&nbsp;
              <button type="button" className="btn-primary" onClick={this.validateAndSetManualEntry}>Add</button></p>
            </div>
          </div>

          <div className="row">
            <div className="col-6">
              <label>Tests Requested</label>
            </div>
            <div className="col-6 req_tests_checks">
              <ul>
                <li><input type="checkbox" onChange={this.reqtests_change} name="microscopy" className="test_for_tb" id="requested_microscopy"/>
                  <label htmlFor="requested_microscopy">Microscopy</label>
                </li>
                <li><input type="checkbox" onChange={this.reqtests_change} name="xpertmtb" className="test_for_tb" id="requested_xpertmtb"/>
                  <label htmlFor="requested_xpertmtb">Xpert MTB/RIF</label>
                </li>
                <li><input type="checkbox" onChange={this.reqtests_change} name="culture" className="test_for_tb" id="requested_culture"/>
                  <label htmlFor="requested_culture">Culture</label>
                </li>
                <li><input type="checkbox" onChange={this.reqtests_change} name="drugsusceptibility" className="test_for_tb" id="requested_drug_susceptibility"/>
                   <label htmlFor="requested_drug_susceptibility">Drug susceptibility</label>
                 </li>
                <li><input type="checkbox" onChange={this.reqtests_change} name="dst" className="test_for_tb" id="requested_dst"/>
                  <label htmlFor="requested_dst">DST</label>
                </li>
                <li><input type="checkbox" onChange={this.reqtests_change} name="lineprobe" className="test_for_tb" id="requested_lineprobe"/>
                  <label htmlFor="requested_lineprobe">Line probe assay</label>
                </li>
                <li><input type="checkbox" onChange={this.reqtests_change} name="cd4" className="test_for_hiv" id="requested_cd4"/>
                  <label htmlFor="requested_cd4">CD4 Count</label>
                </li>
                <li><input type="checkbox" onChange={this.reqtests_change} name="viral" className="test_for_hiv" id="requested_viral"/>
                  <label htmlFor="requested_viral">Viral Load Count</label>
                </li>
                <li><input type="checkbox" onChange={this.reqtests_change} name="hiv" className="test_for_hiv" id="requested_hiv"/>
                  <label htmlFor="requested_hiv">HIV 1/2 Detect</label>
                </li>
                <li><input type="checkbox" onChange={this.reqtests_change} name="rdt" className="test_for_hiv" id="requested_rdt"/>
                  <label htmlFor="requested_rdt">RDT</label>
                </li>
                <li><input type="checkbox" onChange={this.reqtests_change} name="xpertebola" className="test_for_ebola" id="requested_xpertebola"/>
                  <label htmlFor="requested_xpertebola">Xpert Ebola</label>
                </li>
              </ul>
            </div>
          </div>

          { this.state.encounter.exam_reason === 'follow' ? <ReasonFollow treatmentDateChange={this.treatmentDateChange} /> : null }


          <div className="row">
            <div className="col-6">
              <label>Collection Sample Type</label>
            </div>
            <div className="col-6">
              <label>
                <select className="input-large" id="coll_sample_type" name="coll_sample_type" onChange={this.sample_type_change} datavalue={this.state.encounter.coll_sample_type}>
                  <option value="">Please Select...</option>
                  <option value="sputum">Sputum</option>
                  <option value="blood">Blood</option>
                  <option value="other">Other - Please Specify</option>
                </select>
              </label>
            </div>
          </div>

          <div className="row">
            <div className="col-6">
              &nbsp;
            </div>
            <div className="col-6">
              <textarea name="sample_other" id="sample_other" onChange={this.sample_other_change}></textarea>
            </div>
          </div>

          <div className="row">
            <div className="col-6">
              <label>Test Due Date</label>
            </div>
            <div className="col-6">
              <input type="date" id="testdue_date" min={today} onChange={this.testDueDateChange} value={this.state.encounter.testdue_date}/>
            </div>
          </div>

          { this.state.encounter.exam_reason === 'diag' ? <ReasonDiag diagCommentChange={this.diagCommentChange} /> : null }

          <div className="row labelfooter">
            <div className="col-12">
              <ul>
                <li>
                  <a href="#" id="encountersave" className="button save" onClick={this.save}>Save</a>
                </li>
                <li>
                  <a href={cancelUrl} className="button cancel">Cancel</a>
                </li>
              </ul>
            </div>
          </div>

          <Modal ref="addNewSamplesModal">
            <h1>
              <a href="#" className="modal-back" onClick={this.closeAddNewSamplesModal}></a>
              Add sample
            </h1>

            <p><input type="text" className="input-block" placeholder="Sample ID" ref="manualSampleEntry"/></p>
            <p><button type="button" className="btn-primary pull-right" onClick={this.validateAndSetManualEntry}>OK</button></p>
          </Modal>
        </div>
      </div>
    );
  },

  getInitialState: function() {
    $('.if_reason_diag').hide();
    $('.if_reason_follow').hide();
    $('#sample_other').hide();
  },

  checkme: function(what) {
    if (this.state.encounter.tests_requested.indexOf(what) != false)
      return 'selected ';
    return '';
  },

  tests_list: function() {
    var tests = [];
    tests['microscopy'] = 'Microscopy';
    tests['xpert'] = 'Xpert MTB/RIF';
    tests['culture'] = 'Culture';
    tests['drugsusceptibility'] = 'Culture Drug susceptibility';
    tests['lineprobe'] = 'Line probe assay';
    tests['cd4'] = 'CD4 Count';
    tests['viral'] = 'Viral Load Count';
    tests['hiv'] = 'HIV 1/2 Detect';
    var tout = '';
    for (var i in tests) {
      tout += '<li><input type="checkbox" onChange={this.reqtests_change} name="';
      tout += i;
      tout += '" ';
      if (this.state.encounter.tests_requested.indexOf(i) != false)
        tout += 'selected ';
      tout += 'id="requested_';
      tout += i;
      tout += '"/><label htmlFor="requested_';
      tout += i;
      tout += '">';
      tout += tests[i];
      tout += '</label></li>';
    }
    return {__html: tout};
  },

  reqtests_change: function() {
    reqtests = '';
    $('.req_tests_checks input:checked').each(function(dd) {
      reqtests += $(this).attr('name') + '|';
    });
    this.setState(React.addons.update(this.state, {
      encounter: {
        tests_requested: {
          $set: reqtests
        }
      }
    }));
  },

  diagCommentChange: function() {
    var comment = $('#diag_comment').val();
    this.setState(React.addons.update(this.state, {
      encounter: {
        diag_comment: {
          $set: comment
        }
      }
    }));
  },

  treatmentDateChange: function() {
    var treatmentdate = $('#treatment_weeks').val();
    this.setState(React.addons.update(this.state, {
      encounter: {
        treatment_weeks: {
          $set: treatmentdate
        }
      }
    }));
  },

  testDueDateChange: function() {
    var testduedate = $('#testdue_date').val();
    this.setState(React.addons.update(this.state, {
      encounter: {
        testdue_date: {
          $set: testduedate
        }
      }
    }));
    this.state.encounter.testdue_date = testduedate;
  },

  testingForChange: function() {
    var xx = $('#testing_for').val();
    this.setState(React.addons.update(this.state, {
      encounter: {
        testing_for: {
          $set: xx
        }
      }
    }));

    $('.test_for_ebola').attr('checked', false).parent().hide();
    $('.test_for_tb').attr('checked', false).parent().hide();
    $('.test_for_hiv').attr('checked', false).parent().hide();
    switch(xx)
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

  sample_type_change: function() {
    var xx = $('#coll_sample_type').val();
    if (xx == 'other')
      $('#sample_other').show();
    else
      $('#sample_other').hide();
    this.setState(React.addons.update(this.state, {
      encounter: {
        coll_sample_type: {
          $set: xx
        }
      }
    }));
  },

  sample_other_change: function() {
    var xx = $('#sample_other').val();
    this.setState(React.addons.update(this.state, {
      encounter: {
        coll_sample_other: {
          $set: xx
        }
      }
    }));
  }

}, BaseEncounterForm));

var ReasonDiag = React.createClass({
  updateComment: function (e) {
    this.props.diagCommentChange();
  },

  render: function() {
    return (
      <div className="row">
        <div className="col-6">
          <label>Comment</label>
        </div>
        <div className="col-6">
          <textarea name="diag_comment" id="diag_comment" rows="5" cols="60" onChange={this.updateComment}></textarea>
        </div>
      </div>
    );
  }
});

var ReasonFollow = React.createClass({
  updateWeeks: function (e) {
    this.props.treatmentDateChange();
  },

  render: function() {
    return (
      <div className="row if_reason_follow">
        <div className="col-6">
          <label>Weeks in Treatment</label>
        </div>
        <div className="col-6">
          <input type="number" min="0" max="52" onChange={this.updateWeeks} id="treatment_weeks" name="treatment_weeks"/>
        </div>
      </div>
    );
  }
});
