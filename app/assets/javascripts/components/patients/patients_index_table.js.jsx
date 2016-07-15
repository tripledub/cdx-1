var PatientResultRow = React.createClass({
  render: function() {
    return (
    <tr data-href={this.props.patient.viewLink}>
      <td>{this.props.patient.name}</td>
      <td>{this.props.patient.entityId}</td>
      <td>{this.props.patient.dateOfBirth}</td>
      <td>{this.props.patient.city}</td>
      <td>{this.props.patient.lastEncounter}</td>
    </tr>);
  }
});

var PatientsIndexTable = React.createClass({
  getDefaultProps: function() {
    return {
      title: "Patients",
      allowSorting: true,
      orderBy: "patients.name"
    }
  },

  componentDidMount: function() {
    $("table").resizableColumns({store: window.store});
  },

  render: function() {
    var rows           = [];
    var sortableHeader = function (title, field) {
      return <SortableColumnHeader title={title} field={field} orderBy={this.props.orderBy} />
    }.bind(this);

    this.props.patients.forEach(
      function(patient) {
        rows.push(<PatientResultRow key={patient.id} patient={patient} />);
      }
    );

    return (
      <table className="table" cellPadding="0" cellSpacing="0" data-resizable-columns-id="patients-table">
        <thead>
          <tr>
            {sortableHeader("Name", "patients.name")}
            {sortableHeader("Patient Id", "patients.entity_id")}
            <th data-resizable-column-id="dob">Date of Birth</th>
            {sortableHeader("City", "patients.city")}
            <th data-resizable-column-id="last_encounter">Last test order</th>
          </tr>
        </thead>
        <tbody>
          {rows}
        </tbody>
      </table>
    );
  }
});