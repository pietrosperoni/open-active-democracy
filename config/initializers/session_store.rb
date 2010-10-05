# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_esb_session',
  :secret      => '97666fd8afb06371a3b9f5f9arwerjf949034534uj32j43j9432j493281f20c7b9d0e4abebf0ea6a9999983914582f3cb70d83b03ea1a5d00afeff5ba7d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
