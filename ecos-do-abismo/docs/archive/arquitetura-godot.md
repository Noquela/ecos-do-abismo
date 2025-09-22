# 📁 Arquitetura de Pastas - Godot

## Estrutura Recomendada

```
ecos-do-abismo/
├── docs/                     # Documentação (este arquivo)
├── scenes/                   # Cenas (.tscn)
│   ├── main/                 # Menu principal, configurações
│   ├── battle/               # Combate e interface de jogo
│   ├── cards/                # Prefabs de cartas
│   ├── enemies/              # Prefabs de inimigos
│   ├── ui/                   # Elementos de interface
│   └── effects/              # Efeitos visuais e animações
├── scripts/                  # Scripts (.gd)
│   ├── core/                 # Sistemas centrais
│   ├── cards/                # Lógica de cartas
│   ├── battle/               # Sistema de combate
│   ├── resources/            # Gerenciamento Vontade/Corrupção
│   ├── enemies/              # IA e comportamento inimigo
│   └── data/                 # Classes de dados e recursos
├── assets/                   # Recursos visuais e sonoros
│   ├── images/               # Texturas, sprites, UI
│   │   ├── cards/            # Arte das cartas
│   │   ├── backgrounds/      # Cenários de batalha
│   │   ├── ui/               # Elementos de interface
│   │   └── effects/          # Sprites para animações
│   ├── audio/                # Sons e música
│   └── fonts/                # Fontes customizadas
├── data/                     # Dados do jogo
│   ├── cards/                # Definições de cartas (.json)
│   ├── enemies/              # Stats e comportamentos
│   └── events/               # Eventos entre batalhas
└── addons/                   # Plugins e ferramentas
```

## Organização por Sistema
- **Modularidade**: Cada sistema em pasta separada
- **Prefabs**: Cenas reutilizáveis para cartas e inimigos
- **Separação**: Lógica (scripts) separada de apresentação (scenes)
- **Assets**: Organizados por tipo e função no jogo