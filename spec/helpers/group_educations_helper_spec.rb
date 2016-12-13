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
  subject { format_qualification_label(label, qualification) }

  let(:user) { people(:top_leader) }
  let(:qualification) { Fabricate(:qualification, person: user) }
  let(:label) { qualification.qualification_kind.label + " " + format_attr(qualification, :finish_at) }

  context '#format_qualification_label' do
    
    it 'has no finish_at' do
      qualification.update(finish_at: nil)
      is_expected.to eq(label)
    end

    it 'has finish_at in future' do
      qualification.update(start_at: DateTime.now - 1.year)
      is_expected.to eq(label)
    end

    it 'has finish_at in the same year' do
      qualification.update(start_at: DateTime.now - 2.year)
      expect(format_qualification_label(label, qualification)).to eq(content_tag(:span, label, class: 'text-warning'))
    end
  end
end
