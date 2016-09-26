class AddPatientResultAction extends React.Component {
  constructor(props, context) {
    super(props, context);

    this.state = { commentValue: props.actionInfo.commentValue }
  }

  updateResult(comment) {
    const that = this;

    $.ajax({
      url: this.props.actionInfo.updateResultUrl,
      method: 'PUT',
      data: { id: this.props.actionInfo.resultId, patient_result: { comment: comment } }
    }).fail( function(data) {
      alert(I18n.t('components.test_result_actions.update_failed'))
    });
  }

  commentChanged(newComment, reasonId) {
    if (newComment) {
      this.updateResult(newComment);
      this.setState({ commentValue: newComment });
    }
  }

  render() {
    return(
      <div>
        <a className="btn-primary save side-link" href={ this.props.actionInfo.editResultUrl }>
          { I18n.t('components.add_samples_action.add_result') }
        </a>
        <TextInputModal key={ this.props.actionInfo.resultId } showRejectionSelect={ false } mainHeader={ this.props.actionInfo.rejectHeader } linkButton={ this.props.actionInfo.rejectLabel } comment={ this.state.commentValue } commentChanged={ this.commentChanged.bind(this) } edit={ true } ref='inviteModal' />
      </div>

    )
  }
}

AddPatientResultAction.propTypes = {
  actionInfo: React.PropTypes.object.isRequired,
}
