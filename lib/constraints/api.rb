class Constraints::Api

  def initialize(options)
    @default = options[:default]
    @headers = "application/extension.bettrlink.v#{options[:version]}"
  end

  def matches?(request)
    @default || request.headers['Accept'].include?(@headers)
  end

end
