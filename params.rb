require 'haml'
require 'tilt/haml'


class MyHamlContext
  attr_accessor

  def initialize(params)
    @params = params
  end
end

params = { 'q' => "search-term" }
haml_context = MyHamlContext.new(params)

# template = File.read("views/index.html.haml")
engine = Haml::Template.new "views/index.html.haml"
puts engine.render Object.new, params: params
