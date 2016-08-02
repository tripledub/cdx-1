var TextInputModal = React.createClass({
  getInitialState: function() {
    var buttonText = "Save";
    if (this.props.edit == false) {
      buttonText = "Close";
    }

    return {
      newComment: this.props.comment,
      buttonText: buttonText
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
        <a className="btn-add side-link" href='#' title="Add Comment" onClick={this.openInviteModal} ><span className="icon-pencil icon-white"></span></a>
        <Modal ref="inviteModal" hideOuterEvent={this.hideOuterEvent}>
          <h1>Test Comment</h1>
          <p>
            <textarea rows="10" cols="50" placeholder="Add Comment" value={this.state.newComment} onChange={this.handleChange} id="testcomment" disabled={!this.props.edit} />
          </p>
          <p>
            <a className = "btn-add-link btn-primary" href = "#" onClick={this.handleSave}>{this.state.buttonText}</a>
          </p>
        </Modal>
      </div>
    );
  }
});
