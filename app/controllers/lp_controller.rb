class LpController < ApplicationController
  def index()
    redirect_to action: :maintenance and return
    @form = Form::LpForm.new
  end

  def maintenance() end

  def mail_send
    @form = Form::LpForm.new(lp_form_params)
    if @form.valid?
      data = lp_form_params.to_h
      LpMailer.thanks_mail_from_lp(data).deliver_later
      LpMailer.accept_mail_from_lp(data).deliver_later
      @form = Form::LpForm.new
      flash[:success] = t('lp.index.form.thanks_msg')
      redirect_to action: 'index'
    else
      render :index
    end
  end

  private

  def lp_form_params
    params.require(:form_lp_form).permit(:name, :email, :tel, :is_company, willing: [])
  end

end
