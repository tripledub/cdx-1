var PatientResult = React.createClass({
  render: function(){
    return (
      <div className='row'>
        <h2>{this.props.patientResult.start_date}</h2>
      </div>
    );
  }
});
