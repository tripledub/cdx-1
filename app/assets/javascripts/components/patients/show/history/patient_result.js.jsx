var PatientResult = React.createClass({
  navigateTo: function (toUrl) {
    window.location = toUrl;
  },

  render: function(){
    return (
      <tr onClick={this.navigateTo.bind(this, this.props.patientResult.viewLink)}>
        <td>{this.props.patientResult.name}</td>
        <td>{this.props.patientResult.status}</td>
        <td>{this.props.patientResult.date}</td>
      </tr>
    );
  }
});
