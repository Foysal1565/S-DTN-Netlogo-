globals [gap water land shore scaling-unit scaled_transmission_range scaling_factor nodes_linked value check temp_1 temp_2 temp_3 temp_4 temp_5 temp_6 temp_7 temp_8 temp_9 temp_10 temp_11 temp_12 temp_13 temp_14 temp_15 temp_16 temp_17 temp_18  temp_19  temp_20 n node_range AUV_range AUV2_range boat_range sink_range file   
  report_AUV report_node_generate report_total_node_generate report_sink_receive report_node_sent report_node_storage report_AUV_sent report_AUV1_sent report_boat_sent auv1_depth auv2_depth]
breed [nodes node]
breed [AUV AUVs]
breed [AUV2 AUVs2]
breed [boat boats]
breed [sink sinks]
boat-own [speed_boat boat_sent AUV_sent AUV1_sent]
AUV-own [speed_AUV AUV_storage AUV_sent]
AUV2-own [speed_AUV AUV_storage AUV_sent AUV1_sent]
sink-own [sink_receive]
nodes-own [node_generate total_node_generate node_storage node_sent]
undirected-link-breed [link_boats link_boat]
undirected-link-breed [link_sink link_sinks]
undirected-link-breed [link_AUVs link_AUV]
undirected-link-breed [link_AUVs_2 link_AUV_2]

to setup
  reset-timer 
  clear-all
  data_reset
  if data_record = "file_save" [file_open]
  if real_time = false [world_scaling sensor_ranges]
  ask patches with [pycor < 7] [set pcolor 96 ]
  set water (abs (min-pycor) + 7)
  ask patches with [pycor > 10] [set pcolor 75 ]
  set land (max-pycor - 10 + 1)
  ask patches with [pcolor = black] [set pcolor 37]
  set shore (9 - 7 + 1)
  set gap (max-pxcor - min-pxcor) / (number_of_nodes + 1)
  set n (1 / 30)
  if (number_of_nodes > world-width)
    [
      user-message (word "There are too many nodes for the amount of space.\n"
        "Please lower the number of nodes by lowering the NUMBER slider.\n"
        "The setup has stopped.")
      stop
    ]
  simulation_period
  auv_depths
  create_nodes
  ;  stack_nodes
  create_AUV
  create_sink
  ;  inspect node 0
  create_boat
  show_info
  
  reset-ticks
  
  
end



to create_nodes
  
  create-nodes number_of_nodes
  [ set shape "hexagonal prism"
    set size 1.5
    set color 103
    set ycor -16
    set temp_1 0
    set temp_2 0
    
    foreach sort nodes [
      ask ? 
      [ifelse temp_1 = 0 
        [set xcor (min-pxcor + gap) set temp_1 1 set temp_2 xcor] 
        [set xcor temp_2 + gap set temp_2 (temp_2 + gap)]]]
    ;    ask nodes [set label who]
  ]
  
end

to stack_nodes
  
  create-nodes (number_of_nodes / 2) 
  [ set shape "hexagonal prism"
    set size 1.5
    set color 103
    set ycor -10
    set temp_7 0
    set temp_8 0
    
    
    foreach sort nodes [
      ask ?
      [ifelse temp_7 = 0 
        [set xcor (min-pxcor + gap * 1.5) set temp_7 1 set temp_8 xcor]
        [set xcor (temp_8 + gap * 2) set temp_8 (temp_8 + gap * 2)]]]
    ;    ask nodes [set label who]
  ]  
end

