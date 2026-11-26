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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.17.0/appwrite-cli-darwin-arm64"
      sha256 "3e39208f4db2e5e97bfcfde2f37b0d73127375297bdaef41c8cd553c63e541eb"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.17.0/appwrite-cli-darwin-x64"
      sha256 "3232d6cf9bcd6c3be8cb4bdb06927d22ac5f39d284c0c657577c05314298c46a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.17.0/appwrite-cli-linux-arm64"
      sha256 "77213ee350ff9d6c86444f01b7704b3dfedbb0a5c4a25fa152618909b63c0377"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.17.0/appwrite-cli-linux-x64"
      sha256 "a4b6d7fe66f53994aa3822a2031b7e0c436f72d2e20f6ff22472c8c73b31c612"
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
