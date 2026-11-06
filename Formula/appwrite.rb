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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.11.0/appwrite-cli-darwin-arm64"
      sha256 "35f55ea0be860b23a9fd8cf2e09266cf127cbd78e7888108dc603ac937b72218"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.11.0/appwrite-cli-darwin-x64"
      sha256 "9e2e08d7f1701f83c32a8e3a8442b035e8f4c446dda1a1c3dacf70f341c43733"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.11.0/appwrite-cli-linux-arm64"
      sha256 "fa1aa89871f9f63c671c4ddad2178493662e42063dd9ed411a3748c1c4aeaa6b"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.11.0/appwrite-cli-linux-x64"
      sha256 "5f505bbf03a4505a64607f418e93dcd8f94b2783d16583d0d9119fcea6c00d96"
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
