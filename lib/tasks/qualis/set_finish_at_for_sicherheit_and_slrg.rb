#  Copyright (c) 2012-2025, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Qualis
  class SetFinishAtForSicherheitAndSlrg
    JS_LEITER_LST_JUNGENDLICHE = {
      pbs: 23,
      jubla: 4,
      cevi: 2
    }

    QualiKinds = Struct.new(:jubla, :pbs, :cevi, :with_max_leiter, keyword_init: true) do
      def scope(with_finished: false)
        Qualification
          .where(qualification_kind: qualification_kind_id)
          .then { |s| with_finished ? s : s.where(finish_at: nil) }
          .then { |s| with_max_leiter ? add_max_leiter(s) : s }
      end

      def add_max_leiter(scope)
        scope
          .with(max_leiter: max_leiter)
          .joins("LEFT OUTER JOIN max_leiter ON max_leiter.person_id = qualifications.person_id")
      end

      def max_leiter
        Qualification
          .where(qualification_kind_id: JS_LEITER_LST_JUNGENDLICHE.fetch(wagon_name))
          .group(:person_id).select("person_id, max(finish_at) as finish_at")
      end

      def label
        QualificationKind.find(qualification_kind_id).label
      end

      def qualification_kind_id = send(wagon_name)

      def wagon_name = members.find { |key| Wagons.all.map(&:wagon_name).include?(key.to_s) }
    end

    GLOBAL_QUALI_CHANGES = [
      QualiKinds.new(pbs: 25, jubla: 8, cevi: 3, with_max_leiter: true), # SiBerg
      QualiKinds.new(pbs: 27, jubla: 7, cevi: 5, with_max_leiter: true), # SiWinter
      QualiKinds.new(pbs: 26, jubla: 9, cevi: 4, with_max_leiter: true)  # SiWasser
    ]

    RELATIVE_QUALI_CHANGES = [
      [QualiKinds.new(pbs: 31), 4], # SLRG-Brevet Plus Pool
      [QualiKinds.new(pbs: 33), 4], # SLRG-Modul Fluss
      [QualiKinds.new(pbs: 32), 4], # SLRG-Modul See
      [QualiKinds.new(pbs: 34), 2]  # BLS-AED-SRC Komplettkurs
    ]

    def run
      Qualification.transaction do
        GLOBAL_QUALI_CHANGES.each do |kind|
          delete_obsolete(kind)
          update_finish_at(kind, ..Date.new(2024, 12, 31), Date.new(2025, 12, 31))
          update_finish_at(kind, Date.new(2025, 1, 1).., Date.new(2030, 12, 31))
        end

        RELATIVE_QUALI_CHANGES.each do |kind, years|
          next unless kind.qualification_kind_id
          apply_relative_change(kind, years)
        end
      end
    end

    # rubocop:disable Rails/Output, Layout/LineLength
    def delete_obsolete(kind)
      scope = kind.scope.where(max_leiter: {finish_at: nil})
      people = scope.select("DISTINCT qualifications.person_id").count
      count = Qualification.where(id: scope.select(:id)).delete_all
      puts "Deleted #{count} #{kind.label} for #{people} people" if count.positive?
    end

    def update_finish_at(kind, range, finish_at)
      scope = kind.scope.where(max_leiter: {finish_at: range})
      people = scope.select("DISTINCT qualifications.person_id").count
      count = Qualification.where(id: scope.select(:id)).update_all(finish_at:)
      puts "Updated #{count} #{kind.label} to #{finish_at} for #{people} people" if count.positive?
    end

    def apply_relative_change(kind, years)
      people = kind.scope.select("DISTINCT person_id").count
      count = kind.scope.update_all(
        [
          "finish_at = DATE_TRUNC('year', start_at + INTERVAL '? years' + INTERVAL '1 year') - INTERVAL '1 day'",
          years
        ]
      )
      stats = kind.scope(with_finished: true).group("finish_at").order(:finish_at).count
      puts "Updated #{count} #{kind.label} for #{people} people"
      puts stats.transform_keys(&:to_s).to_yaml
    end
    # rubocop:enable Rails/Output, Layout/LineLength
  end
end