to create_AUV
  if scenario_chooser != "two_AUVs" [
    if scenario_chooser != "three_AUVs"[ 
      create-AUV 1 [
        setxy min-pxcor + 1 auv2_depth
        set shape "cylinder"
        set size 2
        set heading 90
        set label "AUV2"
      ]]]
  
  if scenario_chooser = "three_AUVs" [
    create-AUV 1 [
      setxy min-pxcor + 1 auv2_depth
      set shape "cylinder"
      set size 2
      set heading 90
      set label "AUV2"
    ]
    create-AUV 1 [
      setxy ((min-pxcor + 1) + (max-pxcor - 1)) / 2 auv2_depth
      set shape "cylinder"
      set size 2
      set heading 90
      set label "AUV3"
    ]
    create-AUV2 1 [
      setxy min-pxcor + 1 auv1_depth
      set shape "cylinder"
      set size 2
      set heading 90
      set label "AUV1"
    ]]
  
  if scenario_chooser = "two_AUVs" [
    create-AUV 1 [
      setxy min-pxcor + 1 auv2_depth
      set shape "cylinder"
      set size 2
      set heading 90
      set label "AUV2"
    ]
    create-AUV2 1 [
      setxy min-pxcor + 1 auv1_depth
      set shape "cylinder"
      set size 2
      set heading 90
      set label "AUV1"
    ]]
end

to create_boat
  create-boat number_of_boats [
    setxy random-xcor  7
    set heading 90
    set shape "boat"
    set size 5]

  
end


to create_sink
  create-sink 1
  [setxy 22 12
    set shape "v-sat"
    set size 5  
    set label "sink2"  
  ]
  
  
  create-sink 1
  [setxy -22 12
    set shape "v-sat"
    set size 5    
    set label "sink1"  
  ]
end

to linking_AUV
  create-link_AUVs-with nodes in-radius node_range
  ask links [
    set thickness 0.2
    set color 45]
end



to linking_AUV_2
  create-link_AUVs_2-with AUV in-radius AUV2_range
  ask links [
    set thickness 0.2
    set color 45 
  ]
end

to linking_AUV_3
  create-link_AUVs-with nodes with [xcor < 0] in-radius node_range
  ask links [
    set thickness 0.2
    set color 45]
end

to linking_AUV_4
  create-link_AUVs-with nodes with [xcor >= 0] in-radius node_range
  ask links [
    set thickness 0.2
    set color 45]
end


to linking_boat
  create-link_boats-with AUV in-radius AUV_range
  ask links [
    set thickness 0.2
    set color 45 
  ]
end

to linking_boat_2
  create-link_boats-with AUV2 in-radius AUV_range
  ask links [
    set thickness 0.2
    set color 45 
  ]
end


to linking_sink
  create-link_sink-with sink in-radius boat_range
  ask links [
    set thickness 0.2
    set color 45 ]
end



to move_AUV
  
  
  if real_time = true [world_scaling sensor_ranges] 
  if scenario_chooser = "basic"[
    every n [
      ask AUV [
        set speed_AUV (scaling_factor * speed_of_AUV2 * n)
        auv_cruise
        linking_AUV
        ask links [if link-length > node_range [die]
        ]]]]
  
  if scenario_chooser = "three_AUVs" [
    every n [
      ask AUVs (number_of_nodes) [
        set speed_AUV (scaling_factor * speed_of_AUV2 * n)
        auv_cruise_1
        linking_AUV_3
        ask links [if link-length > node_range [die]
        ]]]
    
    every n [
      ask AUVs (number_of_nodes + 1) [
        set speed_AUV (scaling_factor * speed_of_AUV2 * n)
        auv_cruise_2
        linking_AUV_4
        ask links [if link-length > node_range [die]
        ]]]
    every n [
      ask AUV2 [
        set speed_AUV (scaling_factor * speed_of_AUV * n)
        auv_cruise
        linking_AUV_2
        ask links [if link-length > AUV2_range [die]
        ]]]]
  
  if scenario_chooser = "two_AUVs" [
    every n [
      ask AUV [
        set speed_AUV (scaling_factor * speed_of_AUV2 * n)
        auv_cruise
        linking_AUV
        ask links [if link-length > node_range [die]
        ]]]
    
    every n [
      ask AUV2 [
        set speed_AUV (scaling_factor * speed_of_AUV * n)
        auv_cruise
        linking_AUV_2
        ask links [if link-length > AUV2_range [die]
        ]]]]
  
  reset-ticks
