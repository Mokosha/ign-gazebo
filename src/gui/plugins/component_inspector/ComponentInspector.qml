/*
 * Copyright (C) 2019 Open Source Robotics Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
*/
import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import IgnGazebo 1.0 as IgnGazebo


Rectangle {
  id: componentInspector
  color: lightGrey
  Layout.minimumWidth: 400
  Layout.minimumHeight: 375
  anchors.fill: parent

  /**
   * Time delay for tooltip to show, in ms
   */
  property int tooltipDelay: 500

  /**
   * Height of each item in pixels
   */
  property int itemHeight: 30

  /**
   * Entity type
   */
  property string entityType: ComponentInspector.type

  /**
   * Get if entity is nested model or not
   */
  property bool nestedModel : ComponentInspector.nestedModel

  /**
   * Light grey according to theme
   */
  property color lightGrey: (Material.theme == Material.Light) ?
    Material.color(Material.Grey, Material.Shade100) :
    Material.color(Material.Grey, Material.Shade800)

  /**
   * Dark grey according to theme
   */
  property color darkGrey: (Material.theme == Material.Light) ?
    Material.color(Material.Grey, Material.Shade200) :
    Material.color(Material.Grey, Material.Shade900)

  /**
   * Highlight color
   */
  property color highlightColor: Qt.rgba(
    Material.accent.r,
    Material.accent.g,
    Material.accent.b, 0.3)

  function delegateQml(_model) {
    if (_model === null || _model.dataType == undefined)
      return 'NoData.qml'

    return _model.dataType + '.qml'
  }

  // Get number of decimal digits based on a widget's width
  function getDecimals(_width) {
    if (_width <= 80)
      return 2;
    else if (_width <= 100)
      return 4;
    return 6;
  }

  /**
   * Forward pose changes to C++
   */
  function onPose(_x, _y, _z, _roll, _pitch, _yaw) {
    ComponentInspector.OnPose(_x, _y, _z, _roll, _pitch, _yaw)
  }

  /**
   * Forward light changes to C++
   */
  function onLight(_rSpecular, _gSpecular, _bSpecular, _aSpecular,
                   _rDiffuse, _gDiffuse, _bDiffuse, _aDiffuse,
                   _attRange, _attLinear, _attConstant, _attQuadratic,
                   _castShadows, _directionX, _directionY, _directionZ,
                   _innerAngle, _outerAngle, _falloff, _intensity, _type) {
    ComponentInspector.OnLight(_rSpecular, _gSpecular, _bSpecular, _aSpecular,
                               _rDiffuse, _gDiffuse, _bDiffuse, _aDiffuse,
                               _attRange, _attLinear, _attConstant, _attQuadratic,
                               _castShadows, _directionX, _directionY, _directionZ,
                               _innerAngle, _outerAngle, _falloff, _intensity, _type)
  }

  /*
   * Forward physics changes to C++
   */
  function onPhysics(_stepSize, _realTimeFactor) {
    ComponentInspector.OnPhysics(_stepSize, _realTimeFactor)
  }

  /*
   * Forward spherical coordinate changes to C++
   */
  function onSphericalCoordinates(_surface, _lat, _lon, _elevation, _heading) {
    ComponentInspector.OnSphericalCoordinates(_surface, _lat, _lon, _elevation,
        _heading);
  }

  // The component for a menu section header
  Component {
    id: menuSectionHeading
    Rectangle {
      height: childrenRect.height

      Text {
          text: sectionText 
          font.pointSize: 10
          padding: 5
      }
    }
  }

  Rectangle {
    id: header
    height: lockButton.height
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    width: parent.width
    color: darkGrey

    RowLayout {
      anchors.fill: parent
      spacing: 0

      IgnGazebo.TypeIcon {
        id: icon
        height: lockButton.height * 0.8
        width: lockButton.height * 0.8
        entityType: ComponentInspector.type
      }

      Label {
        text: ComponentInspector.type
        font.capitalization: Font.Capitalize
        color: Material.theme == Material.Light ? "#444444" : "#cccccc"
        font.pointSize: 12
        padding: 3
      }

      Item {
        height: entityLabel.height
        Layout.fillWidth: true
      }

      ToolButton {
        id: lockButton
        checkable: true
        checked: false
        text: "Lock entity"
        contentItem: Image {
          fillMode: Image.Pad
          horizontalAlignment: Image.AlignHCenter
          verticalAlignment: Image.AlignVCenter
          source: lockButton.checked ? "qrc:/Gazebo/images/lock.svg" :
                                       "qrc:/Gazebo/images/unlock.svg"
          sourceSize.width: 18;
          sourceSize.height: 18;
        }
        ToolTip.text: lockButton.checked ? "Unlock entity" : "Lock entity"
        ToolTip.visible: hovered
        ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
        onToggled: {
          ComponentInspector.locked = lockButton.checked
        }
      }

      ToolButton {
        id: pauseButton
        checkable: true
        checked: false
        text: pauseButton.checked ? "\u25B6" : "\u275A\u275A"
        contentItem: Text {
          text: pauseButton.text
          color: "#b5b5b5"
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }
        ToolTip.text: pauseButton.checked ? "Resume updates" : "Pause updates"
        ToolTip.visible: hovered
        ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
        onToggled: {
          ComponentInspector.paused = pauseButton.checked
        }
      }

      ToolButton {
        id: addLinkButton
        checkable: false
        text: "Add entity"
        visible: entityType == "model"
        contentItem: Image {
          fillMode: Image.Pad
          horizontalAlignment: Image.AlignHCenter
          verticalAlignment: Image.AlignVCenter
          source: "qrc:/Gazebo/images/plus.png"
          sourceSize.width: 18;
          sourceSize.height: 18;
        }
        ToolTip.text: "Add entity"
        ToolTip.visible: hovered
        ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
        onClicked: {
          addLinkMenu.open()
        }

        FileDialog {
          id: loadFileDialog
          title: "Load mesh"
          folder: shortcuts.home
          nameFilters: [ "Collada files (*.dae)", "(*.stl)", "(*.obj)" ]
          selectMultiple: false
          selectExisting: true
          onAccepted: {
            ComponentInspector.OnLoadMesh("mesh", "link", fileUrl)
          }
        }
      
        Menu {
          id: addLinkMenu
      
          Item {
            Layout.fillWidth: true
            height: childrenRect.height
            Loader { 
              property string sectionText: "Link"
              sourceComponent: menuSectionHeading
            }
          }
      
          MenuItem {
            id: boxLink
            text: "Box"
            onClicked: {
              ComponentInspector.OnAddEntity("box", "link");
              addLinkMenu.close()
            }
          }
      
          MenuItem {
            id: capsuleLink
            text: "Capsule"
            onClicked: {
              ComponentInspector.OnAddEntity("capsule", "link");
              addLinkMenu.close()
            }
          }
      
          MenuItem {
            id: cylinderLink
            text: "Cylinder"
            onClicked: {
              ComponentInspector.OnAddEntity("cylinder", "link");
            }
          }
      
          MenuItem {
            id: ellipsoidLink
            text: "Ellipsoid"
            onClicked: {
              ComponentInspector.OnAddEntity("ellipsoid", "link");
            }
          }
      
          MenuItem {
            id: emptyLink
            text: "Empty"
            onClicked: {
              ComponentInspector.OnAddEntity("empty", "link");
            }
          }
      
          MenuItem {
            id: meshLink
            text: "Mesh"
            onClicked: {
              loadFileDialog.open()
            }
          }
      
          MenuItem {
            id: sphereLink
            text: "Sphere"
            onClicked: {
              ComponentInspector.OnAddEntity("sphere", "link");
            }
          }
      
          MenuSeparator {
            padding: 0
            topPadding: 12
            bottomPadding: 12
            contentItem: Rectangle {
              implicitWidth: 200
              implicitHeight: 1
              color: "#1E000000"
            }
          }
      
          Item {
            Layout.fillWidth: true
            height: childrenRect.height
            Loader { 
              property string sectionText: "Light"
              sourceComponent: menuSectionHeading
            }
          }
      
          MenuItem {
            id: directionalLink
            text: "Directional"
            onClicked: {
              ComponentInspector.OnAddEntity("directional", "light");
              addLinkMenu.close()
            }
          }
      
          MenuItem {
            id: pointLink
            text: "Point"
            onClicked: {
              ComponentInspector.OnAddEntity("point", "light");
              addLinkMenu.close()
            }
          }
      
          MenuItem {
            id: spotLink
            text: "Spot"
            onClicked: {
              ComponentInspector.OnAddEntity("spot", "light");
              addLinkMenu.close()
            }
          }
      
          // \todo(anyone) Add joints
        }
      }

      ToolButton {
        id: addSensorButton
        checkable: false
        text: "Add sensor"
        visible: entityType == "link"
        contentItem: Image {
          fillMode: Image.Pad
          horizontalAlignment: Image.AlignHCenter
          verticalAlignment: Image.AlignVCenter
          source: "qrc:/Gazebo/images/plus.png"
          sourceSize.width: 18;
          sourceSize.height: 18;
        }
        ToolTip.text: "Add sensor"
        ToolTip.visible: hovered
        ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
        onClicked: {
          addSensorMenu.open()
        }

        Menu {
          id: addSensorMenu
          MenuItem {
            id: airPressure
            text: "Air pressure"
            onTriggered: {
              ComponentInspector.OnAddEntity(airPressure.text, "sensor");
            }
          }
      
          MenuItem {
            id: altimeter
            text: "Altimeter"
            onTriggered: {
              ComponentInspector.OnAddEntity(altimeter.text, "sensor");
            }
          }
      
          MenuItem {
            id: cameraSensorMenu
            text: "Camera >"

            MouseArea {
              id: viewSubCameraArea
              anchors.fill: parent
              hoverEnabled: true
              onEntered: secondCameraMenu.open()
            }
          }
      
          MenuItem {
            id: contact
            text: "Contact"
            onTriggered: {
              ComponentInspector.OnAddEntity(contact.text, "sensor");
            }
          }
      
          MenuItem {
            id: forceTorque
            text: "Force torque"
            onTriggered: {
              ComponentInspector.OnAddEntity(forceTorque.text, "sensor");
            }
          }
      
          MenuItem {
            id: gps
            text: "GPS"
            onTriggered: {
              ComponentInspector.OnAddEntity(gps.text, "sensor");
            }
          }
      
          MenuItem {
            id: imu
            text: "IMU"
            onTriggered: {
              ComponentInspector.OnAddEntity(imu.text, "sensor");
            }
          }
      
          MenuItem {
            id: lidar
            text: "Lidar"
          }
      
          MenuItem {
            id: magnetometer
            text: "magnetometer"
            onTriggered: {
              ComponentInspector.OnAddEntity(magnetometer.text, "sensor");
            }
          }
        }
      
        Menu {
          id: secondCameraMenu
          x: addSensorMenu.x - addSensorMenu.width
          y: addSensorMenu.y + cameraSensorMenu.y
          MouseArea {
            id: viewSubCameraAreaExit
            anchors.fill: parent
            hoverEnabled: true
            onExited: secondCameraMenu.close()
          }

          MenuItem {
            id: depth
            text: "Depth"
          }
          MenuItem {
            id: logical
            text: "Logical"
          }
          MenuItem {
            id: monocular
            text: "Monocular"
          }
          MenuItem {
            id: multicamera
            text: "Multicamera"
          }
          MenuItem {
            id: rgbd
            text: "RGBD"
          }
          MenuItem {
            id: thermal
            text: "Thermal"
          }
        }
      }

      Label {
        id: entityLabel
        text: 'Entity ' + ComponentInspector.entity
        Layout.minimumWidth: 80
        color: Material.theme == Material.Light ? "#444444" : "#cccccc"
        font.pointSize: 12
        padding: 5
      }
    }
  }

  ListView {
    anchors.top: header.bottom
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    model: {
      try {
        return ComponentsModel;
      }
      catch (e) {
        // The QML is loaded before we set the context property
        return null
      }
    }
    spacing: 5

    delegate: Loader {
      id: loader
      source: delegateQml(model)
    }
  }
}
