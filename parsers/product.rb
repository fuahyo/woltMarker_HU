
# if page['response_status_code'] != 200 
    
#     if page['refetch_count'] < 2 
#         refetch page['gid']
#     end

#     raise 'too many refetch'
# end


if page['response_status_code'] == 404
    # require 'byebug'; byebug
    url = 'https://prodinfo.wolt.com/'+page['url'].gsub('https://prodinfo.wolt.com/','61780a5b5777202f21085625')
    pages << {
        url: url,
        page_type: 'product',
        fetch_type: 'standard',
        method: 'GET',
        driver:{
            name: 'reparse_products'
        },
        headers: page['headers'],
        http2: true,
        vars: page['vars']
    }
end


require './lib/helpers.rb'

vars = page['vars']
html = Nokogiri.HTML(content)

country_of_origin = html.css('div[class*="InfoItem_root"]').find{|s| s.text.include?('Country of origin')}&.at('p[class*="InfoItem_description"]')&.text


outputs << vars['product'].merge({
    "scraped_at_timestamp" => ((ENV['needs_reparse'] == 1 || ENV['needs_reparse'] == "1") ? (Time.parse(page['fetched_at']) + 1).strftime('%Y-%m-%d %H:%M:%S') : Time.parse(page['fetched_at']).strftime('%Y-%m-%d %H:%M:%S')),
    "country_of_origin" => country_of_origin,
})
