globals [
  temperatura-ambiente ; Temperatura que se percibe en todo el entorno
  temporada ; Invierno, Verano, Primavera, Otono ?
  ; if-arbol-contador ;
]

patches-own [
  id-arbol
  calidad-biomasa-arbol ; 0 - 100
  cantidad-biomasa-arbol ; 0 - 100
  temperatura ; Temperatura en ese parche
  altitud ; altitud de ese parche (altitud del arbol)
]

turtles-own [
  etapa ; "eggs, l1, L2"
  dias-restantes-egg
  dias-restantes-lf ; dias restantes en la etapa L1 (etapa larvaria 1)
  dias-restantes-ls ; dias restantes en la etapa L2 (etapa larvaria 2)
  dias-restantes-pupa
  dias-restantes-polilla
  sexo ; Macho o Hembra
  enterrado? ; Indica si el agente se encuentra enterrado (fase pupa)
  apareado? ; Indica si el agente se reprodujo (fase polilla)
  host ; Variable que almacena el id del arbol donde se encuentran los agentes. (basicamente el id del parche)
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; TODO LO RELACIONADO CON CONFIGURACION INICIAL ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Configuracion inicial del entorno
to setup-entorno
  set temperatura-ambiente random 43 - 10 ; 10 + 20 ; Temperatura entre 20 y 30 grados
end

; Cambiar el color del parche segun la cantidad de biomasa
to recolor-patch
  if cantidad-biomasa-arbol >= 70 [ set pcolor green - 3 ]
  if cantidad-biomasa-arbol < 70 and cantidad-biomasa-arbol >= 40 [ set pcolor green ]
  if cantidad-biomasa-arbol < 40 and cantidad-biomasa-arbol > 0 [ set pcolor green + 2 ]
  if cantidad-biomasa-arbol = 0 [ set pcolor brown ] ; Parche sin biomasa
end

; Configuracion inicial del paisaje con arboles como grupos de parches
to setup-paisaje
  let id 0
  ask n-of cantidad-arboles patches [ ; Usar el valor del slider
    let tree-patches patches in-radius 2 ; Grupo de parches adyacentes
    let biomasa random-float 100 ; Biomasa uniforme para el árbol
    let calidad random-float 100 ; Calidad uniforme para el árbol
    ask tree-patches [
      set id-arbol id
      set calidad-biomasa-arbol calidad
      set cantidad-biomasa-arbol biomasa
      set altitud random 11 + 10 ; asegura que incluya el numero 10 y 20. Altitud del arbol
      recolor-patch
    ]
    ask one-of tree-patches [ ; Designar el tronco del árbol
      set cantidad-biomasa-arbol 0
      set pcolor brown
    ]
    set id id + 1
  ]
end


; Configuracion inicial de la colonia de orugas
to setup-colonia
  ;let numero-individuos random 151 + 150 ; Numero aleatorio entre 150 y 300
  create-turtles numero-individuos-iniciales [
    set etapa "egg"
    set color violet
    set size 0.5 ; Tortugas mas pequeñas
    set shape "circle"
    set dias-restantes-egg 30 ;random 21 + 10 ; Entre 10 y 30 dias como huevo
    set dias-restantes-lf 30
    set dias-restantes-ls 90
    set dias-restantes-pupa 30
    set dias-restantes-polilla 400
    let parche-inicial one-of patches with [ cantidad-biomasa-arbol > 0] ; Asignacion random
    move-to parche-inicial; Posicionar en un arbol
    set host [id-arbol] of parche-inicial ; se asigna el id del arbol donde se encuentra
    set sexo one-of ["macho" "hembra"]
    set enterrado? false
    set apareado? false
  ]
end


; Configuracion completa
to setup
  clear-all
  setup-entorno ; Establece la temperatura min y max que se encontrara en la simulacion
  setup-paisaje ; Establece las configuraciones iniciales sobre cantidad de biomasa, temperatura, altura y demas sobre los arboles
  setup-colonia ; Establece las configuraciones iniciales sobre las colonias. (sexo, dias como l1, l2, etc)
  reset-ticks
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; TODO LO RELACIONADO CON ACTUALIZACION ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to actualizar-entorno
  ; actualizar temperaturas
  ;set temperatura-ambiente random 43 - 10
end

to actualizar-colonias
  ask turtles [
    mortalidad
    desarrollo
    movimiento
  ]
  ; se actualiza el desarrollo


  ; colonias en ultima etapa crean procesion para enterrarse
end

to actualizar-pupas
  ; se ajusta mortalidad y desarrollo (mortalidad por porcentaje de emergencia)
  ; al completar su desarrollo, las pupas se convierten en polillas
end

to actualizar-polilla
  ; las hembras buscan pareja y luego arboles para ovipositar

end

to actualizar-host
  ; reduccion de biomasa y calidad acorde al consumo
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; MODELOS: MORTALIDAD, DESARROLLO Y MOVIMIENTO ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to mortalidad
  ask turtles with [etapa = "egg"][
    let altura-patch [altitud] of patch-here
    let prob-muerte 0
    if altura-patch = 10 [ set prob-muerte 0 ]
    if altura-patch > 10 and altura-patch < 15 [ set prob-muerte 0.2 ]
    if altura-patch >= 15 and altura-patch < 18 [ set prob-muerte 0.4 ]
    if altura-patch >= 18 and altura-patch <= 20 [ set prob-muerte 0.6 ]

    ; calcular la probabilidad total de muerte
    if random-float 1 < prob-muerte [
      if random-float 1 < probabilidad-de-predacion [
        die
      ]
    ]
  ]

  ask turtles with [ etapa = "lf"][
  ]

  ask turtles with [etapa = "ls"][
  ]

  ask turtles with [etapa = "pupa"][
  ]

 ask turtles with [etapa = "polilla"][

    ; if dias-restantes-polilla <= 0 and sexo = "macho" or not apareado?[die]
  ]

end


to desarrollo

  ;;;;;;; CONFIGURA LAS FORMAS DE LOS AGENTES ;;;;;;;;

 ;;;;;;;; LARVAS ;;;;;;;;;;

  ask turtles with [etapa = "egg"][
    set dias-restantes-egg dias-restantes-egg - 1
    if dias-restantes-egg <= 0 [
      set etapa "lf"
      set shape "bug"
      set color yellow
    ]
  ]

  ask turtles with [etapa = "lf"][
    set dias-restantes-lf dias-restantes-lf - 1
    if dias-restantes-lf <= 0 [
      set etapa "ls"
      set shape "bug"
      set size 1
      set color yellow - 2
    ]
  ]

  ask turtles with [etapa = "ls"][
    set dias-restantes-ls dias-restantes-ls - 1
    if dias-restantes-ls <= 0 [
      set etapa "pupa"
    ]
  ]

   ;;;;;;;; PUPAS ;;;;;;;;;;

  ask turtles with [etapa = "pupa" and enterrado? = true][
    set dias-restantes-pupa dias-restantes-pupa - 1
    if dias-restantes-pupa <= 0 [
      set etapa "polilla"
      set enterrado? false
      set shape "butterfly"
      set color white
    ]
  ]

  ;;;;;;;; POLILLAS ;;;;;;;;;;

  ask turtles with [etapa = "polilla"][
    set dias-restantes-polilla dias-restantes-polilla - 1
  ]

end

to movimiento

  ;;;;;;;; LARVAS ;;;;;;;;;;

  ; Alimentarse
  ask turtles with [etapa = "lf" or etapa = "ls"][
    alimentarse
  ]

  ; procesion
  ask turtles with [etapa = "pupa" and enterrado? = false][
    procesion
  ]

   ;;;;;;;; POLILLAS ;;;;;;;;;;

  ; apareamiento
  ask turtles with [etapa = "polilla" and not apareado?][
     deambular
  ]

  ; oviposicion
 ask turtles with [etapa = "polilla" and sexo = "hembra" and apareado?][
    oviposicion
 ]

end


to alimentarse
  let target one-of patches in-radius 1 with [cantidad-biomasa-arbol > 0 and id-arbol = [host] of myself] ; se alimenta unicamente del arbol
   if target != nobody [
    face target
    move-to target
    ask target [
      set cantidad-biomasa-arbol cantidad-biomasa-arbol - 1 ; Reducir biomasa
      recolor-patch
    ]
  ]
end

to procesion
  ; identificamos la oruga lider
  if any? turtles-on neighbors [
    ; seguir al lider mas cercano
    let lider one-of turtles-on neighbors
    face lider
    fd 1
  ]
  ; si no hay lider cerca se mueven hacia un parche vacio para enterrarse
  if not any? turtles-on neighbors [
    let destino one-of patches in-radius 2 with [not any? turtles-here]
    if destino != nobody [
      face destino
      move-to destino
    ]
  ]
  ; enterrarse
  if [cantidad-biomasa-arbol] of patch-here = 0 [
    set enterrado? true
    set color brown
    set shape "dot"
  ]
end

to deambular

  let centro-arbol one-of patches with [id-arbol = [host] of myself]
  if centro-arbol != nobody [
    let distancia-actual distance centro-arbol

    let nuevo-x random-float 4 - 2
    let nuevo-y random-float 4 - 2

    let nuevo-parche patch-at (round nuevo-x)(round nuevo-y)

    if nuevo-parche != nobody and [distance centro-arbol] of nuevo-parche <= 2 [
      move-to nuevo-parche
      apareamiento
    ]
  ]


end



to apareamiento
  let posibles-parejas turtles-here with [sexo = "hembra" and sexo != [sexo] of myself]
  if any? posibles-parejas [
    let pareja one-of posibles-parejas
    ask pareja [
      set apareado? true
      set etapa "polilla"
      set color magenta
    ]
  ]
 ; let parejas turtles-on patches in-radius 2 with [etapa = "polilla" and sexo != [sexo] of myself and not apareado?]

end

to oviposicion
  ; aca, todas las agentes hembras que esten en la fase de "polilla" y esten con la variable apareado? = true, tendran que ovipositar sus huevos y lo haran escogiendo el parche con mas biomasa que se encuentre a lo mas a rango 2 parches de el. Si hay empate en los parches escoger cualquiera. Una vez escogido debe ir hacia el parche y depositar sus huevos de forma random. Posterior a eso morira
  ; Procedimiento para hembras polillas que ya se aparearon

  ; buscar el parche con mayor biomasa dentro del rango 2
  let parche-objetivo max-one-of patches in-radius 2 [cantidad-biomasa-arbol]
  if parche-objetivo != nobody [
    ; movemos al parche
    face parche-objetivo
    move-to parche-objetivo
    ; depositamos huevos de forma aleatoria
    let cantidad-huevos random 21 + 10 ; entre 10 y 30 huevos
    ask patch-here [
      sprout cantidad-huevos [
        set etapa "egg"
        set dias-restantes-egg random 21 + 10; tiempo de desarrollo de los huevos entre 10 y 30 dias
        set host [id-arbol] of patch-here
        set color violet
        set size 0.5
        set sexo one-of ["macho" "hembra"]
      ]
    ]
    ; morir luego de ovipositar
    die
  ]

end

; Ciclo principal
to go
  if not any? turtles [ stop ] ; Detener si no hay orugas
  actualizar-entorno
  actualizar-colonias

  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
51
10
794
784
-1
-1
15.0
1
10
1
1
1
0
0
0
1
-24
24
-25
25
0
0
1
ticks
30.0

BUTTON
890
12
953
45
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
818
12
881
45
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
817
79
989
112
temp-min
temp-min
-15
-1
-1.0
1
1
grados 
HORIZONTAL

SLIDER
1003
80
1175
113
temp-max
temp-max
0
35
22.0
1
1
NIL
HORIZONTAL

SLIDER
818
127
990
160
cantidad-biomasa
cantidad-biomasa
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
1004
128
1176
161
calidad-biomasa
calidad-biomasa
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
819
183
991
216
cantidad-arboles
cantidad-arboles
5
100
21.0
1
1
NIL
HORIZONTAL

SLIDER
1011
183
1226
216
probabilidad-de-predacion
probabilidad-de-predacion
0
1
0.0
0.01
1
%
HORIZONTAL

SLIDER
952
288
1148
321
numero-individuos-iniciales
numero-individuos-iniciales
10
300
56.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
; Comportamiento de alimentación de las orugas
to alimentar-orugas
  ask turtles [
    let target one-of patches in-radius 1 with [cantidad-biomasa-arbol > 0]
    if target != nobody [
      ask target [
        set cantidad-biomasa-arbol cantidad-biomasa-arbol - 1 ; Reducir biomasa
        recolor-patch
      ]
    ]
  ]
end

; Buscar un nuevo árbol con biomasa disponible
to buscar-nuevo-arbol
  ask turtles [
    let nuevo-arbol one-of patches in-radius 10 with [cantidad-biomasa-arbol > 50]
    if nuevo-arbol != nobody [
      move-to nuevo-arbol
    ]
  ]
end
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
