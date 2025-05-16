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
      if params[:file].present?
        import_from_file(params[:file])
        redirect_to products_path, notice: "Products imported successfully!"
      else
        redirect_to products_path, alert: "Please select a file to import."
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

    def import_from_file(file)
      xlsx = Roo::Excelx.new(file.path)
      header = xlsx.row(1).map(&:downcase)

      name_idx = header.index("name")
      stock_in_idx = header.index("stock in")
      stock_out_idx = header.index("stock out")

      (2..xlsx.last_row).each do |i|
        row = xlsx.row(i)
        product_name = row[name_idx]&.strip
        stock_in = row[stock_in_idx].to_i
        stock_out = row[stock_out_idx].to_i

        next if product_name.blank?

        product = Product.where("LOWER(name) = ?", product_name.downcase).first


        if product
          product.stock = product.stock.to_i + stock_in - stock_out
          product.stock = 0 if product.stock < 0
          product.save!
        end
      end
    end

    def product_params
      params.require(:product).permit(:name, :sku, :description, :category_id, :price, :stock)
    end
end
