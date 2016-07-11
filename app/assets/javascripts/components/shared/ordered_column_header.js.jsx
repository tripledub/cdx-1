var OrderedColumnHeader = React.createClass({
  propTypes: {
    orderEvent: React.PropTypes.func
  },

  updateResults: function (e) {
    e.preventDefault();
    this.props.orderEvent(this.props.fieldName);
  },

  render: function(){
    return (
      <th>
        <a href="#" onClick={this.updateResults}>
          {this.props.title} <span dangerouslySetInnerHTML={{ __html: this.props.orderIcon }}></span>
        </a>
      </th>
    );
  }
});
