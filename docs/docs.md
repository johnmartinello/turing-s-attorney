# Referência da API

API dos scripts em `game/` para Godot 4.7. A cena principal é `res://game/scenes/game.tscn`, em 1280×720. O Dialogic desenha o texto. Estes tipos aplicam ao jogo o que a timeline pede.

A ordem no `project.godot` é a ordem de inicialização. Um autoload enxerga os que foram registrados antes dele.

1. `Dialogic`
2. `GameState`
3. `Inventory`
4. `SceneRouter`
5. `DialogueDirector`

`DialogueDirector` é o único script que chama `Dialogic.start()`.

A raiz de `game.tscn` chama `SceneRouter.register_host()` com `%LocationHost`, abre `res://game/scenes/locations/office.tscn` e liga o botão Inventário a `InventoryPanel.toggle()`. Em `dialogue_started`, esconde o painel e desativa o botão. Em `dialogue_finished`, ativa o botão de novo.

O ponteiro do mouse é a imagem em `display/mouse_cursor/custom_image` do `project.godot`.

## Classes

| Classe | Herda | Resumo |
| --- | --- | --- |
| [GameState](#gamestate) | `Node` | Flags da história |
| [Inventory](#inventory) | `Node` | Catálogo e itens do jogador |
| [SceneRouter](#scenerouter) | `Node` | Troca de local |
| [DialogueDirector](#dialoguedirector) | `Node` | Timelines e sinais do Dialogic |
| [ItemData](#itemdata) | `Resource` | Definição de um item |
| [Location](#location) | `Control` | Raiz de um local |
| [Interaction](#interaction) | `Button` | Troca o cursor ao passar o ponteiro |
| [Hotspot](#hotspot) | `Interaction` | Objeto clicável que abre uma timeline |
| [ExitArrow](#exitarrow) | `Interaction` | Seta para outro local |
| [InventoryPanel](#inventorypanel) | `Control` | Painel do inventário |
| [ItemToast](#itemtoast) | `PanelContainer` | Aviso de item adquirido |

---

# GameState

**Herda:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html) **<** [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)

**Autoload:** `GameState`

**Script:** `res://game/autoload/game_state.gd`

Flags da história que não são itens do inventário.

## Descrição

Guarda pares de nome e valor booleano, por exemplo `got_badge` e `met_witness`. A primeira chamada a `set_flag()` cria a flag. Hotspots e setas escutam `flag_changed` para aparecer ou sumir.

Uma condição do Dialogic pode ler a flag direto:

```gdscript
if GameState.has_flag("met_witness"):
	witness: Eu já contei o que vi.
else:
	witness: Vi alguém sair às pressas.
```

A linha de dentro da condição leva tab.

`has_flag()` devolve `true` quando o valor guardado é `true`. Uma flag ausente e uma flag gravada como `false` devolvem `false`.

## Métodos

| Tipo de retorno | Método |
| --- | --- |
| void | set_flag(flag: String, value: bool = true) |
| bool | has_flag(flag: String) |
| void | clear_flag(flag: String) |

## Sinais

### flag_changed(flag: String, value: bool)

Emitido depois que `set_flag()` grava a flag. `value` é o valor novo. `clear_flag()` também emite este sinal, com `false`.

---

## Descrições dos métodos

### void set_flag(flag: String, value: bool = true)

Grava `flag` com `value` e emite `flag_changed`. Um nome vazio é ignorado e o sinal não é emitido.

Uma timeline marca a flag com o evento `[signal arg="set_flag:met_witness"]`. Esse caminho chama `set_flag()` com o valor padrão `true`.

### bool has_flag(flag: String)

Devolve `true` quando `flag` está guardada como `true`.

### void clear_flag(flag: String)

Equivale a `set_flag(flag, false)`.

---

# Inventory

**Herda:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html) **<** [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)

**Autoload:** `Inventory`

**Script:** `res://game/autoload/inventory.gd`

Itens que o jogador está carregando.

## Descrição

No `_ready`, lê cada `ItemData` em `ITEMS_DIR` e monta um catálogo pelo campo `id`. A lista do jogador começa vazia. `get_items()` devolve os itens na ordem em que foram ganhos.

Um arquivo sem `id`, ou que não seja `ItemData`, fica de fora do catálogo. Em exportação, o sufixo `.remap` é removido antes de carregar o `.tres`.

## Constantes

### String ITEMS_DIR = "res://game/data/items/"

Pasta varrida na inicialização. Cada item novo é um `.tres` nesta pasta.

---

## Métodos

| Tipo de retorno | Método |
| --- | --- |
| bool | add(item_id: String) |
| bool | remove(item_id: String) |
| bool | has(item_id: String) |
| Array[ItemData] | get_items() |
| ItemData | get_item(item_id: String) |

## Sinais

### changed()

Emitido depois que `add()` ou `remove()` alteram a lista do jogador. `InventoryPanel` escuta este sinal para redesenhar a lista.

### item_added(item: ItemData)

Emitido depois de um `add()` bem-sucedido. `item` é a definição do catálogo. `ItemToast` escuta este sinal.

---

## Descrições dos métodos

### bool add(item_id: String)

Coloca `item_id` na lista do jogador, uma vez. Emite `changed` e `item_added`. Devolve `true` quando o item entra na lista.

Devolve `false` quando o id está ausente do catálogo, ou quando o jogador já carrega esse item. Um id desconhecido também gera um aviso.

Uma timeline entrega o item com `[signal arg="give_item:attorneys_badge"]`.

### bool remove(item_id: String)

Tira `item_id` da lista e emite `changed`. Devolve `false` quando o jogador não está com o item.

Uma timeline remove o item com `[signal arg="remove_item:attorneys_badge"]`.

### bool has(item_id: String)

Devolve `true` quando o jogador está com `item_id`.

### Array[ItemData] get_items()

Devolve os `ItemData` que o jogador carrega, na ordem em que `add()` os inseriu.

### ItemData get_item(item_id: String)

Devolve a definição do catálogo. O jogador pode ainda não ter o item. Devolve `null` quando o id não está no catálogo.

---

# SceneRouter

**Herda:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html) **<** [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)

**Autoload:** `SceneRouter`

**Script:** `res://game/autoload/scene_router.gd`

Troca o local sob um nó hospedeiro para o HUD continuar na tela.

## Descrição

`register_host()` recebe o `LocationHost` de `game.tscn`. `go_to()` substitui o filho desse nó pela cena pedida. O HUD, irmão do host, permanece.

A troca é adiada com `call_deferred`, para o botão que emitiu `pressed` não ser liberado no meio do sinal. Se `go_to()` for chamado de novo antes da troca rodar, vale o último caminho.

## Propriedades

| Tipo | Propriedade | Valor padrão |
| --- | --- | --- |
| String | current_scene_path | `""` |

## Métodos

| Tipo de retorno | Método |
| --- | --- |
| void | register_host(host: Node) |
| void | go_to(scene_path: String) |

## Sinais

### location_changed(scene_path: String)

Emitido depois que o local novo entra no host. `scene_path` é o caminho que ficou em `current_scene_path`.

---

## Descrições das propriedades

### String current_scene_path = ""

Caminho da cena instanciada no host. Fica vazio até a primeira troca concluir.

---

## Descrições dos métodos

### void register_host(host: Node)

Define o nó que recebe o local atual. A cena principal chama este método no `_ready`, com `%LocationHost`.

### void go_to(scene_path: String)

Agenda a troca para `scene_path`. Um caminho vazio é ignorado.

Na troca, cada filho do host é removido e liberado, e a cena nova é instanciada no lugar. Em seguida grava `current_scene_path` e emite `location_changed`.

Gera um erro quando o host ainda não foi registrado, quando o arquivo não existe, ou quando o recurso não é uma `PackedScene`.

`ExitArrow` chama este método no clique. O sinal `change_scene` de uma timeline também chega aqui, depois que a timeline termina. Veja `DialogueDirector`.

---

# DialogueDirector

**Herda:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html) **<** [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)

**Autoload:** `DialogueDirector`

**Script:** `res://game/autoload/dialogue_director.gd`

Inicia timelines do Dialogic e aplica os sinais delas ao jogo.

## Descrição

`start()` aceita um caminho `res://` terminado em `.dtl`, ou o nome registrado pelo Dialogic, como `pegar_distintivo`. No `_ready`, chama `DialogicResourceUtil.update()` para o Dialogic encontrar os `.dch` e `.dtl` do projeto.

Enquanto `is_running` é `true`, `Location` desliga os botões do local, e a cena principal fecha o inventário.

O identificador de uma fala é o nome do arquivo `.dch`, sem a extensão:

```text
pericles: Este é o escritório. Quieto, por enquanto.
```

Um evento Signal do Dialogic manda o texto `ação:valor`. O diretor separa no primeiro `:`.

| Argumento | Efeito |
| --- | --- |
| `give_item:attorneys_badge` | `Inventory.add()` |
| `remove_item:attorneys_badge` | `Inventory.remove()` |
| `set_flag:met_witness` | `GameState.set_flag()` com `true` |
| `change_scene:res://game/scenes/locations/lobby.tscn` | `SceneRouter.go_to()` quando a timeline acabar |

`change_scene` espera `timeline_ended`. A fala segue até o fim, e o local só troca depois. Vários `change_scene` na mesma timeline deixam o último caminho.

Um argumento que não é `String`, sem os dois lados do `:`, ou com uma ação desconhecida, gera um aviso e é ignorado.

```text
pericles: Meu distintivo de advogado estava na mesa. Vou levá-lo.
[signal arg="give_item:attorneys_badge"]
[signal arg="set_flag:got_badge"]
```

## Propriedades

| Tipo | Propriedade | Valor padrão |
| --- | --- | --- |
| bool | is_running | `false` |

## Métodos

| Tipo de retorno | Método |
| --- | --- |
| bool | start(timeline: String) |

## Sinais

### dialogue_started()

Emitido no começo de `start()`, depois que a timeline foi encontrada e antes de `Dialogic.start()`.

### dialogue_finished()

Emitido quando a timeline que este diretor abriu termina. Se havia um `change_scene` pendente, `SceneRouter.go_to()` roda em seguida.

---

## Descrições das propriedades

### bool is_running = false

`true` do `start()` bem-sucedido até `timeline_ended`. `Hotspot`, `ExitArrow` e `Location` leem esta propriedade para ignorar cliques.

---

## Descrições dos métodos

### bool start(timeline: String)

Abre a timeline e devolve `true`. Devolve `false` quando já existe diálogo, quando `timeline` está vazio, ou quando o arquivo não existe. Nesse caso, `is_running` permanece `false` e `dialogue_started` não é emitido.

Um caminho com `://` é usado como está, se o arquivo existir. Qualquer outra string é resolvida como identificador `.dtl` do Dialogic.

---

# ItemData

**Herda:** [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html) **<** [RefCounted](https://docs.godotengine.org/en/stable/classes/class_refcounted.html) **<** [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)

**Script:** `res://game/resources/item_data.gd`

Definição de um item do inventário.

## Descrição

Cada arquivo em `res://game/data/items/` é um recurso desta classe. `Inventory` indexa pelo `id`. O exemplo do distintivo está em `res://game/data/items/attorneys_badge.tres`.

## Propriedades

| Tipo | Propriedade | Valor padrão |
| --- | --- | --- |
| String | id | `""` |
| String | display_name | `""` |
| String | description | `""` |
| Texture2D | icon | |

---

## Descrições das propriedades

### String id = ""

Identificador usado em `Inventory.add()`, `give_item` e `remove_item`. O jogador vê `display_name`. Um recurso com `id` vazio fica de fora do catálogo.

### String display_name = ""

Nome mostrado na lista do inventário e no aviso de item adquirido.

### String description = ""

Texto do detalhe, quando o jogador seleciona o item no `InventoryPanel`.

### Texture2D icon

Ícone ao lado do nome e no detalhe. Pode ficar vazio. O painel e o aviso escondem a imagem quando o valor é `null`.

---

# Location

**Herda:** [Control](https://docs.godotengine.org/en/stable/classes/class_control.html) **<** [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html) **<** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html) **<** [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)

**Script:** `res://game/scripts/location.gd`

Raiz de cada cena em `res://game/scenes/locations/`.

## Descrição

No `_ready`, estica o controle para preencher o host (`Control.PRESET_FULL_RECT`) e escuta `dialogue_started` e `dialogue_finished`.

A cada um desses sinais, percorre os `BaseButton` descendentes. Quem tem `refresh_state()` se atualiza sozinho. Os demais ficam com `disabled` igual a `DialogueDirector.is_running`.

Um local novo reutiliza este script na raiz. A saída para outra cena é uma `ExitArrow` filha, com `target_scene` apontando para o `.tscn` do outro local.

---

# Interaction

**Herda:** [Button](https://docs.godotengine.org/en/stable/classes/class_button.html) **<** [BaseButton](https://docs.godotengine.org/en/stable/classes/class_basebutton.html) **<** [Control](https://docs.godotengine.org/en/stable/classes/class_control.html) **<** [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html) **<** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html) **<** [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)

**Script:** `res://game/scripts/interaction.gd`

Botão que troca o cursor do mouse enquanto o ponteiro está em cima.

## Descrição

`Hotspot` e `ExitArrow` herdam esta classe. `Hotspot` usa a troca de cursor; `ExitArrow` sobrescreve esse comportamento para manter o cursor padrão e desenhar sua seta no próprio botão.

Com o ponteiro em cima, e o botão ativo, o cursor passa a ser `icon_texture`, redimensionado para `proportions` com filtro nearest. O ponto de clique é `hotspot`, em pixels da textura original, escalado na mesma proporção. Nada é desenhado sobre o botão. Com o botão desativado, ou sem textura, o cursor volta à seta do projeto.

## Propriedades

| Tipo | Propriedade | Valor padrão |
| --- | --- | --- |
| Texture2D | icon_texture | `null` |
| Vector2 | proportions | `Vector2(64, 64)` |
| Vector2 | hotspot | `Vector2(0, 0)` |

---

## Descrições das propriedades

### Texture2D icon_texture = null

Cursor mostrado sobre este controle. Vazio, o ponteiro permanece a seta do projeto.

### Vector2 proportions = Vector2(64, 64)

Largura e altura do cursor, em pixels. A textura é redimensionada para este tamanho.

### Vector2 hotspot = Vector2(0, 0)

Ponto de clique, em pixels de `icon_texture`. Se `proportions` diferir do tamanho da textura, este ponto escala junto.

---

# Hotspot

**Herda:** [Interaction](#interaction) **<** [Button](https://docs.godotengine.org/en/stable/classes/class_button.html) **<** [BaseButton](https://docs.godotengine.org/en/stable/classes/class_basebutton.html) **<** [Control](https://docs.godotengine.org/en/stable/classes/class_control.html) **<** [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html) **<** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html) **<** [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)

**Script:** `res://game/scripts/hotspot.gd`

Botão que abre uma timeline do Dialogic.

## Descrição

As propriedades ficam no inspetor. O clique chama `DialogueDirector.start()` com a timeline escolhida. Uma conversa nova é um `.dtl` em `res://game/dialogue/timelines/`, colocado em `timeline`.

O cursor de `Interaction` troca enquanto o ponteiro está dentro do botão.

A mesa do escritório usa `timeline` = `pegar_distintivo.dtl`. A testemunha do saguão usa `timeline` = `conversa_testemunha.dtl`.

## Propriedades

| Tipo | Propriedade | Valor padrão |
| --- | --- | --- |
| String | timeline | `""` |
| String | timeline_if_flag | `""` |
| String | flag | `""` |
| String | required_flag | `""` |
| bool | one_shot | `false` |

## Métodos

| Tipo de retorno | Método |
| --- | --- |
| void | refresh_state() |

---

## Descrições das propriedades

### String timeline = ""

Caminho ou identificador da timeline padrão. É o argumento de `DialogueDirector.start()` quando `timeline_if_flag` não se aplica.

O export aceita arquivos `*.dtl`.

### String timeline_if_flag = ""

Timeline usada quando `flag` já está definida em `GameState`. Vazia, o clique usa sempre `timeline`.

### String flag = ""

Nome da flag que troca o clique para `timeline_if_flag`. A troca exige `flag` e `timeline_if_flag` preenchidos, e `GameState.has_flag(flag)` verdadeiro.

### String required_flag = ""

Enquanto `GameState` não tiver esta flag, o botão fica invisível e desativado. Vazia, o botão nasce disponível.

### bool one_shot = false

Com `true`, o botão desativa depois do primeiro clique que conseguiu abrir uma timeline. Um `start()` que devolve `false` deixa o botão utilizável.

---

## Descrições dos métodos

### void refresh_state()

Atualiza `visible` e `disabled` a partir de `required_flag`, `one_shot` e `DialogueDirector.is_running`. Com o botão desativado, o cursor volta à seta do projeto.

`Location` chama este método quando o diálogo abre ou fecha. O próprio botão também chama, no `_ready` e em `GameState.flag_changed`.

---

# ExitArrow

**Herda:** [Interaction](#interaction) **<** [Button](https://docs.godotengine.org/en/stable/classes/class_button.html) **<** [BaseButton](https://docs.godotengine.org/en/stable/classes/class_basebutton.html) **<** [Control](https://docs.godotengine.org/en/stable/classes/class_control.html) **<** [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html) **<** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html) **<** [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)

**Script:** `res://game/scripts/exit_arrow.gd`

Área de saída que mostra uma seta e troca de local.

## Descrição

O botão nasce sem caixa e sem texto (`flat`, estilos vazios, `focus_mode` em `FOCUS_NONE`). Ao passar o mouse sobre a área, a seta aparece centralizada no botão; `direction` escolhe para onde ela aponta. O cursor permanece a seta padrão do projeto. Qualquer clique nessa área chama `SceneRouter.go_to(target_scene)`.

Durante o diálogo, o clique é ignorado. Enquanto `required_flag` falta, a área inteira fica invisível.

## Propriedades

| Tipo | Propriedade | Valor padrão |
| --- | --- | --- |
| String | target_scene | `""` |
| String | required_flag | `""` |
| Direction | direction | `Direction.RIGHT` |

## Métodos

| Tipo de retorno | Método |
| --- | --- |
| void | refresh_state() |

## Enumerações

### enum Direction

| Valor | Nome |
| --- | --- |
| `0` | LEFT |
| `1` | RIGHT |
| `2` | UP |
| `3` | DOWN |

**LEFT** marca uma saída para a esquerda.

**RIGHT** marca uma saída para a direita.

**UP** marca uma saída para cima.

**DOWN** marca uma saída para baixo.

---

## Descrições das propriedades

### String target_scene = ""

Cena aberta no clique, passada a `SceneRouter.go_to()`. O export aceita arquivos `*.tscn`.

### String required_flag = ""

Enquanto `GameState` não tiver esta flag, a área fica invisível e desativada. Vazia, a área nasce disponível.

### Direction direction = Direction.RIGHT

Lado para o qual aponta a seta exibida no centro do botão durante o hover.

---

## Descrições dos métodos

### void refresh_state()

Atualiza `visible` e `disabled` a partir de `required_flag` e `DialogueDirector.is_running`.

`Location` chama este método quando o diálogo abre ou fecha. A seta também chama, no `_ready` e em `GameState.flag_changed`.

---

# InventoryPanel

**Herda:** [Control](https://docs.godotengine.org/en/stable/classes/class_control.html) **<** [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html) **<** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html) **<** [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)

**Script:** `res://game/scripts/inventory_panel.gd`

**Cena:** `res://game/scenes/ui/inventory_panel.tscn`

Painel que lista os itens do jogador.

## Descrição

Começa oculto. Escuta `Inventory.changed` e redesenha a lista, com o ícone ao lado de `display_name`. O ícone da lista tem tamanho fixo de 48×48.

Selecionar um item mostra `icon`, `display_name` e `description`. Com a lista vazia, o título fica "Inventário" e o texto fica "Nada aqui ainda.".

O botão Fechar e um clique no fundo escuro chamam `hide()`.

## Métodos

| Tipo de retorno | Método |
| --- | --- |
| void | toggle() |

---

## Descrições dos métodos

### void toggle()

Alterna `visible`. Ao abrir, relê `Inventory.get_items()` e seleciona o primeiro item.

A cena principal liga o botão Inventário a este método. `dialogue_started` esconde o painel por `hide()`, sem passar por `toggle()`.

---

# ItemToast

**Herda:** [PanelContainer](https://docs.godotengine.org/en/stable/classes/class_panelcontainer.html) **<** [Container](https://docs.godotengine.org/en/stable/classes/class_container.html) **<** [Control](https://docs.godotengine.org/en/stable/classes/class_control.html) **<** [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html) **<** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html) **<** [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)

**Script:** `res://game/scripts/item_toast.gd`

Aviso temporário de item adquirido.

## Descrição

Começa oculto e ignora o mouse (`MOUSE_FILTER_IGNORE`). Escuta `Inventory.item_added`.

Quando um item entra no inventário, mostra o `icon` e o texto "Item {display_name} adquirido". O aviso permanece 2,6 segundos e some em 0,35 segundos. Um item novo nesse intervalo reinicia a contagem e mantém o aviso visível.
