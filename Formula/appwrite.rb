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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.3.0/appwrite-cli-darwin-arm64"
      sha256 "5186ac657636434f0499a9c83d4870ca187bf3e382bf089a2e70cfe63484fb61"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.3.0/appwrite-cli-darwin-x64"
      sha256 "f921d9ff08d37ff5a97a21554c82f05729dceebb6bf8592c9ec84665ccdc6c6a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.3.0/appwrite-cli-linux-arm64"
      sha256 "a4f7437b2468ffea4c88edb9a423964d9a15d472e5b82f60cc26112716e1b2c8"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.3.0/appwrite-cli-linux-x64"
      sha256 "9160b79a5da400c6d8493fe0dbfc946696a5f1ec5cd4cf99f265ed22787167d3"
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
