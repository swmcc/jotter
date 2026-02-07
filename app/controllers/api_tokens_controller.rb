class ApiTokensController < ApplicationController
  before_action :set_api_token, only: [ :destroy ]

  def index
    @api_tokens = Current.session.user.api_tokens.order(created_at: :desc)
  end

  def new
    @api_token = Current.session.user.api_tokens.build
  end

  def create
    @api_token = Current.session.user.api_tokens.build(api_token_params)

    if @api_token.save
      # Store token temporarily to show it once
      flash[:new_token] = @api_token.token
      redirect_to api_tokens_path, notice: "API token created successfully. Copy it now - you won't see it again!"
    else
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    @api_token.destroy
    redirect_to api_tokens_path, notice: "API token revoked"
  end

  private

  def set_api_token
    @api_token = Current.session.user.api_tokens.find(params[:id])
  end

  def api_token_params
    params.require(:api_token).permit(:name)
  end
end
