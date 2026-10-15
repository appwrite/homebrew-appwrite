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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.6.0/appwrite-cli-darwin-arm64"
      sha256 "e649629d25312fbdba2da91a65f8b1e8b6376dbce2072e6b2e9a7cc9ecd9e542"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.6.0/appwrite-cli-darwin-x64"
      sha256 "a16a5d05b2c7f2e45bc8f9738e147c5b8334e7eee4d8fbf3eb4430771d759a74"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.6.0/appwrite-cli-linux-arm64"
      sha256 "c656faedda7129427cbd4094c1f4e206178bccd7758c82b4f1563d27daccec34"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.6.0/appwrite-cli-linux-x64"
      sha256 "a0494b35fcf3fd72eed6b588feae7cc971705e312095157a67c8927b3a7e429f"
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
