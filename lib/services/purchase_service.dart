import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Product ID for the Pro subscription (monthly, auto-renewing).
/// Must match the subscription ID configured in Google Play Console /
/// App Store Connect.
const String kProProductId = 'pro_monthly';

/// Android package name — used to deep-link into the Play Store
/// subscription management screen.
const String kAndroidPackageName = 'com.jovasoft.exani';

/// Price shown while the store hasn't answered yet (or on a device
/// without billing). The real price always comes from the store.
const String kProFallbackPrice = '\$49.00 MXN';

/// Billing period label used across the UI.
const String kProPeriodLabel = 'mes';

/// Days the cached Pro status stays valid while the store can't be reached.
/// Protects users who open the app offline from losing their benefits.
const int kProOfflineGraceDays = 7;

/// Singleton service that manages the Pro monthly subscription.
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Whether the store is available on this device.
  bool _storeAvailable = false;

  /// The subscription details fetched from the store.
  ProductDetails? _proProduct;

  /// Current premium status — cached from SharedPreferences.
  bool _isPro = false;

  /// Notifier that widgets can listen to for premium status changes.
  final ValueNotifier<bool> isPro = ValueNotifier<bool>(false);

  /// Optional callback for showing messages to the user.
  void Function(String message)? onMessage;

  /// True while a restore round-trip is being used to verify whether the
  /// subscription is still active.
  bool _verifying = false;

  /// Set when the store reports an active subscription during verification.
  bool _sawActiveSubscription = false;

  Timer? _verificationTimer;

  // ─── Initialization ──────────────────────────────────────────────────────

  Future<void> initialize() async {
    // Load cached premium status first (instant, no network needed)
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool('is_pro') ?? false;
    isPro.value = _isPro;

    // Check if the store is available
    _storeAvailable = await _iap.isAvailable();
    if (!_storeAvailable) {
      // No billing available — honour the offline grace period so a flaky
      // connection doesn't strip Pro from a paying user.
      await _expireIfGraceElapsed();
      return;
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: _onDone,
      onError: _onError,
    );

    // Query subscription details
    await _loadProducts();

    // Ask the store which subscriptions are still active. Google Play and the
    // App Store only replay purchases that are currently valid, so a
    // cancelled or expired subscription simply never comes back — that's how
    // we detect it below.
    await _verifyActiveSubscription();
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails({kProProductId});
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Subscription not found: ${response.notFoundIDs}');
    }
    if (response.productDetails.isNotEmpty) {
      _proProduct = response.productDetails.first;
    }
  }

  // ─── Subscription verification ────────────────────────────────────────────

  /// Restores purchases and revokes Pro if the store doesn't report the
  /// subscription as active within a short window.
  ///
  /// [silent] is true for the automatic check on startup; a restore the user
  /// asked for reports its outcome through [onMessage].
  Future<void> _verifyActiveSubscription({bool silent = true}) async {
    _verifying = silent;
    _sawActiveSubscription = false;

    await _iap.restorePurchases();

    // The purchase stream answers asynchronously; give it a moment before
    // concluding that nothing came back.
    _verificationTimer?.cancel();
    _verificationTimer = Timer(const Duration(seconds: 6), () async {
      _verifying = false;
      if (_sawActiveSubscription) return;
      // Store reachable and no active subscription → the user is not Pro.
      final hadPro = _isPro;
      await _revokePro();
      if (!silent) {
        onMessage?.call('No encontramos una suscripción activa.');
      } else if (hadPro) {
        onMessage?.call('Tu suscripción Pro ya no está activa.');
      }
    });
  }

  /// Drops Pro only after the offline grace period has elapsed, so users
  /// without connectivity keep their benefits for a while.
  Future<void> _expireIfGraceElapsed() async {
    if (!_isPro) return;
    final prefs = await SharedPreferences.getInstance();
    final lastVerified = prefs.getInt('pro_verified_at');
    if (lastVerified == null) {
      // Unknown last verification — stamp it now and keep Pro for the grace
      // period instead of revoking on the first offline launch.
      await prefs.setInt(
        'pro_verified_at',
        DateTime.now().millisecondsSinceEpoch,
      );
      return;
    }
    final elapsed = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastVerified),
    );
    if (elapsed.inDays >= kProOfflineGraceDays) {
      await _revokePro();
    }
  }

  // ─── Purchase Handling ────────────────────────────────────────────────────

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.productID != kProProductId) return;

    switch (purchase.status) {
      case PurchaseStatus.pending:
        onMessage?.call('Procesando suscripción...');
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        _sawActiveSubscription = true;
        await _grantPro();
        if (purchase.status == PurchaseStatus.purchased) {
          onMessage?.call('¡Gracias! Tu suscripción Pro está activa 🎉');
        } else if (!_verifying) {
          // Only announce a restore the user explicitly asked for.
          onMessage?.call('Suscripción restaurada exitosamente ✅');
        }
        break;

      case PurchaseStatus.error:
        onMessage?.call('Error en la suscripción. Intenta de nuevo.');
        break;

      case PurchaseStatus.canceled:
        // User cancelled the checkout — do nothing
        break;
    }

    // Acknowledge the purchase (required by the store within 3 days,
    // otherwise Google Play refunds it automatically).
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  Future<void> _grantPro() async {
    _isPro = true;
    isPro.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_pro', true);
    await prefs.setInt('pro_verified_at', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _revokePro() async {
    if (!_isPro) return;
    _isPro = false;
    isPro.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_pro', false);
    await prefs.remove('pro_verified_at');
  }

  void _onDone() {
    _subscription?.cancel();
  }

  void _onError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Whether the user has an active Pro subscription.
  bool get isProUser => _isPro;

  /// The subscription details (title, price, description) from the store.
  ProductDetails? get proProduct => _proProduct;

  /// Whether the store is available and the subscription can be bought.
  bool get canPurchase => _storeAvailable && _proProduct != null && !_isPro;

  /// Formatted price string from the store (e.g. "$49.00 MXN").
  String get priceString => _proProduct?.price ?? kProFallbackPrice;

  /// Price including the billing period (e.g. "$49.00 MXN/mes").
  String get pricePerPeriodString => '$priceString/$kProPeriodLabel';

  /// Start the subscription flow.
  Future<void> buyPro() async {
    if (_proProduct == null) {
      onMessage?.call('Suscripción no disponible. Verifica tu conexión.');
      return;
    }
    if (_isPro) {
      onMessage?.call('Tu suscripción Pro ya está activa ⭐');
      return;
    }

    final purchaseParam = PurchaseParam(productDetails: _proProduct!);

    // Subscriptions go through buyNonConsumable — the store handles renewal.
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Restore an active subscription (for users who reinstalled or switched
  /// devices).
  Future<void> restorePurchases() async {
    if (!_storeAvailable) {
      onMessage?.call('Tienda no disponible.');
      return;
    }
    await _verifyActiveSubscription(silent: false);
  }

  /// Open the store's subscription management screen so the user can cancel
  /// or change their plan.
  Future<void> openSubscriptionManagement() async {
    final Uri uri;
    if (Platform.isAndroid) {
      uri = Uri.parse(
        'https://play.google.com/store/account/subscriptions'
        '?sku=$kProProductId&package=$kAndroidPackageName',
      );
    } else {
      uri = Uri.parse('https://apps.apple.com/account/subscriptions');
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      onMessage?.call('No se pudo abrir la gestión de suscripciones.');
    }
  }

  /// Clean up resources.
  void dispose() {
    _verificationTimer?.cancel();
    _subscription?.cancel();
    isPro.dispose();
  }
}
