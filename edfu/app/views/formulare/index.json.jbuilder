json.array!(@formulare) do |formular|
  json.extract! formular, :id, :uid, :transliteration, :transliteration_nosuffix, :uebersetzung, :texttyp, :photo, :photo_pfad, :photo_kommentar, :szeneID, :literatur, :band, :seitenzeile
  json.url formular_url(formular, format: :json)
end
