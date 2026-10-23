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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.9.0/appwrite-cli-darwin-arm64"
      sha256 "a02ec13004fae56cde03ce110b264c13147a63eb2b652f987f200c619b9e525a"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.9.0/appwrite-cli-darwin-x64"
      sha256 "acd80ce818ff87d0df2a18ea74c32a6214f48026e3d931390bfc0183fa6a3616"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.9.0/appwrite-cli-linux-arm64"
      sha256 "c60eb1f2d066def4602a0598421ce565bc8688e3748f02d9185e80a16c322a98"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.9.0/appwrite-cli-linux-x64"
      sha256 "529e78f1082f473ff78f0d1ec4ffb3bcdaddc95a4fedad5f47b0aff7e857e726"
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
