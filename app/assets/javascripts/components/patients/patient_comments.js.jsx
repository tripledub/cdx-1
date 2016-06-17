var PatientComments = React.createClass({
  getInitialState: function() {
    return {
      patientComments: []
    };
  },

  componentDidMount: function() {
    this.serverRequest = $.get(this.props.commentsUrl, function (results) {
      this.setState({
        patientComments: results
      });
    }.bind(this));
  },

  componentWillUnmount: function() {
    this.serverRequest.abort();
  },

  render: function(){
    var rows = [];
    this.state.patientComments.forEach(
      function(comment) {
        rows.push(<PatientComment comment={comment} key={comment.key} />);
      }
    );

    return (
      <div className="row">
        <table className="patient-history">
          <thead>
            <tr>
              <th>Date</th>
              <th>Commenter</th>
              <th>Title</th>
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