end
      
      
to launch_boat
  
  if real_time = true [world_scaling sensor_ranges]
  if scenario_chooser = "basic" [
    every n [
      ask boat [
        set speed_boat (scaling_factor * speed_of_boat * n)
        boat_cruise
        linking_boat
        ask link_boats [if link-length > (AUV_range) [die]]
        linking_sink
        ask link_sink [if link-length > (boat_range) [die]]
        stop]]]
  
  if scenario_chooser != "basic" [
    every n [
      ask boat [
        set speed_boat (scaling_factor * speed_of_boat * n)
        boat_cruise
        linking_boat_2
        ask link_boats [if link-length > (AUV_range) [die]]
        linking_sink
        ask link_sink [if link-length > (boat_range) [die]]
        stop]]]
  
  
  
end
      
      
      
to world_scaling 
  set scaling_factor (world-width / (world_scale * 1000)) ;; patches per meter
end
      
to sensor_ranges
  ask nodes[
    set node_range node_sensor_range * scaling_factor] ;; meters converted to patch length
  ask AUV[
    set AUV_range AUV_sensor_range * scaling_factor ;; meters converted to patch length
    set AUV2_range AUV2_sensor_range * scaling_factor]
  ask boat[
    set boat_range boat_sensor_range * scaling_factor] ;; meters converted to patch length
                                                       ;  ask sink [
                                                       ;    set sink_range sink_sensor_range * scaling_factor * 1000] ;; meters converted to patch length
  
end
      
      ;to-report linked_nodes
      ;  report nodes_linked
      ;  
      ;end
      
to data_reset
  ask nodes[
    set node_generate 0
    set node_storage 0
    set node_sent 0]
  ask AUV[
    set AUV_storage 0]
  ask boat[
    set AUV_sent 0]
  ask sink[
    set sink_receive 0]
  set temp_5 1
  
end
      
to node_data_generate
  
  if temp_5 = 1 [
    every 1 [ask nodes [set node_generate (node_generate + data_generation_rate) set report_node_generate node_generate]]]
end
      
