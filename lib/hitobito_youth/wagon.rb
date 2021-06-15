# encoding: utf-8
# frozen_string_literal: true

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module HitobitoYouth
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    # Add a load path for this specific wagon
    config.autoload_paths += %W[
      #{config.root}/app/abilities
      #{config.root}/app/domain
      #{config.root}/app/jobs
    ]

    config.to_prepare do # rubocop:disable Metrics/BlockLength
      # extend application classes here

      # models
      Person.include Youth::Person
      Event.include Youth::Event
      Event::Course.include Youth::Event::Course
      Event::Participation.include Youth::Event::Participation
      Event::ParticipationContactData.include Youth::Event::ParticipationContactData
      Event::Role.include Youth::Event::Role

      TableDisplay::People.register_permission(Person,
                                               :show_full,
                                               :ahv_number,
                                               :j_s_number,
                                               :nationality_j_s)

      # domain
      Event::ParticipationFilter.include Youth::Event::ParticipationFilter
      Event::ParticipantAssigner.include Youth::Event::ParticipantAssigner
      Export::Tabular::Events::List.include Youth::Export::Tabular::Events::List
      Export::Tabular::Events::Row.include Youth::Export::Tabular::Events::Row
      Person::AddRequest::Approver::Event.include Youth::Person::AddRequest::Approver::Event

      # ability
      GroupAbility.include Youth::GroupAbility
      EventAbility.include Youth::EventAbility
      Event::ParticipationAbility.include Youth::Event::ParticipationAbility

      # decorator
      Event::ParticipationDecorator.include Youth::Event::ParticipationDecorator

      # controller
      PeopleFiltersController.include Youth::PeopleFiltersController
      Event::ParticipationsController.include Youth::Event::ParticipationsController

      PeopleController.permitted_attrs += [:nationality_j_s, :ahv_number, :j_s_number]
      EventsController.permitted_attrs += [:tentative_applications]
      Event::KindsController.permitted_attrs += [:kurs_id_fiver, :vereinbarungs_id_fiver]

      Event::ParticipationsController.include Youth::Event::ParticipationsController
      Event::ListsController.include Youth::Event::ListsController
      Event::RolesController.include Youth::Event::RolesController

      # job
      Export::EventParticipationsExportJob.
        include Youth::Export::EventParticipationsExportJob

      # helper
      FilterNavigation::People.include Youth::FilterNavigation::People
      Sheet::Group.include Youth::Sheet::Group
      Sheet::Event.include Youth::Sheet::Event
      Dropdown::PeopleExport.include Youth::Dropdown::PeopleExport
      Dropdown::Event::ParticipantAdd.include Youth::Dropdown::Event::ParticipantAdd

      # serializer
      PersonSerializer.include Youth::PersonSerializer
    end

    initializer 'youth.add_settings' do |_app|
      Settings.add_source!(File.join(paths['config'].existent, 'settings.yml'))
      Settings.reload!
    end

    initializer 'youth.add_inflections' do |_app|
      ActiveSupport::Inflector.inflections do |_inflect|
        # inflect.irregular 'census', 'censuses'
      end
    end

    private

    def seed_fixtures
      fixtures = root.join('db', 'seeds')
      ENV['NO_ENV'] ? [fixtures] : [fixtures, File.join(fixtures, Rails.env)]
    end

  end
end
