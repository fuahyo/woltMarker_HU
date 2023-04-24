require './lib/helpers.rb'

def get_every_second_array(array)
    array.select.with_index{|_,i| (i+1) % 2 == 0}
end

headers = {
    'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'accept-language': 'en-US,en;q=0.9',
    'cache-control': 'no-cache',
    'pragma': 'no-cache',
    'referer': 'https://wolt.com/',
    'sec-ch-ua': '"Chromium";v="104", " Not A;Brand";v="99", "Microsoft Edge";v="104"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'sec-fetch-dest': 'iframe',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-site': 'same-site',
    'upgrade-insecure-requests': '1',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5112.81 Safari/537.36 Edg/104.0.1293.54',
    'accept-encoding': 'gzip, deflate, br'
};


is_full_run = ENV['is_full_run'] == 'true'
vars = page['vars']

json = JSON.parse(content)

categories = json['categories']
if categories.count > 1
    is_sub_category = true
else
    is_sub_category = false
end

# puts json['items'].length
items = json['items']
items.each.with_index(1) do |item, idx|
    item['rank'] = idx
end

items = get_every_second_array(get_every_second_array(get_every_second_array(items))) if !is_full_run
# puts items.length
store_name = json['name']
store_id = json['id']

items.each.with_index(1) do |item, idx|

    id = item['id']

    name = item['name'].gsub(/[[:space:]]/, ' ')
    brand = nil

    if is_sub_category == true
        category_id = json['categories'].first['id']
        category = json['categories'].first['name']
        sub_cat_id = item['category']
        sub_category = categories.select{|c| c['id'] == sub_cat_id}.first['name']
    else
        category_id = item['category']
        category = categories.select{|c| c['id'] == category_id}.first['name']
        sub_category = nil
    end

    # puts id

    customer_price_lc = Float(item['baseprice']) / 100 
    base_price_lc = Float(item['original_price']) / 100 rescue customer_price_lc

    base_price_lc = customer_price_lc if base_price_lc < customer_price_lc
    base_price_lc = customer_price_lc if base_price_lc == 0
    has_discount = base_price_lc != customer_price_lc

    discount_percentage = has_discount ? ((1.0 - (customer_price_lc / base_price_lc)) * 100).round(7) : nil

    puts idx
    is_available = item['quantity_left'] > 0 rescue (item['quantity_left'] == nil ? false : (raise 'edgecase for item["quantity_left"]'))

    def get_size_and_unit(string)
        size_regex = [
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(l)iter(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(l)itre(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(L)itros(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(Galones)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(lt)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(lb)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(Libras)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(Pies³)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(cl)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(ml)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(l)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(gr)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(gl)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(g)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(mg)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\+?\s?(kg)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(oz)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(onz)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(slice[s]?)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(sachet[s]?)(?!\S)/i,   
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(catridge[s]?)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(sheet[s]?)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(stick[s]?)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(bottle[s]?)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(caplet[s]?)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(roll[s]?)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(tip[s]?)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(bundle[s]?)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(pair[s]?)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(set)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(kit)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(box)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(mm)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(cm)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(centimeter)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(m)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(page[s]?)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)\s?(bag)(?!\S)/i,
            /(?<!\S)(?:\d+x)?(\d*[\.,]?\d+)[\s\-]?(inch)(?!\S)/i,
        ] 
        size_regex.find {|sr| string =~ sr}
        std = $1
        size_unit_std = $2
        size_std = std.gsub(',','.').to_f rescue nil
        [std, size_std, size_unit_std]
    end
    
    std, size_std, size_unit_std = get_size_and_unit(name)
    if size_std.nil? && size_unit_std.nil?
        std, size_std, size_unit_std = get_size_and_unit(item['unit_info'])
    end

    if size_unit_std
        size_unit_std = size_unit_std.downcase
    end

    product_pieces_regex = [
        /(\d+)[-\s]?per\s?packs?[\.\)]?(?!\S)/i,
        /(?<!\S)pack\s+of\s+(\d+)(?!\S)/i,
        /(\d+)[-\s]?packs?[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?pcs[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?pieces?[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?tablets?[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?unidades?[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?und[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?uds[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?sobres?[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?paq[\.\)]?(?!\w+)(?!\S)/i,
        /(\d+)[-\s]?tabletas?[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?cápsulas?[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?piezas?[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?ply[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?ks[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?db[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?bags?[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?bars?[\.\)]?(?!\S)/i,
        /(\d+)[-\s]?kapsl[ií][\.\)]?(?!\S)/i,
        /(\d+)[-\s]?vrstv[eé][\.\)]?(?!\S)/i,
        /(\d+)[-\s]?st[\.\)]?(?!\S)/i,
        /(\d+)[-\s]\'s[\.\)]?(?!\S)/i,
        /(?<!\S)x(\d+)(?!\S)/i,
    ]
    find_regex = product_pieces_regex.find {|ppr| name =~ ppr}
    product_pieces = find_regex ? $1.to_i : 1
    product_pieces = 1 if product_pieces == 0
    product_pieces ||= 1


    if product_pieces == 1 && (size_unit_std =~ /litre|liter|Litros|Galones|lt|lb|Libras|l|ml|cl|gr|gl|g|mg|kg|oz|onz/)
        def parse_pieces(string, size_unit_std, std)
            product_pieces_regex = [
                /(?<!\S)#{std}\s?#{size_unit_std}\s?x\s?(\d+)(?!\S)/i,
                /(?<!\S)(\d+)\s?x\s?#{std}\s?#{size_unit_std}(?!\S)/i,
            ].find {|ppr| string =~ ppr}
            product_pieces = product_pieces_regex ? $1.to_i : 1
            product_pieces = 1 if product_pieces == 0
            product_pieces ||= 1
            product_pieces
        end

        product_pieces = parse_pieces(name, size_unit_std, std) if product_pieces == 1 
    end

    

    if product_pieces == 1
        find_regex = product_pieces_regex.find {|ppr| item['unit_info'] =~ ppr}
        product_pieces = find_regex ? $1.to_i : 1
        product_pieces = 1 if product_pieces == 0
        product_pieces ||= 1
    end


    description = item['description']
    rank = item['rank']
    img_url = item['image']
    barcode = id
    
    # finish if id == '62836bbaa4badea9b94e5baf'

    type_of_promotion = nil
    promo_attributes = nil
    is_promoted = false

    is_private_label = (brand =~ /wolt/i) ? false : true
    is_private_label = nil if brand.nil? || brand&.empty?

    item_identifiers = (barcode.nil? || barcode&.empty?) ? nil : {barcode:"'#{barcode}'"}.to_json

    item_attributes = nil
    country_of_origin = nil
    variants = nil

    lat = vars['geo']['latitude'] rescue 59.334122
    long = vars['geo']['longitude'] rescue 18.059795

    store_reviews = {"num_total_reviews": vars['rating']['ratingCount'],"avg_rating": vars['rating']['ratingValue']}.to_json

    product = {
        _collection: "items",
        _id: id,
        competitor_name: "WOLT MARKET",
        competitor_type: "dmart",
        store_name: store_name,
        store_id: store_id,
        country_iso: ENV['country_code'],
        language: Helpers::country_data[ENV['country_code']]['language'],
        currency_code_lc: Helpers::country_data[ENV['country_code']]['currency_code_lc'],
        scraped_at_timestamp: Time.now.strftime("%F %H:%M:%S"),
        competitor_product_id: id,
        name: name,
        brand: brand,
        category_id: category_id,
        category: category,
        sub_category: sub_category.nil? ? nil : sub_category.gsub('💙 ','').gsub(' ⌛',''),
        customer_price_lc: customer_price_lc.to_s,
        base_price_lc: base_price_lc.to_s,
        has_discount: has_discount,
        discount_percentage: discount_percentage,
        rank_in_listing: rank,
        product_pieces: product_pieces,
        size_std: size_std,
        size_unit_std: size_unit_std,
        description: description,
        img_url: img_url,
        barcode: nil,
        sku: nil,
        url: "#{Helpers::country_data[ENV['country_code']]['URL']}/#{id}",
        is_available: is_available,
        crawled_source: "WEB",
        is_promoted: is_promoted,
        type_of_promotion: type_of_promotion,
        promo_attributes: promo_attributes,
        is_private_label: is_private_label,
        latitude: lat.to_s,
        longitude: long.to_s,
        reviews: nil,
        store_reviews: store_reviews,
        item_attributes: item_attributes,
        item_identifiers: nil,
        page_number: page["vars"]["page_number"],
        country_of_origin: country_of_origin,
        variants: variants,
    }
    # puts item['rank']

    if item['has_extra_info']
        pages << {
            url: "https://prodinfo.wolt.com/#{Helpers::country_data[ENV['country_code']]['store_id']}/#{id}?lang=#{Helpers::country_data[ENV['country_code']]['lang']}&themeTextPrimary=rgba%2832%2C+33%2C+37%2C+1%29&themeTextSecondary=rgba%2832%2C+33%2C+37%2C+0.64%29&themeTextTertiary=rgba%2832%2C+33%2C+37%2C+0.40%29&themeSurfaceMain=rgba%28255%2C+255%2C+255%2C+1%29&themeBorderLight=rgba%2832%2C+33%2C+37%2C+0.12%29",
            page_type: 'product',
            fetch_type: 'standard',
            method: 'GET',
            headers: headers,
            http2: true,
            vars: vars.merge({
                "product" => product,
                "parent_gid" => page['gid'],
            }),
        }
    else
        outputs << product
    end

    save_outputs(outputs) if outputs.count > 49
    save_pages(pages) if pages.count > 49
end
