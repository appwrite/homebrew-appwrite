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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.16.0/appwrite-cli-darwin-arm64"
      sha256 "ae4d15e2a9e3c2cc16d933c9bf38c8c3def213d797cab25e415903246d1eedaa"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.16.0/appwrite-cli-darwin-x64"
      sha256 "bf7b7ff29ebc891fd948668dbc8bb6e3a39109eff3be8c059c984703074269a0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.16.0/appwrite-cli-linux-arm64"
      sha256 "4b2d7121cf0789fc14f4f90b3bfc1c5cb7aecfbff4a7ef223969ceebd692428f"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.16.0/appwrite-cli-linux-x64"
      sha256 "528b75e2444969eee2d3e256d07fe6b7370aecf97a4fe0d156605a69581fb89d"
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
