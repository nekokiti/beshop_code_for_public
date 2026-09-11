class TagsController < ApplicationController
  include CsvImport
  before_action :set_tag, only: %i[show edit update destroy]
  before_action :sign_in_required

  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.my_tags(current_company).page(params[:page])
    #@tags = current_company.tags.page(params[:page])
  end

  # GET /tags/1
  # GET /tags/1.json
  def show() end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  # GET /tags/1/edit
  def edit() end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.new(tag_params)
    @tag.company = current_company

    respond_to do |format|
      if @tag.save
        format.html { redirect_to edit_tag_url(@tag) , notice: 'Tag was successfully created.' }
        format.json { render :show, status: :created, location: @tag }
      else
        format.html { render :new }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tags/1
  # PATCH/PUT /tags/1.json
  def update
    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to edit_tag_url(@tag), notice: 'Tag was successfully updated.' }
        format.json { render :show, status: :ok, location: @tag }
      else
        format.html { render :edit }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to tags_url, notice: 'Tag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def csv_export
    tags = Tag.my_tags(current_company).page(params[:page])
    str_time = Time.zone.now.strftime("%Y%m%d%H%M%S")
    send_data TagsCsvExportService.new(tags).excute, type: 'text/csv; charset=shift_jis', filename: "tags_#{str_time}.csv"
  end

  def csv_import
    file = params[:file]
    msgs = tag_import(file)
    msgs = "csvの取り込みを開始しました。暫くしてからページをリロードして下さい" if msgs.nil?
    respond_to do |format|
      format.html { redirect_to tags_url, danger: msgs}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = current_company.tags.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params.require(:tag).permit(:tag_name, :image_path, :url)
    end
end
