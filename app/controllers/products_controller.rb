class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
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

def import
  file = params[:file]
  return redirect_to products_path, alert: "Please upload a valid file." if file.blank?

  begin
    ProductImportService.new(file).call
    redirect_to products_path, notice: "Products imported successfully!"
  rescue => e
    Rails.logger.error("Import failed: #{e.message}")
    redirect_to products_path, alert: "There was an error importing the file: #{e.message}"
  end
end



  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

# DELETE /products/1 or /products/1.json
def destroy
  @product.soft_delete

  respond_to do |format|
    format.html { redirect_to products_path, status: :see_other }
    format.json { head :no_content }
  end
end


  private

  def set_product
    @product = Product.find(params[:id])
  end

  private

  def product_params
    params.require(:product).permit(:name, :sku, :description, :category_id, :price, :stock)
  end
end
