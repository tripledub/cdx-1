class ShowRejectedWithComment extends React.Component {
  render() {
    return(
      <p>
        <strong>{ I18n.t('components.test_result_status.test_rejected') } - { this.props.feedbackMessage }</strong>
        <br />
        <em>{ this.props.commentValue }</em>
      </p>
    )
  }
}

ShowRejectedWithComment.propTypes = {
  commentValue: React.PropTypes.string.isRequired,
  feedbackMessage: React.PropTypes.string.isRequired,
};
