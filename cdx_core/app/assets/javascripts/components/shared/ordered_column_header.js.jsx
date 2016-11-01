var OrderedColumnHeader = React.createClass({
  propTypes: {
    orderEvent: React.PropTypes.func
  },

  updateResults: function (event) {
    event.preventDefault();
    let orderField = '';

    if (this.props.orderBy.charAt(0) === '-' ) {
      orderField = this.props.orderBy.substring(1);
    } else {
      orderField = this.props.orderBy;
    }

    if (this.props.fieldName === orderField) {
      if (this.props.orderBy.charAt(0) === '-' ) {
        orderField = this.props.orderBy.substring(1);
      } else {
        orderField = '-' + this.props.fieldName;
      }
    } else {
      orderField = this.props.fieldName;
    };

    this.props.orderEvent(orderField);
  },

  render: function(){
    let appendTitle = "";
    if (this.props.orderBy == this.props.fieldName) {
      appendTitle = " ↑";
    } else if (this.props.orderBy == "-" + this.props.fieldName) {
      appendTitle = " ↓";
    }

    return (
      <th data-resizable-column-id={ this.props.fieldName }>
        <a href="#" onClick={ this.updateResults }>{ this.props.title } { appendTitle }</a>
      </th>
    );
  }
});
