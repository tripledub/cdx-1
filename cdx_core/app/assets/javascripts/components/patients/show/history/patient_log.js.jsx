var PatientLog = React.createClass({
  navigateTo: function (toUrl) {
    window.location = toUrl;
  },

  render: function(){
    return (
      <tr onClick={this.navigateTo.bind(this, this.props.patientLog.viewLink)}>
        <td>{this.props.patientLog.title}</td>
        <td>{this.props.patientLog.user}</td>
        <td>{this.props.patientLog.device}</td>
        <td>{this.props.patientLog.date}</td>
      </tr>
    );
  }
});
