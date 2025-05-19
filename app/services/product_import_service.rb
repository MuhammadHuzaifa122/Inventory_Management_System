# app/services/product_import_service.rb

class ProductImportService
  def self.call(file)
    new(file).call
  end

  def initialize(file)
    @file = file
  end

  def call
    raise ArgumentError, "No file uploaded" if @file.blank?

    import_file_data
  end

  private

  def import_file_data
    case file_extension
    when ".csv"
      Imports::ProductCsvImport.new(@file).import
    when ".xlsx"
      Imports::ProductXlsxImport.new(@file).import
    else
      raise ArgumentError, "Unsupported file type"
    end
  end

  def file_extension
    File.extname(@file.original_filename).downcase
  end
end
