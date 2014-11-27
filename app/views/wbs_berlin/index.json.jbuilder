json.array!(@wb_berlins) do |wb_berlin|
  json.extract! wb_berlin, :id, :uid, :band, :seite_start, :seite_stop, :zeile_start, :zeile_stop, :wort_id
  json.url wb_berlin_url(wb_berlin, format: :json)
end
