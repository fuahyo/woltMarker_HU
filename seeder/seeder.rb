require './lib/helpers.rb'

pages << {
    url: Helpers::country_data['CZ']['URL'],
    page_type: 'seed',
    fetch_type: 'standard',
    method: 'GET',
    # headers: headers,
    http2: true,
}