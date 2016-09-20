class TestResultStatus extends React.Component {
  constructor(props, context) {
    super(props, context);

    this.state = { currentStatus: props.currentStatus }
  }

  updateResultStatus(status) {
    this.setState({ currentStatus: status })
  }

  render() {
    return(
      <div>
        { this.state.currentStatus === 'in_progress' ? <TestResultActions updateResultStatus={ this.updateResultStatus.bind(this) } resultId={ this.props.resultId } updateResultUrl={ this.props.updateResultUrl }/> : null }
        { this.state.currentStatus === 'new' ? 'New' : null }
        { this.state.currentStatus === 'rejected' ? 'Rejected' : null }
        { this.state.currentStatus === 'completed' ? 'Completed' : null }
      </div>

    );
  }
}

TestResultStatus.propTypes = {
  currentStatus: React.PropTypes.string.isRequired,
  updateResultUrl: React.PropTypes.string.isRequired,
  resultId: React.PropTypes.number.isRequired,
};
