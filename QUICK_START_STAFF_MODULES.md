# Quick Start Guide: Staff Analytics & Digital Twin

## How to Access

### Option 1: From Staff Dashboard
1. Log in as a staff member (Doctor, Nurse, or Admin)
2. Navigate to **Overview** tab (first tab in bottom navigation)
3. Scroll to **Advanced Features** section
4. Tap either:
   - **Analytics** card (blue) for ML-driven insights
   - **Digital Twin** card (light blue) for 3D hospital view

### Option 2: Direct Navigation
```dart
// For Analytics
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => StaffAnalyticsScreen(hospitalId: hospitalId),
  ),
);

// For Digital Twin
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => StaffDigitalTwinScreen(hospitalId: hospitalId),
  ),
);
```

## Staff Analytics Screen

### What You'll See

#### Top Section: Population Health Trends
- **Total Capacity** - Shows total beds and occupancy percentage
- **Available Beds** - Number of beds currently available
- **ICU Status** - ICU occupancy with percentage
- **Avg Wait Time** - Current average wait time in minutes

#### Middle Section: ML Predictions Button
- Large blue button labeled "View ML Predictions"
- Shows "4 Models" badge
- Taps navigate to detailed ML predictions screen

#### Chart Section: Predictive Bed Management
- Bar chart showing:
  - ICU occupancy rate (red bars)
  - ER occupancy rate (orange bars)
  - Ward occupancy rate (green bars)
- Y-axis: Percentage (0-100%)
- Interactive hover/touch for details

#### Department Performance
- List view showing:
  - ICU: occupied/total beds with progress bar
  - Emergency Room: occupied/total beds with progress bar
  - General Ward: occupied/total beds with progress bar
- Color-coded by capacity level

#### Capacity Alerts
- Dynamic alerts based on thresholds:
  - 🔴 "ICU Near Capacity" - when ICU >85% full
  - 🟠 "ER High Volume" - when ER >80% full
  - 🟠 "Long Wait Times" - when wait time >60 minutes
- Shows "All systems operating normally" if no alerts

#### AI Insights
- Purple gradient card with lightbulb icon
- Shows three key insights:
  - ER surge predictions
  - Readmission risk alerts
  - Staffing recommendations

### Actions Available
- **Refresh**: Pull down to refresh all data
- **Time Period**: Top-right menu (Today, This Week, This Month)
- **View ML Predictions**: Tap button to see detailed predictions

## Staff ML Predictions Screen

### What You'll See

#### ML Status Card (Top)
- Purple gradient banner
- Shows "ML Models Active"
- Displays "4 Models • 88% Average Accuracy"
- Green checkmark indicator

#### Section 1: 24-Hour Bed Demand Forecast
- **Model**: LSTM Time Series
- **Display**: Line chart showing predicted occupancy
- **Features**:
  - Hourly predictions for next 24 hours
  - Trend indicator (increasing/stable/decreasing)
  - Current predicted occupancy vs total beds
  - Confidence level display

#### Section 2: ER Surge Prediction
- **Model**: Classification Model
- **Display**: Large percentage card
- **Features**:
  - Surge probability percentage (e.g., "75.2% Surge Probability")
  - Risk factors list (e.g., "High historical ER volume")
  - Prediction window (e.g., "2 hours")
  - Confidence score

#### Section 3: Staff Resource Optimization
- **Model**: Regression Model
- **Display**: Staff allocation cards
- **Features**:
  - Recommended total nurses
  - Recommended total doctors
  - Department breakdown (ICU/ER/Ward staff counts)
  - Model confidence percentage

#### Section 4: Anomaly Detection
- **Model**: Isolation Forest
- **Display**: Alert cards (if anomalies found)
- **Features**:
  - Anomaly description
  - Severity level (Critical/High/Medium/Low)
  - Recommendation
  - Color-coded by severity
- Shows "No anomalies detected" with green checkmark if all clear

### Actions Available
- **Info Button**: Top-right info icon explains each ML model
- **Refresh**: Pull down to refresh predictions
- **Back**: Navigate back to Analytics screen

## Staff Digital Twin Screen

### What You'll See

#### 3D Model Viewer (Top)
- Large 3D model of hospital building
- Dark background for contrast
- Interactive controls:
  - Drag to rotate
  - Pinch to zoom
  - Auto-rotate toggle (play/pause button)
- **Active Layers Indicator** (top-right):
  - Shows which data overlays are active
  - Green "LIVE DATA" badge

#### Hospital Info Card
- Hospital name and address
- Building metadata (if available):
  - Number of floors
  - 3D model file size

#### Operational Statistics
- Real-time dashboard showing:
  - Total Beds
  - Occupied (with percentage)
  - Available
  - Critical patient count
- Department breakdown mini-cards:
  - ICU: occupied/total (percentage)
  - ER: occupied/total (percentage)
  - Ward: occupied/total (percentage)

#### Conditional Sections (Based on Active Layers)

