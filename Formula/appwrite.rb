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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.0.0/appwrite-cli-darwin-arm64"
      sha256 "70981c493053678a5a7b29400757789a42cc4a99b95ea2bcc4323e48a5bc863f"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.0.0/appwrite-cli-darwin-x64"
      sha256 "4f0b27d442d80e8237a4df72d2209a5e90a23641850786d807c287e828e62c77"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.0.0/appwrite-cli-linux-arm64"
      sha256 "d6349a28c1617a5a9fc521265468acfa9645a7025d88add75b0f12ac1ab07a59"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.0.0/appwrite-cli-linux-x64"
      sha256 "7b5ce7b129840fe80316f41c8ab79cc15b56b1ddc27f210c29d4c893fcc31445"
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
