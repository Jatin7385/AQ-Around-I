# AQ Around I - Air Quality Monitoring

A modern Flutter application that tracks real-time air quality monitoring to help users make informed decisions about outdoor activities.

## Features

- **Air Quality Monitoring**: Real-time air quality data from Google Maps Air Quality API
- **Cigarette Consumption Tracking**: Monitor smoking habits and health risks
- **Health Recommendations**: Get health recommendations based on air quality
- **Pollutant Details**: Detailed information about various pollutants
- **Responsive Design**: Works on mobile, tablet, and desktop

## Setup Instructions

### 1. Get a Google Maps API Key

To use the air quality features, you need to obtain a Google Maps API key with the Air Quality API enabled:

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps JavaScript API
   - Geocoding API
   - Air Quality API
4. Create an API key with appropriate restrictions
5. For more details, follow the [official documentation](https://developers.google.com/maps/documentation/air-quality/overview)

### 2. Configure the API Key

1. Open the file `lib/UI/config/api_config.dart`
2. Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key:

```dart
class ApiConfig {
  // Replace this with your actual Google Maps API key
  static const String googleMapsApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
}
```

### 3. Run the Application

```bash
flutter pub get
flutter run
```

## Dependencies

- Flutter SDK
- http: For API requests
- fl_chart: For data visualization
- geolocator: For location services
- intl: For date formatting
- google_maps_flutter: For map integration

## Note on Air Quality API

The Google Maps Air Quality API is a paid service with a free tier. Please check the [pricing information](https://developers.google.com/maps/documentation/air-quality/usage-and-billing) before using it in production.
