display: Roomba Sensor Controller
description: Drive your roomba by tilting your android phone!
platform: turtlebot
launch: otl_android_roomba_app/dummy.launch
interface: otl_android_roomba_app/roomba.interface
icon: otl_android_roomba_app/otl_roomba.png
clients:
  - type: android
    manager:
      api-level: 9
      intent-action: com.ogutti.ros.android.roomba_app.RoombaController
    app:
      base_control_topic: /cmd_vel
      linear_rate: 0.08
      angular_rate: 0.2
