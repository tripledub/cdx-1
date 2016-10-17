Importer::SingleMessageProcessor.class_eval do
  def process
    if XpertResults::VietnamImporter.valid_gene_xpert_result_and_sample?(@parent.device, @parsed_message)
      XpertResults::VietnamImporter.link_xpert_result(@parsed_message, @parent.device)
    else
      process_automatic_message
    end
  end
end
