json.array!(@goetter) do |gott|
  json.extract! gott, :id, :uid, :transliteration, :transliteration_nosuffix, :ort, :eponym, :beziehung, :funktion, :band, :seitezeile, :anmerkung
  json.url gott_url(gott, format: :json)
end
