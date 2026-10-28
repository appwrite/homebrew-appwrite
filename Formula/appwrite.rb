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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.10.0/appwrite-cli-darwin-arm64"
      sha256 "7f2f865b482e7e59b573bd3d1dbd7c96e5eb887189c1b250a8fea910a484707a"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.10.0/appwrite-cli-darwin-x64"
      sha256 "cfbf2d5726ab7420e2a11fd141890dde37516e12b5ce63ec14388956b76f6c59"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.10.0/appwrite-cli-linux-arm64"
      sha256 "bac5b480a21e41407414b1d3dc134d2de23fce71e5d6d61f0b57c65874a5dabf"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/28.10.0/appwrite-cli-linux-x64"
      sha256 "e4e27c52d5ac7484ef2505a71c6e14eded7f150aa1b9d30bd7a835093d5d4f2a"
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
