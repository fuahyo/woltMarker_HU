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

scripts = html.css('script[type="application/ld+json"]').select{|s| s.text.include?('ratingValue')}.first

rating_json = JSON.parse(scripts.text)
rating = rating_json['aggregateRating']
geo = rating_json['geo']
address = rating_json['address']
openingHours = rating_json['openingHours']


slug = page['url'].split('/').select{|x| !x.empty?}.last
pages << {
    url: "https://restaurant-api.wolt.com/v4/venues/slug/#{slug}/menu?unit_prices=true&show_weighted_items=true",
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
    }
}