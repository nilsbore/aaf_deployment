#!/bin/bash

SESSION=change_demo

TOP_MAP=aaf_y4
CONF=human_activity
WAYPOINTS=aaf_y4
DATA_PATH=/storage/quasimodo

tmux -2 new-session -d -s $SESSION
# Setup a window for tailing log files
tmux new-window -t $SESSION:0 -n 'modelserver'
tmux new-window -t $SESSION:1 -n 'quasimodo_object_search'
tmux new-window -t $SESSION:2 -n 'image_database_node'
tmux new-window -t $SESSION:3 -n 'soma_insert_model_server'
tmux new-window -t $SESSION:4 -n 'deep_net_object_store'

tmux select-window -t $SESSION:0
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "cd $(DATA_PATH)" C-m
tmux send-keys "DISPLAY=:0.0 rosrun quasimodo_brain modelserver -addSomaOnline -oclusion_penalty 15"
tmux select-pane -t 1
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 rosrun quasimodo_brain metaroom_additional_view_processing"

tmux select-window -t $SESSION:1
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 roslaunch quasimodo_object_search object_search.launch data_path:=$(DATA_PATH) disable_processing:=true"

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
tmux send-keys "# SOMA VIS GOES HERE!"

tmux select-window -t $SESSION:4
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 rosrun deep_net_object_store deep_net_object_store_node"
tmux select-pane -t 1
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 rosrun deep_object_detection deep_object_detection_node.py --gpu 0 --net ResNet-50"

# Set default window
tmux select-window -t $SESSION:0

# Attach to session
tmux -2 attach-session -t $SESSION

tmux setw -g mode-mouse on
