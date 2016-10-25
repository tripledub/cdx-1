class FakeSMS
  Message = Struct.new(:from, :to, :body)

  cattr_accessor :messages
  @@messages = []

  def initialize(*args)
  end

  def messages
    self
  end

  def create(options = {})
    @@messages << Message.new(options[:from], options[:to], options[:body])
  end
end
