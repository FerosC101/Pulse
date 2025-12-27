# Staff Portal Redesign - Quick Start Guide

## What's New?

The Staff Portal has been completely redesigned following the Pulse design system with:
- ✨ Modern gradient headers
- 🎨 Consistent color palette (Primary Red, Muted Blue, Dark Navy)
- 📊 Enhanced data visualizations
- 🎯 Improved readability and hierarchy
- ⚡ Better performance

## How to Use

### 1. Staff Portal (Main Dashboard)

**Access**: First tab in bottom navigation (Overview)

#### Key Changes:
- **New Gradient Header**: Red-to-blue gradient with "Staff Portal" title
- **Quick Actions Grid**: 2x2 grid of elevated white cards
  - Admit Patient (Green)
  - Discharge (Blue)
  - Transfer (Orange)
  - Emergency (Red)
- **System Management**: Vertical cards for Analytics and Digital Twin
- **Staff on Duty**: Clean table showing real-time ratios

#### How to Navigate:
1. Tap any Quick Action card to open dialogs
2. Tap Analytics or Digital Twin to access advanced features
3. View Pending Tasks for discharge reviews
4. Check Staff on Duty for current coverage

---

### 2. Staff Analytics (Operational Insights)

**Access**: Tap "Analytics" card from Staff Portal

#### Key Features:

##### Population Health Trends (Top Card)
- **Gradient Background**: Red-to-blue with white text
- **4 Metrics Display**: 
  - Bed Capacity (total beds + occupancy)
  - ICU Status (current/total + percentage)
  - Available Beds (open beds count)
  - Average Wait Time (minutes)

##### View ML Predictions Button
- **Purple Card**: Links to detailed ML predictions
- **Shows**: "4 models | 88% Average Accuracy"

##### Predictive Bed Management Chart
- **Bar Chart**: Comparing ICU, ER, and Ward occupancy
- **Colors**: Red for ICU/ER, Muted Blue for Ward
- **Interactive**: Tap bars for details

##### Department Status Overview
- **List View**: ICU, ER, Ward status
- **Status Badges**: Green (OK), Orange (Warning), Red (Critical)
- **Occupancy Ratios**: Current/Total display

##### AI Powered Insights
- **Insight Cards**: Color-coded by type
  - Orange: ER surge warnings
  - Red: Re-admission risk alerts
  - Blue: Staffing recommendations

#### Time Period Filter:
- Tap menu icon (top-right) to switch between:
  - Today
  - This Week
  - This Month

---

### 3. ML Predictions (Advanced Forecasting)

**Access**: Tap "View ML Predictions" from Staff Analytics

#### Key Features:

##### Model Performance Header (Top)
- **Purple Gradient Card**
- **Displays**: Active models count and average accuracy
- **Icon**: Psychology/brain icon

##### 24hr Bed Demand Forecast
- **Spline Area Chart**: Curved line with navy fill
- **X-Axis**: Hours (0-24)
- **Y-Axis**: Number of beds
- **Features**:
  - Smooth curves for better readability
  - Filled area showing demand range
  - Data points with white/navy circles

##### ER Surge Prediction
- **Large Card**: Displays surge probability percentage
- **Color-Coded**: Red (High), Orange (Medium), Green (Low)
- **Risk Factors**: Bullet-point list of contributing factors
- **Time Window**: Shows prediction timeframe (e.g., "2 hours")

##### Staff Resource Optimization
- **Top Row**: 2 large cards
  - Nurses count (Red background)
  - Doctors count (Green background)
- **Bottom Row**: 3 department cards
  - ICU staff (Red)
  - ER staff (Orange)
  - Ward staff (Blue)
- **Model Confidence**: Percentage displayed at bottom

#### Model Information:
- Tap **info icon** (top-right) to view:
  - LSTM Time Series (Bed demand forecasting)
  - Classification Model (ER surge prediction)
  - Regression Model (Staff optimization)
  - Isolation Forest (Anomaly detection)

---

## Visual Design Reference

### Color Usage

| Color | Hex Code | Usage |
|-------|----------|-------|
| Primary Red | #F7444E | Critical alerts, emergency actions |
| Muted Blue | #78BCC4 | Information, secondary elements |
| Dark Navy | #002C3E | Charts, data visualization |
| Gradient Start | #B91C1C | Header gradients (red) |
| Gradient End | #1E3A8A | Header gradients (blue) |

### Typography

| Element | Font Family | Weight | Size |
|---------|-------------|--------|------|
| Page Headers | Open Sans | 700 | 28px |
| Section Titles | Open Sans | 700 | 20px |
| Card Titles | DM Sans | 700 | 16px |
| Body Text | DM Sans | 400/500 | 13-15px |
| Data Labels | DM Sans | 400 | 11-13px |

### Spacing

