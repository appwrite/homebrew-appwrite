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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.10.1/appwrite-cli-darwin-arm64"
      sha256 "54a2329cc6b0d38589240a18268c4f8f03eaa03993bf19708f1e4a6ae199cc90"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.10.1/appwrite-cli-darwin-x64"
      sha256 "c5ea223e3e0178e1762af17ef674c014308516a05e4b36fe5510e0e97ba591ba"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.10.1/appwrite-cli-linux-arm64"
      sha256 "e3b60931deb2d3bd5d38237b77f247701942b719a6f6021781395ad0348183fd"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.10.1/appwrite-cli-linux-x64"
      sha256 "5f96fec9501bb7407e33b0fe01d8799f0afb6eedaa7379873bdcdbbe9a7d4b4f"
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
