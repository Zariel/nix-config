{ inputs, ... }:
{
  # Custom packages overlay
  customPackages = final: prev: {
    propolis = final.callPackage ../packages/propolis { };
  };
}