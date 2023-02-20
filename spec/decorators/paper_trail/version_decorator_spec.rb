# frozen_string_literal: true

#  Copyright (c) 2023, CEVI Schweiz, Pfadibewegung Schweiz,
#  Jungwacht Blauring Schweiz, Pro Natura, Stiftung für junge Auslandschweizer.
#  This file is part of hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe PaperTrail::VersionDecorator, :draper_with_helpers, versioning: true do

  include Rails.application.routes.url_helpers

  let(:top_leader)    { people(:top_leader) }
  let(:bottom_member)    { people(:bottom_member) }
  let(:version)   { PaperTrail::Version.where(main_id: top_leader.id).order(:created_at, :id).last }
  let(:decorator) { PaperTrail::VersionDecorator.new(version) }

  context 'association_change for people_manager' do
    subject { decorator.association_change }

    context 'as manager' do
      it 'builds create text' do
        PeopleManager.create(manager: top_leader, managed: bottom_member)

        is_expected.to eq('<i>Bottom Member</i> wurde als Kind hinzugefügt.')
      end

      it 'builds destroy text' do
        pm = PeopleManager.create(manager: top_leader, managed: bottom_member)
        pm.destroy!

        is_expected.to eq('<i>Bottom Member</i> wurde als Kind entfernt.')
      end
    end

    context 'as managed' do
      it 'builds create text' do
        PeopleManager.create(managed: top_leader, manager: bottom_member)

        is_expected.to eq('<i>Bottom Member</i> wurde als Verwalter*in hinzugefügt.')
      end

      it 'builds destroy text' do
        pm = PeopleManager.create(managed: top_leader, manager: bottom_member)
        pm.destroy!

        is_expected.to eq('<i>Bottom Member</i> wurde als Verwalter*in entfernt.')
      end
    end
  end
end
