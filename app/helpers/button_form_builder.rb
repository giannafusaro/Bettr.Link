class ButtonFormBuilder < ActionView::Helpers::FormBuilder
  def button(label, options={})
    default_class = options[:class] || 'button'
    default_type = options[:type] || :submit
    @template.button_tag(label.to_s, type: default_type, class: default_class)
  end

end
