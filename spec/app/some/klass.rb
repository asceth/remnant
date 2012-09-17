class Some::Klass
  include Some::Module

  def self.world
    'world'
  end

  def yielder
    yield
  end

  def echo(*args)
    args
  end
end
