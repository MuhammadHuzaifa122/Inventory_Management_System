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

  extension = File.extname(file.original_filename).downcase

  begin
  case extension
  when ".csv"
    Product.import_from_csv(file)
  when ".xlsx"
    import_from_xlsx(file)
  else
    return redirect_to products_path, alert: "Unsupported file type. Please upload a .csv or .xlsx file."
  end

  redirect_to products_path, notice: "Products imported successfully!"
  rescue
  redirect_to products_path, alert: "There was an error importing the file. Please check your file format and try again."
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

def import_from_xlsx(file)
  spreadsheet = Roo::Excelx.new(file.path)
  header = spreadsheet.row(1).map(&:downcase)

  name_idx = header.index("name")
  stock_in_idx = header.index("stock in")
  stock_out_idx = header.index("stock out")

  (2..spreadsheet.last_row).each do |i|
    row = spreadsheet.row(i)
    product_name = row[name_idx]&.strip
    stock_in = row[stock_in_idx].to_i
    stock_out = row[stock_out_idx].to_i

    next if product_name.blank?

    product = Product.where("LOWER(name) = ?", product_name.downcase).first

    if product
      product.stock = [ product.stock.to_i + stock_in - stock_out, 0 ].max
      product.save!
    end
  end
end


  def product_params
    params.require(:product).permit(:name, :sku, :description, :category_id, :price, :stock)
  end

# for .csv

def self.import_from_csv(file)
  CSV.foreach(file.path, headers: true) do |row|
    row = row.to_h.transform_keys(&:downcase)
    product_name = row["name"]&.strip
    stock_in = row["stock in"].to_i
    stock_out = row["stock out"].to_i

    next if product_name.blank?

    product = Product.where("LOWER(name) = ?", product_name.downcase).first
    if product
      product.stock += stock_in - stock_out
      product.stock = 0 if product.stock.negative?
      product.save!
    else
      Rails.logger.warn "Product not found: #{product_name}"
    end
  end
end
end
