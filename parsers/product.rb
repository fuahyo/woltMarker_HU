require './lib/helpers.rb'

vars = page['vars']
html = Nokogiri.HTML(content)

country_of_origin = html.css('div[class*="InfoItem_root"]').find{|s| s.text.include?('Country of origin')}&.at('p[class*="InfoItem_description"]')&.text


outputs << vars['product'].merge({
    "scraped_at_timestamp" => (ENV['reparse'] == "1" ? (Time.parse(page['fetched_at']) + 1).strftime('%Y-%m-%d %H:%M:%S') : Time.parse(page['fetched_at']).strftime('%Y-%m-%d %H:%M:%S')),
    "country_of_origin" => country_of_origin,
})