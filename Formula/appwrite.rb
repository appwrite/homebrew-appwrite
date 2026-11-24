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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.15.0/appwrite-cli-darwin-arm64"
      sha256 "ac66665852f467c0aba4b66e8780967658cb78e109cb0fbc3d50aa8c7f358984"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.15.0/appwrite-cli-darwin-x64"
      sha256 "abdc9b2547e06455596a87e6869aeaaf0d730196c960690adaeb4560be94a07a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.15.0/appwrite-cli-linux-arm64"
      sha256 "12e1c945291be84d796c931bb88c0420926a83ca592f5f5fb0c3010c3f1779a6"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.15.0/appwrite-cli-linux-x64"
      sha256 "cfc1dec0a307d5c5cc22ddc5fae1ad46cc848ae50f336dbe08a0f0fc392bab1a"
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
