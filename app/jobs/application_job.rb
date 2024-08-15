class ProcessDocumentJob
  include Sidekiq::Job

  def perform(document_id)
    document = Document.find(document_id)
    xml_content = Nokogiri::XML(document.file.download)

    # Extraia e processe os dados aqui

    document.update(processed: true)
  end
end

