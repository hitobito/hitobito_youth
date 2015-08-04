# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Export::Csv::Events::Row
  extend ActiveSupport::Concern

  included do
    attr_reader :gender_counts, :state_counts

    alias_method_chain :initialize, :counts
  end

  def initialize_with_counts(entry, gender_counts, state_counts)
    initialize_without_counts(entry)
    @gender_counts = gender_counts
    @state_counts = state_counts
  end

  def male_count
    gender_counts[entry.id]['m']
  end

  def female_count
    gender_counts[entry.id]['w']
  end

  def absent_count
    state_counts[entry.id]['absent']
  end

  def canceled_count
    state_counts[entry.id]['canceled']
  end

  def rejected_count
    state_counts[entry.id]['rejected']
  end

end