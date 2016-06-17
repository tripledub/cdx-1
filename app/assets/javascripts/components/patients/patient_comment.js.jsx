var PatientComment = React.createClass({
  render: function(){
    return (
      <tr>
        <td>{this.props.comment.commented_on}</td>
        <td>{this.props.comment.commenter}</td>
        <td>{this.props.comment.description}</td>
      </tr>
    );
  }
});
