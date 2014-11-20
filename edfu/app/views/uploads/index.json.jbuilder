json.array!(@uploads) do |upload|
  json.extract! upload, :id, :formular, :ort, :gott, :wort
  json.url upload_url(upload, format: :json)
end
