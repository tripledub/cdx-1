var PatientResults = React.createClass({
  getInitialState: function() {
    return {
      patientResults: [],
      queryOrder: true
    };
  },

  getpatientResults: function(field, e) {
    if (e) { e.preventDefault(); }
    this.serverRequest = $.get(this.props.testResultsUrl + this.getParams(field), function (results) {
      this.setState({
        patientResults: results
      });
    }.bind(this));
  },

  getParams: function(field) {
    var orderField = field === 1 ? 'date' : 'name';
    this.state.queryOrder = !this.state.queryOrder;
    return '&field='+ orderField + '&order=' + this.state.queryOrder;
  },

  componentDidMount: function() {
    this.getpatientResults(1);
  },

  componentWillUnmount: function() {
    this.serverRequest.abort();
  },

  render: function(){
    var rows = [];
    this.state.patientResults.forEach(
      function(patientResult) {
        rows.push(<PatientResult patientResult={patientResult} key={patientResult.id} />);
      }
    );

    return (
      <div className="row">
        <table className="patient-results">
          <thead>
            <tr>
              <th>Name</th>
              <th>Status</th>
              <th>Date</th>
            </tr>
          </thead>
          <tbody>
            {rows}
          </tbody>
        </table>
      </div>
    );
  }
});
