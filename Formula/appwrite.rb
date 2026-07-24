class Appwrite < Formula
  desc "Command-line tool for interacting with the Appwrite API"
  homepage "https://appwrite.io"
  version "23.1.0"
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
      sha256 "409e09debca9de40985422eefa0f19b79f5c31b643f44d5e2cb9fbb074cc2687"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/#{version}/appwrite-cli-darwin-x64"
      sha256 "94733af7878340c632ae2ac67c478bfd381afe6f0e2c845c9da147f1645a4745"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/#{version}/appwrite-cli-linux-arm64"
      sha256 "3bd3ac602949ed59518921e827378ba1a7d9c81343efb2415a0b4d1f5ad26371"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/#{version}/appwrite-cli-linux-x64"
      sha256 "f4d580c8f63bd04752a475cacaf19d797769e3b921c9d885fd3dabe0c3ae8473"
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
