import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_app/models/machine.dart';
import 'package:laundry_app/models/theme.dart';
import 'package:laundry_app/providers/machine_provider.dart';
import 'package:laundry_app/providers/user_provider.dart';
import 'package:laundry_app/providers/dormitory_provider.dart';
import 'package:laundry_app/screens/machine_info.dart';
import 'package:laundry_app/screens/my_bookings.dart';
import 'package:laundry_app/screens/profile.dart';
import 'package:laundry_app/screens/components/dormitory_selection_sheet.dart';
import 'package:laundry_app/screens/components/machine_illustration.dart';
import 'package:laundry_app/providers/booking_provider.dart';
import 'package:laundry_app/screens/notifications.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    _HomeContent(),
    MyBookingsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'หน้าหลัก',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.calendar_month_rounded,
                  label: 'การจอง',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.person_outline_rounded,
                  label: 'โปรไฟล์',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppTheme.primary : AppTheme.neutral400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.prompt(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.primary : AppTheme.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerStatefulWidget {
  const _HomeContent();

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent> {
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  String? _selectedCategory;
  Timer? _autoScrollTimer;
  static const int _bannerCount = 3;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      final nextPage = (_currentBanner + 1) % _bannerCount;
      _bannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final machineAsync = ref.watch(machineProvider);
    final activeBookingsAsync = ref.watch(activeBookingsProvider);

    // Collect machine IDs that have active bookings right now
    final bookedMachineIds = <String>{};
    if (activeBookingsAsync.hasValue) {
      for (final b in activeBookingsAsync.value!) {
        // Machine is busy if it has any active booking for today
        bookedMachineIds.add(b.machineId);
      }
    }

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── Header: WashQ + Notification ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_laundry_service_rounded,
                        color: AppTheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'WashQ',
                        style: GoogleFonts.prompt(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppTheme.primary,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Dorm Location Selector ──
          SliverToBoxAdapter(
            child: userProfileAsync.when(
              data: (user) {
                if (user == null) return const SizedBox.shrink();
                final dormId = user.dormitoryId;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (context) => const DormitorySelectionSheet(),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppTheme.success,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        if (dormId != null)
                          Consumer(
                            builder: (context, ref, _) {
                              final dormAsync = ref.watch(
                                dormitoryProvider(dormId),
                              );
                              return dormAsync.when(
                                data: (dorm) => Text(
                                  dorm?.name ?? 'ไม่ระบุหอพัก',
                                  style: GoogleFonts.prompt(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                loading: () => Text(
                                  '...',
                                  style: GoogleFonts.prompt(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                error: (_, __) => Text(
                                  'ไม่พบข้อมูลหอพัก',
                                  style: GoogleFonts.prompt(
                                    color: AppTheme.error,
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          Text(
                            'เลือกหอพัก',
                            style: GoogleFonts.prompt(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.error,
                            ),
                          ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Column(
                children: [
                  SizedBox(
                    height: 160,
                    child: PageView(
                      controller: _bannerController,
                      onPageChanged: (i) => setState(() => _currentBanner = i),
                      children: [
                        _buildBanner(
                          title: 'จองคิวซักผ้า',
                          subtitle: 'สะดวก รวดเร็ว\nไม่ต้องรอคิว!',
                          icon: Icons.local_laundry_service_rounded,
                          gradient: const [
                            AppTheme.primary,
                            AppTheme.primaryDark,
                          ],
                        ),
                        _buildBanner(
                          title: 'เช็คสถานะเครื่อง',
                          subtitle: 'ดูสถานะเครื่องซักผ้า\nแบบเรียลไทม์',
                          icon: Icons.timer_rounded,
                          gradient: const [
                            AppTheme.success,
                            Color(0xFF4A9B6E),
                          ],
                        ),
                        _buildBanner(
                          title: 'แจ้งเตือนอัตโนมัติ',
                          subtitle: 'รับแจ้งเตือนเมื่อ\nเครื่องซักเสร็จ',
                          icon: Icons.notifications_active_rounded,
                          gradient: const [
                            AppTheme.accent,
                            AppTheme.accentDark,
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentBanner == i ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentBanner == i
                              ? AppTheme.primary
                              : AppTheme.neutral200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Category Section ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'ค้นหาตามประเภท',
                style: GoogleFonts.prompt(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryCard(
                    label: 'ทั้งหมด',
                    icon: MachineCategoryIcon(
                      size: 32,
                      color: _selectedCategory == null
                          ? AppTheme.primary
                          : AppTheme.neutral400,
                    ),
                    category: null,
                  ),
                  _buildCategoryCard(
                    label: 'เครื่องซัก',
                    icon: MachineCategoryIcon(
                      machineType: MachineType.washer,
                      size: 36,
                      color: _selectedCategory == 'washer'
                          ? AppTheme.primary
                          : AppTheme.neutral400,
                    ),
                    category: 'washer',
                  ),
                  _buildCategoryCard(
                    label: 'เครื่องอบ',
                    icon: MachineCategoryIcon(
                      machineType: MachineType.dryer,
                      size: 36,
                      color: _selectedCategory == 'dryer'
                          ? AppTheme.accent
                          : AppTheme.neutral400,
                    ),
                    category: 'dryer',
                  ),
                  _buildCategoryCard(
                    label: 'ว่างเท่านั้น',
                    icon: MachineCategoryIcon(
                      isAvailable: true,
                      size: 32,
                      color: _selectedCategory == 'available'
                          ? AppTheme.success
                          : AppTheme.neutral400,
                    ),
                    category: 'available',
                  ),
                ],
              ),
            ),
          ),

          // ── Machine List Header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'เครื่องซักผ้า',
                    style: GoogleFonts.prompt(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  machineAsync.when(
                    data: (machines) {
                      final user = userProfileAsync.asData?.value;
                      final userDormId = user?.dormitoryId;
                      if (userDormId == null) return const SizedBox.shrink();
                      final filtered = _filterMachines(
                        machines
                            .where((m) => m.dormitoryId == userDormId)
                            .toList(),
                        bookedMachineIds,
                      );
                      return Text(
                        '${filtered.length} เครื่อง',
                        style: GoogleFonts.prompt(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      );
                    },
                    error: (_, __) => const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // ── Machine Grid ──
          machineAsync.when(
            data: (machines) {
              final user = userProfileAsync.asData?.value;
              final userDormId = user?.dormitoryId;

              if (userDormId == null) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.apartment_rounded,
                          size: 64,
                          color: AppTheme.secondaryLight,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'กรุณาเลือกหอพัก',
                          style: GoogleFonts.prompt(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'เพื่อแสดงเครื่องซักผ้าที่ให้บริการ',
                          style: GoogleFonts.prompt(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (context) =>
                                  const DormitorySelectionSheet(),
                            );
                          },
                          icon: const Icon(Icons.touch_app_rounded),
                          label: Text(
                            'เลือกหอพัก',
                            style: GoogleFonts.prompt(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final filteredMachines = _filterMachines(
                machines.where((m) => m.dormitoryId == userDormId).toList(),
                bookedMachineIds,
              );

              if (filteredMachines.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: AppTheme.neutral400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ไม่พบเครื่องซักผ้าในหอพักนี้',
                          style: GoogleFonts.prompt(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Sort: Available first, then by number
              final sortedMachines = [...filteredMachines];
              sortedMachines.sort((a, b) {
                final aAvailable =
                    a.status == MachineStatus.available &&
                    !bookedMachineIds.contains(a.id);
                final bAvailable =
                    b.status == MachineStatus.available &&
                    !bookedMachineIds.contains(b.id);
                if (aAvailable && !bAvailable) {
                  return -1;
                }
                if (!aAvailable && bAvailable) {
                  return 1;
                }
                return a.machineNumber.compareTo(b.machineNumber);
              });

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final machine = sortedMachines[index];
                      final isBooked = bookedMachineIds.contains(machine.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _MachineCard(
                          machine: machine,
                          isBooked: isBooked,
                        ),
                      );
                    },
                    childCount: sortedMachines.length,
                  ),
                ),
              );
            },
            error: (err, stack) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('เกิดข้อผิดพลาด: $err')),
            ),
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  List<Machine> _filterMachines(
    List<Machine> machines,
    Set<String> bookedMachineIds,
  ) {
    if (_selectedCategory == null) return machines;
    if (_selectedCategory == 'washer') {
      return machines
          .where((m) => m.machineType == MachineType.washer)
          .toList();
    }
    if (_selectedCategory == 'dryer') {
      return machines.where((m) => m.machineType == MachineType.dryer).toList();
    }
    if (_selectedCategory == 'available') {
      return machines
          .where(
            (m) =>
                m.status == MachineStatus.available &&
                !bookedMachineIds.contains(m.id),
          )
          .toList();
    }
    return machines;
  }

  Widget _buildBanner({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.prompt(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.prompt(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String label,
    required Widget icon,
    required String? category,
  }) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLightest : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.neutral200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.prompt(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MachineCard extends StatelessWidget {
  final Machine machine;
  final bool isBooked;

  const _MachineCard({required this.machine, this.isBooked = false});

  @override
  Widget build(BuildContext context) {
    // Machine is unavailable if DB status says so OR if there's an active booking
    final isAvailable = machine.status == MachineStatus.available && !isBooked;
    final statusColor = isAvailable ? AppTheme.success : AppTheme.error;
    final duration = machine.machineType == MachineType.washer ? '40' : '50';
    final isWasher = machine.machineType == MachineType.washer;
    final typeName = isWasher ? 'เครื่องซักผ้า' : 'เครื่องอบผ้า';

    final showPopular = (machine.id.hashCode % 3 == 0);
    final showAvailableOften = (!showPopular && (machine.id.hashCode % 2 == 0));

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MachineInfoScreen(machine: machine),
            ),
          );
        },
        child: SizedBox(
          height: 140,
          child: Row(
            children: [
              // Left: Machine image area
              Container(
                width: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isWasher
                        ? [AppTheme.primaryLight, AppTheme.primaryLightest]
                        : [AppTheme.accentLight, AppTheme.accentLightest],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: MachineIllustration(
                        machineType: machine.machineType,
                        size: 80,
                      ),
                    ),
                    // Machine number badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          machine.machineNumber,
                          style: GoogleFonts.prompt(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row with favorite-like icon
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              typeName,
                              style: GoogleFonts.prompt(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Rating / badge row
                      Row(
                        children: [
                          if (showPopular) ...[
                            _buildBadge('จองบ่อย', AppTheme.warning),
                            const SizedBox(width: 8),
                          ] else if (showAvailableOften) ...[
                            _buildBadge('ว่างบ่อย', AppTheme.primary),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            '${machine.price} บาท',
                            style: GoogleFonts.prompt(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Info row: floor, duration
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: AppTheme.neutral400,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$duration นาที',
                            style: GoogleFonts.prompt(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if (machine.capacity > 0) ...[
                            const SizedBox(width: 10),
                            Icon(
                              Icons.circle,
                              size: 4,
                              color: AppTheme.neutral400,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${machine.capacity} กก.',
                              style: GoogleFonts.prompt(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const Spacer(),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isAvailable ? 'ว่าง' : 'ไม่ว่าง',
                          style: GoogleFonts.prompt(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.prompt(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

extension on Machine {
  int get price => 20;
}
