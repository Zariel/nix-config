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
    hash = "sha256-FSJvImYc5/yHpRw0ZSIG5BF5qj7ErTIKyCIVkZddOQM=";
  };

  vendorHash = "sha256-ZRxf/k8YteOvq5GdmRCbYUG2dI3VrWCOAX5c6EzIfiQ=";

  meta = {
    description = "propolis is a tool that checks the files of FLAC releases.";
    homepage = "https://gitlab.com/passelecasque/propolis";
    mainProgram = "propolis";
  };
}
