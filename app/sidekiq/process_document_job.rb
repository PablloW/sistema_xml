class ProcessDocumentJob #< ApplicationJob
  include Sidekiq::Job

  def perform(document_id)
    document = Document.find(document_id)
    xml_content = Nokogiri::XML(document.file.download)

    # Definição do namespace
    namespace = xml_content.namespaces['xmlns']

    # Extração dos dados do documento fiscal
    document.serie = xml_content.xpath('//nfe:serie', 'nfe' => namespace).text
    document.nNF = xml_content.xpath('//nfe:nNF', 'nfe' => namespace).text
    document.dhEmi = xml_content.xpath('//nfe:dhEmi', 'nfe' => namespace).text
    document.emit = xml_content.xpath('//nfe:emit', 'nfe' => namespace).to_s
    document.dest = xml_content.xpath('//nfe:dest', 'nfe' => namespace).to_s

    # Extração dos produtos
    xml_content.xpath('//nfe:det/nfe:prod', 'nfe' => namespace).each do |prod|
      document.products.create(
        name: prod.xpath('nfe:xProd', 'nfe' => namespace).text,
        ncm: prod.xpath('nfe:NCM', 'nfe' => namespace).text,
        cfop: prod.xpath('nfe:CFOP', 'nfe' => namespace).text,
        uCom: prod.xpath('nfe:uCom', 'nfe' => namespace).text,
        qCom: prod.xpath('nfe:qCom', 'nfe' => namespace).text,
        vUnCom: prod.xpath('nfe:vUnCom', 'nfe' => namespace).text
      )
    end

    # Extração dos impostos
    document.taxes.create(
      icms: xml_content.xpath('//nfe:det/nfe:imposto/nfe:ICMS/nfe:ICMS00/nfe:vICMS', 'nfe' => namespace).text,
      ipi: xml_content.xpath('//nfe:det/nfe:imposto/nfe:IPI/nfe:IPITrib/nfe:vIPI', 'nfe' => namespace).text,
      pis: xml_content.xpath('//nfe:det/nfe:imposto/nfe:PIS/nfe:PISNT/nfe:CST', 'nfe' => namespace).text,
      cofins: xml_content.xpath('//nfe:det/nfe:imposto/nfe:COFINS/nfe:COFINSNT/nfe:CST', 'nfe' => namespace).text
    )

    # Calculo os totalizadores
    document.total_products = document.products.sum('qCom * vUnCom')
    document.total_taxes = document.taxes.sum('icms + ipi + pis + cofins')

    # Atualização do documento p/ processado
    document.update(processed: true)
  end
end