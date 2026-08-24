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
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.2.0/appwrite-cli-darwin-arm64"
      sha256 "97627b8df01c791baadd46d380d107834ee2d5b08462439e5f8c8846d9ac993d"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.2.0/appwrite-cli-darwin-x64"
      sha256 "1d21c580ab3d8bb22c06c6ae5402ca094d3da44651741e6017d3050ffbea6cd2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.2.0/appwrite-cli-linux-arm64"
      sha256 "fd96e65963270e2cfbfb31a66b29ab6ac6b57a72a14adbdec9035f9e3f3951ea"
    else
      url "https://github.com/appwrite/sdk-for-cli/releases/download/27.2.0/appwrite-cli-linux-x64"
      sha256 "df375d04198e17614bb47d711cf38f4bef36ccf209d647816fb0a6bbc7f88ea5"
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
