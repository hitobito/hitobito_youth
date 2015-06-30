# encoding: utf-8

Fabrication.configure do |config|
  config.fabricator_path = ['spec/fabricators',
                            '../hitobito_youth/spec/fabricators']
  config.path_prefix = Rails.root
end
