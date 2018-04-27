class WebsitesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_website, only: [:show, :edit, :update, :destroy]

  # GET /websites
  # GET /websites.json
  def index
    @websites = Website.all
  end

  # GET /websites/1
  # GET /websites/1.json
  def show
  end

  # GET /websites/new
  def new
    # @website = Website.new
    @website = current_user.websites.build
  end

  # GET /websites/1/edit
  def edit
  end

  # POST /websites
  # POST /websites.json
  def create
    @website = current_user.websites.build(website_params)
    
    #     if @post.save
    #       flash[:success] = "Your post has been created!"
    #       redirect_to posts_path
    #     else
    #       flash[:alert] = "Your new post couldn't be created!  Please check the form."
    #       render :new

    # @website = Website.new(website_params)

    respond_to do |format|
      if @website.save
        format.html { redirect_to @website, notice: 'Website was successfully created.' }
        format.json { render :show, status: :created, location: @website }
      else
        format.html { render :new }
        format.json { render json: @website.errors, status: :unprocessable_entity }
      end
    end

    # websiteNew = Website.find_by(url: @website.url)
    # websiteNew.update(urlImage: FetchWebsiteJob.perform_later(@website.url))

    # FetchWebsiteJob.perform_later(@website.url, @website.id)
    HardWorker.perform_async(@website.url, @website.id)
  end

  # PATCH/PUT /websites/1
  # PATCH/PUT /websites/1.json
  def update
    respond_to do |format|
      if @website.update(website_params)
        format.html { redirect_to @website, notice: 'Website was successfully updated.' }
        format.json { render :show, status: :ok, location: @website }
      else
        format.html { render :edit }
        format.json { render json: @website.errors, status: :unprocessable_entity }
      end
    end
    # FetchWebsiteJob.perform_later(@website.url, @website.id)
    HardWorker.perform_async(@website.url, @website.id)
  end

  # DELETE /websites/1
  # DELETE /websites/1.json
  def destroy
    @website.destroy
    respond_to do |format|
      format.html { redirect_to websites_url, notice: 'Website was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # resources :websites, path: '/websites/webdiv'

  # namespace :webdiv do
  #   resources :websites, path: '/websites/webdiv'
  # end





  private
    # Use callbacks to share common setup or constraints between actions.
    def set_website
      @website = Website.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def website_params
      params.require(:website).permit(:url, :title, :urlImage, :category_id)
    end
end
