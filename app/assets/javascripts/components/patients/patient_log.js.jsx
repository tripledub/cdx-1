var PatientLog = React.createClass({
  render: function(){
    return (
      <tr>
        <td>{this.props.patientLog.title}</td>
        <td>{this.props.patientLog.user}</td>
        <td>{this.props.patientLog.date}</td>
      </tr>
    );
  }
});
