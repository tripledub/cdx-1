class ShowApproveTestResult extends React.Component {
  updateResultStatus(status, comment) {
    this.props.updateResultStatus(status, comment)
  }

  render() {
    return(
      <p>
        <TestResultActions actionInfo={ this.props.testApproved } updateResultStatus={ this.updateResultStatus.bind(this) } />
        <a className="btn" href={ this.props.showResultUrl }>{ I18n.t('components.test_result_status.show_test_result') }</a>
      </p>
    )
  }
}

ShowApproveTestResult.propTypes = {
  updateResultStatus: React.PropTypes.func.isRequired,
  showResultUrl: React.PropTypes.string.isRequired,
  testApproved: React.PropTypes.object.isRequired,
};
