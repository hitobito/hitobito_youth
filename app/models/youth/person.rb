# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Person
  extend ActiveSupport::Concern

  NATIONALITIES_J_S = %w(CH FL DIV)

  included do
    validates :nationality_j_s, inclusion: { in: NATIONALITIES_J_S, allow_blank: true }
  end
end
