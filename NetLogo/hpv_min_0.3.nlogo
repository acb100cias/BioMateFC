extensions [nw]
;extensions [r]


globals [
  infection-chance  ;; The chance out of 100 that an infected person will pass on
                    ;;   infection during one week of couplehood.
  symptoms-show     ;; How long a person will be infected before symptoms occur
                    ;;   which may cause the person to get tested.
  slider-check-1    ;; Temporary variables for slider values, so that if sliders
  slider-check-2    ;;   are changed on the fly, the model will notice and
;  slider-check-3    ;;   change people's tendencies appropriately.
  slider-check-4
  initial-people
  vaccine-rate
  vaccine-type
  recruitment-rate
  natural-death-rate
  cc-death-rate
  time              ;; time in weeks
  year
  infected
  population
  n
  num
  ]

breed [women woman]
breed [men man]

turtles-own [
  infected?          ;; If true, the person is infected.  It may be known or unknown.
  known?             ;; If true, the infection is known (and infected? must also be true).
  sane?
  vaccinated?
  cancer?
  virus-type         ;; Stands for virus type 1,2,3 or 4 depending on what family of hpv belong: alpha 11 , 7, 6, 5 respectively
  infection-length   ;; How long the person has been infected.
  coupled?           ;; If true, the person is in a sexually active couple.
  couple-length      ;; How long the person has been in a couple.

  ;; the next four values are controlled by sliders

  commitment         ;; How long the person will stay in a couple-relationship.
  coupling-tendency  ;; How likely the person is to join a couple.
  test-frequency     ;; Number of times a person will get tested per year.
  partner            ;; The person that is our current partner in a couple.
  promiscuity        ;; It measures roughly in a scale of 0 to 1, meaning 0 is monogamous and 1 poligamous (completely promiscuous)
  coupling-efectivity ;;Based on the principle that "el que liga más, liga más"
  age
  stage
  vaccine-lenght
]

;;;
;;; SETUP PROCEDURES
;;;

to setup
  clear-all
  setup-globals
  setup-people
  reset-ticks

end

to setup-globals
  set infection-chance 80    ;;hay que revisar la probabilidad de infección en la literatura
  set symptoms-show 200.0    ;; lo mismo para el tiempo de infeccion
  set slider-check-1 average-commitment
  set slider-check-2 average-coupling-tendency
  set slider-check-4 average-test-frequency
  set vaccine-rate vr
  set vaccine-type vaccine
  set time 0
  set recruitment-rate 0.75
  set natural-death-rate 0.524
  set cc-death-rate 0.0012
  set year 0
  set population (initial-men + initial-women)
end

to setup-people
  set initial-people  initial-women + initial-men
  create-women initial-women
  ask women [ifelse version ="people"[set shape "person righty"][set shape "triangle"]]
  create-men initial-men
  ask men [ifelse version ="people"[set shape "person lefty" ][set shape "circle"]]
  ask turtles [set vaccinated? false set infected? false set sane? true set cancer? false]
  ask n-of (floor(initial-women * vaccine-rate)) women [set vaccinated? true]
  ask n-of (floor((count turtles with [vaccinated? = false]) * random-float 1)) turtles with [vaccinated? = false][set infected? true]
  ask turtles[ setxy random-xcor random-ycor
      set known? false
      set coupled? false
      set partner nobody
      set promiscuity random-float 1
      set coupling-efectivity random-float 1
      set age 13 + random 47
      if vaccinated? = true [set vaccine-lenght random 5]
      if infected? = true  [ set virus-type random 4   set infection-length random-float symptoms-show set sane? false]
      assign-commitment
      assign-coupling-tendency
      assign-test-frequency]
ask women [assign-woman-color]
ask men [assign-man-color
   if vaccine-type = "vac3"[ask n-of (initial-men * vaccine-rate) men [set vaccinated? true ]]]
end

;; Different people are displayed in 4 different colors depending on health
;; green is not infected
;; blue is infected but doesn't know it
;; red is infected and knows it
;; grey is vaccinated

to assign-man-color  ;; turtle procedure
  ask men [ifelse infected? = true [ifelse known? = true[ set color red + 2  ][set color blue + 2]][ set color green + 2]]
