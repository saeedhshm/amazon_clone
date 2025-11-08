/// Network info interface
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Network info implementation
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // For mock data, always return true
    // In a real app, check actual network connectivity
    return true;
  }
}

