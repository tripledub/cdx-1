class TestsController < ApplicationController
  include Policy::Actions

  before_filter :load_filter_resources

  before_filter do
    head :forbidden unless has_access_to_test_results_index?
  end

  protected

  def load_filter_resources
    _institutions, @sites, @devices = Policy.condition_resources_for(QUERY_TEST, TestResult, current_user).values
    @sites = @sites.within(@navigation_context.entity, @navigation_context.exclude_subsites)
    @devices = @devices.within(@navigation_context.entity, @navigation_context.exclude_subsites)
    @localization_helper.devices_by_uuid = @devices_by_uuid = @devices.index_by &:uuid
  end

  def get_hostname
    request.host || 'www.thecdx.org'
  end
end
