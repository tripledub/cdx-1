module PagingHelper
  def has_previous_page
    @page > 1
  end

  def has_next_page
    @page < (@total.to_f / @page_size).ceil
  end

  def previous_page_params
    params.merge("page" => [@page - 1, 1].max)
  end

  def next_page_params
    params.merge("page" => [@page + 1, (@total.to_f / @page_size).ceil].min)
  end

  def paginate_option
    [10, 50, 100].map { |size| ["#{I18n.t('paging_helper.row', count: size)} #{I18n.t('paging_helper.per_page')}", size] }
  end

  PAGE_SIZE_OPTIONS = [10, 50, 100].map { |size| ["#{I18n.t('paging_helper.row', count: size)} #{I18n.t('paging_helper.per_page')}", size] }
end
