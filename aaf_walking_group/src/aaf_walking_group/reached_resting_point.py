#!/usr/bin/env python

import rospy
import smach
from std_msgs.msg import String
import strands_webserver.client_utils
from std_srvs.srv import Empty, EmptyResponse


class RestingPoint(smach.State):
    def __init__(self, display_no):
        smach.State.__init__(
            self,
            outcomes=['key_card', 'killall','rest','continue'],
            input_keys=['waypoints', 'play_music'],
            output_keys=['waypoints', 'play_music']
        )
        self.display_no = display_no
        self.card = False
        self.sub_key = None
        self.sub_dist = None
        self.close = False
        self.action = -1
        self.cont_srv = rospy.Service('/aaf_walking_group/rest/cont', Empty, self.cont_tour)
        self.rest_srv = rospy.Service('/aaf_walking_group/rest/stay', Empty, self.rest_here)

    def execute(self, userdata):
        self.card = False
        self.recall_preempt()
        self.close = False
        self.action = -1
        self.sub_key = rospy.Subscriber("/socialCardReader/commands", String, callback=self.key_callback)
        self.sub_dist = rospy.Subscriber("/socialCardReader/QSR_generator", String, self.dist_callback)
        rospy.loginfo("I am at: " + userdata.waypoints.get_current_resting_waypoint())
        strands_webserver.client_utils.display_relative_page(self.display_no, 'warte.html')
        while not self.close and not rospy.is_shutdown() and not self.preempt_requested():
            rospy.sleep(1)
        rospy.loginfo("Showing rest interface.")
        strands_webserver.client_utils.display_relative_page(self.display_no, "rast.html")
        while self.action == -1 and not rospy.is_shutdown() and not self.preempt_requested():
            rospy.sleep(1)
        self.sub_key.unregister()
        self.sub_key = None
        self.sub_dist.unregister()
        self.sub_dist = None

        if self.preempt_requested():
            if self.card:
                return 'key_card'
            else:
                return 'killall'
        if self.action == 0:
            userdata.waypoints.advance()
            userdata.waypoints.create_route()
            return 'continue'
        elif self.action == 1:
            return 'rest'

    def key_callback(self, data):
        rospy.loginfo("got card: " + str(data.data))
        if data.data == "PAUSE_WALK":
            self.card = True
            smach.State.request_preempt(self)

    def dist_callback(self, data):
        if data.data == "near":
            self.close = True

    def cont_tour(self, req):
        self.action = 0
        return EmptyResponse()

    def rest_here(self, req):
        self.action = 1
        return EmptyResponse()
