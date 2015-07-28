# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Event::ParticipationsController, type: :controller do

  let(:user) { people(:top_leader) }
  let(:other_user) { people(:bottom_member) }
  let(:course) { events(:top_course) }

end
