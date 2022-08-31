vars = page['vars']
html = Nokogiri.HTML(content)

country_of_origin = html.css('div[class*="InfoItem_root"]').find{|s| s.text.include?('Ursprungsland')}&.at('p[class*="InfoItem_description"]')&.text

p country_of_origin


outputs << vars['product'].merge({
    "country_of_origin" => country_of_origin,
    "url" => "https://wolt.com/sv/swe/stockholm/venue/wolt-market-stockholm-city/#{vars['product']['competitor_product_id']}",
})