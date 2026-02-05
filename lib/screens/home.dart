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
      backgroundColor: AppTheme.background, // Light Yellow
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.secondary, // Yellow indicator
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

          // 2. User & Dormitory Info Card
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
                                            return dormAsync.when(
                                              data: (dorm) => Text(
                                                '📍 ${dorm?.name ?? "ไม่ระบุหอพัก"}',
                                                style: GoogleFonts.prompt(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              loading: () => const Text('...'),
                                              error: (_, __) => const Text(
                                                'ไม่พบข้อมูลหอพัก',
                                              ),
                                            );
                                          },
                                        )
                                      else
                                        Text(
                                          'กรุณาเลือกหอพักในหน้าตั้งค่า',
                                          style: GoogleFonts.prompt(
                                            color: AppTheme.error,
                                            fontSize: 14,
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

          // 3. Machine Grid Title
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

          // 4. Machine Grid
          machineAsync.when(
            data: (machines) {
              // Context-aware filtering
              // In a real app, we might pass dormId to the provider, but filtering here works for now.
              final user = userProfileAsync.asData?.value;
              final userDormId = user?.dormitoryId;

              var filteredMachines = machines;
              if (userDormId != null) {
                filteredMachines = machines
                    .where((m) => m.dormitoryId == userDormId)
                    .toList();
              }

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
                          userDormId == null
                              ? 'กรุณาเลือกหอพักก่อน'
                              : 'ไม่พบเครื่องซักผ้าในหอพักนี้',
                          style: GoogleFonts.prompt(
                            color: AppTheme.textSecondary,
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
                    b.status != MachineStatus.available)
                  return -1;
                if (a.status != MachineStatus.available &&
                    b.status == MachineStatus.available)
                  return 1;
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
              // Header: Number + Status Dot
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Icon(Icons.circle, color: statusColor, size: 12),
                ],
              ),

              // Icon
              Expanded(
                child: Center(
                  child: Icon(
                    machine.machineType == MachineType.washer
                        ? Icons.local_laundry_service_rounded
                        : Icons.dry_cleaning_rounded,
                    size: 50,
                    color: AppTheme.textPrimary,
                  ),
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
}

extension on Machine {
  int get price => 20;
}
