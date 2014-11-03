require 'nokogiri'
require 'open-uri'
require 'json'
require_relative "../lib/street_easy/client"

DATA_FILE_PATH = "./data/import.json"
LIMIT = 10 # Select the first 10 sales and rentals

# We wipe any previously stored data before scrapping and storing additional
# StreetEasy listings.
#
def save_listings(listings)
  File.open(DATA_FILE_PATH, "w") do |file|
    file.write(listings.to_json)
  end
end

client = StreetEasy::Client.new

# In the future, these methods should be pulled out and into
# resource-specific StreetEasy::Client modules.
#
sales = client.get_sales
rentals = client.get_rentals

# Save listings to a json file.
#
listings = sales.first(LIMIT)
listings << rentals.first(LIMIT)

# We save both sale and rental listings into the same JSON file for now
#
save_listings(listings)
