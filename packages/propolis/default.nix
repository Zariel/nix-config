{
  buildGoModule,
  fetchFromGitLab,
}:

buildGoModule rec {
  pname = "propolis";
  version = "0.8.0";

  src = fetchFromGitLab {
    owner = "passelecasque";
    repo = "propolis";
    rev = "v${version}";
    hash = "sha256-Uv2E4YdGXJFz4YQGOGNgqLkBkQi3LcMdW1K0WeOIMzI=";
  };

  vendorHash = "sha256-xXy7cOKROI6EBaLa7mYJtNx4mDO7FDegCdcCL5HTNHY=";

  meta = {
    description = "propolis is a tool that checks the files of FLAC releases.";
    homepage = "https://gitlab.com/passelecasque/propolis";
    mainProgram = "propolis";
  };
}
