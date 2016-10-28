var PatientTestOrder = React.createClass({
  navigateTo: function (toUrl) {
    window.location = toUrl;
  },

  render: function(){
    return (
      <tr onClick={this.navigateTo.bind(this, this.props.patientTestOrder.viewLink)}>
        <td>{this.props.patientTestOrder.requestedSiteName}</td>
        <td>{this.props.patientTestOrder.performingSiteName}</td>
        <td>{this.props.patientTestOrder.batchId}</td>
        <td>{this.props.patientTestOrder.requestedBy}</td>
        <td>{this.props.patientTestOrder.requestDate}</td>
        <td>{this.props.patientTestOrder.status}</td>
      </tr>
    );
  }
});
