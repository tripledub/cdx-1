var SitePicker = React.createClass({
  getDefaultProps: function() {
    return {
      institutions_url: '/api/institutions',
      sites_url: '/api/sites'
    }
  },

  getInitialState: function() {
    return { sites: [], sitesTree: [], selected_site: null, query: '', subsites_selected: this.props.subsitesIncluded };
  },

  componentDidMount: function() {
    $.get(this.props.institutions_url, function(institutionsResult) {
      $.get(this.props.sites_url, function(sitesResult) {
        if (!this.isMounted()) return;

        var sitesAndInstitutions = sitesResult.sites;
        _.each(sitesAndInstitutions, function(site) {
          site.parent_uuid = site.parent_uuid || site.institution_uuid;
        });
        _.each(institutionsResult.institutions, function(institution) {
          sitesAndInstitutions.push(institution);
        });

        rootsAndSelected = this._buildTree(sitesAndInstitutions, '', this.props.selected_uuid);

        this.setState(React.addons.update(this.state, {
          sites: { $set: sitesAndInstitutions },
          sitesTree: { $set: rootsAndSelected[0] },
          selected_site: { $set: rootsAndSelected[1] }
        }));
      }.bind(this));
    }.bind(this));
  },

  componentWillReceiveProps: function(nextProps) {
    if (nextProps.selected_uuid != this.state.selected_site.uuid) {
      this.state.selected_site.selected = false;
      var nextSelected = _.find(this.state.sites, {'uuid': nextProps.selected_uuid});
      nextSelected.selected = true;

      this.setState(React.addons.update(this.state, {
        selected_site: { $set: nextSelected },
        subsites_selected: { $set: nextProps.subsitesIncluded }
      }));
    } else {
      // if selected_site has not changed, the include subsites flag might.
      this.setState(React.addons.update(this.state, {
        subsites_selected: { $set: nextProps.subsitesIncluded }
      }));
    }
  },

  _siteMatch: function(site, query) {
    return _.deburr(site.name.toLowerCase()).indexOf(query) != -1;
  },

  _buildTree: function(sites, query, selected_uuid) {
    var sitesByUuid = {};
    var roots = [];
    var selected = null;
    var matchedSites = [];
    var exp = JSON.parse(localStorage.getItem('sidebar_state') || '{}');
    query = _.deburr(query).toLowerCase();

    // prepares a matchedSites with all sites that match query
    // but it prepares a children property on each site for
    // building later the tree
    _.each(sites, function(site){
      if (query != '' && !this._siteMatch(site, query)) return;
      matchedSites.push(site);
      sitesByUuid[site.uuid] = site;
      site.children = [];
      site.selected = site.uuid == selected_uuid;
      site.expanded = exp[site.uuid]=='open' || false;
      if (site.selected) {
        selected = site;
      }
    }.bind(this));

    // builds a tree with all matchedSites and with the children
    // information. If parent is not present, it is considered a root.
    // Roots may vary depending on the query argument due to non-match of parents.
    // TODO what should happen in Match1 -> NonMatch1 -> Match2 ?
    _.each(matchedSites, function(site) {
      parent = sitesByUuid[site.parent_uuid]
      if (parent) {
        parent.children.push(site)
      } else {
        roots.push(site)
      }
    });

    // This handler remembers where the side bar was scrolled to,
    // in conjunction with a scroll setter from application.js file.
    $('#context_side_bar > div').scroll( function()
      {
        if( $('#context_side_bar > div').html().length )
        {
          var scroll_l = $('#context_side_bar > div').scrollLeft();
          var scroll_t = $('#context_side_bar > div').scrollTop();
          localStorage.setItem('scroll_l', scroll_l);
          localStorage.setItem('scroll_t', scroll_t);
        }
      });

    return [roots, selected];
  },

  selectSite: function(site) {
    if (this.state.selected_site) {
      this.state.selected_site.selected = false;
    }
    site.selected = true;

    this.setState(React.addons.update(this.state, {
      selected_site: { $set: site }
    }), function() {
      this.props.onSiteSelected(site);
    }.bind(this));
  },

  // debounce: http://stackoverflow.com/a/24679479/30948
  componentWillMount: function() {
    this.handleSearchDebounced = _.debounce(function(){
      this.handleSearch.apply(this, [this.state.query]);
    }, 500);
  },

  onSearchChange: function(event) {
    this.setState(React.addons.update(this.state, {
      query: { $set: event.target.value }
    }));
    this.handleSearchDebounced();
  },

  handleSearch: function(query) {
    rootsAndSelected = this._buildTree(this.state.sites, query, this.state.selected_site.uuid);
    // should not change selected site while filtering

    this.setState(React.addons.update(this.state, {
      sitesTree: { $set: rootsAndSelected[0] },
    }));
  },

  onSubsiteCheckboxChange: function() {
    var oldValue = this.state.subsites_selected;
    this.setState(React.addons.update(this.state, {
      subsites_selected: { $set: !oldValue },
    }));
    this.props.onSubsitesToggled(!oldValue);

    if (oldValue == false) {
      localStorage.setItem('sidebar_subsites_included','true');
    } else {
      localStorage.setItem('sidebar_subsites_included','false');
    }
  },

  render: function() {
    return (
      <div>
        <input type="text" className="input-block search-sites" onChange={this.onSearchChange} autoFocus="true" placeholder={I18n.t("components.sites.search_sites_placeholder")} />
        <div>
          <input type="checkbox" id="include-subsites" onChange={this.onSubsiteCheckboxChange} checked={this.state.subsites_selected} />
          <label htmlFor="include-subsites" id="include-subsites">{I18n.t("components.sites.selection_label")}</label>
          <SitesTreeView sites={this.state.sitesTree} onSiteClick={this.selectSite} />
        </div>
      </div>
    )
  }
});

