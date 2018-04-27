class HardWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(website, websiteID)
    # Do something later
    options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    wd = Selenium::WebDriver.for(:chrome, options: options)

    wd.get(website)

    width  = wd.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
    height = wd.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")
    wd.manage.window.resize_to(width+100, height+500)

    websiteTitle = wd.title
    img = wd.screenshot_as(:png)


    wd.quit()


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
            puts image.data
            image.resize "1024"
            image.format "png"
            image.write "#{websiteTitle}_scaled.png"
            puts image.path
            puts image.data

            urlObject = Cloudinary::Uploader.upload("#{image.path}", auth)
            secure_url = urlObject.fetch("secure_url")
            puts secure_url
            puts "#{websiteTitle} Screenshot and Uploaded!"
            websiteNew = Website.find_by(id: websiteID)
            puts websiteNew
            websiteNew.update(urlImage: secure_url, title: websiteTitle)
        end
        File.delete("./#{websiteTitle}.png")
        puts "file deleted"
    end
  end
end

# HardWorker.perform_in(1.minutes, @Websites.all)