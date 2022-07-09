require "error_handler"

describe ErrorHandler do
  let(:subject) { rescuable.new.process(rules) }
  let(:rules) { [] }
  let(:rescuable) do
    Class.new do
      include ErrorHandler

      def process(rules)
        handle_errors(rules) do
          raise IOError.new "Something went wrong"
        end
      end
    end
  end

  it "is an object" do
    expect(ErrorHandler).to be_a(Object)
  end

  context "when no rules are provided" do
    it "raises the exception" do
      expect { subject }.to raise_error(IOError)
    end
  end

  context "when rules are provided" do
    context "when rule is not a Proc" do
      let(:rules) do
        [
          ->(e) { e.is_a?(IOError) },
          "Not a Proc"
        ]
      end

      it "raises an exception" do
        expect { subject }.to raise_error(ArgumentError, "All rules must be Procs")
      end
    end


    context "when there is only one rule" do
      let(:rules) do
        ->(e) { e.is_a?(IOError) }
      end

      it "is fine if it's not in an array" do
        expect { subject }.not_to raise_error
      end
    end

    context "when all rules match" do
      let(:rules) do
        [
          ->(e) { e.is_a?(IOError) },
          ->(e) { e.message == "Something went wrong" }
        ]
      end

      it "rescues the exception" do
        expect { subject }.not_to raise_error
      end
    end

    context "when some rules match" do
      let(:rules) do
        [
          ->(e) { e.is_a?(IOError) },
          ->(e) { e.message == "Everything is fine" }
        ]
      end

      it "rescues the exception" do
        expect { subject }.not_to raise_error
      end
    end

    context "when no rules match" do
      let(:rules) do
        [
          ->(e) { e.is_a?(ArgumentError) },
          ->(e) { e.message == "Everything is fine" }
        ]
      end

      it "raises the exception" do
        expect { subject }.to raise_error(IOError)
      end
    end
  end
end
