class ShowRejectedWithComment extends React.Component {
  render() {
    return(
      <p>
        <strong>Rejected</strong>
        <br />
        <em>{ this.props.commentValue }</em>
      </p>
    )
  }
}

ShowRejectedWithComment.propTypes = {
  commentValue: React.PropTypes.string.isRequired,
};
