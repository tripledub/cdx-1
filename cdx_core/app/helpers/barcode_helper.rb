require 'barby'
require 'barby/barcode/code_93'
require 'barby/outputter/html_outputter'
require 'barby/outputter/png_outputter'

module BarcodeHelper
  def barcode(code)
    barcode = Barby::Code93.new(code)
    Barby::HtmlOutputter.new(barcode).to_html.html_safe
  end

  def image_barcode(code)
    barcode = Barby::Code93.new(code)
    file = Tempfile.new(['barcode', '.png'])
    outputter = Barby::PngOutputter.new(barcode)
    outputter.height = 35
    outputter.xdim = 2
    file.write outputter.to_png
    file.rewind
    yield file
    file.close
    file.unlink
  end
end
