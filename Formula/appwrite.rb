class Appwrite < Formula
  desc "Command-line tool for interacting with the Appwrite API"
  homepage "https://appwrite.io"
  version "26.0.0"
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
      sha256 "a01481bb16bdb954a434a884a6fcfca4e33a600624d79b77fd9c0785b2763dfd"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/#{version}/appwrite-cli-darwin-x64"
      sha256 "b0e35d97e0cb820d9e14973f8cd2806c5afa234ef801120b4c06f21b3df7eef7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/#{version}/appwrite-cli-linux-arm64"
      sha256 "52819f05687907f674f73eb4818d9e6b92ccf3b0fd49f3a71a371fc57f997ca6"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/#{version}/appwrite-cli-linux-x64"
      sha256 "0941f9aa47791eea92670cfddc7ed0c96a3e3ed600494e9671da7b86bfdd6829"
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
    assert_match "Usage:", shell_output("#{bin}/appwrite --help")
    assert_match "compdef", shell_output("#{bin}/appwrite completion zsh")
  end
end
