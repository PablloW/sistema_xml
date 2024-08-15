class DocumentsController < ApplicationController
  before_action :set_document, only: %i[ show edit update destroy report ]

  # GET /documents or /documents.json
  def index
    @documents = Document.all
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
    
    # Atribuição do usuário logado ao documento
    @document.user = current_user

    respond_to do |format|
      if @document.save
        # Enfileira o job para processamento em background
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

  # GET /documents/1/report
  def report
    respond_to do |format|
      format.html
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def document_params
      params.require(:document).permit(:user_id, :file, :processed)
    end
end