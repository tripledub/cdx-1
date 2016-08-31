module ApplicationHelper
  define_component :card, sections: [:top, :actions, :bottom], attributes: [:image]
  define_component :cdx_table, sections: [:columns, :thead, :tbody, :actions], attributes: [:title]
  define_component :empty_data, sections: [:body] ,attributes: [:icon, :title]
  define_component :setting_card, sections: [:body], attributes: [:title, :href, :icon]

  define_component :cdx_tabs do |c|
    c.section :headers, multiple: true, component: :cdx_tabs_header
    c.section :contents, multiple: true
  end
  define_component :cdx_tabs_header, attributes: [:title, :url]

  ViewComponents::ComponentsBuilder::Component.classes[:cdx_tabs].class_eval do
    def tab(options, &block)
      self.header options
      if block_given?
        self.content &block
      else
        self.content {}
      end
    end
  end

  define_component :cdx_select, attributes: [:form, :name, :value, :class]
  ViewComponents::ComponentsBuilder::Component.classes[:cdx_select].class_eval do
    def item(value, label)
      @data[:items] ||= []
      @data[:items] << {value: value.to_s, label: label}
    end

    def items(values, value_attr = nil, label_attr = nil)
      if values.is_a?(Hash)
        # Mimic `options_for_select` behaviour
        values.each do |label, value|
          self.item(value, label)
        end
        return values
      end

      values.each do |value|
        if value.is_a?(Array)
          # Mimic `options_for_select` behaviour
          self.item(value[1], value[0])
        else
          item_value = resolve(value, value_attr)
          item_label = resolve(value, label_attr)
          self.item(item_value, item_label)
        end
      end
    end

    private

    def resolve(obj, attr)
      if attr.nil?
        obj
      elsif obj.is_a?(Hash)
        obj[attr]
      else
        obj.send(attr)
      end
    end
  end
end
