module ApplicationHelper
  def button_form_for(name, *args, &block)
    options = args.extract_options!
    form_for(name, *(args << options.merge(:builder => ButtonFormBuilder)), &block)
  end
end
