require './lib/helpers.rb'

html = Nokogiri.HTML(content)

headers = {
    'accept': 'application/json, text/plain, */*',
    'accept-language': 'en-US,en;q=0.9',
    'app-language': 'sv',
    'cache-control': 'no-cache',
    'clientversionnumber': '1.7.69',
    'origin': 'https://wolt.com',
    'platform': 'Web',
    'pragma': 'no-cache',
    'referer': 'https://wolt.com/',
    'sec-ch-ua': '"Chromium";v="104", " Not A;Brand";v="99", "Microsoft Edge";v="104"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'same-site',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5112.81 Safari/537.36 Edg/104.0.1293.47',
    'accept-encoding': 'gzip, deflate, br'
}

cat_url = html.css('div[data-test-id="navigation-sidebar"] a[class*="sc-32329728-0"]')
scripts = html.css('script[type="application/ld+json"]').select{|s| s.text.include?('ratingValue')}.first

rating_json = JSON.parse(scripts.text)
rating = rating_json['aggregateRating']
geo = rating_json['geo']
address = rating_json['address']
openingHours = rating_json['openingHours']
store_id = content[/https\:\/\/imageproxy.wolt.com\/venue\/([^\/]+)\//, 1]

# cat_url.each do |cat|
#     slug = cat.attr('href').split('/').select{|x| !x.empty?}.last
    
#     pages << {
#         url: "https://restaurant-api.wolt.com/v4/venues/slug/#{Helpers::country_data[ENV['country_code']]['url']}/menu/categories/slug/#{slug}?unit_prices=true&show_weighted_items=true&show_subcategories=true",
#         # url: "https://restaurant-api.wolt.com/v4/venues/slug//menu?unit_prices=true&show_weighted_items=true",
#         page_type: 'listings',
#         fetch_type: 'standard',
#         method: 'GET',
#         headers: headers,
#         http2: true,
#         vars: {
#             page_number: 1,
#             rating: rating,
#             geo: geo,
#             address: address,
#             openingHours: openingHours,
#             store_id: store_id,
#         }
#     }
# end

# slug = html.css('.sc-32329728-0.jLcOl').attr('href').text.split('/').select{|x| !x.empty?}.last
    
pages << {
    # url: "https://restaurant-api.wolt.com/v4/venues/slug/#{Helpers::country_data[ENV['country_code']]['url']}/menu/categories/slug/#{slug}?unit_prices=true&show_weighted_items=true&show_subcategories=true",
    url: "https://restaurant-api.wolt.com/v4/venues/slug/wolt-market-kamppi/menu/categories/slug/lihat-127?show_subcategories=true&show_weighted_items=true&unit_prices=true",
    page_type: 'listings',
    fetch_type: 'standard',
    method: 'GET',
    headers: headers,
    http2: true,
    vars: {
        page_number: 1,
        rating: rating,
        geo: geo,
        address: address,
        openingHours: openingHours,
        store_id: store_id,
    }
}
