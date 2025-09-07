import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/app_data_store.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _friendCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _friendCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataStore>(
      builder: (context, store, child) {
        final brightness = store.brightness;
        
        return Scaffold(
          backgroundColor: AppTheme.appBackground(brightness),
          body: SafeArea(
            child: Column(
              children: [
                // Modern header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.gridMargin, 
                    AppTheme.lg, 
                    AppTheme.gridMargin, 
                    AppTheme.md
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Add Friends',
                        style: AppTheme.heading1.copyWith(
                          color: AppTheme.primaryText(brightness),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // Show friends list or settings
                        },
                        icon: Icon(
                          Icons.people_outline,
                          color: AppTheme.primaryText(brightness),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Modern tab bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppTheme.gridMargin),
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.appSurface(brightness),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: const [AppTheme.cardShadow],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.secondaryText(brightness),
                    labelStyle: AppTheme.body.copyWith(fontWeight: FontWeight.w600),
                    unselectedLabelStyle: AppTheme.body,
                    indicator: BoxDecoration(
                      color: AppTheme.primaryColor(brightness),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicatorPadding: const EdgeInsets.all(4),
                    tabs: const [
                      Tab(text: 'My QR Code'),
                      Tab(text: 'Scan QR'),
                    ],
                  ),
                ),
                
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMyQRCode(store, brightness),
                      _buildScanQR(store, brightness),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // My QR Code tab - following Figma design
  Widget _buildMyQRCode(AppDataStore store, Brightness brightness) {
    final shareCode = store.generateShareCodeForCurrentUser();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.gridMargin),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.lg),
          
          // Main QR card
          Container(
            width: double.infinity,
            decoration: AppTheme.cardDecoration(brightness),
            padding: const EdgeInsets.all(AppTheme.xl),
            child: Column(
              children: [
                // Profile avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor(brightness),
                        AppTheme.primaryColor(brightness).withOpacity(0.7),
                      ],
                    ),
                    boxShadow: const [AppTheme.cardShadow],
                  ),
                  child: Center(
                    child: Text(
                      store.currentUser.name[0].toUpperCase(),
                      style: AppTheme.heading1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppTheme.lg),
                
                Text(
                  store.currentUser.name,
                  style: AppTheme.heading2.copyWith(
                    color: AppTheme.primaryText(brightness),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: AppTheme.xs),
                
                Text(
                  'Scan this code to connect',
                  style: AppTheme.body.copyWith(
                    color: AppTheme.secondaryText(brightness),
                  ),
                ),
                
                const SizedBox(height: AppTheme.xl),
                
                // QR Code with modern styling
                Container(
                  padding: const EdgeInsets.all(AppTheme.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: const [AppTheme.cardShadow],
                  ),
                  child: QrImageView(
                    data: shareCode,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryText(brightness),
                    padding: EdgeInsets.zero,
                  ),
                ),
                
                const SizedBox(height: AppTheme.xl),
                
                // Share button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _shareQRCode(shareCode),
                    icon: const Icon(Icons.share),
                    label: Text(
                      'Share QR Code',
                      style: AppTheme.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor(brightness),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.lg),
          
          // Friend code section
          Container(
            width: double.infinity,
            decoration: AppTheme.cardDecoration(brightness),
            padding: const EdgeInsets.all(AppTheme.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Friend Code',
                  style: AppTheme.body.copyWith(
                    color: AppTheme.primaryText(brightness),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: AppTheme.sm),
                
                GestureDetector(
                  onTap: () => _copyToClipboard(shareCode),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.md),
                    decoration: BoxDecoration(
                      color: AppTheme.appSurface(brightness),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(
                        color: AppTheme.primaryColor(brightness).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            shareCode,
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.primaryText(brightness),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        Icon(
                          Icons.copy,
                          color: AppTheme.primaryColor(brightness),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppTheme.xs),
                
                Text(
                  'Tap to copy',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.secondaryText(brightness),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.lg),
          
          // Connected friends
          if (store.friends.isNotEmpty)
            Container(
              width: double.infinity,
              decoration: AppTheme.cardDecoration(brightness),
              padding: const EdgeInsets.all(AppTheme.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        color: AppTheme.primaryText(brightness),
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.xs),
                      Text(
                        'Connected Friends (${store.friends.length})',
                        style: AppTheme.body.copyWith(
                          color: AppTheme.primaryText(brightness),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.md),
                  
                  ...store.friends.take(5).map((friend) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.sm),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.primaryColor(brightness).withOpacity(0.1),
                            child: Text(
                              friend.name[0].toUpperCase(),
                              style: AppTheme.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor(brightness),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.sm),
                          Text(
                            friend.name,
                            style: AppTheme.body.copyWith(
                              color: AppTheme.primaryText(brightness),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  if (store.friends.length > 5)
                    Text(
                      'and ${store.friends.length - 5} more...',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.secondaryText(brightness),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Scan QR tab - following Figma design
  Widget _buildScanQR(AppDataStore store, Brightness brightness) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.gridMargin),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.lg),
          
          // Camera frame placeholder
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: AppTheme.primaryText(brightness),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: const [AppTheme.cardShadow],
            ),
            child: Stack(
              children: [
                // Camera overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryText(brightness).withOpacity(0.3),
                        AppTheme.primaryText(brightness).withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                
                // Scanning overlay
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.primaryColor(brightness),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Stack(
                      children: [
                        // Corner decorations
                        Positioned(
                          top: -3,
                          left: -3,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AppTheme.primaryColor(brightness), width: 3),
                                left: BorderSide(color: AppTheme.primaryColor(brightness), width: 3),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AppTheme.primaryColor(brightness), width: 3),
                                right: BorderSide(color: AppTheme.primaryColor(brightness), width: 3),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -3,
                          left: -3,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppTheme.primaryColor(brightness), width: 3),
                                left: BorderSide(color: AppTheme.primaryColor(brightness), width: 3),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -3,
                          right: -3,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppTheme.primaryColor(brightness), width: 3),
                                right: BorderSide(color: AppTheme.primaryColor(brightness), width: 3),
                              ),
                            ),
                          ),
                        ),
                        
                        // Center instruction
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white,
                                size: 48,
                              ),
                              const SizedBox(height: AppTheme.sm),
                              Text(
                                'Position QR code here',
                                style: AppTheme.caption.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.lg),
          
          // Start scanning button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openQRScanner(store),
              icon: const Icon(Icons.camera_alt),
              label: Text(
                'Start Scanning',
                style: AppTheme.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor(brightness),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.xl),
          
          // Divider
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: AppTheme.secondaryText(brightness).withOpacity(0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
                child: Text(
                  'OR',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.secondaryText(brightness),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: AppTheme.secondaryText(brightness).withOpacity(0.3),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.xl),
          
          // Manual code entry
          Container(
            width: double.infinity,
            decoration: AppTheme.cardDecoration(brightness),
            padding: const EdgeInsets.all(AppTheme.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Friend Code Manually',
                    style: AppTheme.body.copyWith(
                      color: AppTheme.primaryText(brightness),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.lg),
                  
                  TextFormField(
                    controller: _friendCodeController,
                    style: AppTheme.body.copyWith(
                      color: AppTheme.primaryText(brightness),
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Friend Code',
                      labelStyle: AppTheme.body.copyWith(
                        color: AppTheme.secondaryText(brightness),
                      ),
                      hintText: 'fwb:user:...',
                      hintStyle: AppTheme.body.copyWith(
                        color: AppTheme.secondaryText(brightness).withOpacity(0.7),
                        fontFamily: 'monospace',
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.paste,
                          color: AppTheme.primaryColor(brightness),
                        ),
                        onPressed: _pasteFromClipboard,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(
                          color: AppTheme.secondaryText(brightness).withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(
                          color: AppTheme.secondaryText(brightness).withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(
                          color: AppTheme.primaryColor(brightness),
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a friend code';
                      }
                      if (!value.startsWith('fwb:user:')) {
                        return 'Invalid friend code format';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: AppTheme.lg),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _addFriendByCode(store),
                      icon: const Icon(Icons.person_add),
                      label: Text(
                        'Add Friend',
                        style: AppTheme.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor(brightness),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Friend code copied to clipboard!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _friendCodeController.text = data!.text!;
    }
  }

  void _shareQRCode(String shareCode) {
    // In a real app, this would use share_plus package
    _copyToClipboard(shareCode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('QR code data copied! You can share this with friends.'),
        backgroundColor: AppTheme.primaryColor(Theme.of(context).brightness),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
    );
  }

  void _openQRScanner(AppDataStore store) {
    // Placeholder for QR scanner - in production this would open camera
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('QR Scanner will be available soon! Use manual entry for now.'),
        backgroundColor: AppTheme.primaryColor(Theme.of(context).brightness),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
    );
  }

  void _addFriendByCode(AppDataStore store) {
    if (!_formKey.currentState!.validate()) return;

    final friendCode = _friendCodeController.text.trim();
    final success = store.addFriend(friendCode);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Friend added successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
        ),
      );
      _friendCodeController.clear();
      
      // Switch to My QR Code tab to show updated friends list
      _tabController.animateTo(0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid friend code or friend already added'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
        ),
      );
    }
  }
}