var SitesTreeView = React.createClass({
  onSiteClick: function(site) {
    this.props.onSiteClick(site);
  },
  render: function() {
    return (
      <ul id="sites_tree_body" className="sites-tree-view">
      {this.props.sites.map(function(site){
        return <SiteTreeViewNode key={site.uuid} site={site} onSiteClick={this.onSiteClick}/>;
      }.bind(this))}
      </ul>
    );
  }
});

var SiteTreeViewNode = React.createClass({
  getInitialState: function() {
    return { expanded: this.props.site.expanded };
  },

  toggle: function(event) {
    this.setState(React.addons.update(this.state, {
      expanded: { $set: !this.state.expanded }
    }));
    var zs = JSON.parse( localStorage.getItem('sidebar_state') ) || {};
    zs[ this.props.site.uuid ] = this.state.expanded?'closed':'open';
    localStorage.setItem('sidebar_state', JSON.stringify(zs) );
    event.stopPropagation();
  },

  // This handles a click on an entry in the sidebar.
  // This has been modified to do a call as jquery ajax instead of a page refresh
  onSiteClick: function(event) {
    event.preventDefault();
    var ctx = this.props.site.uuid;
    var url = window.location.href.split('?')[0];
    var link = url+'?nav=true&context='+ctx;
    window.location.href = link;
  },

  render: function() {
    var site = this.props.site;
    var inner = null;

    if (site.children.length > 0 && this.state.expanded) {
      inner = (
        <ul>
        {site.children.map( function(site){
          return <SiteTreeViewNode onSiteClick={this.props.onSiteClick} key={site.uuid} site={site} />;
          }.bind(this))
        }
        </ul>
      );
    }

    if(site.selected) document.getElementById('nav-context').innerHTML = I18n.t("components.sites.at")+site.name;

    return (
      <li key={site.uuid} className={(this.state.expanded ? "expanded" : "") + " " + (site.selected ? "selected" : "")}>
        <a href="#" onClick={this.onSiteClick}>
          {(function(){
            if (site.children.length > 0) {
              return <button onClick={this.toggle} />;
            }
          }.bind(this))()}
          {site.name}
        </a>
        {inner}
      </li>
    );
  }
});
