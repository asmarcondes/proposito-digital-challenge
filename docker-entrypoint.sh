#!/bin/bash

ruby parser/main.rb
echo '\n---------------------\n'
bundle exec rackup --host 0.0.0.0 -p 4567
