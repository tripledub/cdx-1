class ShowApproveTestResult extends React.Component {
  updateResultStatus(status, comment) {
    this.props.updateResultStatus(status, comment)
  }

  render() {
    return(
      <div>
        <TestResultActions actionInfo={ this.props.testApproved } updateResultStatus={ this.updateResultStatus.bind(this) } />
        <a className="btn" href={ this.props.showResultUrl }>{ I18n.t('components.test_result_status.show_test_result') }</a>
      </div>
    )
  }
}

ShowApproveTestResult.propTypes = {
  updateResultStatus: React.PropTypes.func.isRequired,
  showResultUrl: React.PropTypes.string.isRequired,
  testApproved: React.PropTypes.object.isRequired,
};
