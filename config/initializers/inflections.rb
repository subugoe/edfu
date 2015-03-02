# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'Formular', 'Formulare'
  inflect.irregular 'Stelle', 'Stellen'
  inflect.irregular 'Gott', 'Goetter'
  inflect.irregular 'Ort', 'Orte'
  inflect.irregular 'Wbberlin', 'Wbsberlin'
  inflect.irregular 'Wort', 'Worte'
  inflect.irregular 'Szene', 'Szenen'
  inflect.irregular 'Photo', 'Photos'
  inflect.irregular 'Literatur', 'Literaturen'
  inflect.irregular 'Szene', 'Szenen'
  inflect.irregular 'Szenebild', 'Szenebilder'
  inflect.irregular 'Edfulog', 'Edfulogs'
  inflect.irregular 'Fehler', 'Fehler'
end
