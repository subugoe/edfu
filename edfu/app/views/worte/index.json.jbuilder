json.array!(@worte) do |wort|
  json.extract! wort, :id, :uid, :transliteration, :transliteration_nosuffix, :uebersetzung, :hieroglyph, :weiteres, :belegstellenEdfu, :belegstellenWb, :anmerkung
  json.url wort_url(wort, format: :json)
end
