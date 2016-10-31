class TestResultStatus extends React.Component {
  constructor(props, context) {
    super(props, context);

    this.state = {
      commentValue: props.commentValue,
      testOrderStatus: 'new',
      actionInfo: {
        sampleReceived: {
          actionStatus: 'allocated',
          actionStyles: 'btn-danger side-link',
          actionLabel: I18n.t('components.test_result_status.allocated.action_label'),
          rejectLabel: I18n.t('components.test_result_status.allocated.reject_label'),
          rejectHeader: I18n.t('components.test_result_status.allocated.reject_header'),
          rejectReasons: props.rejectReasons['samplesCollected'],
          resultId: props.resultId,
          updateResultUrl: props.encounterRoutes['updateResultUrl'],
          commentValue: props.commentValue,
        },
        sampleApproved: {
          actionLabel: I18n.t('components.test_result_status.sample_approved.action_label'),
          actionStyles: 'btn-danger side-link',
          rejectLabel: I18n.t('components.test_result_status.sample_approved.reject_label'),
          rejectHeader: I18n.t('components.test_result_status.sample_approved.reject_header'),
          resultId: props.resultId,
          updateResultUrl: props.encounterRoutes['updateResultUrl'],
          commentValue: props.commentValue,
          editResultUrl: props.editResultUrl,
        },
        inProgress: {
          actionStatus: 'pending_approval',
          actionStyles: 'btn-danger side-link',
          actionLabel: I18n.t('components.test_result_status.in_progress.action_label'),
          rejectLabel: I18n.t('components.test_result_status.in_progress.reject_label'),
          rejectHeader: I18n.t('components.test_result_status.in_progress.reject_header'),
          rejectReasons: props.rejectReasons['approval'],
          resultId: props.resultId,
          updateResultUrl: props.encounterRoutes['updateResultUrl'],
          commentValue: props.commentValue,
        }
      }
    }
  }

  render() {
    return(
      <div>
        { this.props.currentStatus === 'sample_collected' ?
          <TestResultActions actionInfo={ this.state.actionInfo['sampleReceived'] } updateResultStatus={ this.props.updateResultStatus } /> : null }
        { this.props.currentStatus === 'allocated' ?
          <AddPatientResultAction actionInfo={ this.state.actionInfo['sampleApproved'] } /> : null }
        { this.props.currentStatus === 'in_progress' ?
          <TestResultActions actionInfo={ this.state.actionInfo['inProgress'] } updateResultStatus={ this.props.updateResultStatus } /> : null }
        { (this.props.currentStatus === 'pending_approval') ?
          <a className="btn" href={ this.props.showResultUrl }>{ I18n.t('components.test_result_status.show_test_result') }</a> : null }
        { this.props.currentStatus === 'rejected' ?
          <ShowRejectedWithComment commentValue={ this.state.commentValue } showResultUrl={ this.props.showResultUrl } feedbackMessage={ this.props.feedbackMessage }/> : null }
        { this.props.currentStatus === 'completed' ?
          <ShowCompletedTestResult showResultUrl={ this.props.showResultUrl } /> : null }
      </div>
    );
  }
}

TestResultStatus.propTypes = {
  currentStatus: React.PropTypes.string.isRequired,
  showResultUrl: React.PropTypes.string.isRequired,
  encounterRoutes: React.PropTypes.object.isRequired,
  editResultUrl: React.PropTypes.string.isRequired,
  resultId: React.PropTypes.number.isRequired,
  commentValue: React.PropTypes.string.isRequired,
  feedbackMessage: React.PropTypes.string.isRequired,
  rejectReasons: React.PropTypes.object.isRequired,
  updateResultStatus: React.PropTypes.func.isRequired,
};
