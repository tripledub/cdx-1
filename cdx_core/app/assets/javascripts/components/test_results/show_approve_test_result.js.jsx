class ShowApproveTestResult  extends React.Component {
  constructor(props) {
    testApproved: {
      actionStatus: 'completed',
      actionStyles: 'btn-danger side-link',
      actionLabel: I18n.t('components.test_result_status.test_received.action_label'),
      rejectLabel: I18n.t('components.test_result_status.test_received.reject_label'),
      rejectHeader: I18n.t('components.test_result_status.test_received.reject_header'),
      rejectReasons: props.rejectReasons,
      resultId: props.resultId,
      updateResultUrl: props.updateResultUrl,
      commentValue: props.commentValue,
    }
  }

  updateResultStatus(status, comment) {
    this.props.updateResultStatus(status, comment)
  }

  render() {
    return(
      <div>
        <TestResultActions actionInfo={ this.props.testApproved } updateResultStatus={ this.updateResultStatus.bind(this) } />
      </div>
    )
  }
}

ShowApproveTestResult.propTypes = {
  resultId: React.PropTypes.string.isRequired
  commentValue: React.PropTypes.string,
  updateResultUrl: React.PropTypes.string.isRequired,
  rejectReasons: React.PropTypes.object.isRequired,
};
