class LabAgentDroneLatest < Formula
  desc "Fault-tolerant RPC agent drone for executing coding commands (Latest/Development) (Stable)"
  homepage "https://github.com/spscorp/lab-agent-drone"
  license "MIT"
  version "0.1.5-alpha.6"

  on_macos do
    if Hardware::CPU.arm?
      url "https://packages.buildinlab.ai/homebrew/lab-agent-drone-v#{version}-darwin-arm64.tar.gz"
      sha256 "7b9b713a3748d72b2063937c54d7e85da537cb5e785a902526937ec604ab0139"
    end
    if Hardware::CPU.intel?
      url "https://packages.buildinlab.ai/homebrew/lab-agent-drone-v#{version}-darwin-amd64.tar.gz"
      sha256 "0ff475d6bec466cc45521643f2d0d043a7f8a31533239ec7c1946c0f46ca2e93"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://packages.buildinlab.ai/homebrew/lab-agent-drone-v#{version}-linux-arm64.tar.gz"
      sha256 "5bd330b2d1d73583881305c033486c6ccb9eb4e94a887e014534d83348b960f5"
    end
    if Hardware::CPU.intel?
      url "https://packages.buildinlab.ai/homebrew/lab-agent-drone-v#{version}-linux-amd64.tar.gz"
      sha256 "86591f39dc70d9850294d682cbe3eae9b23ac2e57a481d7de909cfe5709bd465"
    end
  end

  depends_on "git" # Required for git repository detection

  conflicts_with "lab-agent-drone-rc", because: "both install lab-agent-drone binary"
  conflicts_with "lab-agent-drone-latest", because: "both install lab-agent-drone binary"

  def install
    bin.install "lab-agent-drone"

    # Install default configuration template
    (etc/"lab-agent-drone").mkpath
    config_file = etc/"lab-agent-drone/config.toml.example"
    config_file.write config_template unless config_file.exist?
    
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
