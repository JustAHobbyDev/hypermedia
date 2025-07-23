# models/contact.rb
class Contact
  :attr_accessor

  @@master_id = 1
  @@db = Hash.new do |hash, key|
    hash[@@master_id] = ""
  end

  def initalize(params)
    @id = @@master_id
    @@master_id += 1
    @first = params.fetch(:name, "")
    @last = params.fetch(:last, "")
    @phone = params.fetch(:phone, "")
    @email = params.fetch(:email, "")
  end

  def self.all
    @@db
  end

  def self.find_by(params)
    return @@contacts unless query && !query.empty?

    params.each do |k, v|
      _db = (_db || @@db).select do |contact| 
        contact[k].downcase.include?(v)
      end
    end

    _db
  end
end

class Contacts
  # In a real app, this would query a database
  @@contacts = [
    { id: 1, name: "Alice", email: "alice@example.com" },
    { id: 2, name: "Bob", email: "bob@example.com" },
    { id: 3, name: "Charlie", email: "charlie@example.com" }
  ]

  def self.all
    @@contacts
  end

  def self.filter_by_name(query)
    return @@contacts unless query && !query.empty?
    @@contacts.select { |contact| contact[:name].downcase.include?(query.downcase) }
  end

  # ... other methods like find, create, update, delete
end
