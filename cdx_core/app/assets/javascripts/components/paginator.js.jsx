class Paginator extends React.Component {
  render () {
    let pagination = this.props.pages;
    let current_page = pagination.current_page;
    let prevPage = pagination.prev_page;
    let nextPage = pagination.next_page;
    let firstPage = pagination.first_page;
    let lastPage = pagination.last_page;

    return(
      <div className="pagination">
        <PagePrev firstPage={firstPage} prevPage={prevPage} pageData={this.props.pageData} /> |
        <PageNext lastPage={lastPage} nextPage={nextPage} pageData={this.props.pageData} />
      </div>
    )
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
    let nextPage = this.props.nextPage;
    let hasNext = !this.props.lastPage;
    let nextButton, nextText;
    nextText = I18n.t('components.next');

    if(hasNext) {
      nextButton = React.createElement(
        'a',
        {
          onClick: this._getNext.bind(this)
        },
        nextText
      );
    } else {
      nextButton = nextText;
    }

    return(
      <span>{nextButton}</span>
    )
  }
}
