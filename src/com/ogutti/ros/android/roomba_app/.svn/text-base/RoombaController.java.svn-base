/*
 * Copyright (C) 2011 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
package com.ogutti.ros.android.roomba_app;
import com.ogutti.ros.android.roomba_app.RoombaProxy;
import ros.android.activity.RosAppActivity;

import org.ros.node.Node;
import org.ros.android.R;
import org.ros.android.RosActivity;

import java.text.DecimalFormat;
import java.util.List;
import java.util.HashMap;

import android.os.Bundle;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;
import android.widget.ToggleButton;


import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

import android.widget.ImageView;
import android.graphics.drawable.Drawable;

/**
 * @author t.ogura@gmail.com (Takashi Ogura)
 */
public class RoombaController extends RosAppActivity implements SensorEventListener{
  private SensorManager sensorManager;
  private String topicName;
  private TextView velocityTextView;
  private RoombaProxy controllerNode;
  private double linearVelocityRate;
  private double angularVelocityRate;
  private HashMap<String, Drawable> droidBitmap;
  private static final double LINEAR_VELOCITY_RATE  = 0.08;
  private static final double ANGULAR_VELOCITY_RATE = 0.2;
  
  private double speedRate;
  
  /** Called when the activity is first created. */
  @Override
  public void onCreate(Bundle savedInstanceState) {
    setDefaultAppName("otl_android_roomba_app");
    setDashboardResource(R.id.top_bar);
    setMainWindowResource(R.layout.main);

    droidBitmap = new HashMap<String, Drawable>();
    super.onCreate(savedInstanceState);
    speedRate = 0.5;

    droidBitmap.put("stop", getResources().getDrawable(R.drawable.droid_s));
    droidBitmap.put("forward", getResources().getDrawable(R.drawable.droid_f));
    droidBitmap.put("backward", getResources().getDrawable(R.drawable.droid_b));
    droidBitmap.put("right", getResources().getDrawable(R.drawable.droid_r));
    droidBitmap.put("left", getResources().getDrawable(R.drawable.droid_l));
                    
    topicName = "cmd_vel";
    linearVelocityRate = LINEAR_VELOCITY_RATE;
    angularVelocityRate = ANGULAR_VELOCITY_RATE;
    
    if (getIntent().hasExtra("base_control_topic")) {
      topicName = getIntent().getStringExtra("base_control_topic");
    }
    try {
      if (getIntent().hasExtra("linear_rate")) {
        linearVelocityRate = Double.parseDouble(getIntent().getStringExtra("linear_rate"));
      }
      if (getIntent().hasExtra("angular_rate")) {
        angularVelocityRate = Double.parseDouble(getIntent().getStringExtra("angular_rate"));
      }
    } catch (Exception e) {
      Log.e("RoombaController", "intent value error");
    }
    
    sensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
    velocityTextView = (TextView)findViewById(R.id.velocity_text);
  }
  
  /** Called when the node is created */
  @Override
  protected void onNodeCreate(Node node) {
    super.onNodeCreate(node);


    // create ROS nodes
    controllerNode = new RoombaProxy(topicName);
    // manually call onStart()
    controllerNode.onStart(node);
    
    // set callback for accelerometer
    List<Sensor> sensors = sensorManager
        .getSensorList(Sensor.TYPE_ACCELEROMETER);
    if (sensors.size() > 0) {
      Sensor accelerometer = sensors.get(0);
      sensorManager.registerListener(this, accelerometer,
                                     SensorManager.SENSOR_DELAY_FASTEST);
    } else {
      Log.v("RoombaController", "NOT found sensor!");
    }
    
    // set toggle button's callback
    ToggleButton tb = (ToggleButton) findViewById(R.id.toggleButton1);
    tb.setOnCheckedChangeListener(new OnCheckedChangeListener() {
        @Override
        public void onCheckedChanged(CompoundButton buttonView,
                                     boolean isChecked) {
          controllerNode.publishClean(isChecked);
        }
      });
    
    // set seekbar callback. 
    SeekBar seekBar = (SeekBar) findViewById(R.id.speedSeekBar);
    final TextView tv1 = (TextView) findViewById(R.id.speedTextView);
    seekBar.setOnSeekBarChangeListener(new OnSeekBarChangeListener() {
        public void onProgressChanged(SeekBar seekBar, int progress,
                                      boolean fromUser) {
          tv1.setText("Speed:" + progress + "%");
          speedRate = progress * 0.01f;
        }
        
        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {
        }
        
        @Override
        public void onStopTrackingTouch(SeekBar seekBar) {
        }
      });
    Button dockButton = (Button) findViewById(R.id.button1);
    dockButton.setOnClickListener(new OnClickListener() {
        @Override
        public void onClick(android.view.View v) {
          controllerNode.publishDock();
        }
      });
  }
  
  @Override
  public void onAccuracyChanged(Sensor sensor, int accuracy) {
  }

  /**
   * callback of sensor change(accelerometer)
   */
  @Override
  public void onSensorChanged(SensorEvent event) {
    if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
      double linearX = event.values[1] * -linearVelocityRate * speedRate;
      double angularZ = event.values[0] * angularVelocityRate * speedRate;
      if (Math.abs(linearX) < linearVelocityRate) {
        linearX = 0.0d;
      }
      if (Math.abs(angularZ) < angularVelocityRate) {
        angularZ = 0.0d;
      }
      ImageView imageView = (ImageView)findViewById(R.id.imageView);
      if (linearX > 0.0) {
        imageView.setImageDrawable(droidBitmap.get("forward"));
      } else if (linearX < 0.0) {
        imageView.setImageDrawable(droidBitmap.get("backward"));
      } else if (angularZ > 0.0) {
        imageView.setImageDrawable(droidBitmap.get("left"));
      } else if (angularZ < 0.0) {
        imageView.setImageDrawable(droidBitmap.get("right"));
      } else {
        imageView.setImageDrawable(droidBitmap.get("stop"));
      }
      
      try {
        DecimalFormat df = new DecimalFormat("0");
        df.setMaximumFractionDigits(2);
        df.setMinimumFractionDigits(2);
        velocityTextView.setText("= publishing velocity =\n" +
                                 "linear.x = " + df.format(linearX) +
                                 "\nangular.z = " + df.format(angularZ));
      } catch (Exception e) {
      }
      controllerNode.publishVelocity(linearX, angularZ);
    }
  }
  
  /** Called when the node is destroyed */
  @Override
  protected void onNodeDestroy(Node node) {
    super.onNodeDestroy(node);

    sensorManager.unregisterListener(this);
  }
  
  /** Creates the menu for the options */
  @Override
  public boolean onCreateOptionsMenu(Menu menu) {
    MenuInflater inflater = getMenuInflater();
    inflater.inflate(R.menu.otl_android_roomba_menu, menu);
    return true;
  }

  /** Run when the menu is clicked. */
  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    switch (item.getItemId()) {
    case R.id.kill: //Shutdown if the user clicks kill
      sensorManager.unregisterListener(this);
      android.os.Process.killProcess(android.os.Process.myPid());
      return true;
    //TODO: add cases for any additional menu items here.
    default:
      return super.onOptionsItemSelected(item);
    }
  }
}
