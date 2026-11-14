# CPU-x (com.benchu.ARMCPUZ 1.9.1, build 181) — achados

Alvo: `CPU-x.ipa` baixado com ipatool. Executável `ARMCPUZ`, arm64, iOS 15+, SDK 27.1,
UUID `913F1D07-EA87-3F69-ACEE-D5E8CDFACBDF`, sha256 `ef0dc55c…6c1`.

## Limite principal

O executável e as três extensões estão criptografados pelo FairPlay (`cryptid 1`).
Não há descompilação: o código e os nomes de classe Swift/ObjC do próprio app
ficam inacessíveis. Tudo abaixo vem de partes não criptografadas.

## Observado

| Fonte | Evidência REA / ferramenta | O que mostra |
| --- | --- | --- |
| Imports do Mach-O | `ev_a118d7ca…` (`inspect_macho`) | APIs usadas para medir hardware |
| Info.plist | `plist.json` | Permissões, modos de segundo plano, extensões |
| Localizable.strings (en) | `strings-en.txt` | 1.275 textos = mapa de funções |
| Assets.car | `assets-info.json` (assetutil) | 118 ícones = seções do app |
| Storyboards | `ib.json` (`decode_interface_builder`) | Poucas telas; interface quase toda em código |
| Recursos | `Battery.plist`, `rank.plist`, `pip/*.mov` | Capacidade de bateria por modelo, ranking Geekbench, vídeos para PiP |

APIs de medição importadas: `host_processor_info`, `host_statistics64`, `task_info`,
`sysctlbyname`, `mach_absolute_time`, `getifaddrs`, `statfs`, `nw_path_monitor_*`,
`MTLCreateSystemDefaultDevice`, `glGetString`, `CMMotionManager`, `CMAltimeter`,
`CMPedometer`, `CTTelephonyNetworkInfo`, `NEHotspotNetwork`, `AVCaptureDevice`,
`AVAudioRecorder`, `vDSP_fft_zrip`, `HKStatisticsQuery`, `BGTaskScheduler`,
`AVPictureInPictureController`.

Extensões: `CPUZWidget` (WidgetKit; intents Brief, Clock, ProDataFlow, HealthA),
`CPUZTodayExt` (widget Today legado) e `IntentHandler` (`CPUZLaunchConfigurationIntent`).

Monetização: Google Mobile Ads, StoreKit (Pro vitalício), vídeo com recompensa.

## Funções (dos textos e ícones)

- Painel: CPU por núcleo (E/P), uso, frequência atual, memória, armazenamento, bateria, rede.
- Dispositivo, processador, GPU (Metal), tela, câmera, sistema, bateria, armazenamento.
- Tráfego Wi-Fi e celular com ciclos de reinício e limite do plano.
- Teste de velocidade (ping, jitter, download, upload) e servidores.
- Testes de desempenho: CPU inteiro/ponto flutuante, memória, ranking Geekbench.
- Checagem do aparelho: tela, toque, câmera, microfone, alto-falante, botões, sensores, relatório.
- Sensores: acelerômetro, giroscópio, magnetômetro, barômetro, bússola, GPS e velocímetro.
- Janela flutuante via Picture in Picture com estilos de métricas.
- Ferramentas: decibelímetro, régua, limpeza do alto-falante, LED marquee, regex, área de transferência.

## Inferências (não verificadas)

- A "frequência atual da CPU" provavelmente é estimada com um laço cronometrado
  por `mach_absolute_time`; o iOS não expõe a frequência real.
- Os vídeos `pip/*.mov` servem de base para a janela flutuante em PiP.

## Reconstrução

Implementação própria (clean-room) com APIs públicas, sem copiar código, marca
ou recursos do app original. Fase 1: painel ao vivo, dispositivo e sensores.
