import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../app/di/injector.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../data/admin_api.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final AdminApi _adminApi;

  bool _loadingUsers = true;
  bool _loadingDevices = true;
  String? _usersError;
  String? _devicesError;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _devices = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _adminApi = AdminApi(dio: getIt<Dio>());
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadUsers(), _loadDevices()]);
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loadingUsers = true;
      _usersError = null;
    });

    try {
      final users = await _adminApi.getUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _usersError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingUsers = false;
      });
    }
  }

  Future<void> _loadDevices() async {
    setState(() {
      _loadingDevices = true;
      _devicesError = null;
    });

    try {
      final devices = await _adminApi.getDevices();
      if (!mounted) return;
      setState(() {
        _devices = devices;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _devicesError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingDevices = false;
      });
    }
  }

  Future<void> _toggleRole(Map<String, dynamic> user) async {
    final id = user['id'];
    final currentRole = (user['role'] ?? 'USER').toString().toUpperCase();
    final newRole = currentRole == 'ADMIN' ? 'USER' : 'ADMIN';

    try {
      await _adminApi.updateUserRole(id as int, newRole);
      await _loadUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User role updated to $newRole')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update role: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Devices'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildDevicesTab(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_loadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_usersError != null) {
      return _ErrorState(
        message: _usersError!,
        onRetry: _loadUsers,
      );
    }

    if (_users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        itemCount: _users.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spacingS),
        itemBuilder: (context, index) {
          final user = _users[index];
          final role = (user['role'] ?? 'USER').toString().toUpperCase();

          return Card(
            child: ListTile(
              title: Text(user['email']?.toString() ?? '-'),
              subtitle: Text('Name: ${user['name'] ?? '-'}'),
              trailing: TextButton(
                onPressed: () => _toggleRole(user),
                child: Text(role),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDevicesTab() {
    if (_loadingDevices) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_devicesError != null) {
      return _ErrorState(
        message: _devicesError!,
        onRetry: _loadDevices,
      );
    }

    if (_devices.isEmpty) {
      return const Center(child: Text('No devices found'));
    }

    return RefreshIndicator(
      onRefresh: _loadDevices,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        itemCount: _devices.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spacingS),
        itemBuilder: (context, index) {
          final device = _devices[index];
          return Card(
            child: ListTile(
              title: Text(device['name']?.toString() ?? '-'),
              subtitle: Text(
                'Owner: ${device['ownerEmail'] ?? '-'}\nType: ${device['deviceType'] ?? '-'}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $message', textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.spacingM),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
