class ShowRejectedWithComment extends React.Component {
  render() {
    return(
      <p>
        <strong>{ I18n.t('components.test_result_status.test_rejected') } - { this.props.feedbackMessage }</strong> -
        <a className="btn" href={ this.props.showResultUrl }>{ I18n.t('components.test_result_status.show_test_result') }</a>
        <br />
        <em>{ this.props.commentValue }</em>
      </p>
    )
  }
}

ShowRejectedWithComment.propTypes = {
  commentValue: React.PropTypes.string.isRequired,
  feedbackMessage: React.PropTypes.string.isRequired,
  showResultUrl: React.PropTypes.string.isRequired,
};