;  ask men [ifelse infected? = true and Known? = true[ set color red + 0.2  ][set color green + 0.2]]
 ; ask men[if infected? = true and known? = false [ set color blue + 0.2] ]

end


to assign-woman-color  ;; turtle procedure
  ask women [ifelse infected? = true [ifelse known? = true[ set color red - 2  ][set color blue - 2]][ set color green - 2]]
;  ask women [if sane? = true ]
;;  ask women[ if infected? = true and known? = false  ]

end

to getSick
 if infected? = true [set stage 1 set sane? false]
 if infection-length >  50 and random 12 < 6 [set stage 2]
 if infection-length > 150 and random 12 = 11[set stage 3]
 if stage = 3 and random 12 > 1 [set cancer? true]
 if cancer? = true and random 12 = 11[die set pcolor black]
end


;; The following four procedures assign core turtle variables.  They use
;; the helper procedure RANDOM-NEAR so that the turtle variables have an
;; approximately "normal" distribution around the average values set by
;; the sliders.

to assign-commitment  ;; turtle procedure
  ifelse vaccinated? = false [set commitment random-near average-commitment][set commitment random-near 0.5 * average-commitment
    set coupling-efectivity coupling-efectivity + 0.2]
end

to assign-coupling-tendency  ;; turtle procedure
  set coupling-tendency random-near average-coupling-tendency
end

to assign-test-frequency  ;; turtle procedure
  set test-frequency random-near average-test-frequency
end

to-report random-near [center]  ;; turtle procedure
  let result 0
  repeat 40
    [ set result (result + random-float center) ]
  report result / 20
end

;; Recruitment hay que cambiar como se hace el reclutamiento,debe asignarse a estas tortugas las variables
to new-year
  if time = 52 [cp set time 0  set year year + 1 ask n-of (floor(natural-death-rate * population)) turtles [die set pcolor black]
    create-women 0.51 * initial-people * recruitment-rate  create-men 0.49 * initial-people * recruitment-rate
  ask women with  [xcor = 0 and ycor = 0 ][ifelse version ="people"[set shape "person righty"][set shape "triangle"]]
  ask men with [xcor = 0 and ycor = 0 ][ifelse version ="people"[set shape "person lefty"][set shape "circle"]]
  ask turtles with [xcor = 0 and ycor = 0 ][set vaccinated? false set infected? false set sane? true set cancer? false]
  ask n-of (floor((count women with [xcor = 0 and ycor = 0]) * vaccine-rate)) women with [xcor = 0 and ycor = 0 ] [set vaccinated? true]
;  ask n-of (floor(initial-women * vaccine-rate)) women [set vaccinated? true]
  ask n-of (floor((count turtles with [xcor = 0 and ycor = 0 and vaccinated? = false]) * random-float 1)) turtles with [xcor = 0 and ycor = 0 and vaccinated? = false][set infected? true]
  ask turtles with [xcor = 0 and ycor = 0 ][ setxy random-xcor random-ycor
      set known? false
      set coupled? false
      set partner nobody
      set promiscuity random-float 1
      set coupling-efectivity random-float 1
      set age 13 + random 47
      if vaccinated? = true [set vaccine-lenght random 5]
      if infected? = true  [ set virus-type random 4   set infection-length random-float symptoms-show set sane? false ]
      assign-commitment
      assign-coupling-tendency
 ;     assign-condom-use
      assign-test-frequency]
ask women [assign-woman-color]
ask men [assign-man-color
   if vaccine-type = "vac3"[ask n-of (initial-men * vaccine-rate) men [set vaccinated? true ]]]]
end


;;;
;;; GO PROCEDURES
;;;

to go
   if all? turtles [known? = true]
    [ stop ]
  check-sliders
  ask patches[if turtles-here = 0 [set pcolor black]]
  ask turtles
    [ if infected? = true
        [ set infection-length infection-length + 1 ]
      if coupled? = true
        [ set couple-length couple-length + 1 ] ]
  ask turtles
    [ if coupled? = false
        [ move ] ]
  ;; Righties are always the ones to initiate mating.  This is purely
  ;; arbitrary choice which makes the coding easier.
  ask women
    [ if coupled? = false and (random-float 10.0 < coupling-tendency)
        [ couple ] ]
  ask turtles [ uncouple ]
  ask turtles [ infect ]
  ask turtles [ test ]
  ask turtles [getSick]
  ask men [ assign-man-color ]
  ask women [ assign-woman-color ]
  nw:set-context turtles links
  tick
  set time time + 1
  new-year
  ask turtles [set age age + year]
  set population (count turtles)
  ask turtles with [coupled? = true][if partner = nobody[set coupled? false]]
  set n  random 100
  set num (word n)
  if time = 50 [nw:save-matrix (word "matriz"  num  ".txt")]
