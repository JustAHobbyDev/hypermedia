require 'dotenv/load'
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/flash'
require 'logger'
require 'haml'
require_relative 'models/contact'

class ContactApp < Sinatra::Base
  register Sinatra::Flash

  logger = Logger.new(STDOUT)
  logger.level = Logger::Severity::INFO

  configure do
    set :public_folder, Proc.new { File.join(root, 'static') }
    enable :sessions
    set :session_secret, ENV['SESSION_SECRET']

    contact_data_list = [
      { first: "Jane", last: "Doe", email: "jane.doe@example.com", phone: "555-123-4567" },
      { first: "John", last: "Smith", email: "john.smith@example.com", phone: "555-987-6543" },
      { first: "Alice", last: "Wonderland", email: "alice@example.com", phone: "555-555-1111" },
      { first: "Bob", last: "The Builder", email: "bob@example.com", phone: "555-777-2222" }
    ]

    contact_data_list.each do |contact_data|
      contact = Contact.new(contact_data)
      if contact.save
        logger.info "Seeded contact #{contact.first} #{contact.last}"
      else
        logger.error "Failed to save contact: #{contact}"
      end
    end

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
      logger.info(@contacts)
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
    redirect '/'
  end

  get '/contacts/:id' do
    id = params[:id].to_i
    response = Contact.find(id)
    logger.info(response)
    if response.is_a? Result::Success
      @contact = response.data
      haml :show
    else
      flash[:error] = response.message
      logger.error(response.message)
      redirect '/contacts'
    end
  end

  get '/contacts/:id/edit' do
    id = params[:id].to_i
    response = Contact.find(id)
    logger.info(response)

    if response.is_a? Result::Success
      @contact = response.data
    else
      flash[:error] = response.message
      logger.error(response.message)
    end
    haml :edit
  end

  post '/contacts/:id/edit' do
    id = params[:id].to_i
    response = Contact.find(id)
    logger.info(response)

    if response.is_a? Result::Success
      @contact = response.data
      args = {}
      args[:first] = params.fetch(:first, @contact.first)
      args[:last]  = params.fetch(:last, @contact.last)
      args[:email] = params.fetch(:email, @contact.email)
      args[:phone] = params.fetch(:phone, @contact.phone)
      @contact.update(args)
      redirect  "/contacts/#{@contact.id}"
    end

    flash[:error] = response.message
    logger.error(response.message)
  end

  delete '/contacts/:id' do
    id = params[:id].to_i
    response = Contact.find(id)
    logger.info(response)

    if response.is_a? Result::Success
      @contact = response.data
      deletion = @contact.delete
      if deletion.is_a? Result::Success
        flash[:success] = "Contact Deleted!"
      else
        flash[:error] = deletion.message
      end
    else
      flash[:error] = response.message
    end

    redirect '/contacts', 303
  end
end
