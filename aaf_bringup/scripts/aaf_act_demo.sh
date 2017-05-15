#!/bin/bash

SESSION=act_demo

TOP_MAP=aaf_y4
CONF=human_activity
WAYPOINTS=aaf_y4

tmux -2 new-session -d -s $SESSION
# Setup a window for tailing log files
tmux new-window -t $SESSION:0 -n 'people'
tmux new-window -t $SESSION:1 -n 'rwth'
tmux new-window -t $SESSION:2 -n 'soma'
tmux new-window -t $SESSION:3 -n 'learning'
tmux new-window -t $SESSION:4 -n 'online_act'

tmux select-window -t $SESSION:0
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 roslaunch cpm_skeleton cpm_skeleton.launch reomve_rgb:=False"
tmux split-window -v
tmux select-pane -t 1
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 rosrun CPM?"
tmux split-window -v
tmux select-pane -t 2
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "roslaunch activity_data record_data.launch use_roi:=True soma_map:=$TOP_MAP roi_config:=$CONF frame_rate_reduce:=2"
tmux select-pane -t 3
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "rosrun consent_tsc consent_for_images.py" C-m
tmux split-window -v
tmux select-pane -t 4
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "roslaunch --wait record_skeletons_action recording_action.launch soma_map:=$TOP_MAP soma_config:=$CONF consent_num_frames:=300"


tmux select-window -t $SESSION:1
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 roslaunch perception_people_launch people_tracker_robot.launch with_mdl_tracker:=true"
tmux select-pane -t 1
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "source ~/tensorflow/bin/activate" C-m
tmux send-keys "DISPLAY=:0.0 roslaunch skeletons_cnn pose_cnn.launch"



tmux select-window -t $SESSION:2
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "roslaunch soma_manager soma_local.launch map_name:=aaf_y4_demo"
tmux select-pane -t 1
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "rosrun soma_manager object_manager.py $CONF"
tmux split-window -h
tmux select-pane -t 2
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "rosrun soma_roi_manager soma_roi_node.py $CONF"


tmux select-window -t $SESSION:3
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "roslaunch nav_goals_generator nav_goals_generator.launch map:=/move_base/global_costmap/costmap is_costmap:=True"
tmux select-pane -t 1
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "roslaunch human_activities learn_human_activities.launch"
tmux split-window -h
tmux select-pane -t 2
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys ""

tmux select-window -t $SESSION:4
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys "DISPLAY=:0.0 rosrun online_activity_recognition activity_action.py"
tmux select-pane -t 1
tmux send-keys "ssh werner-left-cortex" C-m
tmux send-keys ""





# Set default window
tmux select-window -t $SESSION:0

# Attach to session
tmux -2 attach-session -t $SESSION

tmux setw -g mode-mouse on
