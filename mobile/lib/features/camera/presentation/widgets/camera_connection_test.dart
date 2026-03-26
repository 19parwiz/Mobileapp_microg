import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Widget to test camera server connectivity
class CameraConnectionTest extends StatefulWidget {
  final String url;

  const CameraConnectionTest({
    super.key,
    required this.url,
  });

  @override
  State<CameraConnectionTest> createState() => _CameraConnectionTestState();
}

class _CameraConnectionTestState extends State<CameraConnectionTest> {
  bool _isTesting = false;
  String? _result;
  String? _error;

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _result = null;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(widget.url),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _isTesting = false;
          _result = 'Success! Status: ${response.statusCode}\n'
              'Headers: ${response.headers}\n'
              'Body length: ${response.bodyBytes.length} bytes';
          _error = null;
        });
      } else {
        setState(() {
          _isTesting = false;
          _result = null;
          _error = 'HTTP ${response.statusCode}. Stream URL responded but is not playable.\n'
              'Body length: ${response.bodyBytes.length} bytes';
        });
      }
    } catch (e) {
      setState(() {
        _isTesting = false;
        _result = null;
        _error = 'Connection failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Connection Test',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            'URL: ${widget.url}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          ElevatedButton(
            onPressed: _isTesting ? null : _testConnection,
            child: _isTesting
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: AppSizes.spacingS),
                      Text('Testing...'),
                    ],
                  )
                : const Text('Test Connection'),
          ),
          if (_result != null) ...[
            const SizedBox(height: AppSizes.spacingM),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Text(
                _result!,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Colors.green,
                ),
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: AppSizes.spacingM),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Text(
                _error!,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
