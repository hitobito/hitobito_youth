#  Copyright (c) 2012-2025, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

namespace :qualis do
  desc "Sets finish_at for Sicherheits and SLRG qualis (pbs#394)"

  task set_finish_at_for_sicherheit_and_slrg: :environment do
    require_relative "qualis/set_finish_at_for_sicherheit_and_slrg"
    Qualis::SetFinishAtForSicherheitAndSlrg.new.run
  end
end
