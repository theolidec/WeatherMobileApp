import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/location_result.dart';
import '../../data/services/location_service.dart';
import '../../data/services/location_history_service.dart';
import '../providers/weather_provider.dart';

class LocationSearchDialog extends StatefulWidget {
  const LocationSearchDialog({Key? key}) : super(key: key);

  @override
  _LocationSearchDialogState createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final LocationService _locationService = LocationService();
  final LocationHistoryService _historyService = LocationHistoryService();
  final TextEditingController _searchController = TextEditingController();
  List<LocationResult> _searchResults = [];
  List<LocationResult> _recentLocations = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecentLocations();
  }

  Widget _buildResults() {
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    if (_isSearching) {
      if (_searchResults.isEmpty) {
        return const Center(
          child: Text('No locations found'),
        );
      }

      return ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final location = _searchResults[index];
          return _buildLocationTile(location);
        },
      );
    } else {
      return _buildRecentLocations();
    }
  }

  Widget _buildRecentLocations() {
    if (_recentLocations.isEmpty) {
      return const Center(
        child: Text('Your recent locations will appear here'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const Text(
                'Recent Locations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await _historyService.clearHistory();
                  await _loadRecentLocations();
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentLocations.length,
            itemBuilder: (context, index) {
              final location = _recentLocations[index];
              return _buildLocationTile(location, isRecent: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationTile(LocationResult location, {bool isRecent = false}) {
    return ListTile(
      leading: Icon(isRecent ? Icons.history : Icons.location_on),
      title: Text(
        location.getShortAddress(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: isRecent ? Text(
        '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
        style: Theme.of(context).textTheme.bodySmall,
      ) : null,
      onTap: () => _selectLocation(location),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentLocations() async {
    try {
      final locations = await _historyService.getRecentLocations();
      if (mounted) {
        setState(() {
          _recentLocations = locations;
        });
      }
    } catch (e) {
      debugPrint('Error loading recent locations: $e');
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
      _error = null;
    });

    try {
      final results = await _locationService.searchLocation(query);
      if (mounted) {
        setState(() => _searchResults = results);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to search locations');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectLocation(LocationResult location) async {
    try {
      debugPrint('Selected location: ${location.displayName} (${location.latitude}, ${location.longitude})');
      
      // Show loading state
      setState(() => _isLoading = true);
      
      // Save to recent locations
      await _historyService.addToHistory(location);
      
      // Close the dialog first to show loading in the main screen
      if (mounted) {
        Navigator.of(context).pop(location);
      }
      
      // The parent widget will handle the weather update since we're passing the location back
    } catch (e, stackTrace) {
      debugPrint('Error selecting location: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update weather for the selected location'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    'Search Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for a city or address',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchLocations('');
                          },
                        )
                      : null,
                ),
                onChanged: _searchLocations,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              else
                Expanded(child: _buildResults()),
            ],
          ),
        ),
      ),
    );
  }
}
