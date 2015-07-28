# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

Fabrication.configure do |config|
  config.fabricator_path = ['spec/fabricators', '../hitobito_youth/spec/fabricators']
  config.path_prefix = Rails.root
end
