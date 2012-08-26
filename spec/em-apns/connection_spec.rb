# encoding: UTF-8
require "spec_helper"
include HelperMethods
describe "APN" do
  it "receives message" do
    on_request = proc{|args| args.should == {"aps"=>{"alert"=>"test message"}}; EM.stop }
    run_em_apns({request: on_request}) do
      EM::APNS.send_notification("f"*64, alert: "test message")
    end
  end
end
