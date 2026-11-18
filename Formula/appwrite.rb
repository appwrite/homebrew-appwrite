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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.14.0/appwrite-cli-darwin-arm64"
      sha256 "665b89e71cdc9764f2df8c3ca511282eaeeebb574f916ad5104d56adc2eb6da7"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.14.0/appwrite-cli-darwin-x64"
      sha256 "84f427ffd18585bb1b5edcbe0f7d3198847f362abefaa786cf9fd4f1bbf82abf"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.14.0/appwrite-cli-linux-arm64"
      sha256 "ec04b85ed37e3f5056a2272a8ed7796065eaadd5ffa8e5869ac8f01bad300c4d"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.14.0/appwrite-cli-linux-x64"
      sha256 "58430ebda8e19600645d222eddca764ab24eab0708c932724a41d979d64e7e9a"
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
