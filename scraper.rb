require 'nokogiri'
require 'httparty'
require 'open-uri'



#Hàm dùng để download các ảnh từ web về
def downloadImages(images)
    #Tạo forder dùng để lưu hình ảnh
    path= "/home/minh/scraper/images" 

   #Tạo thư mục chỉ định của người dùng
    Dir.mkdir path unless File.exist? path

    threads = []
    images.each do |curr_image| 
        threads << Thread.new(curr_image){
            open(curr_image[:link]) do |image|
                File.open("#{path}/".concat(curr_image[:link].split('/').last.to_s.split('?').first.to_s),"a+") do |file|
                    file.write(image.read)
                    #cập nhập lại size ảnh
                    curr_image[:size] = image.size.to_s             
                end 
            end

        }
    end
    threads.each{|t| t.join}
end

#Hàm chính dùng để crawl data từ web về
def tomosia_123rf_crawl

    url = "https://www.123rf.com/stock-photo/dog.html?start=1&sti=mwk3081ovjk7062i9c|"
    unparsed_page = HTTParty.get(url)
    parsed_page = Nokogiri::HTML(unparsed_page )
    jobs = Array.new

    list_imgs = parsed_page.css('div.mosaic-main-container') 
    #list_imgs.count = 110 imges
    #Ta sẽ crawl data từ web với số trang tối đa mà ta muốn crawl data   
    puts "Nhập số trang mà bạn cần muốn hiển thị :"
    page = gets.chomp.to_i
    # Key truyền vào
    puts " Nhập khóa mà bạn cần muốn truyền vào :"
    key =  gets.chomp.to_s

    count_page  = 1  
    #Tạo file dùng để ghi những thông tin của file
    File.delete("images.xls") if File.file?("images.xls")
    File.new("images.xls","a+")
    File.open("images.xls","a") do |file|
        file.write("NAME,URL,SIZE,EXTENSION")
        file.write("\n")
    end
    


    while count_page <= page*110
        pagination_url ="https://www.123rf.com/stock-photo/#{key}.html?start=#{count_page}&sti=mwk3081ovjk7062i9c|"
        pagination_unparsed_page = HTTParty.get(pagination_url)
        pagination_parsed_page = Nokogiri::HTML( pagination_unparsed_page  )
        pagination_list_imgs =  pagination_parsed_page.css('div.mosaic-main-container')
        puts "Page :#{count_page}"
        puts pagination_url
        puts " "


         #Ghi những thông tin về ảnh mà ta muốn download được lưu vào trong mảng jobs
        pagination_list_imgs.each do |img_list|
            job={
                name: img_list.css('img').attr('src').text.split('/').last.to_s,
                link: img_list.css('img').attr('src').text,
                size: 'nil',
                extension: img_list.css('img').attr('src').text.split('.').last.to_s.split('?').first.to_s
    
            }   
            jobs << job  
        end
        downloadImages(jobs)
    

        count_page+=110
    end

     #Ghi những thông tin ảnh vào file excel mà ta đã download về được từ mảng jobs
     jobs.each do |curr_image| 
        File.open("images.xls","a+") do |file|
            file.write(curr_image[:name].concat(",").concat(curr_image[:link]).concat(",").concat(curr_image[:size]).concat(",").concat(curr_image[:extension]))
          file.write("\n")
        end
    end
    

end
tomosia_123rf_crawl
