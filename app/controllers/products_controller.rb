require "faraday"

class ProductsController < ApplicationController
  skip_before_action :verify_authenticity_token, if: -> { action_name == "create" }
  before_action :authenticate_user!
  before_action :set_product, if: -> { %w[show edit update destroy].include?(action_name) }
  before_action :authorize_resource
  include PaginationHelper
  def index
    threshold = ENV["LOW_STOCK_THRESHOLD"].to_i

    db_products = Product.includes(:category)

    db_products = db_products.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    db_products = db_products.where(category_id: params[:category_id]) if params[:category_id].present?

    @products = format_and_paginate_products(
      db_products: db_products,
      page: params[:page]
    )

    @low_stock_products = Product.where("stock <= ?", threshold)
  end
end


  def search
    authorize Product, :index?
    threshold = ENV["LOW_STOCK_THRESHOLD"].to_i
    @products = Product.includes(:category)

    if params[:search].present?
      @products = @products.where("name ILIKE ?", "%#{params[:search]}%")
    end

    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end

    @products = @products.paginate(page: params[:page], per_page: 5)
    @low_stock_products = Product.where("stock <= ?", threshold)

    render partial: "product_table", locals: { products: @products }
  end

  def show; end

def new
  session_id = params[:session_id]

  if session_id.present?
    begin
      session = Stripe::Checkout::Session.retrieve(session_id)

      if session.payment_status == "paid"
        session[:product_payment_session_id] = session_id
      else
        redirect_to new_product_path, alert: "Payment not completed."
        return
      end

    rescue Stripe::InvalidRequestError => e
      Rails.logger.error("Stripe error: #{e.message}")
      redirect_to new_product_path, alert: "Invalid payment session."
      return
    end
  end

  @product = Product.new
  @product.build_image
end

  def edit
    @product = Product.find(params[:id])
    @product.build_image unless @product.image.present?
  end

def create
  @product = Product.new(product_params)

  if session[:product_payment_session_id].present?
    stripe_session = Stripe::Checkout::Session.retrieve(session[:product_payment_session_id])

    # Save full stripe session JSON into jsonb column
    @product.stripe_payment_data = stripe_session.to_hash
  end

  if @product.save
    session.delete(:product_payment_session_id)
    redirect_to products_path, notice: "Product was successfully created."
  else
    render :new
  end
end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: "Product was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.soft_delete
    redirect_to products_path, status: :see_other
  end

  def import
    ProductImportService.call(params[:file])
    redirect_to products_path, notice: "Products imported successfully"
  rescue => e
    redirect_to products_path, alert: "Import failed: #{e.message}"
  end

  def payment_cancelled
    flash[:alert] = "Payment was cancelled."
    redirect_to products_path
  end

  private


  def set_product
    @product = Product.find(params[:id]) if params[:id].present?
  end

  def authorize_resource
    action = action_name.to_sym

    case action
    when :index
      authorize Product
    when :import
      authorize Product, :import?
    when :new, :create
      @product ||= Product.new
      authorize @product
    when :show, :edit, :update, :destroy
      authorize @product
    end
  end

  def product_params
    params.require(:product).permit(
      :name, :sku, :description, :category_id, :price, :stock, image_attributes: [ :file ]
    )
  end
