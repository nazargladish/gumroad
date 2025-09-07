# frozen_string_literal: true

class Products::AffiliatedController < Sellers::BaseController
  before_action :authorize
  before_action :set_affiliate_account, only: [:destroy]

  def index
    @title = "Products"
    @props = AffiliatedProductsPresenter.new(current_seller,
                                             query: affiliated_products_params[:query],
                                             page: affiliated_products_params[:page],
                                             sort: affiliated_products_params[:sort])
                                        .affiliated_products_page_props
    respond_to do |format|
      format.html
      format.json { render json: @props }
    end
  end

  def destroy
    @affiliate_account.mark_deleted!
    AffiliateMailer.direct_affiliate_self_removal(@affiliate_account.id).deliver_later
    render json: { success: true }
  end

  private
    def authorize
      super([:products, :affiliated])
    end

    def affiliated_products_params
      params.permit(:query, :page, sort: [:key, :direction])
    end

    def set_affiliate_account
      @affiliate_account = current_seller.direct_affiliate_accounts.alive.find_by_external_id(params[:id])
      e404_json if @affiliate_account.nil? || @affiliate_account.affiliate_user != current_user
    end
end
