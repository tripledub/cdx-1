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
  }

  render() {
    const sampleReceived = {
      actionStatus: 'sample_received',
      actionLabel: I18n.t('components.test_result_status.sample_received.action_label'),
      rejectLabel: I18n.t('components.test_result_status.sample_received.reject_label'),
      rejectHeader: I18n.t('components.test_result_status.sample_received.reject_header'),
      rejectReasons: this.props.rejectReasons['samplesCollected'],
      resultId: this.props.resultId,
      updateResultUrl: this.props.updateResultUrl,
      commentValue: this.state.commentValue,
    };
    const sampleApproved = {
      actionLabel: I18n.t('components.test_result_status.sample_approved.action_label'),
      rejectLabel: I18n.t('components.test_result_status.sample_approved.reject_label'),
      rejectHeader: I18n.t('components.test_result_status.sample_approved.reject_header'),
      resultId: this.props.resultId,
      updateResultUrl: this.props.updateResultUrl,
      commentValue: this.state.commentValue,
      editResultUrl: this.props.editResultUrl,
    };
    const inProgress = {
      actionStatus: 'pending_approval',
      actionLabel: I18n.t('components.test_result_status.in_progress.action_label'),
      rejectLabel: I18n.t('components.test_result_status.in_progress.reject_label'),
      rejectHeader: I18n.t('components.test_result_status.in_progress.reject_header'),
      rejectReasons: this.props.rejectReasons['approval'],
      resultId: this.props.resultId,
      updateResultUrl: this.props.updateResultUrl,
      commentValue: this.state.commentValue,
    };
    const testApproved = {
      actionStatus: 'completed',
      actionLabel: I18n.t('components.test_result_status.test_received.action_label'),
      rejectLabel: I18n.t('components.test_result_status.test_received.reject_label'),
      rejectHeader: I18n.t('components.test_result_status.test_received.reject_header'),
      rejectReasons: this.props.rejectReasons['labTech'],
      resultId: this.props.resultId,
      updateResultUrl: this.props.updateResultUrl,
      commentValue: this.state.commentValue,
    };

    return(
      <div>
        { this.state.currentStatus === 'new' ? I18n.t('components.test_result_status.test_new') : null }
        { this.state.currentStatus === 'sample_collected' && this.props.paymentDone ?
          <TestResultActions actionInfo={ sampleReceived } updateResultStatus={ this.updateResultStatus.bind(this) } /> : null }
        { this.state.currentStatus === 'sample_received' ?
          <AddPatientResultAction actionInfo={ sampleApproved } /> : null }
        { this.state.currentStatus === 'in_progress' ?
          <TestResultActions actionInfo={ inProgress } updateResultStatus={ this.updateResultStatus.bind(this) } /> : null }
        { this.state.currentStatus === 'pending_approval' && this.props.userCanApprove ?
          <TestResultActions actionInfo={ testApproved } updateResultStatus={ this.updateResultStatus.bind(this) } /> : null }
        { this.state.currentStatus === 'rejected' ?
          <ShowRejectedWithComment commentValue={ this.state.commentValue } feedbackMessage={ this.props.feedbackMessage }/> : null }
        { this.state.currentStatus === 'completed' ? I18n.t('components.test_result_status.test_completed') : null }
      </div>

    );
  }
}

TestResultStatus.propTypes = {
  currentStatus: React.PropTypes.string.isRequired,
  updateResultUrl: React.PropTypes.string.isRequired,
  editResultUrl: React.PropTypes.string.isRequired,
  paymentDone: React.PropTypes.bool.isRequired,
  userCanApprove: React.PropTypes.bool.isRequired,
  resultId: React.PropTypes.number.isRequired,
  commentValue: React.PropTypes.string.isRequired,
  feedbackMessage: React.PropTypes.string.isRequired,
  rejectReasons: React.PropTypes.object.isRequired,
};
