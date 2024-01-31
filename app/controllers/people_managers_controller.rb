# frozen_string_literal: true

#  Copyright (c) 2024, Schweizer Alpen-Club. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

class PeopleManagersController < ApplicationController

  before_action :authorize_action, except: [:index]
  before_action :authorize_class, only: :index
  helper_method :entry, :person

  class_attribute :assoc

  def index
  end

  def new
  end

  def create
    assign_attributes
    if entry.save
      redirect_to redirect_to_path
    else
      render :new
    end
  end

  def destroy
    find_entry.destroy!
    redirect_to redirect_to_path
  end

  private

  def authorize_action
    kind = assoc.to_s.split("_").last.singularize
    action_to_authorize = :"#{action_name}_#{kind}"

    authorize!(action_to_authorize, entry)
  end

  def authorize_class
    authorize!(:index, PeopleManager)
  end

  def assign_attributes
    entry.attributes = model_params
  end

  def entry
    @entry ||= person.send(assoc).build
  end

  def find_entry
    person.send(assoc).find_by(params[:id])
  end

  def person
    @person ||= Person
      .accessible_by(current_ability)
      .find(params[:person_id])
  end
end