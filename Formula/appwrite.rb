class Appwrite < Formula
  desc "Command-line tool for interacting with the Appwrite API"
  homepage "https://appwrite.io"
  version "19.2.0"
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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/#{version}/appwrite-cli-darwin-arm64"
      sha256 "dcbf03b4b5269ad783ea73ca389ed219cf43d8b627df2fdfd3012ce93706b49e"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/#{version}/appwrite-cli-darwin-x64"
      sha256 "b0a66063a2f34dd2b5c19dcb8b6914eeb0bd37cb5fe5395be24a065f7722cd72"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/#{version}/appwrite-cli-linux-arm64"
      sha256 "9f5b0447c51fdd686673307e01daeeb78d2263724bcdfe5ff51e3f14adb82ab1"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/#{version}/appwrite-cli-linux-x64"
      sha256 "2e9f4c101b443ebb94c993fb7fdd12f4473bd85177fae31635ae53f114b15891"
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

    generate_completions_from_executable(bin/"appwrite", "completion")
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/appwrite --help")
    assert_match "compdef", shell_output("#{bin}/appwrite completion zsh")
  end
end
