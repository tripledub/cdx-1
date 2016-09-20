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
      actionLabel: 'Sample received',
    };
    const sampleApproved = {
      actionStatus: 'completed',
      actionLabel: 'Approve',
    };

    return(
      <div>
        { this.state.currentStatus === 'new' ? 'New' : null }
        { this.state.currentStatus === 'sample_collected' ?
          <TestResultActions actionInfo={ sampleReceived } updateResultStatus={ this.updateResultStatus.bind(this) } commentValue={ this.state.commentValue } resultId={ this.props.resultId } updateResultUrl={ this.props.updateResultUrl }/> : null }
        { this.state.currentStatus === 'sample_received' ?
          <AddPatientResultAction editResultUrl={ this.props.editResultUrl }/> : null }
        { this.state.currentStatus === 'pending_approval' ?
          <TestResultActions actionInfo={ sampleApproved } updateResultStatus={ this.updateResultStatus.bind(this) } commentValue={ this.state.commentValue } resultId={ this.props.resultId } updateResultUrl={ this.props.updateResultUrl }/> : null }
        { this.state.currentStatus === 'rejected' ?
          <ShowRejectedWithComment commentValue={ this.state.commentValue } />
          : null }
        { this.state.currentStatus === 'completed' ? 'Completed' : null }
      </div>

    );
  }
}

TestResultStatus.propTypes = {
  currentStatus: React.PropTypes.string.isRequired,
  updateResultUrl: React.PropTypes.string.isRequired,
  editResultUrl: React.PropTypes.string.isRequired,
  resultId: React.PropTypes.number.isRequired,
  commentValue: React.PropTypes.string.isRequired,
};
