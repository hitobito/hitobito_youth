# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

namespace :app do
  namespace :license do
    task :config do
      @licenser = Licenser.new('hitobito_youth',
                               'Pfadibewegung Schweiz',
                               'https://github.com/hitobito/hitobito_youth')
    end
  end
end
