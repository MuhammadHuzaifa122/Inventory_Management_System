class ProductImportService
  def initialize(file)
    @file = file
  end

  def call
    raise "No file uploaded" if @file.blank?

    extension = File.extname(@file.original_filename).downcase

    case extension
    when ".csv"
      Imports::ProductCsvImport.new(@file).import
    when ".xlsx"
      Imports::ProductXlsxImport.new(@file).import
    else
      raise "Unsupported file type"
    end
  end
end
