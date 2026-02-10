import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app/models/theme.dart';
import 'package:laundry_app/providers/dormitory_provider.dart';
import 'package:laundry_app/providers/user_provider.dart';

class DormitorySelectionSheet extends ConsumerWidget {
  const DormitorySelectionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dormitoriesAsync = ref.watch(allDormitoriesProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'เลือกหอพัก',
            style: GoogleFonts.prompt(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'กรุณาเลือกหอพักเพื่อแสดงเครื่องซักผ้าที่ให้บริการ',
            style: GoogleFonts.prompt(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          dormitoriesAsync.when(
            data: (dormitories) {
              if (dormitories.isEmpty) {
                return Center(
                  child: Text(
                    'ไม่พบข้อมูลหอพัก',
                    style: GoogleFonts.prompt(color: AppTheme.textSecondary),
                  ),
                );
              }

              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: dormitories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final dorm = dormitories[index];
                    return InkWell(
                      onTap: () async {
                        // Update user dormitory
                        await ref
                            .read(userProfileProvider.notifier)
                            .updateDormitory(dorm.id);

                        // Close sheet
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.secondary),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.secondary.withValues(
                                  alpha: 0.2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.apartment_rounded,
                                color: AppTheme.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                dorm.name,
                                style: GoogleFonts.prompt(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text(
                'เกิดข้อผิดพลาด: $err',
                style: GoogleFonts.prompt(color: AppTheme.error),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