to data
  
  if scenario_chooser = "basic" [
    
    ask nodes [set temp_15 node_generate]
    ask nodes [set total_node_generate (node_generate * number_of_nodes) set report_total_node_generate total_node_generate]
    ask AUV [ask link_AUV-neighbors [set node_sent temp_15]]
    set temp_3 (sum [node_sent] of nodes) set report_node_sent temp_3 
    ask nodes [set node_storage (node_generate - node_sent)]
    set temp_16 (sum [node_storage] of nodes) set report_node_storage temp_16 
    
    ask AUV [ask link_boat-neighbors [set AUV_sent temp_3 set report_AUV_sent AUV_sent set temp_4 AUV_sent]]
    
    ask boat [ask link_sinks-neighbors [set sink_receive temp_4 set report_sink_receive sink_receive set temp_6 sink_receive]]
    ask boat [set boat_sent temp_6 set report_boat_sent boat_sent]
    
  ]
  
  
  if scenario_chooser = "two_AUVs"[
    
    ask nodes [set temp_15 node_generate]
    ask nodes [set total_node_generate (node_generate * number_of_nodes) set report_total_node_generate total_node_generate]
    ask AUV [ask link_AUV-neighbors [set node_sent temp_15]]
    set temp_3 (sum [node_sent] of nodes) set report_node_sent temp_3 
    ask nodes [set node_storage (node_generate - node_sent)]
    set temp_16 (sum [node_storage] of nodes) set report_node_storage temp_16 
    
    ask AUV [ ask link_AUV_2-neighbors [set AUV_sent temp_3 set report_AUV_sent AUV_sent set temp_4 AUV_sent]]
    ask AUV2  [ask link_boat-neighbors [set AUV1_sent temp_4 set report_AUV1_sent AUV1_sent set temp_14 AUV1_sent]]
    
    ask boat [ask link_sinks-neighbors [set sink_receive temp_14 set report_sink_receive sink_receive set temp_6 sink_receive]]
    ask boat [set boat_sent temp_6 set report_boat_sent boat_sent]
    
  ]
  
  
  if scenario_chooser = "three_AUVs" [
    
    ask nodes [set temp_15 node_generate]
    ask nodes [set total_node_generate (node_generate * number_of_nodes) set report_total_node_generate total_node_generate]
    ask AUV [ask link_AUV-neighbors [set node_sent temp_15]]
    set temp_3 (sum [node_sent] of nodes) set report_node_sent temp_3 
    ask nodes [set node_storage (node_generate - node_sent)]
    set temp_16 (sum [node_storage] of nodes) set report_node_storage temp_16 
    
    set temp_10 (sum [node_sent] of nodes with [xcor < 0])
    set temp_11 (sum [node_sent] of nodes with [xcor >= 0])
    
    ;    ask AUVs (number_of_nodes) [ask link_boat-neighbors [set temp_12 temp_10]]
    ;    ask AUVs (number_of_nodes + 1) [ask link_boat-neighbors [set temp_13 temp_11]]
    ;    ask AUV [ set AUV_sent (temp_12 + temp_13) set report_AUV_sent AUV_sent set temp_4 AUV_sent]
    ;    
    ;    ask boat [ask link_sinks-neighbors [set sink_receive temp_4 set report_sink_receive sink_receive set temp_6 sink_receive]]
    ;    ask boat [set boat_sent temp_6 set report_boat_sent boat_sent]
    
    ask AUVs (number_of_nodes) [ask link_AUV_2-neighbors[set temp_12 temp_10]]
    ask AUVs (number_of_nodes + 1) [ask link_AUV_2-neighbors [set temp_13 temp_11]]
    ask AUV [ set AUV_sent (temp_12 + temp_13) set report_AUV_sent AUV_sent set temp_4 AUV_sent]
    
    ask AUV2  [ask link_boat-neighbors [set AUV1_sent temp_4 set report_AUV1_sent AUV1_sent set temp_14 AUV1_sent]]
    
    ask boat [ask link_sinks-neighbors [set sink_receive temp_14 set report_sink_receive sink_receive set temp_6 sink_receive]]
    ask boat [set boat_sent temp_6 set report_boat_sent boat_sent]
    
    
  ]
end
      
to-report generate_node
  report report_node_generate
end
      
to-report generate_node_total
  report report_total_node_generate
  
end
      
to-report storage_node
  report report_node_storage
end
      
to-report sent_node
  report report_node_sent
end
      
to-report sent_AUV
  report report_AUV_sent
end
      
to-report sent_AUV1
  report report_AUV1_sent
end
      
to-report sent_boat
  report report_boat_sent
end
      
      
      
to-report receive_sink
  report report_sink_receive
end
      
to simulation_period
  if terminate_simulation = "elapsed_time" [if timer > (simulation_time * 60) [stop]]
end
      
to volume_data
  if terminate_simulation = "data_volume" [if report_sink_receive > (data_volume * 1024) [stop]]
end
      
to run_simulate
  move_AUV
  launch_boat
  node_data_generate
  data
  if data_record = "file_save" [file_output]
  set temp_20 timer
end
      
      
to file_open
  
  set file user-new-file
  
  if is-string? file
  [if file-exists? file
    [ file-delete file ]
  file-open file
  ]
end
      
to file_output
  file-open file
  export-plot "tota" file
end
      
to show_info
  print (word "world height is " precision ((world_scale / world-width) * world-height) 3 " kilometers")
  print (word "ocean depth is " round (water * 1000 * (world_scale / world-width)) " meters")
  print (word "node to node gap is " round (gap * 1000 * (world_scale / world-width)) " meters")
  print (word "sink separation " round ( 40 * 1000 * (world_scale / world-width)) " meters")
  
  print (word "depth of AUV1 from surface " round ((water - temp_17) * 1000 * (world_scale / world-width)) " meters")
  print (word "depth of AUV2 from surface " round ((water - temp_18) * 1000 * (world_scale / world-width)) " meters")
  
end
      
