require 'zip'

class DocumentsController < ApplicationController
  before_action :set_document, only: %i[show edit update destroy report]

  # GET /documents or /documents.json
  def index
    if params[:query].present?
      @documents = Document.joins(:file_attachment => :blob).where("active_storage_blobs.filename LIKE ?", "%#{params[:query]}%")
    else
      @documents = Document.all
    end
  end

  # GET /documents/1 or /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents or /documents.json
  def create
    @document = Document.new(document_params)
    @document.user = current_user

    respond_to do |format|
      if @document.save
        ProcessDocumentJob.perform_async(@document.id)
        format.html { redirect_to document_url(@document), notice: "O documento foi criado com sucesso e está sendo processado." }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1 or /documents/1.json
  def update
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to document_url(@document), notice: "O documento foi atualizado com sucesso." }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1 or /documents/1.json
  def destroy
    @document.destroy!
    respond_to do |format|
      format.html { redirect_to documents_url, notice: "O documento foi destruído com sucesso." }
      format.json { head :no_content }
    end
  end

  # POST /upload_documents
  def upload
    uploaded_file = params[:file]

    if uploaded_file.present? && File.extname(uploaded_file.original_filename) == ".zip"
      temp_file_path = Rails.root.join('tmp', uploaded_file.original_filename)

      # Salva o arquivo ZIP no diretório temporário
      File.open(temp_file_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end

      # Extrai e processa os arquivos XML dentro do ZIP
      begin
        Zip::File.open(temp_file_path) do |zip_file|
          zip_file.each do |entry|
            next unless entry.file? && File.extname(entry.name) == ".xml"

            document = Document.new(user: current_user)
            document.file.attach(io: StringIO.new(entry.get_input_stream.read), filename: entry.name)

            if document.save
              ProcessDocumentJob.perform_async(document.id)
            else
              flash[:alert] ||= []
              flash[:alert] << "Erro ao processar o documento #{entry.name}"
            end
          end
        end
        flash[:notice] = "Os documentos foram importados e estão sendo processados."
      rescue => e
        flash[:alert] = "Erro ao extrair o arquivo ZIP: #{e.message}"
      ensure
        File.delete(temp_file_path) if File.exist?(temp_file_path)
      end
    else
      flash[:alert] = "Por favor, envie um arquivo ZIP válido."
    end

    redirect_to documents_path
  end

  def export_excel
    @document = Document.find(params[:id])
  
    # Criação do arquivo Excel
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
  
    # Adicionando cabeçalhos
    worksheet.add_cell(0, 0, 'Série')
    worksheet.add_cell(0, 1, 'Número da Nota Fiscal')
    worksheet.add_cell(0, 2, 'Data e Hora de Emissão')
    worksheet.add_cell(0, 3, 'Emitente')
    worksheet.add_cell(0, 4, 'Destinatário')
  
    # Adicionando os dados do documento
    worksheet.add_cell(1, 0, @document.serie)
    worksheet.add_cell(1, 1, @document.nNF)
    worksheet.add_cell(1, 2, @document.dhEmi)
    worksheet.add_cell(1, 3, @document.emit)
    worksheet.add_cell(1, 4, @document.dest)
  
    # Adicionando os produtos
    worksheet.add_cell(3, 0, 'Nome')
    worksheet.add_cell(3, 1, 'NCM')
    worksheet.add_cell(3, 2, 'CFOP')
    worksheet.add_cell(3, 3, 'Unidade')
    worksheet.add_cell(3, 4, 'Quantidade')
    worksheet.add_cell(3, 5, 'Valor Unitário')
  
    @document.products.each_with_index do |product, index|
      row = index + 4
      worksheet.add_cell(row, 0, product.name)
      worksheet.add_cell(row, 1, product.ncm)
      worksheet.add_cell(row, 2, product.cfop)
      worksheet.add_cell(row, 3, product.uCom)
      worksheet.add_cell(row, 4, product.qCom)
      worksheet.add_cell(row, 5, product.vUnCom)
    end
  
    # Adicionando os impostos (assumindo que há apenas um imposto por documento)
    if @document.taxes.any?
      tax = @document.taxes.first
      worksheet.add_cell(6 + @document.products.size, 0, 'ICMS')
      worksheet.add_cell(7 + @document.products.size, 0, tax.icms)
      worksheet.add_cell(6 + @document.products.size, 1, 'IPI')
      worksheet.add_cell(7 + @document.products.size, 1, tax.ipi)
      worksheet.add_cell(6 + @document.products.size, 2, 'PIS')
      worksheet.add_cell(7 + @document.products.size, 2, tax.pis)
      worksheet.add_cell(6 + @document.products.size, 3, 'COFINS')
      worksheet.add_cell(7 + @document.products.size, 3, tax.cofins)
    end
  
    # Nome do arquivo e envio
    temp_file = Tempfile.new(["document_report_#{@document.id}", '.xlsx'])
    workbook.write(temp_file.path)
  
    send_file temp_file.path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                              filename: "Relatorio_Documento_#{@document.id}.xlsx",
                              disposition: 'attachment'
  
    temp_file.close
  end
  
  # GET /documents/1/report
  def report
    respond_to do |format|
      format.html
    end
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:user_id, :file, :processed)
  end
end
