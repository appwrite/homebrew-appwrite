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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.7.0/appwrite-cli-darwin-arm64"
      sha256 "a53a75ee29a6efac5fc69bc9978a591d8c5cfcffdc05716ecccc99baec6a5b60"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.7.0/appwrite-cli-darwin-x64"
      sha256 "ed07d1b5e65fb040ecfa5649c32a33d375b3cdb4e986898b64cc4419c60bb78f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.7.0/appwrite-cli-linux-arm64"
      sha256 "cf7af200d6fa1531646c4857b139b485045b538873d63850bcbf04f895c7b8e7"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.7.0/appwrite-cli-linux-x64"
      sha256 "7ec7fe5e2a92dda475564d93963b8d12b70900d7db227e1c788550e8688a5188"
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
