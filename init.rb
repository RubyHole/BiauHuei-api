# frozen_string_literal: true

folders = 'lib,config,models,components,policies,services,controllers'
Dir.glob("./{#{folders}}/init.rb").each do |file|
    require file
end
