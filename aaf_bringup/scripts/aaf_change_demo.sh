#!/bin/bash

# Topics to visualize:
# /quasimodo/segmentation/roomObservation/dynamic_clusters - overlay on room observation
# /quasimodo_db_visualization - current quasimodo database image
# /quasimodo_retrieval/visualization - the query images
# XXX - the complete room cloud


SESSION=change_demo

TOP_MAP=aaf_y4
CONF=human_activity
WAYPOINTS=aaf_y4
DATA_PATH="/storage/quasimodo"

tmux -2 new-session -d -s $SESSION
# Setup a window for tailing log files
tmux new-window -t $SESSION:0 -n 'modelserver'
tmux new-window -t $SESSION:1 -n 'quasimodo_object_search'
tmux new-window -t $SESSION:2 -n 'image_database_node'
tmux new-window -t $SESSION:3 -n 'soma_insert_model_server'
tmux new-window -t $SESSION:4 -n 'deep_net_object_store'
tmux new-window -t $SESSION:5 -n 'people_rejection'
tmux new-window -t $SESSION:6 -n 'semantic_map'
tmux new-window -t $SESSION:7 -n 'soma_roi_manager'
tmux new-window -t $SESSION:8 -n 'view_planning'
tmux new-window -t $SESSION:9 -n 'add_change_demo'

tmux select-window -t $SESSION:0
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "cd $DATA_PATH" C-m
tmux send-keys "DISPLAY=:0.0 rosrun quasimodo_brain modelserver -addSomaOnline -oclusion_penalty 15"
tmux select-pane -t 1
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 rosrun quasimodo_brain metaroom_additional_view_processing"

tmux select-window -t $SESSION:1
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 roslaunch quasimodo_object_search object_search.launch data_path:=$DATA_PATH disable_processing:=true"

tmux select-window -t $SESSION:2
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0 rosrun aaf_bringup aaf_headless.sh"
tmux select-pane -t 1
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0 rosrun quasimodo_object_search image_database_node"

tmux select-window -t $SESSION:3
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 rosrun quasimodo_conversions soma_insert_model_server.py"
tmux select-pane -t 1
tmux send-keys "DISPLAY=:0 roslaunch soma_visualizer soma_visualizer.launch"

tmux select-window -t $SESSION:4
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 rosrun deep_net_object_store deep_net_object_store_node"
tmux select-pane -t 1
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 rosrun deep_object_detection deep_object_detection_node.py --gpu 0 --net ResNet-50"

tmux select-window -t $SESSION:5
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 rosrun local_metric_map_people_rejection people_rejection.py"

tmux select-window -t $SESSION:6
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 roslaunch semantic_map_launcher semantic_map.launch"

tmux select-window -t $SESSION:7
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 roslaunch soma_manager soma_local.launch map_name:=aaf_y4_demo"
tmux select-pane -t 1
tmux split-window -h
tmux select-pane -t 1
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 rosrun soma_manager object_manager.py object_demo"
tmux select-pane -t 2
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 rosrun soma_roi_manager soma_roi_node.py object_demo"

tmux select-window -t $SESSION:8
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 roslaunch multi_object_learning_launcher run_viper_suite.launch"
tmux select-pane -t 1
tmux split-window -h
tmux select-pane -t 1
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 roslaunch observation_registration_launcher observation_registration.launch"
tmux select-pane -t 2
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 roslaunch multi_object_learning_launcher run_full_pipeline.launch"

tmux select-window -t $SESSION:9
tmux send-keys "DISPLAY=:0.0 rosrun aaf_bringup add_change_demo.py"

# Set default window
tmux select-window -t $SESSION:0

# Attach to session
tmux -2 attach-session -t $SESSION

tmux setw -g mode-mouse on
