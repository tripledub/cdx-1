var EncounterForm = React.createClass({
  getDefaultProps: function() {
    return {
      assayResultOptions: _.map(['positive', 'negative', 'indeterminate'], function(v){return {value: v, label: _.capitalize(v)};})
    }
  },

  getInitialState: function() {
    return {encounter: this.props.encounter};
  },

  save: function() {
    var callback = function() {
      window.location.href = '/encounters/' + this.state.encounter.id;
    };

    if (this.state.encounter.id) {
      this._ajax('PUT', '/encounters/' + this.state.encounter.id, callback);
    } else {
      this._ajax('POST', '/encounters', callback);
    }
  },

  showSamplesModal: function(event) {
    this.refs.samplesModal.show()
    event.preventDefault()
  },

  closeSamplesModal: function (event) {
    this.refs.samplesModal.hide();
    event.preventDefault();
  },

  _ajax_put: function(url, success) {
    this._ajax('PUT', url, success);
  },

  _ajax: function(method, url, success) {
    var _this = this;
    $.ajax({
      url: url,
      method: method,
      data: { encounter: JSON.stringify(this.state.encounter) },
      success: function (data) {
        if (data.status == 'error') {
          alert(data.message); //TODO show errors nicely
        }

        _this.setState(React.addons.update(_this.state, {
          encounter: { $set: data.encounter }
        }), function(){
          if (data.status == 'ok' && success) {
            success.call(_this);
          }
        });
      }
    });
  },

  appendSample: function(sample) {
    this.setState(React.addons.update(this.state, {
      encounter : { samples : {
        $push : [sample]
      }}
    }));
    this.refs.samplesModal.hide()
    this._ajax_put("/encounters/add/sample/" + sample.uuid);
  },

  showTestsModal: function(event) {
    this.refs.testsModal.show()
    event.preventDefault()
  },

  closeTestsModal: function(event) {
    this.refs.testsModal.hide()
    event.preventDefault()
  },

  appendTest: function(test) {
    this.setState(React.addons.update(this.state, {
      encounter : { test_results : {
        $push : [test]
      }}
    }));
    this.refs.testsModal.hide()
    this._ajax_put("/encounters/add/test/" + test.uuid);
  },

  encounterChanged: function(field){
    return function(event) {
      var newValue = event.target.value;
      this.setState(React.addons.update(this.state, {
        encounter : { [field] : { $set : newValue } }
      }));
    }.bind(this);
  },

  encounterAssayChanged: function(index, field){
    return function(event) {
      var newValue;

      if (field == 'result') {
        newValue = event;
      } else if (field == 'quantitative') {
        newValue = parseInt(event.target.value)
        if (isNaN(newValue)) {
          newValue = null;
        }
      } else {
        newValue = event.target.value;
      }

      this.setState(React.addons.update(this.state, {
        encounter : { assays : { [index] : { [field] : { $set : newValue } } } }
      }));
    }.bind(this);
  },

  render: function() {
    var institutionSelect = <InstitutionSelect onChange={this.setInstitution} url="/encounters/institutions"/>;

    if (this.state.encounter.institution == null)
      return (<div>{institutionSelect}</div>);

    var diagnosisEditor = null;

    if (this.state.encounter.assays.length > 0) {
      diagnosisEditor = (
        <div className="col assays-editor">
          {this.state.encounter.assays.map(function(assay, index){
            return (
              <div className="row" key={index}>
                <div className="col pe-4">
                  <div className="underline">
                    <span>{assay.condition.toUpperCase()}</span>
                  </div>
                </div>
                <div className="col pe-3">
                  <Select value={assay.result} options={this.props.assayResultOptions} onChange={this.encounterAssayChanged(index, 'result')} />
                </div>
                <div className="col pe-1">
                  <input type="text" className="quantitative" value={assay.quantitative} placeholder="Quant." onChange={this.encounterAssayChanged(index, 'quantitative')} />
                </div>
              </div>
            );
          }.bind(this))}

          <textarea value={this.state.encounter.observations} placeholder="Observations" onChange={this.encounterChanged('observations')} />
        </div>);
    } else {
      diagnosisEditor = (
        <div className="col">
          <i>
            <a href="#" onClick={this.showSamplesModal}>Add samples</a> or <a href="#" onClick={this.showTestsModal}>tests</a> to edit the diagnosis associated with the encounter
          </i>
        </div>);
    }


    return (
      <div>
        <FlexFullRow>
          <PatientCard patient={this.state.encounter.patient} />
        </FlexFullRow>

        <div className="row">
          <div className="col pe-2">
            <label>Diagnosis</label>
          </div>
          {diagnosisEditor}
        </div>

        <div className="row">
          <div className="col pe-2">
            <label>Samples</label>
            <p>
              <a className="btn-add btn-add-secondary" href='#' onClick={this.showSamplesModal}>+</a>
            </p>
          </div>
          <div className="col">
            <SamplesList samples={this.state.encounter.samples} />
          </div>
          <Modal ref="samplesModal">
            <h1>
              <a href="#" className="modal-back" onClick={this.closeSamplesModal}><img src="/assets/arrow-left.png"/></a>
              Add sample
            </h1>

            <AddItemSearch callback={"/encounters/search_sample?institution_uuid=" + this.state.encounter.institution.uuid} onItemChosen={this.appendSample}
              itemTemplate={AddItemSearchSampleTemplate}
              itemKey="uuid" />
          </Modal>
        </div>

        <div className="row">
          <div className="col">
            <TestResultsList testResults={this.state.encounter.test_results} /><br/>
            <a className="btn-add btn-add-secondary" href='#' onClick={this.showTestsModal}>+</a>
          </div>

          <Modal ref="testsModal">
            <h1>
              <a href="#" className="modal-back" onClick={this.closeTestsModal}><img src="/assets/arrow-left.png"/></a>
              Add test
            </h1>

            <AddItemSearch callback={"/encounters/search_test?institution_uuid=" + this.state.encounter.institution.uuid} onItemChosen={this.appendTest}
              itemTemplate={AddItemSearchTestResultTemplate}
              itemKey="uuid" />
          </Modal>
        </div>

        <FlexFullRow>
          <button type="button" className="btn-primary" onClick={this.save}>Save</button>
        </FlexFullRow>

      </div>
    );
  },

});
