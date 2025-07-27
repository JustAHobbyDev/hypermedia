require 'dotenv/load'
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/flash'
require 'logger'
require 'haml'
require_relative 'models/contact'

logger = Logger.new(STDOUT)
logger.level = Logger::Severity::INFO

class ContactApp < Sinatra::Base
  register Sinatra::Flash

  configure do
    set :public_folder, Proc.new { File.join(root, 'static') }
    enable :sessions
    set :session_secret, ENV['SESSION_SECRET']
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

  get '/contacts/new' do
    @contact = Contact.new
    haml :new
  end

  post '/contacts/new' do
    @contact = Contact.new(params)
    @contact.save
    flash[:success] = "Created New Contact!"
    haml :new
  end
end
