var CsvCheckboxColumn = React.createClass({
  selectedTestOrders: function (e) {
    this.props.selectedTestOrders(false);
  },

  setDefaultChecked: function () {
    return window.store.get('selectedItems').indexOf(this.props.columnId) > -1
  },

  render: function() {
    var chbox = React.createElement('input', { type: 'checkbox', onChange: this.selectedTestOrders, defaultChecked: this.setDefaultChecked(), name: this.props.columnId, id: this.props.columnId });
    return (
      <td className="csv-check-box">
        {chbox}
        <label htmlFor={this.props.columnId}>&nbsp;</label>
      </td>
    );
  }
});

var CsvCheckboxColumnHeader = React.createClass({
  selectedTestOrders: function (e) {
    $(".table input:checkbox").prop('checked', $(".headerCheckBox").prop("checked"));
    this.props.selectedTestOrders($(this).prop("checked"));
  },

  render: function() {
    return (
      <th className="csv-check-box">
        <input type="checkbox" className="headerCheckBox" onChange={this.selectedTestOrders} name={this.props.columnId} id={this.props.columnId} />
        <label htmlFor={this.props.columnId}>CSV</label>
      </th>
    );
  }
});
