# Guardfile
# More info at https://github.com/guard/guard#readme

guard 'bundler' do
  watch('Gemfile')
end

guard 'pow' do
  watch('.powenv')
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/.*\.yml$})
  watch(%r{^config/environments/.*\.rb$})
  watch(%r{^config/initializers/.*\.rb$})
  watch(%r{^vendor/assets/*/*.*$})
  watch(%r{^app/assets/images/sprites/*/*.*$})
  watch(%r{^lib/*})
end
