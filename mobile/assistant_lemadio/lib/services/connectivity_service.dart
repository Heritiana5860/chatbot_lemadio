import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = false;
  bool _wasOffline = false;

  bool get isConnected => _isConnected;
  bool get wasOffline => _wasOffline;

  ConnectivityService() {
    _init();
  }

  Future<void> _init() async {
    // Vérifier la connectivité initiale
    await checkConnectivity();

    // Écouter les changements de connectivité
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  /// Vérifier la connectivité actuelle
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
      return _isConnected;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de connectivité : $e');
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  /// Mettre à jour le statut de connexion
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;

    // Vérifier si au moins une connexion est disponible
    _isConnected = results.any((result) => result != ConnectivityResult.none);

    // Détecter un retour en ligne après avoir été hors ligne
    if (!wasConnected && _isConnected) {
      _wasOffline = true;
      debugPrint('📶 Connexion rétablie');
    } else if (wasConnected && !_isConnected) {
      debugPrint('📵 Connexion perdue - Mode hors ligne activé');
    }

    notifyListeners();
  }

  /// Réinitialiser le flag "était hors ligne"
  void resetOfflineFlag() {
    _wasOffline = false;
    notifyListeners();
  }

  /// Obtenir le type de connexion actuel
  Future<String> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();

      if (results.isEmpty || results.first == ConnectivityResult.none) {
        return 'Aucune connexion';
      }

      if (results.contains(ConnectivityResult.wifi)) {
        return 'WiFi';
      }

      if (results.contains(ConnectivityResult.mobile)) {
        return 'Données mobiles';
      }

      if (results.contains(ConnectivityResult.ethernet)) {
        return 'Ethernet';
      }

      return 'Connecté';
    } catch (e) {
      return 'Inconnu';
    }
  }

  /// Obtenir une icône selon le type de connexion
  Future<String> getConnectionIcon() async {
    final type = await getConnectionType();

    switch (type) {
      case 'WiFi':
        return '📶';
      case 'Données mobiles':
        return '📱';
      case 'Ethernet':
        return '🔌';
      case 'Aucune connexion':
        return '📵';
      default:
        return '🌐';
    }
  }

  /// Vérifier si une connexion spécifique est disponible
  Future<bool> hasWifi() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }

  Future<bool> hasMobile() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile);
  }

  /// Stream pour écouter les changements de connectivité
  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.any((result) => result != ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
