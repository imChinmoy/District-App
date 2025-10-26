import 'package:district/utils/colors.dart';
import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  final double _padding = 16.0;

  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    _nameController = TextEditingController(
      text: user?.name ?? 'Update your name',
    );
    _emailController = TextEditingController(
      text: user?.email ?? '+91 7099256167',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;

      if (!_isEditing) {
        _saveChanges();
      }
    });
  }

  void _saveChanges() {
    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();

    log('Profile Updated: Name=$newName, Phone=$newEmail');
  }

  @override
  Widget build(BuildContext context) {
    final darkBackgroundColor = AppColors.backgroundColor1;
    const textColor = Colors.white;
    const secondaryTextColor = Colors.grey;
    const sectionSpacing = SizedBox(height: 24);

    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _padding,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF333333),
                    backgroundImage: user?.profileImageUrl != null
                        ? NetworkImage(user!.profileImageUrl!)
                        : null,
                    child: user?.profileImageUrl == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isEditing
                            ? _buildEditableField(
                                controller: _nameController,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              )
                            : Text(
                                user?.name ?? 'Update your name',
                                style: const TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                        Text(
                          user?.email ?? ' abc@email.com',
                          style: const TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: Icon(
                      _isEditing ? Icons.save : Icons.edit,
                      color: _isEditing
                          ? Colors.greenAccent
                          : secondaryTextColor.shade400,
                      size: 20,
                    ),
                    onPressed: _toggleEdit,
                  ),
                ],
              ),
            ),

            sectionSpacing,

            _sectionTitle('All bookings', textColor),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _bookingCard(
                    'Table bookings',
                    Icons.restaurant_menu,
                    darkBackgroundColor,
                  ),
                  _bookingCard(
                    'Movie tickets',
                    Icons.movie,
                    darkBackgroundColor,
                  ),
                  _bookingCard(
                    'Event tickets',
                    Icons.music_note,
                    darkBackgroundColor,
                  ),
                ],
              ),
            ),

            sectionSpacing,

            _sectionTitle('Vouchers', textColor),
            _profileListRow(
              title: 'Collected vouchers',
              icon: Icons.card_giftcard,
              onTap: () => log('Collected vouchers tapped'),
            ),

            sectionSpacing,

            _sectionTitle('Payments', textColor),
            _profileListRow(
              title: 'Dining transactions',
              icon: Icons.receipt_long,
              onTap: () => log('Dining transactions tapped'),
            ),
            _profileListRow(
              title: 'Store transactions',
              icon: Icons.shopping_bag_outlined,
              onTap: () => log('Store transactions tapped'),
            ),
            _profileListRow(
              title: 'District Money',
              icon: Icons.account_balance_wallet_outlined,
              onTap: () => log('District Money tapped'),
            ),
            _profileListRow(
              title: 'Claim a Gift Card',
              icon: Icons.card_membership_outlined,
              onTap: () => log('Claim a Gift Card tapped'),
            ),

            sectionSpacing,

            _sectionTitle('Manage', textColor),
            _profileListRow(
              title: 'Your reviews',
              icon: Icons.edit_note,
              onTap: () => log('Your reviews tapped'),
            ),
            _profileListRow(
              title: 'Hotlists',
              icon: Icons.bookmark_border,
              onTap: () => log('Hotlists tapped'),
            ),

            const SizedBox(height: 30),
            Center(
              child: TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      height: fontSize + 16,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 0,
          ),
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.greenAccent.shade400,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) {
    return Padding(
      padding: EdgeInsets.fromLTRB(_padding, 0, _padding, 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _bookingCard(String title, IconData icon, Color backgroundColor) {
    final cardColor = Color.alphaBlend(
      Colors.white.withOpacity(0.08),
      backgroundColor,
    );

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => log('$title tapped'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileListRow({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final rowColor = Color.alphaBlend(
      Colors.white.withOpacity(0.02),
      AppColors.backgroundColor1,
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        color: rowColor,
        padding: EdgeInsets.symmetric(horizontal: _padding, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade700,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
