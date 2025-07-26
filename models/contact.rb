# frozen_string_literal: true

# Result
module Result
  Success = Struct.new(:action, :message, :data)
  Failure = Struct.new(:action, :message, :data)
end

# DB
class DB
  attr_reader :name, :all

  def initialize(name)
    @name = name
    @all = []
    @id = 1
  end

  def save(entry)
    entry_index = @all.find_index { |e| e.id == entry.id && entry.id }
    if entry_index
      @all[entry_index] = entry
      Result::Success.new(action: :save, message: "Updated #{entry}", data: { id: entry.id })
    else
      entry.instance_variable_set(:@id, @id) # Assign ID for new entries
      @all << entry
      result = Result::Success.new(action: :save, message: "Saved #{entry}", data: { id: @id })
      @id += 1
      result
    end
  end

  def delete(id)
    entry_index = @all.find_index { |entry| entry.id == id }
    return Result::Failure.new(action: :delete, message: "[#{@name}]: id[#{id}] not found", data: { id: id }) unless entry_index
    deleted_entry = @all.delete_at(entry_index)
    Result::Success.new(action: :delete, message: "[#{@name}]: deleted #{deleted_entry}", data: { id: id })
  end

  def find(id)
    found = @all.find { |entry| entry.id == id }
    return Result::Failure.new(action: :find, message: "[#{@name}]: id[#{id}] not found", data: { id: id }) unless found
    Result::Success.new(action: :find, message: "[#{@name}]: found #{found}", data: found)
  end

  def search(query)
    hits = []
    @all.each do |contact|
      if contact.first.include?(query) || contact.last.include?(query) || contact.email.include?(query) || contact.phone.include?(query)
        hits.push(contact)
      end
    end
    if hits
      Result::Success.new(action: :search, message: "[#{name}]: Search Term:#{query}, hits count: #{hits.length}", data: hits)
    end
  end

  private

  attr_writer :id
end

# Contact model
class Contact
  @@contacts = DB.new("db")

  attr_accessor :first, :last, :email, :phone
  attr_reader :id

  @@valid_keys = [:id, :first, :last, :email, :phone]

  def initialize(params)
    @first = params.fetch(:first, "")
    @last = params.fetch(:last, "")
    @email = params.fetch(:email, "")
    @phone = params.fetch(:phone, "")
    @id = nil # ID assigned by DB#save
  end

  def self.all
    @@contacts.all
  end

  def self.find(id)
    @@contacts.find(id)
  end

  def self.search(query)
    response = @@contacts.search(query)
    response.data
  end

  def save
    result = @@contacts.save(self)
    Result::Success.new(action: :save, message: result.message, data: result.data)
  end

  def delete
    result = @@contacts.delete(@id)
    result
  end

  def update(params)
    validation_result = validate_params(params)
    return validation_result if validation_result.is_a?(Result::Failure)

    @first = params[:first] if params.key?(:first)
    @last = params[:last] if params.key?(:last)
    @email = params[:email] if params.key?(:email)
    @phone = params[:phone] if params.key?(:phone)
    Result::Success.new(action: :update, message: "Updated #{self}", data: self)
  end

  def to_s
    "Contact(id: #{@id}, first: #{@first}, last: #{@last}, email: #{@email}, phone: #{@phone})"
  end

  private

  def validate_params(params)
    invalid_keys = params.keys - @@valid_keys
    unless invalid_keys.empty?
      return Result::Failure.new(
        action: :validate_params,
        message: "Invalid keys: #{invalid_keys.join(', ')}. Allowed keys are: #{@@valid_keys.join(', ')}",
        data: { invalid_keys: invalid_keys }
      )
    end

    params.each do |key, value|
      unless value.is_a?(String)
        return Result::Failure.new(
          action: :validate_params,
          message: "Value for #{key} must be a String, got #{value.class}",
          data: { key => value }
        )
      end
    end
    Result::Success.new(action: :validate_params, message: "Valid params", data: self)
  end
end