end

;; Each tick a check is made to see if sliders have been changed.
;; If one has been, the corresponding turtle variable is adjusted

to check-sliders
  if (slider-check-1 != average-commitment)
    [ ask turtles [ assign-commitment ]
      set slider-check-1 average-commitment ]
  if (slider-check-2 != average-coupling-tendency)
    [ ask turtles [ assign-coupling-tendency ]
      set slider-check-2 average-coupling-tendency ]
  if (slider-check-4 != average-test-frequency )
    [ ask turtles [ assign-test-frequency ]
      set slider-check-4 average-test-frequency ]
end

;; People move about at random.

to move  ;; turtle procedure
  ifelse version = "people" [rt random-float 360  fd 1] [fd 1]
end

;; People have a chance to couple depending on their tendency to have sex and
;; if they meet.  To better show that coupling has occurred, the patches below
;; the couple turn gray.

to couple  ;; turtle procedure -- righties only!
  let potential-partner one-of (men-at -1 0)
                          with [coupled? = false]
  if potential-partner != nobody
    [ if random-float 10.0 < [coupling-tendency] of potential-partner and coupling-efectivity > 0.6
      [ set partner potential-partner
        if relacion = true [create-link-with partner]
        set coupled? true
        ask partner [ set coupled? true ]
        ask partner [ set partner myself ]
        move-to patch-here ;; move to center of patch
        ask potential-partner [move-to patch-here] ;; partner moves to center of patch
        set pcolor gray - 3
        ask (patch-at -1 0) [ set pcolor gray - 3 ] ] ]
    if turtles-here = nobody [set pcolor black]
end

;; If two peoples are together for longer than either person's commitment variable
;; allows, the couple breaks up.

to uncouple  ;; turtle procedure
  ask women [if coupled? = true
    [ if (couple-length > commitment) or
         ([couple-length] of partner) > ([commitment] of partner) or promiscuity > 0.7
        [ set coupled? false
          set couple-length 0
          ask partner [ set couple-length 0 ]
          set pcolor black
          ask (patch-at -1 0) [ set pcolor black ]
          ask partner [ set partner nobody ]
          ask partner [ set coupled? false ]
          set partner nobody ] ]]
end

;; Infection can occur if either person is infected, but the infection is unknown.
;; This model assumes that people with known infections will continue to couple,
;; but will automatically practice safe sex, regardless of their condom-use tendency.
;; Note also that for condom use to occur, both people must want to use one.  If
;; either person chooses not to use a condom, infection is possible.  Changing the
;; primitive to AND in the third line will make it such that if either person
;; wants to use a condom, infection will not occur.

to infect  ;; turtle procedure
  if coupled? = true and infected? = true and  known? = false and vaccinated? = false
        [ if random-float 100 < infection-chance
            [ ask partner [ set infected? true ] ] ] ;]

   if vaccine-type = "vac1"[
   if coupled? = true and infected? = true and  known? = false and [vaccinated?] of partner = true and [vaccine-lenght] of partner < 2 and virus-type > 2
        [ if random-float 100 < infection-chance
            [ ask partner [ set infected? true ] ] ] ]

   if vaccine-type = "vac2"[
   if coupled? = true and infected? = true and  known? = false and [vaccinated?] of partner = true and [vaccine-lenght] of partner < 2 and virus-type = 3
         [ if random-float 100 < infection-chance
            [ ask partner  [set infected? true ] ] ] ];]

end


;; People have a tendency to check out their health status based on a slider value.
;; This tendency is checked against a random number in this procedure. However, after being infected for
;; some amount of time called SYMPTOMS-SHOW, there is a 5% chance that the person will
;; become ill and go to a doctor and be tested even without the tendency to check.

