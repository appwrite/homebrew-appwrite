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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.12.1/appwrite-cli-darwin-arm64"
      sha256 "b0d0dc7a4ea2f2dc56c1c7490eb82fba040388c6a87da1829dcaf710741a5f4f"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.12.1/appwrite-cli-darwin-x64"
      sha256 "5038e058516031e226b4f1541f350642a3fd9b3a6aabbbe387faa2dea7e94877"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.12.1/appwrite-cli-linux-arm64"
      sha256 "cdd47f073eac24d2b1719c8b21fc494e75b0bd5285616d818c7622cda4ab2492"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.12.1/appwrite-cli-linux-x64"
      sha256 "10e5a6b8442d0837f9ed6fa975b84a617fdcb3435a39d7dff3f05f389cb5e54c"
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
