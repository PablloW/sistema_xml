json.extract! document, :id, :user_id, :file, :processed, :created_at, :updated_at
json.url document_url(document, format: :json)
json.file url_for(document.file)
