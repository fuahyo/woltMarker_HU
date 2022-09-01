require './lib/helpers.rb'

pages << {
    url: Helpers::country_data[ENV['country_code']]['URL'],
    page_type: 'seed',
    fetch_type: 'standard',
    method: 'GET',
    # headers: headers,
    http2: true,
}