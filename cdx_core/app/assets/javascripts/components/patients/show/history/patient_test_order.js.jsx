var PatientTestOrder = React.createClass({
  navigateTo: function (toUrl) {
    window.location = toUrl;
  },

  render: function(){
    console.log(this.props.patientTestOrder);
    return (
      <tr onClick={this.navigateTo.bind(this, this.props.patientTestOrder.viewLink)}>
        <td>{this.props.patientTestOrder.siteName}</td>
        <td>{this.props.patientTestOrder.performingSiteName}</td>
        <td>{this.props.patientTestOrder.batchId}</td>
        <td>{this.props.patientTestOrder.requester}</td>
        <td>{this.props.patientTestOrder.requestDate}</td>
        <td>{this.props.patientTestOrder.dueDate}</td>
        <td>{this.props.patientTestOrder.turnaroundTime}</td>
        <td>{this.props.patientTestOrder.status}</td>
      </tr>
    );
  }
});
