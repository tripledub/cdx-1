class TestResultActions extends React.Component{
  constructor(props, context) {
    super(props, context);

    this.state = { currentStatus: props.currentStatus, commentValue: props.commentValue }
  }

  updateResult(status, comment, reasonId) {
    const that = this;
    $.ajax({
      url: this.props.updateResultUrl,
      method: 'PUT',
      data: { id: this.props.resultId, patient_result: { result_status: status, comment: comment, feedback_message_id: reasonId } }
    }).done( function(data) {
      that.props.updateResultStatus(data['result'], comment);
    }).fail( function(data) {
      alert('Can not update status.')
    });
  }

  rejectResult(event) {
    event.preventDefault();
    this.refs.inviteModal.show();
  }

  commentChanged(newComment, reasonId) {
    if (newComment) {
      this.updateResult('rejected', newComment, reasonId);
    }
  }

  render() {
    return(
      <div>
        <button onClick={ this.updateResult.bind(this, this.props.actionInfo.actionStatus, '') } className="btn-primary save">{ this.props.actionInfo.actionLabel }</button>
        <TextInputModal key={ this.props.resultId } showRejectionSelect={ true } rejectReasons={ this.props.rejectReasons } mainHeader='Please explain why this test is rejected' linkButton='Reject' comment={ this.state.commentValue } commentChanged={ this.commentChanged.bind(this) } edit={ true } ref='inviteModal' />
      </div>

    )
  }
}

TestResultActions.propTypes = {
  updateResultUrl: React.PropTypes.string.isRequired,
  commentValue: React.PropTypes.string.isRequired,
  actionInfo: React.PropTypes.object.isRequired,
  rejectReasons: React.PropTypes.array.isRequired,
  resultId: React.PropTypes.number.isRequired,
  updateResultStatus: React.PropTypes.func.isRequired,
};
