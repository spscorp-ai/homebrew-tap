class LabAgentDrone < Formula
  desc "Lab RPC Agent CLI - fault-tolerant command execution daemon"
  homepage "https://github.com/spscorp-ai/lab-rpc-agent-cli"
  url "https://github.com/spscorp-ai/lab-rpc-agent-cli/releases/download/v0.1.3/lab-agent-drone-v0.1.3-darwin-amd64.tar.gz"
  sha256 "PLACEHOLDER_SHA256"
  license "MIT"

  depends_on "git"

  def install
    bin.install "lab-agent-drone"
  end

  test do
    system "#{bin}/lab-agent-drone", "--version"
  end
end
