// lib/utils/connectivity_helper.dart
import 'package:flutter/material.dart';
import 'package:smart_lms/services/offline_manager.dart';

class ConnectivityHelper {
  static final OfflineManager _offlineManager = OfflineManager();

  /// إظهار رسالة حالة الاتصال
  static Future<void> showConnectivityStatus(BuildContext context) async {
    final systemStatus = await _offlineManager.getSystemStatus();
    final isOnline = systemStatus['connectivity']['is_online'] as bool;
    final recommendations = systemStatus['recommendations'] as List<String>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isOnline ? Icons.wifi : Icons.wifi_off,
              color: isOnline ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8),
            Text(isOnline ? 'Online' : 'Offline'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...recommendations.map((rec) => Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(rec, style: TextStyle(fontSize: 14)),
                )),
            SizedBox(height: 12),
            if (!isOnline)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Some features like progress tracking and new content may not work until you reconnect.',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                ),
              ),
          ],
        ),
        actions: [
          if (isOnline)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Refreshing data...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                try {
                  await _offlineManager.forceRefreshAllData();
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('✅ Data refreshed successfully'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 8),
                          Text('❌ Failed to refresh data'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Refresh Data'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  /// فحص سريع والإرجاع true/false
  static Future<bool> isConnected() async {
    return await _offlineManager.checkConnectivity();
  }

  /// إعداد المراقب في main.dart
  static void setupGlobalConnectivityListener() {
    _offlineManager.setupConnectivityListener();
  }
}
