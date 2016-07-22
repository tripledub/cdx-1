var PatientComment = React.createClass({
  navigateTo: function (toUrl) {
    window.location = toUrl;
  },

  render: function(){
    return (
      <tr onClick={this.navigateTo.bind(this, this.props.comment.viewLink)}>
        <td>{this.props.comment.commentDate}</td>
        <td>{this.props.comment.commenter}</td>
        <td>{this.props.comment.title}</td>
      </tr>
    );
  }
});
