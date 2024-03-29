# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

Rails.application.routes.draw do

  extend LanguageRouteScope

  language_scope do
    resources :people, only: [] do
      scope module: 'person' do
        resources :managers, except: [:edit, :update]
        resources :manageds, except: [:edit, :update]
      end
    end

    resources :groups do
      member do
        scope module: 'group' do
          resources :educations, only: :index
        end
      end

      resources :events, only: [] do # do not redefine events actions, only add new ones
        scope module: 'event' do
          resources :tentatives, only: [:index, :new, :create] do
            get :query, on: :collection
          end

          resources :participations, only: [] do
            collection do
              scope module: :participation_contact_data do
                get 'contact_data/managed' => 'managed#edit'
                post 'contact_data/managed' => 'managed#update'
              end
            end

            member do
              put :cancel
              put :reject
              put :assign
              put :absent
              put :attend
            end
          end
        end
      end
    end

    scope path: 'list_courses', as: 'list_courses' do
      get 'bsv_export' => 'event/lists#bsv_export'
      get 'slrg_export' => 'event/lists#slrg_export'
    end
  end

end
