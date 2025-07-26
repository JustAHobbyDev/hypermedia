# spec/contact_spec.rb
require 'rspec'
require_relative '../models/contact' # Adjust path as needed

RSpec.describe DB do
  let(:db) { DB.new("contacts") }

  before(:each) do
    db.instance_variable_set(:@all, [])
    db.instance_variable_set(:@id, 1)
  end

  describe '#initialize' do
    it 'sets name and initializes empty array and id' do
      expect(db.name).to eq("contacts")
      expect(db.all).to eq([])
      expect(db.instance_variable_get(:@id)).to eq(1)
    end
  end

  describe '#save' do
    let(:contact) { Contact.new(first: "Alice", last: "Smith", email: "alice@example.com", phone: "123-456-7890") }

    it 'saves new contact and assigns id' do
      result = db.save(contact)
      expect(result).to be_a(Result::Success)
      expect(result.action).to eq(:save)
      expect(result.message).to eq("Saved #{contact}")
      expect(result.data).to eq({ id: 1 })
      expect(contact.id).to eq(1)
      expect(db.all).to eq([contact])
      expect(db.instance_variable_get(:@id)).to eq(2)
    end

    it 'updates existing contact with matching id' do
      db.save(contact)
      updated_contact = Contact.new(first: "Bob")
      updated_contact.instance_variable_set(:@id, 1)
      result = db.save(updated_contact)
      expect(result).to be_a(Result::Success)
      expect(result.action).to eq(:save)
      expect(result.message).to eq("Updated #{updated_contact}")
      expect(result.data).to eq({ id: 1 })
      expect(db.all).to eq([updated_contact])
      expect(db.all.first.first).to eq("Bob")
      expect(db.instance_variable_get(:@id)).to eq(2) # Unchanged
    end

    it 'saves contact with nil id as new entry' do
      contact.instance_variable_set(:@id, nil)
      result = db.save(contact)
      expect(result).to be_a(Result::Success)
      expect(result.action).to eq(:save)
      expect(result.message).to eq("Saved #{contact}")
      expect(result.data).to eq({ id: 1 })
      expect(contact.id).to eq(1)
      expect(db.all).to eq([contact])
    end
  end

  describe '#delete' do
    let(:contact) { Contact.new(first: "Alice") }

    it 'deletes contact by id and returns Success' do
      db.save(contact)
      result = db.delete(1)
      expect(result).to be_a(Result::Success)
      expect(result.action).to eq(:delete)
      expect(result.message).to eq("[#{db.name}]: deleted #{contact}")
      expect(result.data).to eq({ id: 1 })
      expect(db.all).to be_empty
    end

    it 'returns Failure when id not found' do
      result = db.delete(999)
      expect(result).to be_a(Result::Failure)
      expect(result.action).to eq(:delete)
      expect(result.message).to eq("[contacts]: id[999] not found")
      expect(result.data).to eq({ id: 999 })
      expect(db.all).to be_empty
    end
  end

  describe '#find' do
    let(:contact) { Contact.new(first: "Alice") }

    it 'finds contact by id and returns Success' do
      db.save(contact)
      result = db.find(1)
      expect(result).to be_a(Result::Success)
      expect(result.action).to eq(:find)
      expect(result.message).to eq("[contacts]: found #{contact}")
      expect(result.data).to eq(contact)
      expect(db.all).to eq([contact])
    end

    it 'returns Failure when id not found' do
      result = db.find(999)
      expect(result).to be_a(Result::Failure)
      expect(result.action).to eq(:find)
      expect(result.message).to eq("[contacts]: id[999] not found")
      expect(result.data).to eq({ id: 999 })
      expect(db.all).to be_empty
    end
  end
end

