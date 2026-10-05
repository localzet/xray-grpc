# Xray gRPC schemas

Protobuf schemas and PHP client bindings for an Xray-core API snapshot. These files are an integration layer, not a complete Xray server or a promise of compatibility with every current Xray release.

[Русская документация](README.ru.md) · [PHP bindings](https://github.com/localzet/xray-grpc-php)

## Layout and provenance

`src/` contains Xray protobuf schemas; `php/` is a separate repository/submodule containing generated PHP messages and gRPC clients. Upstream schema names and package paths refer to [XTLS/Xray-core](https://github.com/XTLS/Xray-core). The exact upstream release of this legacy snapshot is not recorded; determine and record it before upgrading schemas or claiming release compatibility. Preserve upstream notices and applicable licenses when importing a newer snapshot.

The historical `.grpc/grpc_php_plugin` binary has no recorded compiler provenance/version and is not selected automatically. Choose a locally built or otherwise verified plugin explicitly. Do not treat a checked-in native executable as a portable toolchain.

## Validate and generate

The script requires protoc 25.8, runs from any working directory and fails on errors. CI checks schema syntax/imports and generated PHP message emission in a temporary directory; it does not overwrite the binding repository.

```sh
bash compile_proto.sh --check
PHP_OUT_DIR=/tmp/xray-php-generated bash compile_proto.sh --php-only
GRPC_PHP_PLUGIN=/absolute/path/to/grpc_php_plugin bash compile_proto.sh
```

`PROTOC` can select an absolute compiler path. Obtain protoc from the [official v25.8 release](https://github.com/protocolbuffers/protobuf/releases/tag/v25.8). Linux x86_64 archive SHA-256 used by CI: `f7873a2b57811575c661faffa847e0e9b1bb06a1aea5021eccb05e8c04b260d5`.

For full client generation, use a PHP gRPC plugin built from an explicitly selected official grpc source revision. Record that revision and compare the generated diff before committing; plugin pinning is still a release requirement. Never overwrite manual client wrappers as if they were generated files. Publish and verify the binding commit before updating the parent submodule pointer.

## Deployment boundary

Xray management APIs expose privileged operations. Bind them locally or behind authenticated private transport and access controls. PHP consumer code requires `ext-grpc` and Composer dependencies; production verification must exercise an actual supported Xray instance, error statuses and timeouts. The unfinished local API wrapper is not part of a verified generated-client release. CI here does not publish to Packagist or deploy an instance.

## Attribution

Maintainer of Localzet contributions: **Ivan Zorin (localzet)** — <creator@localzet.com> · https://www.localzet.com. Copyright © 2026 Localzet Group. Original authorship and third-party licenses remain applicable. See [AUTHORS](.github/AUTHORS.md).
