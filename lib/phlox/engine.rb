module Phlox
  class << self
    mattr_accessor :site
  end

  def self.setup(&block)
    yield self
  end

  if defined?(Rails)
    class Engine < ::Rails::Engine
      isolate_namespace Phlox
    end
  end
end
