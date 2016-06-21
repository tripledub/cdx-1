var PatientContent = React.createClass({
  render: function(){
    return(
      <div className="row">
        <div className="col-12">
          {this.props.currentTab === 1 ?
            <PatientAuditLogs patientLogsUrl={this.props.patientLogsUrl} />
            :null}

          {this.props.currentTab === 2 ?
            <PatientTestOrders testOrdersUrl={this.props.commentsUrl} />
            :null}

          {this.props.currentTab === 3 ?
            <PatientResults testResultsUrl={this.props.commentsUrl} />
            :null}

          {this.props.currentTab === 4 ?
            <PatientComments commentsUrl={this.props.commentsUrl} />
            :null}
        </div>
      </div>
    );
  }
});
