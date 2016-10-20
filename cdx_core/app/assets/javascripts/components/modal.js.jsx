var Modal = React.createClass({
  getInitialState: function() {
    return { show: false };
  },

  show: function() {
    this.setState(React.addons.update(this.state, {
      show: { $set: true }
    }));
  },

  hide: function() {
    if (this.props.hideOuterEvent instanceof Function ) {
      this.props.hideOuterEvent();
    };

    this.setState(React.addons.update(this.state, {
      show: { $set: false }
    }));
  },

  hideOnOuterClick: function(event) {
    if (this.getDOMNode() == event.target) {
      this.hide();
    }
  },

  handleKeyDown: function(event) {
    if (event.keyCode == 27) // esc
      this.hide();
  },

  componentDidMount: function() {
    document.addEventListener('keydown', this.handleKeyDown);
  },

  componentWillUnmount: function() {
    document.removeEventListener('keydown', this.handleKeyDown);
  },

  render: function() {
    if (this.state.show)
      return (<div className="modal-wrapper" onClick={this.hideOnOuterClick} onKeyDown={this.handleKeyDown}>
        <div className="modal">
          <div className="close-modal" onClick={this.hide} title="Close">
            <img src="/img/ic-cross.png" />
          </div>
          {this.props.children}
        </div>
      </div>);
    else
      return null;
  }
});
