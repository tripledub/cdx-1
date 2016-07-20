var tabList = [
    { 'id': 1, 'name': 'History' },
    { 'id': 2, 'name': 'Test Orders' },
    { 'id': 3, 'name': 'Results' },
    { 'id': 4, 'name': 'Comments' }
];

var PatientHistory = React.createClass({
  getInitialState: function () {
    return {
      tabList: tabList,
      currentTab: this.props.defaultTab
    };
  },

  changeTab: function(tab, e) {
    document.cookie = 'defaultTab=' + tab.id;
    this.setState({ currentTab: tab.id });
  },

  render: function(){
    return(
      <div>
        <PatientTabs
          currentTab={this.state.currentTab}
          tabList={this.state.tabList}
          changeTab={this.changeTab}
          />
        <PatientContent currentTab={this.state.currentTab} commentsUrl={this.props.commentsUrl} testOrdersUrl={this.props.testOrdersUrl} patientLogsUrl={this.props.patientLogsUrl} testResultsUrl={this.props.testResultsUrl} />
      </div>
    );
  }
});
