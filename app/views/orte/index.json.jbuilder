json.array!(@orte) do |ort|
  json.extract! ort, :id, :uid, :stelle, :transliteration, :transliteration_nosuffix, :ort, :lokalisation, :anmerkung
  json.url ort_url(ort, format: :json)

  # todo handle stellen
end