to auv_cruise
  if xcor >= max-pxcor - 1 [set heading 270]
  if heading = 270 [ ifelse xcor > min-pxcor + 1 [fd speed_AUV][set heading 90]]
  if xcor < max-pxcor - 1 [fd speed_AUV]
end
      
to auv_cruise_1
  if xcor >= temp_9 [set heading 270]
  if heading = 270 [ ifelse xcor > min-pxcor + 1 [fd speed_AUV][set heading 90]]
  if xcor < temp_9 [fd speed_AUV]
end
      
to auv_cruise_2
  if xcor >= max-pxcor - 1 [set heading 270]
  if heading = 270 [ ifelse xcor > temp_9 [fd speed_AUV][set heading 90]]
  if xcor < max-pxcor - 1 [fd speed_AUV]
end
      
to boat_cruise
  if xcor >= max-pxcor - 4 [set heading 270]
  if heading = 270 [ ifelse xcor > min-pxcor + 2 [fd speed_boat][set heading 90]]
  if xcor < max-pxcor - 1 [fd speed_boat]
end
      
to auv_depths
  
  set temp_17 (AUV1_height_from_seabed * (world-width / (world_scale * 1000)))
  set auv1_depth (min-pycor + temp_17)
  ;  print (word "auv1_depth " auv1_depth " patches")
  
  set temp_18 (AUV2_height_from_seabed * (world-width / (world_scale * 1000)))
  set auv2_depth (min-pycor + temp_18)
  ;  print (word "auv2_depth " auv2_depth " patches")
  
  
end
      
      
      ;to file_output
      ;  file-open file
      ;  ask nodes [                 
      ;    file-print total_node_generate]
      ;  file-close
      ;end
      
      
      ;to data_volume_transfer
      ;  ask nodes [set temp_6 node_generate]
      ;  ask sink [set temp_7 sink_receive]
      ;  if data_volume = temp_6[ set temp_5 0]
      ;  if temp_6 = temp_7 [output-print (word "delay time: " timer " seconds") stop]
      ;
      ;end
@#$#@#$#@
GRAPHICS-WINDOW
510
10
1230
501
25
16
13.94
1
10
1
1
1
0
0
0
1
-25
25
-16
16
0
0
1
ticks
500.0

BUTTON
43
295
128
334
Setup
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
41
64
216
97
number_of_nodes
number_of_nodes
0
60
10
2
1
NIL
HORIZONTAL

SLIDER
41
130
216
163
speed_of_AUV2
speed_of_AUV2
0
30
10
.1
1
m/s
HORIZONTAL

SLIDER
41
162
216
195
speed_of_boat
speed_of_boat
0
50
15
.1
1
m/s
HORIZONTAL

SLIDER
240
47
407
80
node_sensor_range
node_sensor_range
100
1000
390
10
1
m
HORIZONTAL

SLIDER
41
31
216
64
world_scale
world_scale
.1
20
3
.1
1
km
HORIZONTAL

SWITCH
273
10
367
43
real_time
real_time
0
1
-1000

SLIDER
240
80
407
113
AUV_sensor_range
AUV_sensor_range
0
1500
800
10
1
m
HORIZONTAL

SLIDER
240
145
408
178
boat_sensor_range
boat_sensor_range
0
1500
880
10
1
m
HORIZONTAL

BUTTON
136
295
216
334
Simulate
run_simulate\nif terminate_simulation = \"elapsed_time\" [simulation_period]\nif terminate_simulation = \"data_volume\" [ volume_data]
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
240
178
408
211
simulation_time
simulation_time
0
60
30.6
.1
1
minutes
HORIZONTAL

MONITOR
857
507
949
552
node_generate
generate_node
17
1
11

SLIDER
41
194
216
227
data_generation_rate
data_generation_rate
0
50
5
1
1
Bps
HORIZONTAL

MONITOR
585
507
664
552
sink_receive
receive_sink
17
1
11

PLOT
21
342
441
571
total_data_transfer
Time
Data
0.0
0.0
0.0
0.0
true
true
"" ""
PENS
"node_generate" 1.0 0 -13345367 true "plot report_total_node_generate" "plot report_total_node_generate"
"sink_receive" 1.0 0 -13840069 true "plot report_sink_receive" "plot report_sink_receive"

