class ShowApproveTestResult  extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
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
    };
  }

  updateResultStatus(status, comment) {
    location.reload(true);
  }

  render() {
    return(
      <TestResultActions actionInfo={ this.state.testApproved } updateResultStatus={ this.updateResultStatus.bind(this) } />
    )
  }
}

ShowApproveTestResult.propTypes = {
  resultId: React.PropTypes.number.isRequired,
  commentValue: React.PropTypes.string,
  updateResultUrl: React.PropTypes.string.isRequired,
  rejectReasons: React.PropTypes.array.isRequired,
};