to test  ;; turtle procedure
  if random-float 52 < test-frequency
    [ if infected? = true
        [ set known? true ] ]
  if infection-length > symptoms-show
    [ if random-float 100 < 5
        [ set known? true ] ]
end

;;;
;;; MONITOR PROCEDURES
;;;

to-report %infected
  ifelse any? turtles
    [ report (count turtles with [infected? = true] / count turtles) * 100 ]
    [ report 0 ]
end

to-report %vaccinated
  ifelse any? women
    [ report (count women with [vaccinated? = true] / count women) * 100 ]
    [ report 0 ]
end


to-report %sane
ifelse any? turtles
    [ report (count turtles with [sane? = true] / count turtles) * 100 ]
    [ report 0 ]
end

to-report global-clustering-coefficient
  let closed-triplets sum [ nw:clustering-coefficient * count my-links * (count my-links - 1) ] of turtles
  let triplets sum [ count my-links * (count my-links - 1) ] of turtles
  report closed-triplets / triplets
end
@#$#@#$#@
GRAPHICS-WINDOW
329
10
1226
785
-1
-1
8.805
1
10
1
1
1
0
0
0
1
-50
50
-43
43
1
1
1
weeks
60.0

BUTTON
18
123
101
156
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
102
123
185
156
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
0

MONITOR
17
303
100
348
% infected
%infected
2
1
11

SLIDER
9
196
278
229
average-commitment
average-commitment
1
200
52.0
1
1
weeks
HORIZONTAL

SLIDER
9
161
278
194
average-coupling-tendency
average-coupling-tendency
0
10
9.0
1
1
NIL
HORIZONTAL

SLIDER
6
234
275
267
average-test-frequency
average-test-frequency
0
2
0.33
0.01
1
times/year
HORIZONTAL

PLOT
1610
26
1879
225
Populations
weeks
people
0.0
52.0
0.0
350.0
true
true
"set-plot-y-range 0 (initial-people + 50)" ""
PENS
"Sane" 1.0 0 -10899396 true "" "plot count turtles with [sane? = true]"
"Infected" 1.0 0 -2674135 true "" "plot count turtles with [known? = true]"
"Infectious" 1.0 0 -13345367 true "" "plot count turtles with [infected? = true]  - count turtles with [known? = true]"
"Vaccinated" 1.0 2 -7500403 true "plot count women with [vaccinated?]" "plot count women with [vaccinated? = true]"

SLIDER
16
83
188
116
initial-men
initial-men
0
1000
503.0
1
1
NIL
HORIZONTAL

SLIDER
16
47
188
80
initial-women
initial-women
0
1000
605.0
1
1
NIL
HORIZONTAL

SWITCH
70
10
184
43
relacion
relacion
0
1
-1000

CHOOSER
193
12
327
57
vaccine
vaccine
"vac1" "vac2" "vac3"
0

MONITOR
104
304
198
349
NIL
%vaccinated
17
1
11

PLOT
1262
10
1593
239
Prevalence of hpv type
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"vph 1" 1.0 0 -2674135 true "" "plot count turtles with [infected? = true and virus-type = 0]"
"vph 2" 1.0 0 -10141563 true "" "plot count turtles with [infected? = true and virus-type = 1]"
"vph 3" 1.0 0 -14070903 true "" "plot count turtles with [infected? = true and virus-type = 2]"
"vph 4" 1.0 0 -12087248 true "" "plot count turtles with [infected? = true and virus-type = 3]"

PLOT
1246
269
1576
469
progression of cc
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"cin 1" 1.0 0 -12345184 true "" "plot count turtles with [infected? = true and stage = 1]"
"cin 2" 1.0 0 -14439633 true "" "plot count turtles with [infected? = true and stage = 2]"
" cin 3" 1.0 0 -5298144 true "" "plot count turtles with [infected? = true and stage = 3]"
"cc" 1.0 0 -13297659 true "" "plot count turtles with [cancer? = true ]"

CHOOSER
190
67
328
112
version
version
"people" "nodes"
0

SLIDER
17
267
189
300
vr
vr
0
1
0.19355
0.0000001
1
NIL
HORIZONTAL

MONITOR
223
321
280
366
NIL
%sane
17
1
11

