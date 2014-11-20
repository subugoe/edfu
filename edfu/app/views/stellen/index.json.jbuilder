json.array!(@stellen) do |stelle|
  json.extract! stelle, :id, :uid, :tempel, :band, :bandseite, :bandseitezeile, :seite_start, :seite_stop, :zeile_start, :zeile_stop, :stelle_anmerkung, :stelle_unsicher, :start, :stop, :zerstoerung, :freigegeben
  json.url stelle_url(stelle, format: :json)
end
