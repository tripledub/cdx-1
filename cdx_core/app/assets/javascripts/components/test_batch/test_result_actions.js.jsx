class TestResultActions extends React.Component{
  constructor(props, context) {
    super(props, context);

    this.state = { currentStatus: props.currentStatus, commentValue: props.commentValue }
  }

  updateResult(status, comment) {
    const that = this;
    $.ajax({
      url: this.props.updateResultUrl,
      method: 'PUT',
      data: { id: this.props.resultId, patient_result: { result_status: status, comment: comment } }
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

  commentChanged(newComment) {
    if (newComment) {
      this.updateResult('rejected', newComment);
    }
  }

  render() {
    return(
      <div>
        <button onClick={ this.updateResult.bind(this, 'received', '') } className="btn-primary save">Received</button>
        <TextInputModal key={ this.props.resultId } mainHeader='Please, explain why this test is rejected' linkButton='Reject' comment={ this.state.commentValue } commentChanged={ this.commentChanged.bind(this) } edit={ true } ref='inviteModal' />
      </div>

    )
  }
}

TestResultActions.propTypes = {
  updateResultUrl: React.PropTypes.string.isRequired,
  commentValue: React.PropTypes.string.isRequired,
  resultId: React.PropTypes.number.isRequired,
  updateResultStatus: React.PropTypes.func.isRequired,
};
