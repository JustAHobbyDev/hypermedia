require 'sinatra'

get '/' do
  redirect '/contacts', 303
end

get '/contacts' do
  search = params.get["q"]
  if search.nil? do
    contacts_set = Contact.all()
  else
    contacts_set = Contact.search(search)
  end
end
