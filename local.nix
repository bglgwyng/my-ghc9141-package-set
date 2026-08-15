{ inputs }:
let
  servantMultipartPackage = packageName: "${inputs.servant-multipart.outPath}/${packageName}";
in
{
  reflex = "${inputs.reflex}";
}
// {
  # The servant-* packages have not been updated on Hackage yet.
  servant = "${inputs.servant.outPath}/servant";
  servant-client = "${inputs.servant.outPath}/servant-client";
  servant-client-core = "${inputs.servant.outPath}/servant-client-core";
  servant-client-ghcjs = "${inputs.servant.outPath}/servant-client-ghcjs";
  servant-conduit = "${inputs.servant.outPath}/servant-conduit";
  servant-docs = "${inputs.servant.outPath}/servant-docs";
  servant-foreign = "${inputs.servant.outPath}/servant-foreign";
  servant-http-streams = "${inputs.servant.outPath}/servant-http-streams";
  servant-machines = "${inputs.servant.outPath}/servant-machines";
  servant-openapi3 = "${inputs.servant.outPath}/servant-openapi3";
  servant-pipes = "${inputs.servant.outPath}/servant-pipes";
  servant-quickcheck = "${inputs.servant.outPath}/servant-quickcheck";
  servant-server = "${inputs.servant.outPath}/servant-server";
  servant-swagger = "${inputs.servant.outPath}/servant-swagger";
  servant-auth = "${inputs.servant.outPath}/servant-auth/servant-auth";
  servant-auth-client = "${inputs.servant.outPath}/servant-auth/servant-auth-client";
  servant-auth-docs = "${inputs.servant.outPath}/servant-auth/servant-auth-docs";
  servant-auth-server = "${inputs.servant.outPath}/servant-auth/servant-auth-server";
  servant-auth-swagger = "${inputs.servant.outPath}/servant-auth/servant-auth-swagger";
  servant-multipart = "${inputs.servant-multipart.outPath}/servant-multipart";
  servant-multipart-api = "${inputs.servant-multipart.outPath}/servant-multipart-api";
  servant-multipart-client = "${inputs.servant-multipart.outPath}/servant-multipart-client";
}
