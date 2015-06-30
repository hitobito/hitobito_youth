# encoding: utf-8

namespace :app do
  namespace :license do
    task :config do
      @licenser = Licenser.new('hitobito_hitobito_youth',
                               'TODO: Customer Name',
                               'https://github.com/hitobito/hitobito_hitobito_youth')
    end
  end
end