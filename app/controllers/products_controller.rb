class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: %i[show edit update destroy]
  before_action :authorize_resource

  def index
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
    session_id = params[:session_id] || session[:product_payment_session_id]

    if session_id.blank?
      redirect_to products_path, alert: "Please pay $5 to add a product."
      return
    end

    begin
      stripe_session = Stripe::Checkout::Session.retrieve(session_id)
    rescue Stripe::InvalidRequestError => e
      redirect_to products_path, alert: "Invalid payment session."
      Rails.logger.error("Stripe error: #{e.message}")
      return
    end

    if stripe_session.payment_status != "paid"
      redirect_to products_path, alert: "Payment not completed."
      return
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

  if @product.save
    session.delete(:product_payment_session_id) # Clear the payment session after product creation
    redirect_to @product, notice: "Product was successfully created."
  else
    flash.now[:alert] = "There were some issues with your submission."
    render :new, status: :unprocessable_entity
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
end
