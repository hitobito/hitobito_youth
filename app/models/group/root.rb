# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

# TODO: rename class to specific name and change all references
class Group::Root < ::Group

  self.layer = true

  # TODO: define actual child group types
  children Group::Root

  ### ROLES

  # TODO: define actual role types
  class Leader < ::Role
    self.permissions = [:layer_and_below_full, :admin]
  end

  class Member < ::Role
    self.permissions = [:group_read]
  end

  roles Leader, Member

end
