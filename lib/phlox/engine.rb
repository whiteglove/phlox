module Phlox
  class << self
    mattr_accessor :site, :system_user, :system_password, :drchrono_site, :drchrono_system_user, :drchrono_redirect_uri, :drchrono_system_password, :drchrono_default_office, :drchrono_client_id, :drchrono_client_secret
  end

  def self.setup(&block)
    yield self
    Phlox::Openemr::Base.site = self.site
  end

  if defined?(Rails)
    class Engine < ::Rails::Engine
      isolate_namespace Phlox
    end
  end
end
