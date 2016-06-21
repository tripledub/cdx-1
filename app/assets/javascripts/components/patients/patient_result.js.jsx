var PatientResult = React.createClass({
  render: function(){
    return (
      <tr>
        <td>{this.props.patientResult.name}</td>
        <td>{this.props.patientResult.status}</td>
        <td>{this.props.patientResult.date}</td>
      </tr>
    );
  }
});
