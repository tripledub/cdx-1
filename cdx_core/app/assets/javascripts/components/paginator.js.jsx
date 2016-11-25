class Paginator extends React.Component {
  render () {
    return(
      <div className="pagination">
        <PagePrev firstPage={ this.props.pages.firstPage } prevPage={ this.props.pages.prevPage } pageData={ this.props.pageData } /> |
        <PageNext lastPage={ this.props.pages.lastPage } nextPage={ this.props.pages.nextPage } pageData={ this.props.pageData } />
        <PageIndicator pages={this.props.pages} pageData={ this.props.pageData } />
      </div>
    )
  }
}

class PageIndicator extends React.Component {
  render() {
    let currentPage = this.props.pages.currentPage;
    let totalPages = this.props.pages.totalPages;
    return (
      <span className='page-indicator'> - page {currentPage} of {totalPages}</span>
    );
  }
}

class PagePrev extends React.Component {
  _getPrevious(e) {
    e.preventDefault();
    this.props.pageData(this.props.prevPage);
  }

  render () {
    let prevPage = this.props.prevPage;
    let hasPrevious = !this.props.firstPage;
    let previousButton, prevText;
    prevText = I18n.t('components.previous');

    if(hasPrevious) {
      previousButton = React.createElement(
        'a',
        {
          onClick: this._getPrevious.bind(this)
        },
        prevText
      )
    } else {
      previousButton = prevText;
    }

    return(
      <span>{previousButton}</span>
    )
  }
}

class PageNext extends React.Component {
  _getNext(e) {
    e.preventDefault();
    this.props.pageData(this.props.nextPage);
  }

  render () {
    let nextButton;

    if (!this.props.lastPage) {
      nextButton = React.createElement(
        'a',
        {
          onClick: this._getNext.bind(this)
        },
        I18n.t('components.next')
      );
    } else {
      nextButton = I18n.t('components.next');
    }

    return(
      <span>{ nextButton }</span>
    )
  }
}
