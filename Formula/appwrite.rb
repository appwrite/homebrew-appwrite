class Appwrite < Formula
  desc "Command-line tool for interacting with the Appwrite API"
  homepage "https://appwrite.io"
  license "BSD-3-Clause"

  def self.binary_arch
    Hardware::CPU.arm? ? "arm64" : "x64"
  end

  def self.binary_os
    return "darwin" if OS.mac?
    return "linux" if OS.linux?

    raise "Homebrew formula is only supported on macOS and Linux"
  end

  def self.binary_name
    "appwrite-cli-#{binary_os}-#{binary_arch}"
  end

  def self.build_target
    return "mac-#{binary_arch}" if OS.mac?
    return "linux-#{binary_arch}" if OS.linux?

    raise "Homebrew formula is only supported on macOS and Linux"
  end

  head "https://github.com/appwrite/sdk-for-cli.git", branch: "master" do
    depends_on "bun" => :build
  end

  # Release automation injects per-target SHA256 values when publishing binaries.
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.3.0/appwrite-cli-darwin-arm64"
      sha256 "ab5bd4dd102c98cb94f403c78e70d49da2536de841c76b623f53955a9044df0e"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.3.0/appwrite-cli-darwin-x64"
      sha256 "47bae7c727880c1e373bc5b0628628b5583e26808e23ee765ac75b13ad5ff047"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.3.0/appwrite-cli-linux-arm64"
      sha256 "15f3bae7b687ca7ba56b6e342e9976302bbe439fa1493bad351331a93f540770"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.3.0/appwrite-cli-linux-x64"
      sha256 "12ff8ec1884a0b03b78dc1c41fc9f6727799df6b7664866d2c8525f03842b991"
    end
  end

  def install
    if build.head?
      system "bun", "install", "--frozen-lockfile"
      system "bun", "run", self.class.build_target
      bin.install "build/#{self.class.binary_name}" => "appwrite"
    else
      bin.install self.class.binary_name => "appwrite"
    end

    (bin/"appwrite").chmod 0755

    generate_completions_from_executable(bin/"appwrite", "completion")
  end

  test do
    assert_match "USAGE", shell_output("#{bin}/appwrite --help")
    assert_match "compdef", shell_output("#{bin}/appwrite completion zsh")
  end
end
