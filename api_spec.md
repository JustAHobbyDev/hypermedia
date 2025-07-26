# Contact
  - __init__
    1. first_name: str
    2. last_name: str
    3. email: str
    4. phone: str
    
  - update
    Updates the contact's details with new values for first name, last name, email, and phone.
    1. first_name: str
    2. last_name: str
    3. email: str
    4. phone: str
    
# ContactsModel
  - __init__
    
  - add_contact
    Adds a new contact to the model's contact list with the provided details.
    1. first_name: str
    2. last_name: str
    3. email: str
    4. phone: str
    
  - get_all_contacts
    Returns the entire list of contacts stored in the model.
    
  - get_contact
    Retrieves a contact from the model by their email address.
    1. email: str
    
  - update_contact
    Updates an existing contact's details in the model using the provided email to locate the contact.
    1. email: str
    2. first_name: str
    3. last_name: str
    4. phone: str
    
  - delete_contact
    Removes a contact from the model based on the provided email address.
    1. email: str
    
