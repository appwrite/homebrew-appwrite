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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.2.1/appwrite-cli-darwin-arm64"
      sha256 "1d23fe2cd06ff6784c75a92c1aaabd7d59fcc1582768d76ed96b9545e95f84d0"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.2.1/appwrite-cli-darwin-x64"
      sha256 "1e2ee2590c13ce5636116ec29e3998f5f080cc61ee58d7b90119364f9780bcca"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.2.1/appwrite-cli-linux-arm64"
      sha256 "37e5b1f4fd856ae0c635a995203d168fcd178dae17602067b2cf3fc91465ab2b"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.2.1/appwrite-cli-linux-x64"
      sha256 "b892227fa82222e5ef72626c0dbf8b6be1ac039e1802741e5372d007fc00c885"
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
