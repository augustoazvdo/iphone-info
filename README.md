# Iphone Info

Iphone Info é um app iOS de ficha de hardware: processador, memória, armazenamento, bateria, tela, sistema, rede e sensores. É uma implementação própria, com APIs públicas do iOS e um catálogo de aparelhos. Potência, tensão e corrente da bateria aparecem como estimativa.

O app não usa o nome, o ícone, os textos nem as artes do CPU-x. O arquivo `CPU-x.ipa` fica no repositório só como referência de engenharia reversa. O executável está criptografado pelo FairPlay, então o código do app original não é copiado.

## Começar

Requisitos e o passo a passo estão em [INSTALL.md](INSTALL.md).

Na raiz do repositório:

```bash
./bootstrap.sh --build
```

O script confere o Xcode, descompacta `CPU-x.ipa` em `extracted/` e, com `--build`, compila o scheme `IphoneInfo` no simulador iPhone 17. O `.xcodeproj` versionado é o que entra no build. `--generate` recria esse projeto com XcodeGen.

## Mapa do repositório

| Caminho | O que é |
| --- | --- |
| `IphoneInfo/` | Projeto: app SwiftUI, widget, testes e `project.yml` |
| `IphoneInfo/IphoneInfo.xcodeproj` | Projeto Xcode. A fonte editável é `IphoneInfo/project.yml` |
| `IphoneInfo/IphoneInfo/` | Código do app (`App`, `Monitoring`, `Views`, `Native`) |
| `IphoneInfo/IphoneInfoTests/` | Testes de unidade |
| `IphoneInfo/Widget/` | Widget da tela inicial |
| `CPU-x.ipa` | Pacote da App Store usado como referência |
| `extracted/` | Conteúdo descompactado do IPA. Não entra no git |
| `evidence/` | Notas e saídas da análise do IPA |
| `.specs/` | Especificação, desenho e tarefas do app |

Versão de marketing: `0.1.0`. Alvo de deployment: iOS 26. Identificador: `com.azvdo.iphoneinfo`.
