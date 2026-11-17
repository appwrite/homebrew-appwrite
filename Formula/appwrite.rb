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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.13.3/appwrite-cli-darwin-arm64"
      sha256 "76ff154fee8913bea0e4ad4c87e46ebe8e5fa2ed99c2edd28c266111fdce0a5c"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.13.3/appwrite-cli-darwin-x64"
      sha256 "73d72b1660ffeb215bf2d29f0692af6238603c57c011962c50253c0cc8c24d1c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.13.3/appwrite-cli-linux-arm64"
      sha256 "04428122f10ea590194c05af8de4f4d6fd2d71f9620bd803b327cdff8c6c48cb"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.13.3/appwrite-cli-linux-x64"
      sha256 "d060ac451049f031ef9d67e218eceb384d87006bfb79fc34aedb9f7a1c3a4c0c"
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