@#$#@#$#@
## WHAT IS IT?


## HOW IT WORKS


## HOW TO USE IT

## THINGS TO NOTICE

## THINGS TO TRY

## EXTENDING THE MODEL

## NETLOGO FEATURES


## CREDITS AND REFERENCES


## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* .

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE
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

person lefty
false
0
Circle -7500403 true true 170 5 80
Polygon -7500403 true true 165 90 180 195 150 285 165 300 195 300 210 225 225 300 255 300 270 285 240 195 255 90
Rectangle -7500403 true true 187 79 232 94
Polygon -7500403 true true 255 90 300 150 285 180 225 105
Polygon -7500403 true true 165 90 120 150 135 180 195 105

person righty
false
0
Circle -7500403 true true 50 5 80
Polygon -7500403 true true 45 90 60 195 30 285 45 300 75 300 90 225 105 300 135 300 150 285 120 195 135 90
Rectangle -7500403 true true 67 79 112 94
Polygon -7500403 true true 135 90 180 150 165 180 105 105
Polygon -7500403 true true 45 90 0 150 15 180 75 105

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment_1" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>;nw:set-context turtles links
;nw:save-matrix "adyacencias-"behaviorspace-run-number".txt"
export-world "~/tesis/experiment1_run_"behaviorspace-run-number"png"</final>
    <timeLimit steps="20"/>
    <metric>count turtles</metric>
    <metric>count turtles with [known? = true]</metric>
    <metric>count turtles with [sane? = true]</metric>
    <metric>count turtles with [vaccinated? = true]</metric>
    <metric>count turtles with [infected? = true]</metric>
    <metric>count turtles with [infected? = true and virus-type = 0]</metric>
    <metric>count turtles with [infected? = true and virus-type = 1]</metric>
    <metric>count turtles with [infected? = true and virus-type = 2]</metric>
    <metric>count turtles with [infected? = true and virus-type = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 1]</metric>
    <metric>count turtles with [infected? = true and stage = 2]</metric>
    <metric>count turtles with [infected? = true and stage = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 4]</metric>
    <enumeratedValueSet variable="initial-men">
      <value value="414"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-coupling-tendency">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vaccine">
      <value value="&quot;vac1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-test-frequency">
      <value value="0.33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relacion">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-commitment">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-women">
      <value value="643"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vr">
      <value value="0.38"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="CONTROL" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2048"/>
    <metric>count turtles with [known? = true]</metric>
    <metric>count turtles with [sane? = true]</metric>
    <metric>count turtles with [vaccinated? = true]</metric>
    <metric>count turtles with [infected? = true]</metric>
    <metric>count turtles with [infected? = true and virus-type = 0]</metric>
    <metric>count turtles with [infected? = true and virus-type = 1]</metric>
    <metric>count turtles with [infected? = true and virus-type = 2]</metric>
    <metric>count turtles with [infected? = true and virus-type = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 1]</metric>
    <metric>count turtles with [infected? = true and stage = 2]</metric>
    <metric>count turtles with [infected? = true and stage = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 4]</metric>
    <metric>"global-clustering-coefficient"</metric>
    <metric>"nw:clustering-coefficient of turtles"</metric>
    <enumeratedValueSet variable="average-coupling-tendency">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vaccine">
      <value value="&quot;vac1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vr">
      <value value="0.38"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-women">
      <value value="975"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-test-frequency">
      <value value="0.33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relacion">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="version">
      <value value="&quot;people&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-men">
      <value value="414"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-commitment">
      <value value="25"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="E1" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2048"/>
    <metric>count turtles with [known? = true]</metric>
    <metric>count turtles with [sane? = true]</metric>
    <metric>count turtles with [vaccinated? = true]</metric>
    <metric>count turtles with [infected? = true]</metric>
    <metric>count turtles with [infected? = true and virus-type = 0]</metric>
    <metric>count turtles with [infected? = true and virus-type = 1]</metric>
    <metric>count turtles with [infected? = true and virus-type = 2]</metric>
    <metric>count turtles with [infected? = true and virus-type = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 1]</metric>
    <metric>count turtles with [infected? = true and stage = 2]</metric>
    <metric>count turtles with [infected? = true and stage = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 4]</metric>
    <metric>"global-clustering-coefficient"</metric>
    <metric>"nw:clustering-coefficient of turtles"</metric>
    <enumeratedValueSet variable="average-coupling-tendency">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vaccine">
      <value value="&quot;vac1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vr">
      <value value="0.58"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-women">
      <value value="610"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-test-frequency">
      <value value="0.33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relacion">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="version">
      <value value="&quot;people&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-men">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-commitment">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="E2" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2048"/>
    <metric>count turtles with [known? = true]</metric>
    <metric>count turtles with [sane? = true]</metric>
    <metric>count turtles with [vaccinated? = true]</metric>
    <metric>count turtles with [infected? = true]</metric>
    <metric>count turtles with [infected? = true and virus-type = 0]</metric>
    <metric>count turtles with [infected? = true and virus-type = 1]</metric>
    <metric>count turtles with [infected? = true and virus-type = 2]</metric>
    <metric>count turtles with [infected? = true and virus-type = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 1]</metric>
    <metric>count turtles with [infected? = true and stage = 2]</metric>
    <metric>count turtles with [infected? = true and stage = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 4]</metric>
    <metric>"global-clustering-coefficient"</metric>
    <metric>"nw:clustering-coefficient of turtles"</metric>
    <enumeratedValueSet variable="average-coupling-tendency">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vaccine">
      <value value="&quot;vac2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vr">
      <value value="0.58"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-women">
      <value value="610"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-test-frequency">
      <value value="0.33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relacion">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="version">
      <value value="&quot;people&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-men">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-commitment">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="E3" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2048"/>
    <metric>count turtles with [known? = true]</metric>
    <metric>count turtles with [sane? = true]</metric>
    <metric>count turtles with [vaccinated? = true]</metric>
    <metric>count turtles with [infected? = true]</metric>
    <metric>count turtles with [infected? = true and virus-type = 0]</metric>
    <metric>count turtles with [infected? = true and virus-type = 1]</metric>
    <metric>count turtles with [infected? = true and virus-type = 2]</metric>
    <metric>count turtles with [infected? = true and virus-type = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 1]</metric>
    <metric>count turtles with [infected? = true and stage = 2]</metric>
    <metric>count turtles with [infected? = true and stage = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 4]</metric>
    <metric>"global-clustering-coefficient"</metric>
    <metric>"nw:clustering-coefficient of turtles"</metric>
    <enumeratedValueSet variable="average-coupling-tendency">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vaccine">
      <value value="&quot;vac1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vr">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-women">
      <value value="610"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-test-frequency">
      <value value="0.33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relacion">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="version">
      <value value="&quot;people&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-men">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-commitment">
      <value value="25"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="E4" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2048"/>
    <metric>count turtles with [known? = true]</metric>
    <metric>count turtles with [sane? = true]</metric>
    <metric>count turtles with [vaccinated? = true]</metric>
    <metric>count turtles with [infected? = true]</metric>
    <metric>count turtles with [infected? = true and virus-type = 0]</metric>
    <metric>count turtles with [infected? = true and virus-type = 1]</metric>
    <metric>count turtles with [infected? = true and virus-type = 2]</metric>
    <metric>count turtles with [infected? = true and virus-type = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 1]</metric>
    <metric>count turtles with [infected? = true and stage = 2]</metric>
    <metric>count turtles with [infected? = true and stage = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 4]</metric>
    <metric>"global-clustering-coefficient"</metric>
    <metric>"nw:clustering-coefficient of turtles"</metric>
    <enumeratedValueSet variable="average-coupling-tendency">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vaccine">
      <value value="&quot;vac2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vr">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-women">
      <value value="610"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-test-frequency">
      <value value="0.33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relacion">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="version">
      <value value="&quot;people&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-men">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-commitment">
      <value value="25"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="E5" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2048"/>
    <metric>count turtles with [known? = true]</metric>
    <metric>count turtles with [sane? = true]</metric>
    <metric>count turtles with [vaccinated? = true]</metric>
    <metric>count turtles with [infected? = true]</metric>
    <metric>count turtles with [infected? = true and virus-type = 0]</metric>
    <metric>count turtles with [infected? = true and virus-type = 1]</metric>
    <metric>count turtles with [infected? = true and virus-type = 2]</metric>
    <metric>count turtles with [infected? = true and virus-type = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 1]</metric>
    <metric>count turtles with [infected? = true and stage = 2]</metric>
    <metric>count turtles with [infected? = true and stage = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 4]</metric>
    <metric>"global-clustering-coefficient"</metric>
    <metric>"nw:clustering-coefficient of turtles"</metric>
    <enumeratedValueSet variable="average-coupling-tendency">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vaccine">
      <value value="&quot;vac1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vr">
      <value value="0.18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-women">
      <value value="610"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-test-frequency">
      <value value="0.33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relacion">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="version">
      <value value="&quot;people&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-men">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-commitment">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="E6" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2048"/>
    <metric>count turtles with [known? = true]</metric>
    <metric>count turtles with [sane? = true]</metric>
    <metric>count turtles with [vaccinated? = true]</metric>
    <metric>count turtles with [infected? = true]</metric>
    <metric>count turtles with [infected? = true and virus-type = 0]</metric>
    <metric>count turtles with [infected? = true and virus-type = 1]</metric>
    <metric>count turtles with [infected? = true and virus-type = 2]</metric>
    <metric>count turtles with [infected? = true and virus-type = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 1]</metric>
    <metric>count turtles with [infected? = true and stage = 2]</metric>
    <metric>count turtles with [infected? = true and stage = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 4]</metric>
    <metric>"global-clustering-coefficient"</metric>
    <metric>"nw:clustering-coefficient of turtles"</metric>
    <enumeratedValueSet variable="average-coupling-tendency">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vaccine">
      <value value="&quot;vac2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vr">
      <value value="0.18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-women">
      <value value="610"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-test-frequency">
      <value value="0.33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relacion">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="version">
      <value value="&quot;people&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-men">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-commitment">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="E7" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2048"/>
    <metric>count turtles with [known? = true]</metric>
    <metric>count turtles with [sane? = true]</metric>
    <metric>count turtles with [vaccinated? = true]</metric>
    <metric>count turtles with [infected? = true]</metric>
    <metric>count turtles with [infected? = true and virus-type = 0]</metric>
    <metric>count turtles with [infected? = true and virus-type = 1]</metric>
    <metric>count turtles with [infected? = true and virus-type = 2]</metric>
    <metric>count turtles with [infected? = true and virus-type = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 1]</metric>
    <metric>count turtles with [infected? = true and stage = 2]</metric>
    <metric>count turtles with [infected? = true and stage = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 4]</metric>
    <metric>"global-clustering-coefficient"</metric>
    <metric>"nw:clustering-coefficient of turtles"</metric>
    <enumeratedValueSet variable="average-coupling-tendency">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vaccine">
      <value value="&quot;vac3&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vr">
      <value value="0.58"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-women">
      <value value="610"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-test-frequency">
      <value value="0.33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relacion">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="version">
      <value value="&quot;people&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-men">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-commitment">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="E8" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2048"/>
    <metric>count turtles with [known? = true]</metric>
    <metric>count turtles with [sane? = true]</metric>
    <metric>count turtles with [vaccinated? = true]</metric>
    <metric>count turtles with [infected? = true]</metric>
    <metric>count turtles with [infected? = true and virus-type = 0]</metric>
    <metric>count turtles with [infected? = true and virus-type = 1]</metric>
    <metric>count turtles with [infected? = true and virus-type = 2]</metric>
    <metric>count turtles with [infected? = true and virus-type = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 1]</metric>
    <metric>count turtles with [infected? = true and stage = 2]</metric>
    <metric>count turtles with [infected? = true and stage = 3]</metric>
    <metric>count turtles with [infected? = true and stage = 4]</metric>
    <metric>"global-clustering-coefficient"</metric>
    <metric>"nw:clustering-coefficient of turtles"</metric>
    <enumeratedValueSet variable="average-coupling-tendency">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vaccine">
      <value value="&quot;vac3&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vr">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-women">
      <value value="610"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-test-frequency">
      <value value="0.33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relacion">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="version">
      <value value="&quot;people&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-men">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-commitment">
      <value value="25"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment_1" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="24000"/>
    <metric>(count turtles with [known? = true]) / (count turtles)</metric>
    <metric>(count turtles with [sane? = true]) /  (count turtles)</metric>
    <metric>(count turtles with [vaccinated? = true]) / (count turtles)</metric>
    <metric>(count turtles with [infected? = true]) / (count turtles)</metric>
    <metric>(count turtles with [infected? = true and virus-type = 0]) / (count turtles)</metric>
    <metric>(count turtles with [infected? = true and virus-type = 1])/ (count turtles)</metric>
    <metric>(count turtles with [infected? = true and virus-type = 2]) / (count turtles)</metric>
    <metric>(count turtles with [infected? = true and virus-type = 3]) / (count turtles)</metric>
    <metric>(count turtles with [infected? = true and stage = 1])  / (count turtles)</metric>
    <metric>(count turtles with [infected? = true and stage = 2])/ (count turtles)</metric>
    <metric>(count turtles with [infected? = true and stage = 3])/ (count turtles)</metric>
    <metric>(count turtles with [infected? = true and stage = 4])/(count turtles)</metric>
    <enumeratedValueSet variable="average-coupling-tendency">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vaccine">
      <value value="&quot;vac1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vr">
      <value value="0.19355"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-women">
      <value value="605"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-men">
      <value value="503"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relacion">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-test-frequency">
      <value value="0.33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="version">
      <value value="&quot;people&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-commitment">
      <value value="14"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment_3" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="24000"/>
    <metric>(count turtles with [known? = true]) / (count turtles)</metric>
    <metric>(count turtles with [sane? = true]) /  (count turtles)</metric>
    <metric>(count turtles with [vaccinated? = true]) / (count turtles)</metric>
    <metric>(count turtles with [infected? = true]) / (count turtles)</metric>
    <metric>(count turtles with [infected? = true and virus-type = 0]) / (count turtles)</metric>
    <metric>(count turtles with [infected? = true and virus-type = 1])/ (count turtles)</metric>
    <metric>(count turtles with [infected? = true and virus-type = 2]) / (count turtles)</metric>
    <metric>(count turtles with [infected? = true and virus-type = 3]) / (count turtles)</metric>
    <metric>(count turtles with [infected? = true and stage = 1])  / (count turtles)</metric>
    <metric>(count turtles with [infected? = true and stage = 2])/ (count turtles)</metric>
    <metric>(count turtles with [infected? = true and stage = 3])/ (count turtles)</metric>
    <metric>(count turtles with [infected? = true and stage = 4])/(count turtles)</metric>
    <enumeratedValueSet variable="average-coupling-tendency">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vaccine">
      <value value="&quot;vac1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vr">
      <value value="0.19355"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-women">
      <value value="605"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-test-frequency">
      <value value="0.33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="version">
      <value value="&quot;people&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relacion">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-men">
      <value value="503"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-commitment">
      <value value="52"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment_2" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="24000"/>
    <metric>(count turtles with [known? = true]) / (count turtles)</metric>
    <metric>(count turtles with [sane? = true]) /  (count turtles)</metric>
    <metric>(count turtles with [vaccinated? = true]) / (count turtles)</metric>
    <metric>(count turtles with [infected? = true]) / (count turtles)</metric>
    <metric>(count turtles with [infected? = true and virus-type = 0]) / (count turtles)</metric>
    <metric>(count turtles with [infected? = true and virus-type = 1])/ (count turtles)</metric>
    <metric>(count turtles with [infected? = true and virus-type = 2]) / (count turtles)</metric>
    <metric>(count turtles with [infected? = true and virus-type = 3]) / (count turtles)</metric>
    <metric>(count turtles with [infected? = true and stage = 1])  / (count turtles)</metric>
    <metric>(count turtles with [infected? = true and stage = 2])/ (count turtles)</metric>
    <metric>(count turtles with [infected? = true and stage = 3])/ (count turtles)</metric>
    <metric>(count turtles with [infected? = true and stage = 4])/(count turtles)</metric>
    <enumeratedValueSet variable="average-coupling-tendency">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vaccine">
      <value value="&quot;vac1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vr">
      <value value="0.19355"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-women">
      <value value="605"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-test-frequency">
      <value value="0.33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="version">
      <value value="&quot;people&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relacion">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-men">
      <value value="503"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-commitment">
      <value value="26"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
