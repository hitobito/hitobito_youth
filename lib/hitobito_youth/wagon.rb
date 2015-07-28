# encoding: utf-8

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
    config.autoload_paths += %W( #{config.root}/app/abilities
                                 #{config.root}/app/domain
                                 #{config.root}/app/jobs
                             )

    config.to_prepare do
      # rubocop:disable SingleSpaceBeforeFirstArg
      # extend application classes here

      # models
      Person.send :include, Youth::Person
      Event::Course.send :include, Youth::Event::Course
      Event::Participation.send :include, Youth::Event::Participation
      Event::Role.send :include, Youth::Event::Role

      # domain
      Event::ParticipationFilter.send :include, Youth::Event::ParticipationFilter
      Event::ParticipantAssigner.send :include, Youth::Event::ParticipantAssigner

      # ability
      GroupAbility.send :include, Youth::GroupAbility
      EventAbility.send :include, Youth::EventAbility
      Event::ParticipationAbility.send :include, Youth::Event::ParticipationAbility

      # controller
      Event::ParticipationDecorator.send :include, Youth::Event::ParticipationDecorator
      PeopleFiltersController.send :include, Youth::PeopleFiltersController
      Event::ParticipationsController.send :include, Youth::Event::ParticipationsController
      Event::RolesController.send :include, Youth::Event::RolesController

      PeopleController.permitted_attrs += [:nationality_j_s, :ahv_number, :j_s_number]
      EventsController.permitted_attrs += [:tentative_applications]
      Event::KindsController.permitted_attrs += [:kurs_id_fiver, :vereinbarungs_id_fiver]

      # helper
      FilterNavigation::People.send :include, Youth::FilterNavigation::People
      Sheet::Group.send :include, Youth::Sheet::Group
      Sheet::Event.send :include, Youth::Sheet::Event
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
