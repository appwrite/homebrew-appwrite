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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.18.0/appwrite-cli-darwin-arm64"
      sha256 "016e5c76562266069be255207164d678e9ed08a1104869101974e0acef3e9550"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.18.0/appwrite-cli-darwin-x64"
      sha256 "0426050785709c3a95929448cd6bbe0267e937fac0d397210dda23ebf3d98efa"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.18.0/appwrite-cli-linux-arm64"
      sha256 "35a9aaf3c88ac53fac128e4713718d93c1f1961525274af478a9e8659ec5876a"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.18.0/appwrite-cli-linux-x64"
      sha256 "fbef97e4161fedfc9e427e3dda867699cb5314186d280202895b6cc13b0626dd"
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
