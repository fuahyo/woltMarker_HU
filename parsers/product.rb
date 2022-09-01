require './lib/helpers.rb'

vars = page['vars']
html = Nokogiri.HTML(content)

country_of_origin = html.css('div[class*="InfoItem_root"]').find{|s| s.text.include?('Country of origin')}&.at('p[class*="InfoItem_description"]')&.text


outputs << vars['product'].merge({
    "country_of_origin" => country_of_origin,
    "url" => "#{Helpers::country_data[ENV['country_code']]['URL']}/#{vars['product']['competitor_product_id']}",
})