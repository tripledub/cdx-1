module ConfirmationHelper
  def confirm_deletion_button target, entity_type=nil, relations=nil
    can_destroy = !target.respond_to?(:can_destroy?) || target.can_destroy?
    entity_type ||= target.model_name.singular
    
    link_to_if can_destroy, I18n.t('confirmation_helper.btn_delete'), target, method: :delete, data: { confirm: "#{I18n.t('confirmation_helper.confirm_msg')} #{entity_type}. #{I18n.t('confirmation_helper.confirm_question')}" }, class: 'btn-secondary pull-right', title: "#{I18n.t('confirmation_helper.btn_delete')} #{entity_type.capitalize}" do
      relations ||= target.destroy_restrict_associations_with_elements.map{|assoc| assoc.plural_name.humanize(capitalize: false)}.to_sentence.presence || 'entities'
      content_tag :span, I18n.t('confirmation_helper.cannot_delete'), title: "#{entity_type} #{I18n.t('confirmation_helper.has_associated')} #{relations}.", class: 'btn-link not-allowed pull-right'
    end
  end
end
