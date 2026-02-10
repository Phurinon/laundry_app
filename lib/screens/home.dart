import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_app/models/machine.dart';
import 'package:laundry_app/models/theme.dart';
import 'package:laundry_app/providers/machine_provider.dart';
import 'package:laundry_app/providers/user_provider.dart';
import 'package:laundry_app/providers/dormitory_provider.dart';
import 'package:laundry_app/screens/machine_info.dart';
import 'package:laundry_app/screens/setting.dart';
import 'package:laundry_app/screens/components/dormitory_selection_sheet.dart';
import 'package:laundry_app/models/booking.dart';
import 'package:laundry_app/providers/booking_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    _HomeContent(),
    SettingScreen(),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.secondary,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.local_laundry_service_rounded),
            label: 'ซักผ้า',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'ตั้งค่า',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final machineAsync = ref.watch(machineProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Brand AppBar
          SliverAppBar(
            expandedHeight: 100.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.secondary, // Brand Yellow
            surfaceTintColor: AppTheme.secondary,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_laundry_service,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LAUNDRY',
                    style: GoogleFonts.prompt(
                      color: AppTheme.primary, // Brand Red
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: _MyActiveBookingSection(),
          ),

          SliverToBoxAdapter(
            child: userProfileAsync.when(
              data: (user) {
                if (user == null) return const SizedBox.shrink();
                final dormId = user.dormitoryId;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Welcome Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primary,
                            width: 2,
                          ), // Red Border
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: AppTheme.secondary,
                                  child: Text(
                                    user.fullName.isNotEmpty
                                        ? user.fullName[0]
                                        : 'U',
                                    style: GoogleFonts.prompt(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'สวัสดี, คุณ${user.fullName}',
                                        style: GoogleFonts.prompt(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (dormId != null)
                                        Consumer(
                                          builder: (context, ref, _) {
                                            final dormAsync = ref.watch(
                                              dormitoryProvider(dormId),
                                            );
                                            return InkWell(
                                              onTap: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            24,
                                                          ),
                                                        ),
                                                  ),
                                                  builder: (context) =>
                                                      const DormitorySelectionSheet(),
                                                );
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  dormAsync.when(
                                                    data: (dorm) => Text(
                                                      '📍 ${dorm?.name ?? "ไม่ระบุหอพัก"}',
                                                      style: GoogleFonts.prompt(
                                                        color: AppTheme
                                                            .textSecondary,
                                                        fontSize: 14,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                    loading: () =>
                                                        const Text('...'),
                                                    error: (err, stack) =>
                                                        const Text(
                                                          'ไม่พบข้อมูลหอพัก',
                                                        ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(
                                                    Icons.edit_rounded,
                                                    size: 14,
                                                    color:
                                                        AppTheme.textSecondary,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )
                                      else
                                        InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            24,
                                                          ),
                                                        ),
                                                  ),
                                              builder: (context) =>
                                                  const DormitorySelectionSheet(),
                                            );
                                          },
                                          child: Text(
                                            'ยังไม่ได้เลือกหอพัก (คลิกเพื่อเลือก)',
                                            style: GoogleFonts.prompt(
                                              color: AppTheme.error,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) =>
                  Center(child: Text('Error loading profile: $err')),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'เครื่องซักผ้าที่ว่าง',
                style: GoogleFonts.prompt(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),

          machineAsync.when(
            data: (machines) {
              final user = userProfileAsync.asData?.value;
              final userDormId = user?.dormitoryId;

              if (userDormId == null) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.apartment_rounded,
                          size: 64,
                          color: AppTheme.secondary,
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
                          label: const Text('เลือกหอพัก'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Filter by Dorm ID
              final filteredMachines = machines
                  .where((m) => m.dormitoryId == userDormId)
                  .toList();

              if (filteredMachines.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.grey,
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
                if (a.status == MachineStatus.available &&
                    b.status != MachineStatus.available) {
                  return -1;
                }
                if (a.status != MachineStatus.available &&
                    b.status == MachineStatus.available) {
                  return 1;
                }
                return a.machineNumber.compareTo(b.machineNumber);
              });

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final machine = sortedMachines[index];
                      return _MachineCard(machine: machine);
                    },
                    childCount: sortedMachines.length,
                  ),
                ),
              );
            },
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _MachineCard extends StatelessWidget {
  final Machine machine;

  const _MachineCard({required this.machine});

  @override
  Widget build(BuildContext context) {
    final isAvailable = machine.status == MachineStatus.available;
    final statusColor = isAvailable ? AppTheme.success : AppTheme.error;

    // 1. Estimated Duration
    final duration = machine.machineType == MachineType.washer ? '40' : '50';

    // 2. Pseudo-random Badges (Deterministic based on ID)
    // We use the hash code of the ID to decide if we show a badge
    final showPopular = (machine.id.hashCode % 3 == 0); // 33% chance
    final showAvailableOften =
        (!showPopular && (machine.id.hashCode % 2 == 0)); // 33% chance

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isAvailable ? AppTheme.success : AppTheme.secondary,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MachineInfoScreen(machine: machine),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header: Number + Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (showPopular)
                    _buildBadge('จองบ่อย', Colors.orange)
                  else if (showAvailableOften)
                    _buildBadge('ว่างบ่อย', Colors.blue),
                  Icon(Icons.circle, color: statusColor, size: 12),
                ],
              ),

              // Icon & Duration
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      machine.machineType == MachineType.washer
                          ? Icons.local_laundry_service_rounded
                          : Icons.dry_cleaning_rounded,
                      size: 40,
                      color: AppTheme.textPrimary,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '~$duration นาที',
                        style: GoogleFonts.prompt(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer: Status Text & Price
              Column(
                children: [
                  Text(
                    isAvailable ? 'ว่าง' : 'ไม่ว่าง',
                    style: GoogleFonts.prompt(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${machine.price} บาท',
                    style: GoogleFonts.prompt(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.prompt(
          fontSize: 8,
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

class _MyActiveBookingSection extends ConsumerWidget {
  const _MyActiveBookingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get My Bookings Stream
    final bookingsStream = ref.watch(bookingProvider).getMyBookings();
    final machinesAsync = ref.watch(machineProvider);

    return StreamBuilder<List<Booking>>(
      stream: bookingsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        // 2. Filter Active Bookings
        final activeBookings = snapshot.data!.where((b) {
          return b.status == BookingStatus.pending ||
              b.status == BookingStatus.checkedIn ||
              b.status == BookingStatus.inProgress;
        }).toList();

        if (activeBookings.isEmpty) return const SizedBox.shrink();

        // 3. Take the first one (most urgent)
        final booking = activeBookings.first;
        final isStarted = booking.status == BookingStatus.inProgress;

        // 4. Resolve Machine Number
        String machineLabel = 'เครื่อง ${booking.machineId}';
        if (machinesAsync.hasValue) {
          final machine = machinesAsync.value!.cast<Machine?>().firstWhere(
            (m) => m?.id == booking.machineId,
            orElse: () => null,
          );
          if (machine != null) {
            machineLabel = 'เครื่อง ${machine.machineNumber}';
          }
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            0,
          ), // Added top padding
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.timer_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isStarted ? 'กำลังทำงาน...' : 'การจองของคุณ',
                            style: GoogleFonts.prompt(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            isStarted
                                ? 'ซักเสร็จในอีก ${_getTimeRemaining(booking)}'
                                : 'เริ่มซักในอีก ${_getTimeUntilStart(booking)}',
                            style: GoogleFonts.prompt(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(booking.status),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_laundry_service_rounded,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            machineLabel,
                            style: GoogleFonts.prompt(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${booking.startTime.substring(0, 5)} - ${booking.endTime.substring(0, 5)}',
                        style: GoogleFonts.prompt(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  String _getTimeRemaining(Booking booking) {
    final endTimeStr = booking.endTime;
    final now = DateTime.now();
    final parts = endTimeStr.split(':');
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    final diff = endDateTime.difference(now);
    if (diff.isNegative) return '0 นาที';
    return '${diff.inMinutes} นาที';
  }

  String _getTimeUntilStart(Booking booking) {
    final startTimeStr = booking.startTime;
    final now = DateTime.now();
    final parts = startTimeStr.split(':');
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    final diff = startDateTime.difference(now);
    if (diff.isNegative) return 'ตอนนี้';
    return '${diff.inMinutes} นาที';
  }

  Widget _buildStatusChip(BookingStatus status) {
    String label;
    Color color;

    switch (status) {
      case BookingStatus.pending:
        label = 'รอซัก';
        color = Colors.orange;
        break;
      case BookingStatus.checkedIn:
        label = 'เช็คอินแล้ว';
        color = Colors.blue;
        break;
      case BookingStatus.inProgress:
        label = 'กำลังซัก';
        color = Colors.green;
        break;
      default:
        label = 'สถานะอื่น';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.prompt(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
