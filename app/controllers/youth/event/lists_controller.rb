# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::Event::ListsController
  extend ActiveSupport::Concern

  included do
  end

  def bsv_export_courses
    authorize!(:bsv_export_courses, Event::Course)
    render text: 'haha'
  end

  private

  def load_courses

  end

end
