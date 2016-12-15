# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe 'GroupEducationsHelper' do

  include FormatHelper
  include GroupEducationsHelper
  include LayoutHelper
  include UtilityHelper
  include QualificationsHelper

  subject { joined_qualification_kind_labels(user) }

  let(:user) { people(:top_leader) }
  let(:qualification_kind) { QualificationKind.create!(label: 'chief', validity: 2, reactivateable: 2) }
  let(:qualification) { Fabricate(:qualification, person: user, qualification_kind: qualification_kind) }

  context '#format_qualification_label' do
    
    it 'has no finish_at' do
      qualification_kind.update!(validity: nil, reactivateable: nil)
      qualification
      is_expected.to eq("<span>chief</span>")
    end

    it 'has finish_at in future' do
      qualification.update!(start_at: Time.zone.now )
      is_expected.to eq("<span>chief bis 31.12.#{qualification.finish_at.year}</span>")
    end

    it 'has finish_at in the same year' do
      qualification.update!(start_at: Time.zone.now - 2.years)
      is_expected.to eq("<span class=\"text-warning\">chief bis 31.12.#{qualification.finish_at.year}</span>")
    end

    it 'has finish_at in the past' do
      qualification.qualification_kind.update!(reactivateable: 2)
      qualification.update!(start_at: Time.zone.now - 3.years)
      is_expected.to eq("<span class=\"muted\">chief bis 31.12.#{qualification.finish_at.year}</span>")
    end

    it 'has finish_at in the far past' do
      qualification.qualification_kind.update!(reactivateable: 2)
      qualification.update!(start_at: Time.zone.now - 5.years)
      is_expected.to eq('')
    end

  end
end
