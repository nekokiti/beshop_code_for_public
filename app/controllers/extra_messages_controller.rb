class ExtraMessagesController < ApplicationController
  before_action :set_extra_message, only: %i[new show edit update destroy]
  before_action :sign_in_required

  # GET /extra_message/new
  def new
    if @extra_message.nil?
      @extra_message = ExtraMessage.new
    else
      redirect_to edit_extra_message_url(@extra_message)
    end
  end

  # GET /extra_message/1
  # GET /extra_message/1.json
  def show() end

  # GET /extra_message/1/edit
  def edit() end

  # POST /extra_message
  # POST /extra_message.json
  def create
    @extra_message = ExtraMessage.new(extra_message_params)
    @extra_message.company = current_company

    respond_to do |format|
      if @extra_message.save
        format.html { redirect_to edit_extra_message_url(@extra_message) , notice: '確認メールへの追加メッセージを保存しました' }
        format.json { render :show, status: :created, location: @extra_message }
      else
        format.html { render :new }
        format.json { render json: @extra_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /extra_message/1
  # PATCH/PUT /extra_message/1.json
  def update
    respond_to do |format|
      if @extra_message.update(extra_message_params)
        format.html { redirect_to edit_extra_message_url(@extra_message), notice: '確認メールへの追加メッセージを更新しました' }
        format.json { render :show, status: :ok, location: @extra_message }
      else
        format.html { render :edit }
        format.json { render json: @extra_message.errors, status: :unprocessable_entity }
      end
    end
  end

  def send_test_mail
    NotificationMailer.send_confirm_to_user_test(current_company).deliver_now
    flash[:success] = t('.success')
    if current_company.extra_message.nil?
      redirect_to action: 'new'
    else
      redirect_to action: 'edit'
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_extra_message
      @extra_message = current_company.extra_message
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extra_message_params
      params.require(:extra_message).permit(:extra_message)
    end
end
