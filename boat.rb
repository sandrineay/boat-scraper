require 'open-uri'
require 'nokogiri'
require 'csv'

csv_options = { col_sep: ','}
filepath = XXX

CSV.open(filepath, 'wb', csv_options) do |csv|
  csv << ['id', 'Make', 'Model', 'Year', 'Condition', 'Price', 'Currency', 'Type', 'Class', 'Length', 'Fuel Type', 'Hull Material', 'Location', 'Tax Status', 'url']
  for number in 1..625
    puts "Scraping page #{number}..."
    url = "https://uk.boats.com/boats-for-sale/?boat-type=sail&page=#{number}"
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)
    links = html_doc.search('.boat-listings a').map{|link| link.attribute('href').value}.select{|link| link.include?("sailing-boats")}
    full_links = links.map{|link| "https://uk.boats.com#{link}"}
    full_links.each do |url|
      html_file = open(url).read
      html_doc = Nokogiri::HTML(html_file)
      data = {}
      html_doc.search('#boat-details th').each_with_index do |key, index|
        data[key.text.downcase.gsub(' ', '-')] = html_doc.search('#boat-details td')[index].text
      end
      csv << [
              url.split("-")[-1][0..-2].to_i,
              data['make'],
              data['model'],
              data['year'],
              data['condition'],
              data['price'][1..-1].delete(',').to_i,
              data['price'][0],
              data['type'], data['class'],
              data['length'],
              data['fuel-type'],
              data['hull-material'],
              data['location'],
              data['tax-status'],
              url
            ]
    end
    sleep(10)
    puts "... done with page #{number}!"
  end
end
