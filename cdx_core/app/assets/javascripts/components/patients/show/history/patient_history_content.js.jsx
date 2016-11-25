var PatientHistoryContent = React.createClass({
  render: function(){
    return(
      <div className="row">
        <div className="col-12">
          {this.props.currentTab === 1 ?
            <PatientTestOrders testOrdersUrl={ this.props.testOrdersUrl } defaultOrdersOrder={ this.props.defaultOrdersOrder } />
            :null}

          {this.props.currentTab === 2 ?
            <PatientResults testResultsUrl={ this.props.testResultsUrl } defaultResultsOrder={ this.props.defaultResultsOrder } />
            :null}

          { this.props.currentTab === 3 ?
            <PatientAuditLogs patientLogsUrl={ this.props.patientLogsUrl } defaultLogsOrder={ this.props.defaultLogsOrder } />
            : null }

          { this.props.currentTab === 4 ?
            <PatientComments commentsUrl={ this.props.commentsUrl } defaultCommentsOrder={ this.props.defaultCommentsOrder } />
            : null }
        </div>
      </div>
    );
  }
});
