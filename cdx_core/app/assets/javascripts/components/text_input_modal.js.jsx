var TextInputModal = React.createClass({
  getInitialState: function() {
    return {
      newComment: this.props.comment,
      buttonText: this.props.actionButton || I18n.t('components.text_input_modal.save_btn'),
      mainHeader: this.props.mainHeader || I18n.t("components.text_input_modal.add_comment_title"),
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

  handleSave: function() {
    event.preventDefault();
    this.props.commentChanged(this.state.newComment);
    this.refs.inviteModal.hide();
  },

  render: function() {
    return (
      <div>
        <a className="btn-primary save side-link" href='#' title={I18n.t("components.text_input_modal.add_comment_title")} onClick={this.openInviteModal} >
          { this.props.linkButton ? this.props.linkButton
            : <span className="icon-pencil icon-white"></span>
          }
        </a>
        <Modal ref="inviteModal" hideOuterEvent={this.hideOuterEvent}>
          <h1>{ this.state.mainHeader }</h1>
          <p>
            <textarea rows="10" cols="50" placeholder={I18n.t("components.text_input_modal.add_comment_placeholder")} value={this.state.newComment} onChange={this.handleChange} id="testcomment" disabled={!this.props.edit} />
          </p>
          <p>
            <a className = "btn-add-link btn-primary" href = "#" onClick={this.handleSave}>{this.state.buttonText}</a>
          </p>
        </Modal>
      </div>
    );
  }
});
