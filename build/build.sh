#!/bin/bash
source $HOME/.bash_profile
export RAILS_ENV=test

cd /home/ccrb/.cruise/projects/Phlox/work
bundle install

FAILFAST=true bundle exec rake cruise --trace

ret=$?
exit $ret
