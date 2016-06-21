var PatientTestOrder = React.createClass({
  render: function(){
    return (
      <tr>
        <td>{this.props.patientTestOrder.siteName}</td>
        <td>{this.props.patientTestOrder.id}</td>
        <td>{this.props.patientTestOrder.requester}</td>
        <td>{this.props.patientTestOrder.requestDate}</td>
        <td>{this.props.patientTestOrder.dueDate}</td>
        <td>{this.props.patientTestOrder.status}</td>
      </tr>
    );
  }
});