- **Section Spacing**: 24-28px
- **Card Spacing**: 12-16px
- **Internal Padding**: 16-20px
- **Border Radius**: 12-16px

---

## Tips for Best Experience

### Staff Portal
1. **Check Quick Actions First**: Most common tasks are one tap away
2. **Use System Management**: Access advanced features easily
3. **Monitor Pending Tasks**: Stay on top of discharges
4. **Review Staff Ratios**: Ensure adequate coverage

### Staff Analytics
1. **Start with Population Health**: Get overview at a glance
2. **Check Department Status**: Identify capacity issues
3. **Review AI Insights**: Proactive recommendations
4. **Use Time Period Filter**: Analyze trends over time
5. **Tap ML Predictions**: Dive deeper into forecasts

### ML Predictions
1. **Check Model Performance**: Verify accuracy before decisions
2. **Review 24hr Forecast**: Plan ahead for bed demand
3. **Monitor ER Surge**: Prepare for patient influx
4. **Optimize Staffing**: Use recommendations for scheduling
5. **Read Model Info**: Understand prediction methodology

---

## Common Actions

### Admitting a Patient
1. Go to Staff Portal (Overview tab)
2. Tap "Admit Patient" (green card)
3. Fill in patient details
4. Confirm admission

### Checking Capacity
1. Go to Staff Analytics
2. View Population Health Trends card (top)
3. Check Available Beds metric
4. Review Department Status list

### Planning Staffing
1. Go to Staff Analytics
2. Tap "View ML Predictions"
3. Scroll to "Staff Resource Optimization"
4. Review recommended counts for each role
5. Check department-specific allocations

### Preparing for Surge
1. Go to ML Predictions
2. Check "ER Surge Prediction" card
3. Review surge probability percentage
4. Read risk factors
5. Note time window for surge
6. Return to Analytics for AI Insights
7. Follow staffing recommendations

---

## Troubleshooting

### Data Not Loading
- **Pull to Refresh**: Drag down on any screen to refresh
- **Check Connection**: Ensure internet connectivity
- **Verify Permissions**: Contact admin if hospital not assigned

### Charts Not Displaying
- **Wait for Data**: Charts load after hospital data
- **Check Time Period**: Some data varies by timeframe
- **Refresh Screen**: Pull to refresh to reload

### Buttons Not Responding
- **Wait for Load**: Ensure screen fully loaded
- **Check Permissions**: Verify staff role permissions
- **Restart App**: Close and reopen if issues persist

---

## Keyboard Shortcuts (Desktop)

- **R**: Refresh current screen
- **Esc**: Go back/Close dialog
- **Tab**: Navigate between cards
- **Enter**: Activate selected card

---

## Accessibility Features

- **High Contrast**: All text meets WCAG AA standards
- **Screen Reader**: Full support for VoiceOver/TalkBack
- **Font Scaling**: Respects system font size settings
- **Color Blind**: Color + icon combinations for all statuses

---

## Performance Tips

### For Optimal Performance:
1. **Keep App Updated**: Latest version has performance improvements
2. **Clear Cache**: Settings > Clear Cache (monthly)
3. **Stable Connection**: Use WiFi for data-heavy screens
4. **Close Unused Tabs**: Free up memory

### Data Refresh Rates:
- **Real-time**: Patient admissions, discharges
- **5 minutes**: Staff on duty, queue status
- **15 minutes**: ML predictions, analytics
- **Manual**: Pull to refresh anytime

---

## Feedback & Support

### Report Issues:
- In-app: Settings > Report Issue
- Email: support@pulse-health.app
- Document: Include screenshots and steps to reproduce

### Feature Requests:
- In-app: Settings > Suggest Feature
- Provide detailed description and use case

---

## Changelog

### Version 2.0.0 (December 27, 2025)
- ✅ Complete UI redesign with Pulse design system
- ✅ New gradient headers for all modules
- ✅ Enhanced data visualizations
- ✅ Improved color consistency
- ✅ Better typography hierarchy
- ✅ Optimized performance
- ✅ Full functional parity maintained

### Previous Versions:
- v1.0.0: Initial release with basic features
- v1.1.0: Added ML predictions
- v1.2.0: Enhanced analytics

---

**Quick Reference Card**

| Need to... | Go to... | Look for... |
|------------|----------|-------------|
| Admit patient | Staff Portal | Green Quick Action card |
| Check capacity | Staff Analytics | Population Health Trends |
| View predictions | ML Predictions | 24hr Forecast chart |
| Plan staffing | ML Predictions | Resource Optimization |
| See surge risk | ML Predictions | ER Surge Prediction |
| Review insights | Staff Analytics | AI Powered Insights |
| Monitor departments | Staff Analytics | Department Status |

---

**Last Updated**: December 27, 2025  
**Version**: 2.0.0  
**Module**: Staff Portal Redesign
