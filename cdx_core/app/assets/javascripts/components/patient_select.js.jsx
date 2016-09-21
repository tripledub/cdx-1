var PatientSelect = React.createClass({
  getInitialState: function() {
    return { patient : this.props.patient };
  },

  getDefaultProps: function() {
    return {
      className: "input-large",
      placeholder: I18n.t("components.patient_select.search_patient_placeholder"),
      onPatientChanged: null,
      onError: null
    };
  },

  render: function() {
    return (
    <div className="row">
      <div className="col-6">
        <label>{I18n.t("components.patient_select.patient_lable")}</label>
      </div>
      <div className="col-6">

        <label style={{ display: "none" }}>disableautocomplete</label>
        <Select
          value={this.state.patient}
          className="input-xx-large patients"
          placeholder={this.props.placeholder}
          clearable={false}
          asyncOptions={this.search}
          autoload={false}
          onChange={this.onPatientChanged}
          optionRenderer={this.renderOption}
          valueRenderer={this.renderValue}
          valueKey='id'
          cacheAsyncResults={false}
          filterOptions={this.filterOptions}>
        </Select>

        {(function(){
          if (this.state.patient == null) {
            return <a className="btn-add-link" href={"/patients/new?" + $.param({next_url: window.location.href})} title={I18n.t("components.patient_select.create_new_patient_title")}><span className="icon-circle-plus icon-blue"></span></a>;
          }
        }.bind(this))()}

        <br/>
        <br/>

        {(function(){
          if (this.state.patient != null) {
            return <PatientCard patient={this.state.patient} canEdit={true} />;
          }
        }.bind(this))()}

      </div>
    </div>);
  },

  // private

  onPatientChanged: function(newValue, selection) {
    var patient = (selection && selection[0]) ? selection[0] : null;
    this.setState(
      function(state) {
        return React.addons.update(state, {
          patient: { $set : patient }
        })
      }
      , function() {
        if (this.props.onPatientChanged) {
          this.props.onPatientChanged(patient);
        }
      }.bind(this));
    },

  search: function(value, callback) {
    $.ajax({
      url: '/patients/search',
      data: { context: this.props.context.uuid, q: value },
      success: function(patients) {
        callback(null, {options: patients, complete: false});
        if (patients.length == 0 && this.props.onError) {
          this.props.onError(I18n.t("components.patient_select.no_patient_found"));
        }
      }.bind(this)
    });
  },

  renderOption: function(option) {
    return (<span key={option.id}>
      {option.name} ({option.age || "n/a"}) {option.entity_id}
    </span>);
  },

  renderValue: function(option) {
    return option.name;
  },

  filterOptions: function(options, filterValue, exclude) {
    return options || [];
  },
});
