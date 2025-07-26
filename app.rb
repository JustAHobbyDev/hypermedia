require 'sinatra'
require 'logger'
require 'haml'
require_relative 'models/contact'

logger = Logger.new(STDOUT)
logger.level = Logger::Severity::INFO

configure do
  set :public_folder, Proc.new { File.join(root, 'static') }
end

get '/' do
  redirect '/contacts', 303
end

get '/contacts' do
  query = params[:q]

  if query
    @contacts = Contact.search(query)
  else
    @contacts = Contact.all
  end

  haml :index
end