MONITOR
768
507
858
552
total_node_sent
sent_node
17
1
11

MONITOR
947
507
1024
552
AUV_sent
sent_AUV
17
1
11

MONITOR
1099
507
1171
552
boat_sent
sent_boat
17
1
11

PLOT
588
647
968
865
data_transfers
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
"node_sent" 1.0 0 -5825686 true "plot report_node_sent" "plot report_node_sent"
"AUV_sent" 1.0 0 -955883 true "plot report_AUV_sent" "plot report_AUV_sent"
"boat_sent" 1.0 0 -14454117 true "plot report_boat_sent" "plot report_boat_sent"

MONITOR
471
507
587
552
total_node_generate
generate_node_total
17
1
11

CHOOSER
241
247
409
292
scenario_chooser
scenario_chooser
"basic" "two_AUVs" "three_AUVs" "four_AUVs"
1

CHOOSER
137
238
229
283
data_record
data_record
"on_display" "file_save"
0

SLIDER
41
97
216
130
speed_of_AUV
speed_of_AUV
0
30
10
.1
1
m/s
HORIZONTAL

MONITOR
1020
507
1099
552
AUV1_sent
sent_AUV1
17
1
11

SLIDER
240
112
407
145
AUV2_sensor_range
AUV2_sensor_range
0
1500
1500
10
1
m
HORIZONTAL

MONITOR
663
507
769
552
total_node_storage
storage_node
17
1
11

SLIDER
422
106
455
291
AUV1_height_from_seabed
AUV1_height_from_seabed
0
800
600
10
1
m
VERTICAL

SLIDER
458
106
491
291
AUV2_height_from_seabed
AUV2_height_from_seabed
0
800
250
10
1
m
VERTICAL

CHOOSER
31
238
138
283
terminate_simulation
terminate_simulation
"never" "elapsed_time" "data_volume"
0

MONITOR
1170
507
1244
552
timer(sec)
timer
1
1
11

SLIDER
240
211
408
244
data_volume
data_volume
0
50
5
.1
1
kB
HORIZONTAL

INPUTBOX
411
33
507
93
number_of_boats
2
1
0
Number

PLOT
56
685
385
909
plot 1
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
"Node Sent" 1.0 2 -8732573 true "" "plot report_node_sent"
"Node Generate" 1.0 2 -5298144 true "" "plot report_node_generate"
"Node Storage" 1.0 2 -7500403 true "" "plot report_node_storage"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

boat
false
0
Polygon -16777216 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -8630108 true false 158 33 230 157 182 150 169 151 157 156
Polygon -13345367 true false 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

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
Circle -7500403 true true 45 45 210
Rectangle -7500403 true true 60 90 120 165
Circle -7500403 true true 75 75 150

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

container
false
0
Rectangle -7500403 false true 0 75 300 225
Rectangle -2674135 true false 0 75 300 225
Line -16777216 false 0 210 300 210
Line -16777216 false 0 90 300 90
Line -16777216 false 150 90 150 210
Line -16777216 false 120 90 120 210
Line -16777216 false 90 90 90 210
Line -16777216 false 240 90 240 210
Line -16777216 false 270 90 270 210
Line -16777216 false 30 90 30 210
Line -16777216 false 60 90 60 210
Line -16777216 false 210 90 210 210
Line -16777216 false 180 90 180 210

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

hexagonal prism
false
0
Rectangle -7500403 true true 90 90 210 270
Polygon -1 true false 210 270 255 240 255 60 210 90
Polygon -13345367 true false 90 90 45 60 45 240 90 270
Polygon -11221820 true false 45 60 90 30 210 30 255 60 210 90 90 90

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

v-sat
false
0
Polygon -1 true false 180 135 255 90 240 135 195 150 210 285 240 285 255 300 180 300
Circle -13345367 true false 90 -15 150
Polygon -2674135 true false 150 45 165 75 180 60 150 45

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
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
