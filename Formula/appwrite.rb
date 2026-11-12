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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.12.0/appwrite-cli-darwin-arm64"
      sha256 "060d2dc2875b6bc20262606ff15cf7b04b89597d2aa00fada97a68b24df5586c"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.12.0/appwrite-cli-darwin-x64"
      sha256 "ccd908881a16085030f61e8fc73d26b9780b66955415d21a1a052eaf1708155f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.12.0/appwrite-cli-linux-arm64"
      sha256 "72dbcdd6d07b68168384be8c75bcca31337db18730699ee92fcaf92852574276"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.12.0/appwrite-cli-linux-x64"
      sha256 "3f1c44739fa20368a3e77fc745cb5aecb82560332dc62f1f0b61ca7f7eae4f3b"
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
