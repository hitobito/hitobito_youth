#  Copyright (c) 2012-2025, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Qualis
  class SetFinishAtForSicherheitAndSlrg
    QualiKinds = Struct.new(:jubla, :pbs, :cevi, keyword_init: true) do
      def scope(with_finished: false)
        Qualification
          .where(qualification_kind: qualification_kind_id)
          .then { |s| with_finished ? s : s.where(finish_at: nil) }
      end

      def label
        QualificationKind.find(qualification_kind_id).label
      end

      def qualification_kind_id
        members
          .find { |key| Wagons.all.map(&:wagon_name).include?(key.to_s) }
          .then { |key| send(key) }
      end
    end

    GLOBAL_QUALI_CHANGES = [
      QualiKinds.new(pbs: 25, jubla: 8, cevi: 3), # SiBerg
      QualiKinds.new(pbs: 27, jubla: 7, cevi: 5), # SiWinter
      QualiKinds.new(pbs: 26, jubla: 9, cevi: 4)  # SiWasser
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
          apply_global_change(kind)
        end
        RELATIVE_QUALI_CHANGES.each do |kind, years|
          next unless kind.qualification_kind_id
          apply_relative_change(kind, years)
        end
      end
    end

    # rubocop:disable Rails/Output, Layout/LineLength
    def apply_global_change(kind)
      finish_at = Date.new(2029, 12, 31)
      people = kind.scope.select("DISTINCT person_id").count
      count = kind.scope.update_all(finish_at:)
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
