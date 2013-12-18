require 'spec_helper'
require 'evil-chef'

describe EvilChef::Runner do
	subject(:runner) {EvilChef::Runner.new}

	describe "#recipe_eval" do
		it "should run a recipe successfully" do
			FileUtils.rm "/tmp/test.txt" if File.exists? "/tmp/test.txt" 
			runner.recipe_eval do
				log "TEst"
				file "/tmp/test.txt" do
					content "TEST"
				end
			end
			expect(File.read("/tmp/test.txt")).to eq("TEST")
		end
		it "`recipe_eval` should return a run_status object" do
			run_status = runner.recipe_eval do
				log "TEST"
			end
			expect(run_status).to be_kind_of(Chef::RunStatus)
		end

		it "should throw an exception when the recipe cannot compile" do
			expect do
				runner.recipe_eval do
					dlksdsjldsf
				end
			end.to raise_error(NameError)
		end

		it "should return run_status with failure data when recipe fails" do
			run_status = runner.recipe_eval do
				ruby_block "test" do
					block do
						raise RuntimeError.new("test")
					end
				end
			end
			expect(run_status.success?).to be(false)
		end
	end

	it "should expose the node object" do
		expect(runner.node).to be_kind_of(Chef::Node)
	end
end