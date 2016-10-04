class TestResultStatus extends React.Component {
  constructor(props, context) {
    super(props, context);

    this.state = {
      currentStatus: props.currentStatus,
      commentValue: props.commentValue,
    }
  }

  updateResultStatus(status, comment) {
    this.setState({ currentStatus: status, commentValue: comment })
    this.props.updateResultStatus(status);
  }

  render() {
    const sampleReceived = {
      actionStatus: 'allocated',
      actionStyles: 'btn-danger side-link',
      actionLabel: I18n.t('components.test_result_status.allocated.action_label'),
      rejectLabel: I18n.t('components.test_result_status.allocated.reject_label'),
      rejectHeader: I18n.t('components.test_result_status.allocated.reject_header'),
      rejectReasons: this.props.rejectReasons['samplesCollected'],
      resultId: this.props.resultId,
      updateResultUrl: this.props.encounterRoutes['updateResultUrl'],
      commentValue: this.state.commentValue,
    };
    const sampleApproved = {
      actionLabel: I18n.t('components.test_result_status.sample_approved.action_label'),
      actionStyles: 'btn-danger side-link',
      rejectLabel: I18n.t('components.test_result_status.sample_approved.reject_label'),
      rejectHeader: I18n.t('components.test_result_status.sample_approved.reject_header'),
      resultId: this.props.resultId,
      updateResultUrl: this.props.encounterRoutes['updateResultUrl'],
      commentValue: this.state.commentValue,
      editResultUrl: this.props.editResultUrl,
    };
    const inProgress = {
      actionStatus: 'pending_approval',
      actionStyles: 'btn-danger side-link',
      actionLabel: I18n.t('components.test_result_status.in_progress.action_label'),
      rejectLabel: I18n.t('components.test_result_status.in_progress.reject_label'),
      rejectHeader: I18n.t('components.test_result_status.in_progress.reject_header'),
      rejectReasons: this.props.rejectReasons['approval'],
      resultId: this.props.resultId,
      updateResultUrl: this.props.encounterRoutes['updateResultUrl'],
      commentValue: this.state.commentValue,
    };
    const testApproved = {
      actionStatus: 'completed',
      actionStyles: 'btn-danger side-link',
      actionLabel: I18n.t('components.test_result_status.test_received.action_label'),
      rejectLabel: I18n.t('components.test_result_status.test_received.reject_label'),
      rejectHeader: I18n.t('components.test_result_status.test_received.reject_header'),
      rejectReasons: this.props.rejectReasons['labTech'],
      resultId: this.props.resultId,
      updateResultUrl: this.props.encounterRoutes['updateResultUrl'],
      commentValue: this.state.commentValue,
    };

    return(
      <div>
        { this.state.currentStatus === 'new' ?
          I18n.t('components.test_result_status.test_new') : null }
        { this.state.currentStatus === 'sample_collected' ?
          <TestResultActions actionInfo={ sampleReceived } updateResultStatus={ this.updateResultStatus.bind(this) } /> : null }
        { this.state.currentStatus === 'allocated' ?
          <AddPatientResultAction actionInfo={ sampleApproved } /> : null }
        { this.state.currentStatus === 'in_progress' ?
          <TestResultActions actionInfo={ inProgress } updateResultStatus={ this.updateResultStatus.bind(this) } /> : null }
        { this.state.currentStatus === 'pending_approval' && this.props.userCanApprove ?
          <ShowApproveTestResult showResultUrl={ this.props.showResultUrl } testApproved={ testApproved } updateResultStatus={ this.updateResultStatus.bind(this) } /> : null }
        { this.state.currentStatus === 'rejected' ?
          <ShowRejectedWithComment commentValue={ this.state.commentValue } showResultUrl={ this.props.showResultUrl } feedbackMessage={ this.props.feedbackMessage }/> : null }
        { this.state.currentStatus === 'completed' ?
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
  userCanApprove: React.PropTypes.bool.isRequired,
  resultId: React.PropTypes.number.isRequired,
  commentValue: React.PropTypes.string.isRequired,
  feedbackMessage: React.PropTypes.string.isRequired,
  rejectReasons: React.PropTypes.object.isRequired,
  updateResultStatus: React.PropTypes.func.isRequired,
};
