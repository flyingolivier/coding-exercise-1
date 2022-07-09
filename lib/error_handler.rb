module ErrorHandler
  # TODO: implementation
  # #handle_errors should accept a block as an argument that will execute
  # code in the block and conditionally swallow errors given the defined rules
  #
  # Example:
  #
  # class MyClass
  #   include ErrorHandler
  #
  #   def perform
  #     handle_errors do
  #       puts "Do work..."
  #     end
  #   end
  # end

  def handle_errors(rules)
    rules = Array(rules)

    raise ArgumentError.new("All rules must be Procs") unless rules.all?{|r| r.is_a?(Proc)}

    begin
      yield
    rescue => e
      raise e unless rules.any?{ |r| r.(e) }
    end
  end
end
