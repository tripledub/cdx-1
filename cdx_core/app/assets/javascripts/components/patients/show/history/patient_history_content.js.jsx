var PatientHistoryContent = React.createClass({
  render: function(){
    return(
      <div className="row">
        <div className="col-12">
          {this.props.currentTab === 1 ?
            <PatientTestOrders testOrdersUrl={this.props.testOrdersUrl} />
            :null}

          {this.props.currentTab === 2 ?
            <PatientResults testResultsUrl={this.props.testResultsUrl} />
            :null}

          {this.props.currentTab === 3 ?
            <PatientAuditLogs patientLogsUrl={this.props.patientLogsUrl} />
            :null}

          {this.props.currentTab === 4 ?
            <PatientComments commentsUrl={this.props.commentsUrl} />
            :null}
        </div>
      </div>
    );
  }
});
