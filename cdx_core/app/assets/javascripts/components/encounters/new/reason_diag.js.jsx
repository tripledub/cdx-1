class ReasonDiag extends React.Component {
  updateComment(event) {
    this.props.diagCommentChange();
  }

  render() {
    return (
      <div className="row">
        <div className="col-6 flexStart">
          <label>{ I18n.t('components.encounters.btn_comment')}</label>
        </div>
        <div className="col-6">
          <textarea name="diag_comment" maxLength="200" id="diag_comment" rows="5" cols="60" onChange={ this.updateComment.bind(this) }></textarea>
        </div>
      </div>
    );
  }
};
