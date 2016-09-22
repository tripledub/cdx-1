var TextInputModal = React.createClass({
  getInitialState: function() {
    return {
      newComment: this.props.comment,
      buttonText: this.props.actionButton || I18n.t('components.text_input_modal.save_btn'),
      mainHeader: this.props.mainHeader || I18n.t("components.text_input_modal.add_comment_title"),
      reasonId:   this.props.rejectReasons ? this.props.rejectReasons[0]['id'] : 0,
    };
  },

  openInviteModal: function() {
    this.refs.inviteModal.show();
    event.preventDefault();
  },

  hideOuterEvent: function () {
    event.preventDefault();
    this.setState({ newComment: this.props.comment });
  },

  handleChange: function(e) {
    this.setState({ newComment: e.currentTarget.value });
  },

  reasonChange: function(reasonId) {
    console.log(reasonId);
    this.setState({ reasonId: reasonId });
  },

  handleSave: function() {
    event.preventDefault();
    this.props.commentChanged(this.state.newComment, this.state.reasonId);
    this.refs.inviteModal.hide();
  },

  render: function() {
    return (
      <div>
        <a className="btn-primary save side-link" href='#' title={ I18n.t("components.text_input_modal.add_comment_title") } onClick={ this.openInviteModal } >
          { this.props.linkButton ? this.props.linkButton
            : <span className="icon-pencil icon-white"></span>
          }
        </a>
        <Modal ref="inviteModal" hideOuterEvent={ this.hideOuterEvent }>
          <h1>{ this.state.mainHeader }</h1>
          <p>
            <textarea rows="10" cols="50" placeholder={ I18n.t("components.text_input_modal.add_comment_placeholder") } value={ this.state.newComment } onChange={ this.handleChange } id="testcomment" disabled={ !this.props.edit } />
          </p>
          { this.props.showRejectionSelect ?
            <RejectionSelect rejectReasons={ this.props.rejectReasons } reasonChange={ this.reasonChange }/> : null }
          <p>
            <a className = "btn-add-link btn-primary" href = "#" onClick={ this.handleSave }>{ this.state.buttonText }</a>
          </p>
        </Modal>
      </div>
    );
  }
});