**If Equipment Tracking is ON:**
- Shows list of IoT-enabled medical devices:
  - Device name (e.g., "Ventilator #12")
  - Current location (e.g., "ICU Floor 3")
  - Status (In Use/Available/Maintenance)
  - Battery level with color-coded indicator
  - ⚠️ Low battery warnings (<50%)

**If Staff Locations is ON:**
- Shows real-time staff positions:
  - Staff name and role
  - Current location
  - Active/Break status (green/orange dot)
  - Avatar with role initial

**If Room Occupancy is ON:**
- Grid of room status cards:
  - Room number
  - Department type (ICU/ER/Ward)
  - Status: Occupied (red), Available (green), Cleaning (orange)
  - Color-coded status dots

### Actions Available
- **Play/Pause**: Toggle auto-rotation of 3D model
- **Layers Menu**: Top-right layers icon opens toggle dialog
- **Layer Toggles**:
  - ✅ Staff Locations (Real-time staff tracking)
  - ✅ Equipment Tracking (IoT-enabled medical devices)
  - ✅ Room Occupancy (Bed and room status)
  - ✅ IoT Sensors (Environmental monitoring)
- **Refresh**: Pull down to refresh all data
- **3D Controls**: Touch and drag to interact with model

## Layer Toggle Dialog

### How to Access
Tap the **Layers** icon (top-right) in Digital Twin screen

### What You'll See
- Dialog with 4 toggle switches:
  1. **Staff Locations**
     - Subtitle: "Real-time staff tracking"
     - Toggle ON to show staff positions
  
  2. **Equipment Tracking**
     - Subtitle: "IoT-enabled medical devices"
     - Toggle ON to show equipment locations
  
  3. **Room Occupancy**
     - Subtitle: "Bed and room status"
     - Toggle ON to show room status grid
  
  4. **IoT Sensors**
     - Subtitle: "Environmental monitoring"
     - Toggle ON for future sensor data

### Behavior
- Changes take effect immediately
- Active layers shown in 3D viewer overlay
- Sections appear/disappear based on toggles
- State persists while on screen

## Tips for Best Experience

### Analytics Screen
1. **Check alerts first** - Review capacity alerts before diving into details
2. **Use time periods** - Switch between Today/Week/Month for trends
3. **Explore ML predictions** - Tap the ML button for deeper insights
4. **Pull to refresh** - Get latest data anytime

### ML Predictions Screen
1. **Read model info** - Tap info icon to understand each model
2. **Focus on confidence** - Higher confidence = more reliable predictions
3. **Act on recommendations** - Use resource optimization for staffing
4. **Monitor anomalies** - Check for unusual patterns

### Digital Twin Screen
1. **Start with default layers** - Staff Locations + Room Occupancy
2. **Interact with 3D model** - Drag and zoom to explore
3. **Check battery levels** - Monitor IoT equipment batteries
4. **Use layer toggles** - Customize view for your needs
5. **Watch for live indicators** - Green "LIVE" badge means real-time data

## Data Refresh Rates

- **Population Health**: Real-time (streaming)
- **ML Predictions**: Updated every 15 minutes
- **Staff Locations**: Real-time (1-second intervals)
- **Equipment Tracking**: Real-time (IoT updates)
- **Room Occupancy**: Real-time (streaming)
- **3D Model**: Static (loaded once)

## Troubleshooting

### "No data available" in Analytics
- ✅ Check internet connection
- ✅ Verify staff has hospital assigned
- ✅ Pull to refresh
- ✅ Contact admin if issue persists

### "No 3D model available" in Digital Twin
- ⚠️ Hospital hasn't uploaded a 3D model yet
- 📧 Contact hospital administrator
- 🏥 Check hospital profile settings

### ML predictions not updating
- ✅ Pull to refresh
- ✅ Check prediction timestamp
- ✅ Verify hospital data is being collected
- 🔄 Models run every 15 minutes

### IoT equipment not showing
- ✅ Ensure "Equipment Tracking" layer is ON
- ✅ Check if hospital has IoT devices registered
- 📡 Verify IoT devices are connected
- 🔌 Contact IT support for connectivity issues

## Quick Reference: Color Codes

| Color | Meaning | Usage |
|-------|---------|-------|
| 🔴 Red | Critical/Occupied/High Risk | ICU alerts, occupied rooms, critical anomalies |
| 🟠 Orange | Warning/Maintenance | ER alerts, cleaning status, medium risk |
| 🟢 Green | Available/Success/Active | Available beds, normal status, active staff |
| 🔵 Blue | Information/Primary | Analytics features, info cards |
| 🟣 Purple | AI/ML Features | ML predictions, AI insights |

## Support

For technical issues or feature requests:
- 📧 Email: support@pulse-health.app
- 📱 In-app: Settings > Help & Support
- 🐛 Report bugs: Settings > Report Issue

---

**Last Updated**: December 20, 2025
**Version**: 1.0.0
**Module**: Staff Analytics & Digital Twin