RSpec.describe Contact do
  before(:each) do
    Contact.class_variable_set(:@@contacts, DB.new("contacts"))
    Contact.class_variable_get(:@@contacts).instance_variable_set(:@all, [])
    Contact.class_variable_get(:@@contacts).instance_variable_set(:@id, 1)
  end

  let(:valid_params) { { first: "Alice", last: "Smith", email: "alice@example.com", phone: "123-456-7890" } }

  describe '#initialize' do
    it 'sets attributes and nil id' do
      contact = Contact.new(valid_params)
      expect(contact.id).to be_nil
      expect(contact.first).to eq("Alice")
      expect(contact.last).to eq("Smith")
      expect(contact.email).to eq("alice@example.com")
      expect(contact.phone).to eq("123-456-7890")
    end

    it 'sets default empty strings for missing params' do
      contact = Contact.new({})
      expect(contact.id).to be_nil
      expect(contact.first).to eq("")
      expect(contact.last).to eq("")
      expect(contact.email).to eq("")
      expect(contact.phone).to eq("")
    end
  end

  describe '#all' do
    it 'returns all contacts from DB' do
      contact = Contact.new(valid_params)
      contact.save
      expect(Contact.all).to eq([contact])
    end

    it 'returns empty array when no contacts exist' do
      expect(Contact.all).to eq([])
    end
  end

  describe '#find' do
    it 'returns Success for existing contact' do
      contact = Contact.new(valid_params)
      contact.save
      result = Contact.find(1)
      expect(result).to be_a(Result::Success)
      expect(result.action).to eq(:find)
      expect(result.data).to eq(contact)
      expect(result.message).to eq("[contacts]: found #{contact}")
    end

    it 'returns Failure for non-existent id' do
      result = Contact.find(999)
      expect(result).to be_a(Result::Failure)
      expect(result.action).to eq(:find)
      expect(result.message).to eq("[contacts]: id[999] not found")
      expect(result.data).to eq({ id: 999 })
    end
  end

  describe '#save' do
    it 'saves new contact and assigns id' do
      contact = Contact.new(valid_params)
      result = contact.save
      expect(result).to be_a(Result::Success)
      expect(result.action).to eq(:save)
      expect(result.message).to eq("Saved #{contact}")
      expect(result.data).to eq({ id: 1 })
      expect(contact.id).to eq(1)
      expect(Contact.all).to eq([contact])
    end

    it 'updates existing contact with matching id' do
      contact1 = Contact.new(valid_params)
      contact1.save
      contact2 = Contact.new(first: "Bob")
      contact2.instance_variable_set(:@id, 1)
      result = contact2.save
      expect(result).to be_a(Result::Success)
      expect(result.action).to eq(:save)
      expect(result.message).to eq("Updated #{contact2}")
      expect(result.data).to eq({ id: 1 })
      expect(Contact.all).to eq([contact2])
      expect(Contact.all.first.first).to eq("Bob")
    end
  end

  describe '#delete' do
    it 'deletes contact and returns Success' do
      contact = Contact.new(valid_params)
      contact.save
      result = contact.delete
      expect(result).to be_a(Result::Success)
      expect(result.action).to eq(:delete)
      expect(result.message).to eq("[contacts]: deleted #{contact}")
      expect(result.data).to eq({ id: 1 })
      expect(Contact.all).to be_empty
    end

    it 'returns Failure when contact not found' do
      contact = Contact.new(valid_params)
      result = contact.delete
      expect(result).to be_a(Result::Failure)
      expect(result.action).to eq(:delete)
      expect(result.message).to eq("[contacts]: id[#{contact.id}] not found")
      expect(result.data).to eq({ id: contact.id })
      expect(Contact.all).to be_empty
    end
  end

  describe '#update' do
    let(:contact) { Contact.new(valid_params) }

    it 'updates attributes and returns Success for valid params' do
      contact.save
      result = contact.update(first: "Bob", email: "bob@example.com")
      expect(result).to be_a(Result::Success)
      expect(result.action).to eq(:update)
      expect(result.message).to eq("Updated #{contact}")
      expect(result.data).to eq(contact)
      expect(contact.first).to eq("Bob")
      expect(contact.email).to eq("bob@example.com")
      expect(contact.last).to eq("Smith")
      expect(contact.phone).to eq("123-456-7890")
    end

    it 'returns Failure for invalid keys' do
      result = contact.update(name: "Bob")
      expect(result).to be_a(Result::Failure)
      expect(result.action).to eq(:validate_params)
      expect(result.message).to eq("Invalid keys: name. Allowed keys are: id, first, last, email, phone")
      expect(result.data).to eq({ invalid_keys: [:name] })
      expect(contact.first).to eq("Alice")
    end

    it 'returns Failure for non-string values' do
      result = contact.update(first: 123)
      expect(result).to be_a(Result::Failure)
      expect(result.action).to eq(:validate_params)
      expect(result.message).to eq("Value for first must be a String, got Integer")
      expect(result.data).to eq({ first: 123 })
      expect(contact.first).to eq("Alice")
    end

    it 'updates only provided keys' do
      contact.save
      result = contact.update(first: "Bob")
      expect(result).to be_a(Result::Success)
      expect(result.action).to eq(:update)
      expect(contact.first).to eq("Bob")
      expect(contact.last).to eq("Smith")
      expect(contact.email).to eq("alice@example.com")
      expect(contact.phone).to eq("123-456-7890")
    end
  end

  describe '#validate_params' do
    let(:contact) { Contact.new(valid_params) }

    it 'returns Success for valid params' do
      result = contact.send(:validate_params, first: "Bob", email: "bob@example.com")
      expect(result).to be_a(Result::Success)
      expect(result.action).to eq(:validate_params)
      expect(result.message).to eq("Valid params")
      expect(result.data).to eq(contact)
    end

    it 'returns Failure for invalid keys' do
      result = contact.send(:validate_params, name: "Bob")
      expect(result).to be_a(Result::Failure)
      expect(result.action).to eq(:validate_params)
      expect(result.message).to eq("Invalid keys: name. Allowed keys are: id, first, last, email, phone")
      expect(result.data).to eq({ invalid_keys: [:name] })
    end

    it 'returns Failure for non-string values' do
      result = contact.send(:validate_params, first: 123)
      expect(result).to be_a(Result::Failure)
      expect(result.action).to eq(:validate_params)
      expect(result.message).to eq("Value for first must be a String, got Integer")
      expect(result.data).to eq({ first: 123 })
    end

    it 'returns Success for empty params' do
      result = contact.send(:validate_params, {})
      expect(result).to be_a(Result::Success)
      expect(result.action).to eq(:validate_params)
      expect(result.message).to eq("Valid params")
      expect(result.data).to eq(contact)
    end
  end

  describe '#to_s' do
    it 'returns a string representation of the contact' do
      contact = Contact.new(valid_params)
      contact.save
      expect(contact.to_s).to eq("Contact(id: 1, first: Alice, last: Smith, email: alice@example.com, phone: 123-456-7890)")
    end
  end
end
