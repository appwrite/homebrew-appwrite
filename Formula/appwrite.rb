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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.13.0/appwrite-cli-darwin-arm64"
      sha256 "10f41b23988f27b7474ee65342936d24d7c4d67c54a5c28103396076f24676b9"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.13.0/appwrite-cli-darwin-x64"
      sha256 "8d6577aee0e2161368e27cec4ac721cd8e5bba22e771089d8e8e0568357e3f04"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.13.0/appwrite-cli-linux-arm64"
      sha256 "66625f8a17a3fa59edfb8e63c6fd160d041c885e374e36669ab12e0128515366"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.13.0/appwrite-cli-linux-x64"
      sha256 "39768431e0969f7356f84b2864214780bc6061f9275f45b78161d998065106f5"
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
