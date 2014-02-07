module Phlox
  class << self
    mattr_accessor :site, :system_user, :system_password
  end

  def self.setup(&block)
    yield self
    Phlox::Base.site = self.site
  end

  if defined?(Rails)
    class Engine < ::Rails::Engine
      isolate_namespace Phlox
    end
  end
end
