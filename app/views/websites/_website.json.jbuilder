json.extract! website, :id, :url, :title, :urlImage, :category_id, :created_at, :updated_at
json.url website_url(website, format: :json)
