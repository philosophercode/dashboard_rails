class ScreenshotterWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(*args)
    @updatedURLS = Website.where('updated_at < ?', 15.minutes.ago)
    # Website.where(:updated_at => (Time.now - 15.minutes)..Time.now)
    puts @updatedURLS
    sitesURLs = @updatedURLS.pluck(:url)
    puts @updatedURLS.pluck(:updated_at)
    # sitesURLs = Website.pluck(:url)
    totalURLs = sitesURLs.length
    puts "#{totalURLs} Websites"
    puts sitesURLs

    screenshot(sitesURLs)
  end


  def screenshot(sitesArr)

    options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    wd = Selenium::WebDriver.for(:chrome, options: options)
    sitesArr.each do |website|


      wd.get(website)

      width  = wd.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
      height = wd.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")
      wd.manage.window.resize_to(width+100, height+500)

      websiteTitle = wd.title
      img = wd.screenshot_as(:png)

      data = wd.find_element(:tag_name, 'html').text
      # data = wd.text
      puts data
      counter = WordsCounted.count(data)
      puts counter.most_frequent_tokens
      puts counter.token_frequency[0,30]
      # wd.close()
      # wd.quit()


      localDir = '/tmp/'

      auth = {
          cloud_name: "isaacs",
          api_key:    "",
          api_secret: "",
          fetch_format: "auto"
      }

      Dir.chdir(localDir) do
          File.open("#{websiteTitle}.png", 'wb') do |fh|
              fh.write img

              image = MiniMagick::Image.open("#{websiteTitle}.png")
              image.resize "1024"
              image.format "png"
              image.write "#{websiteTitle}_scaled.png"

              urlObject = Cloudinary::Uploader.upload("#{image.path}", auth)
              secure_url = urlObject.fetch("secure_url")

              puts secure_url
              puts "#{websiteTitle} Screenshot and Uploaded!"

              websiteNew = Website.find_by(url: website)
              puts websiteNew
              websiteNew.update(urlImage: secure_url, title: websiteTitle)
          end
          File.delete("./#{websiteTitle}.png")
          puts "file deleted"
      end

    end
    wd.quit()
  end
end
