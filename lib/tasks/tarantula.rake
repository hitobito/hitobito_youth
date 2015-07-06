# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

desc 'Crawl app with tarantula'
task :tarantula do
  sh 'rm -rf ../../../tmp/tarantula'
  sh 'rm -rf ../hitobito/tmp/tarantula'
  sh "bash -c \"RAILS_ENV=test #{ENV['APP_ROOT']}/bin/with_mysql " \
     "rake app:tarantula:test\""
end
