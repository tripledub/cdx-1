class ShowRejectedWithComment extends React.Component {
  render() {
    return(
      <p>
        <strong>Rejected - { this.props.feedbackMessage }</strong>
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
