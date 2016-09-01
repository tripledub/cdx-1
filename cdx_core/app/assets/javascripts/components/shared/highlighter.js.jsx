var TextHighlight = React.createClass({
  componentDidMount() {
    this.updateDOM();
  },

  componentDidUpdate() {
    this.updateDOM();
  },

  updateDOM() {
    var el = React.findDOMNode(this.refs.text);
    el.innerHTML = this.mark(
      this.props.highlight,
      this.props.text,
      this.props.markTag,
      this.props.caseSensitive
    );
  },

  mark(val, str, markTag, caseSensitive) {
    val = val || '';

    var escape = val.replace(/[-\\^$*+?.()|[\]{}]/g, '\\$&');
    var tagStr = '<{tag}>$&</{tag}>';

    markTag = markTag || 'mark';

    if (val.length === 0) {
      return str;
    }

    return str.replace(
      RegExp(escape, caseSensitive ? 'g':'gi'),
      tagStr.replace(/{tag}/gi, markTag)
    );
  },

  render() {
    return (
      <p className="text-highlight" ref="text"></p>
    );
  }
});

TextHighlight.propTypes = {
  highlight: React.PropTypes.string.isRequired,
  text: React.PropTypes.string.isRequired,
  markTag: React.PropTypes.string,
  caseSensitive: React.PropTypes.bool
};

TextHighlight.defaultProps = {
  highlight: null,
  text: null,
  markTag: 'mark',
  caseSensitive: false
};
