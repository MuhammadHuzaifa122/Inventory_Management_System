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

    @low_stock_products = Product.where("stock <= ?", threshold)
  end

  def show; end

  def new
    @product = Product.new
  end

  def edit; end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to @product, notice: "Product was successfully created."
    else
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

  private

  def set_product
    @product = Product.find(params[:id]) if params[:id].present?
  end

  # 🔁 Centralized authorization
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
    params.require(:product).permit(:name, :sku, :description, :category_id, :price, :stock)
  end
end
