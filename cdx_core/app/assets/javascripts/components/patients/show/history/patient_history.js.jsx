var PatientHistory = React.createClass({
  getInitialState: function () {
    return {
      tabList: [
        { 'id': 1, 'name': I18n.t("components.patients.show.history.lst_test_order") },
        { 'id': 2, 'name': I18n.t("components.patients.show.history.lst_results") },
        { 'id': 3, 'name': I18n.t("components.patients.show.history.lst_history") },
        { 'id': 4, 'name': I18n.t("components.patients.show.history.lst_comments") }
      ],
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
          currentTab={ this.state.currentTab }
          tabList={ this.state.tabList }
          changeTab={ this.changeTab }
          />
        <PatientHistoryContent
          currentTab={ this.state.currentTab }
          commentsUrl={ this.props.commentsUrl }
          defaultCommentsOrder={ this.props.defaultCommentsOrder }
          testOrdersUrl={ this.props.testOrdersUrl }
          defaultOrdersOrder={ this.props.defaultOrdersOrder }
          patientLogsUrl={ this.props.patientLogsUrl }
          defaultLogsOrder={ this.props.defaultLogsOrder }
          testResultsUrl={ this.props.testResultsUrl }
          defaultResultsOrder={ this.props.defaultResultsOrder }
          />
      </div>
    );
  }
});
