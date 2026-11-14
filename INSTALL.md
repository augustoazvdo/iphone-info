# Instalação

O Iphone Info compila no Xcode, no simulador. O `CPU-x.ipa` não é instalado: o binário da App Store está criptografado e serve só para inspeção.

## Pré-requisitos

- macOS com Xcode que tenha o SDK do iOS 26
- Simulador **iPhone 17**
- [XcodeGen](https://github.com/yonaskolb/XcodeGen), só se for regenerar o projeto a partir do YAML:

```bash
brew install xcodegen
```

A assinatura do alvo `IphoneInfo` é automática (`CODE_SIGN_STYLE: Automatic`). No simulador não é preciso um perfil de distribuição.

O alvo do app depende do pacote Swift [Google Mobile Ads](https://github.com/googleads/swift-package-manager-google-mobile-ads) `13.12.0` ou mais novo. O primeiro build baixa esse pacote.

## Bootstrap

Na raiz do repositório:

```bash
./bootstrap.sh
```

Isso faz duas coisas:

1. Confere se o `xcodebuild` está disponível e usa o `IphoneInfo/IphoneInfo.xcodeproj` que já está no git.
2. Recria `extracted/` descompactando `CPU-x.ipa`. Essa pasta está no `.gitignore`.

Flags:

```bash
./bootstrap.sh --build      # compila no simulador iPhone 17
./bootstrap.sh --open       # abre o projeto no Xcode
./bootstrap.sh --generate   # recria o .xcodeproj com xcodegen
./bootstrap.sh --help
```

`--build` e `--open` podem ir juntos. `--generate` lê `IphoneInfo/project.yml`. Use-o só quando quiser recriar o projeto de propósito. O `project.yml` já declara o `DEVELOPMENT_TEAM`, então a assinatura continua igual.

## Passos manuais

Equivalente ao script, a partir da raiz:

```bash
rm -rf extracted
mkdir -p extracted
unzip -q CPU-x.ipa -d extracted
```

Para recriar o projeto a partir do YAML:

```bash
cd IphoneInfo
xcodegen generate
```

Abra `IphoneInfo/IphoneInfo.xcodeproj`, escolha o scheme **IphoneInfo** e um simulador iPhone 17, e rode.

## Build

```bash
xcodebuild -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath IphoneInfo/build build
```

O produto sai em `IphoneInfo/build`. Essa pasta não entra no git.

## Testes

Os testes de unidade ficam em `IphoneInfo/IphoneInfoTests` e cobrem as regras de domínio. As views passam pelo build.

```bash
xcodebuild test -project IphoneInfo/IphoneInfo.xcodeproj -scheme IphoneInfo \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath IphoneInfo/build \
  -only-testing:IphoneInfoTests
```

## IPA de referência

`CPU-x.ipa` é o app de terceiros `com.benchu.ARMCPUZ`. Descompactar mostra `Payload/`, plists, assets e o executável criptografado. Notas dessa leitura estão em `evidence/achados.md`.

Não copie código, marca nem recursos desse pacote para o Iphone Info. O `.gitignore` já ignora `extracted/`, `build/`, `DerivedData/` e `xcuserdata/`.
