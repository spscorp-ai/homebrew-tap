class LabAgentDroneLatest < Formula
  desc "Fault-tolerant RPC agent drone for executing coding commands (Latest/Development) (Stable)"
  homepage "https://github.com/spscorp/lab-agent-drone"
  license "MIT"
  version "0.1.4-alpha.29"

  on_macos do
    if Hardware::CPU.arm?
      url "https://packages.buildinlab.ai/homebrew/lab-agent-drone-v#{version}-darwin-arm64.tar.gz"
      sha256 "3635c83e3a7159a91ec423f1cf3130cb0bffee56e2a03a633257878d6f3775f3"
    end
    if Hardware::CPU.intel?
      url "https://packages.buildinlab.ai/homebrew/lab-agent-drone-v#{version}-darwin-amd64.tar.gz"
      sha256 "4286f163773166e76aa02c15d8d792563fadfab985fbd169203e16631847361c"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://packages.buildinlab.ai/homebrew/lab-agent-drone-v#{version}-linux-arm64.tar.gz"
      sha256 "2466fb7a563fe630ed2bee89b2d04a90f40f0712f98fffb98223fd2211f7ca1f"
    end
    if Hardware::CPU.intel?
      url "https://packages.buildinlab.ai/homebrew/lab-agent-drone-v#{version}-linux-amd64.tar.gz"
      sha256 "f23cd6dcfd65bec240daa7f4bc0f70955aaddd846239d0526411a6b4d5f2c7ae"
    end
  end

  depends_on "git" # Required for git repository detection

  def install
    bin.install "lab-agent-drone"
    
    # Install default configuration template
    (etc/"lab-agent-drone").mkpath
    (etc/"lab-agent-drone/config.toml.example").write config_template
    
    # Install completion scripts if they exist
    if (buildpath/"completions").exist?
      bash_completion.install "completions/lab-agent-drone.bash"
      zsh_completion.install "completions/_lab-agent-drone"
      fish_completion.install "completions/lab-agent-drone.fish"
    end

    # Install man page if it exists
    if (buildpath/"man").exist?
      man1.install "man/lab-agent-drone.1"
    end
  end

  def config_template
    <<~EOS
      # Lab RPC Agent CLI Configuration
      # Copy this file to ~/.config/lab-agent-drone/config.toml or use --config flag

      [agent]
      backend_url = "https://api.buildinlab.ai"
      register_endpoint = "/api/runners/register"
poll_endpoint = "/api/runners/poll"
      poll_interval_secs = 5
      max_retries = 3
      retry_delay_ms = 1000

      [commands]
      timeout_secs = 300
      max_output_size = 10485760  # 10MB
      working_directory = "#{Dir.home}/workspace"

      [system]
      monitor_git = true
      git_scan_interval_secs = 30
      monitor_resources = true
    EOS
  end

  def caveats
    <<~EOS
      To get started with lab-agent-drone:

      1. Set your API token:
         export LAB_API_KEY="your_jwt_token_here"

      2. Create a configuration file (optional):
         mkdir -p ~/.config/lab-agent-drone
         cp #{etc}/lab-agent-drone/config.toml.example ~/.config/lab-agent-drone/config.toml

      3. Edit the configuration file to match your setup

      4. Run the agent:
         lab-agent-drone

      The LAB_API_KEY environment variable is required for authentication.
      The agent will hard fail on startup if this is not set.

      For more information, see: #{homepage}
    EOS
  end

  service do
    run [opt_bin/"lab-agent-drone"]
    environment_variables LAB_API_KEY: "your_token_here"
    working_dir var
    log_path var/"log/lab-agent-drone.log"
    error_log_path var/"log/lab-agent-drone.error.log"
    keep_alive true
    restart_delay 5
  end

  test do
    # Test that the binary is installed and can show help
    assert_match "Fault-tolerant RPC agent CLI", shell_output("#{bin}/lab-agent-drone --help")
    
    # Test version output
    assert_match version.to_s, shell_output("#{bin}/lab-agent-drone --version")
    
    # Test config validation (should fail without LAB_API_KEY)
    output = shell_output("#{bin}/lab-agent-drone --dry-run 2>&1 || true")
    assert_match(/LAB_API_KEY.*required|environment variable/, output)
    
    # Test with mock API key
    ENV["LAB_API_KEY"] = "test_token_12345"
    system bin/"lab-agent-drone", "--dry-run"
  end
end
