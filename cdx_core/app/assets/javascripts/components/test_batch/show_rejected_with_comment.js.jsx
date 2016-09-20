class ShowRejectedWithComment extends React.Component {
  render() {
    return(
      <div className="tooltip">
        Rejected
        <div className="tooltiptext_r">
          { this.props.commentValue }
        </div>
      </div>
    )
  }
}

ShowRejectedWithComment.propTypes = {
  commentValue: React.PropTypes.string.isRequired,
};
