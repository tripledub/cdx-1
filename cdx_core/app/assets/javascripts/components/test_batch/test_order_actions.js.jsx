// This class handles the update of a test order
class TestOrderActions extends React.Component{
  constructor(props, context) {
    super(props, context);

    this.state = { commentValue: props.actionInfo.commentValue }
  }

  sendStatusUpdates(result) {
    StatusActions.updateStatus(result);
  }

  updateResult(status, comment, reasonId, event) {
    if (event) { event.preventDefault() }
    const that = this;

    $.ajax({
      url: this.props.actionInfo.updateTestOrderUrl,
      method: 'PUT',
      data: {
        id: this.props.actionInfo.resultId,
        encounter: { status: status, comment: comment, feedback_message_id: reasonId }
      }
    }).done( function(data) {
      that.props.updateResultStatus(data['result']['testOrderStatus'], comment);
      that.sendStatusUpdates(data['result']);
    }).fail( function(data) {
      alert(I18n.t('components.test_order_actions.update_failed'))
    });
  }

  rejectResult(event) {
    event.preventDefault();
    this.refs.inviteModal.show();
  }

  commentChanged(newComment, reasonId) {
    if (newComment) { this.updateResult('not_financed', newComment, reasonId); }
  }

  render() {
    return(
      <div>
        <button onClick={ this.updateResult.bind(this, this.props.actionInfo.actionStatus, '', 0) } className="btn-primary save side-link">{ this.props.actionInfo.actionLabel }</button>
        <TextInputModal key={ this.props.actionInfo.resultId } showRejectionSelect={ true } rejectReasons={ this.props.actionInfo.rejectReasons } mainHeader={ this.props.actionInfo.rejectHeader } actionStyles={ this.props.actionInfo.actionStyles } linkButton={ this.props.actionInfo.rejectLabel } comment={ this.state.commentValue } commentChanged={ this.commentChanged.bind(this) } edit={ true } ref='inviteModal' />
      </div>

    )
  }
}

TestOrderActions.propTypes = {
  actionInfo: React.PropTypes.object.isRequired,
  updateResultStatus: React.PropTypes.func.isRequired,
};
