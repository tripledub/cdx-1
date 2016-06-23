var PatientSearchActions = Reflux.createActions([
  'searchPatients'
]);

var PatientSearchStore = Reflux.createStore({

  listenables: PatientSearchActions,

  searchPatients: function(patientName) {
    this.trigger(patientName);
  }
});

var PatientNameSearchResults = React.createClass({
  mixins: [Reflux.listenTo(PatientSearchStore, "onStatusChange")],

  getInitialState: function() {
    return { searchResults: [] };
  },

  onStatusChange: function(patientName) {
    var that = this;
    // sanitize patientName
    console.log(patientName);
    $.get(this.props.patientsSearchUrl + '&q=' + patientName, function (results) {
      console.log(results);
      that.setState({ searchResults: results });
    });
  },

  render: function(){
    var rows = [];
    this.state.searchResults.forEach(
      function(searchResult) {
        rows.push(<PatientNameSearchResult patientNameSearchResult={searchResult} key={searchResult.id} />);
      }
    );
    return (
      <table className="patient-name-duplicates">
        <caption>Patients with same name.</caption>
        <thead>
          <tr>
            <th>Name</th>
            <th>Gender</th>
            <th>Birth date</th>
          </tr>
        </thead>
        <tbody>
          {rows}
        </tbody>
      </table>
    );
  }
});

var PatientNameSearchResult = React.createClass({
  navigateTo: function (toUrl) {
    window.location = toUrl;
  },

  render: function(){
    return (
      <tr onClick={this.navigateTo.bind(this, this.props.patientNameSearchResult.viewLink)}>
        <td>{this.props.patientNameSearchResult.name}</td>
        <td>{this.props.patientNameSearchResult.gender}</td>
        <td>{this.props.patientNameSearchResult.dob}</td>
      </tr>
    );
  }
});
