require 'nokogiri'
require 'open-uri'

module StreetEasy
	class Client

		SALE_URL = "http://streeteasy.com/for-sale/soho?sort_by=price_desc"
		RENTAL_URL = "http://streeteasy.com/for-rent/soho?sort_by=price_desc"

		# Accepts a url and returns a json array of listings
		#
		def get_sales
			doc = scrape_page(SALE_URL)

			# We want to ignore all featured listings
			build_listings(doc.css(".listing:not(.featured)"), "Sale")
		end

		def get_rentals
			doc = scrape_page(RENTAL_URL)
			build_listings(doc.css(".listing:not(.featured)"), "Rental")
		end

		# Use Nokogiri to access the DOM for a particular URL.
		#
		def scrape_page(url)
			Nokogiri::HTML(open(url))
		end

		private

		# Iterate over our listings, pulling out individual data from each.
		#
		# Note: This logic should not technically exist in the client.
		#
		def build_listings(listings_html, type)
			listings = []
			listings_html.each do |listing|
				title = listing.children.css("h5 a").text

				# Note: We assume that anything after the '#' is the unit. This seems
				# to be true, but we can't be 100% certain. There could potentially be
				# a cleaner way to identify both the address and unit.
				#
				if title.include?("#")
					address, unit = title.split("#")
				else
					address = title
					unit = "N/A"
				end

				# Pull the listing URL out of the title a tag.
				a_tag = listing.children.css("h5 a")[0]
				url = a_tag.attributes["href"].value

				# Pull the listing price out of the '.price' span
				price = listing.children.css(".price")[0].text

				listings << {
					address: address.strip,
					unit: unit,
					url: url,
					price: price,
					type: type
				}
			end
			listings
		end
	end
end
