import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app/models/machine.dart';
import 'package:laundry_app/models/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_app/providers/booking_provider.dart';

class MachineInfoScreen extends ConsumerStatefulWidget {
  final Machine machine;

  const MachineInfoScreen({super.key, required this.machine});

  @override
  ConsumerState<MachineInfoScreen> createState() => _MachineInfoScreenState();
}

class _MachineInfoScreenState extends ConsumerState<MachineInfoScreen> {
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'ข้อมูลเครื่องซักผ้า',
          style: GoogleFonts.prompt(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  widget.machine.machineType == MachineType.washer
                      ? Icons.local_laundry_service_rounded
                      : Icons.dry_cleaning_rounded,
                  size: 80,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'เครื่อง ${widget.machine.machineNumber}',
                      style: GoogleFonts.prompt(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStatusBadge(widget.machine.status),
                    const SizedBox(height: 30),
                    _buildInfoRow(
                      'ประเภท',
                      widget.machine.machineType == MachineType.washer
                          ? 'เครื่องซักผ้า'
                          : 'เครื่องอบผ้า',
                    ),
                    const Divider(height: 30),
                    _buildInfoRow(
                      'ขนาด',
                      '${widget.machine.capacity} กิโลกรัม',
                    ),
                    const Divider(height: 30),
                    _buildInfoRow('ราคา', '${widget.machine.price} บาท'),
                    const Divider(height: 30),
                    _buildInfoRow('ชั้น', '${widget.machine.floor ?? "-"}'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      widget.machine.status == MachineStatus.available &&
                          !_isBooking
                      ? _handleBooking
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: _isBooking
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.machine.status == MachineStatus.available
                              ? 'จองคิว'
                              : 'ไม่ว่าง',
                          style: GoogleFonts.prompt(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleBooking() async {
    final now = DateTime.now();
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        now.add(const Duration(minutes: 5)),
      ), // Default next 5 mins
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null || !mounted) return;

    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (selectedDateTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ไม่สามารถจองเวลาย้อนหลังได้',
            style: GoogleFonts.prompt(),
          ),
        ),
      );
      return;
    }

    // 2. Confirm Dialog
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'ยืนยันการจอง',
          style: GoogleFonts.prompt(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'ต้องการจองเครื่อง ${widget.machine.machineNumber}\nเวลา ${time.format(context)} หรือไม่?',
          style: GoogleFonts.prompt(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'ยกเลิก',
              style: GoogleFonts.prompt(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'ยืนยัน',
              style: GoogleFonts.prompt(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return; // Add mounted check

    setState(() => _isBooking = true);
    try {
      await ref
          .read(bookingProvider)
          .createBooking(
            machineId: widget.machine.id,
            machineNumber: widget.machine.machineNumber,
            startTime: selectedDateTime,
            durationMinutes: 60, // Default 1 hour for now
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('จองคิวสำเร็จ!', style: GoogleFonts.prompt()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to Home
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'เกิดข้อผิดพลาด: ${e.toString().replaceAll("Exception: ", "")}',
              style: GoogleFonts.prompt(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.prompt(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.prompt(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(MachineStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getStatusText(status),
        style: GoogleFonts.prompt(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  String _getStatusText(MachineStatus status) {
    switch (status) {
      case MachineStatus.available:
        return 'ว่าง';
      case MachineStatus.inUse:
        return 'กำลังทำงาน';
      case MachineStatus.reserved:
        return 'จองแล้ว';
      case MachineStatus.maintenance:
        return 'ซ่อมบำรุง';
      case MachineStatus.overdue:
        return 'ผ้าตกค้าง';
    }
  }

  Color _getStatusColor(MachineStatus status) {
    switch (status) {
      case MachineStatus.available:
        return AppTheme.success;
      case MachineStatus.inUse:
        return AppTheme.error;
      case MachineStatus.reserved:
        return AppTheme.warning;
      case MachineStatus.maintenance:
        return AppTheme.textSecondary;
      case MachineStatus.overdue:
        return Colors.purple;
    }
  }
}

extension on Machine {
  int get price => 20;
}
