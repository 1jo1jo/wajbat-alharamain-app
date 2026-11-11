import 'package:flutter/material.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  static const _green = Color(0xFF0C4B3A);
  static const _grey = Color(0xFF73807B);
  static const _issues = [
    (label: 'الوجبة', icon: Icons.restaurant),
    (label: 'التوصيل', icon: Icons.delivery_dining),
    (label: 'الموقع', icon: Icons.location_off),
    (label: 'أخرى', icon: Icons.help_outline),
  ];

  final _detailsController = TextEditingController();
  int _selectedIssue = -1;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            tooltip: 'رجوع',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
          title: const Text(
            'الإبلاغ عن مشكلة',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'نوع المشكلة',
                    style: TextStyle(
                      color: _green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var index = 0; index < _issues.length; index++)
                        _issueChip(index),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'تفاصيل المشكلة',
                    style: TextStyle(
                      color: _green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _detailsController,
                    minLines: 5,
                    maxLines: 5,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    decoration: InputDecoration(
                      hintText: 'اشرح المشكلة بالتفصيل...',
                      hintStyle: const TextStyle(
                        color: _grey,
                        fontFamily: 'Cairo',
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFD5DAD8),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFD5DAD8),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _green, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('قريباً'))),
                    child: const Row(
                      children: [
                        Icon(Icons.attach_file, color: _grey),
                        SizedBox(width: 6),
                        Text(
                          'إرفاق صورة (اختياري)',
                          style: TextStyle(
                            color: _grey,
                            fontSize: 13,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text(
                            'إرسال البلاغ',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }

  Widget _issueChip(int index) {
    final issue = _issues[index];
    final selected = _selectedIssue == index;
    return InkWell(
      onTap: () => setState(() => _selectedIssue = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _green : const Color(0xFFD5DAD8),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(issue.icon, color: selected ? _green : _grey, size: 18),
            const SizedBox(width: 6),
            Text(
              issue.label,
              style: TextStyle(
                color: selected ? _green : _grey,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitReport() {
    if (_selectedIssue == -1 || _detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تحديد نوع المشكلة وكتابة التفاصيل')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _green.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0C4B3A), Color(0xFF1A6B50)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _green.withValues(alpha: 0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'تم إرسال البلاغ',
                  style: TextStyle(
                    color: Color(0xFF0C4B3A),
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    fontFamily: 'Cairo',
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Container(width: 40, height: 3, color: Color(0xFFC6963C)),
                const SizedBox(height: 16),
                const Text(
                  'شكراً لك على تعاونك\nسيتم مراجعة البلاغ في أقرب وقت',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF73807B),
                    fontSize: 15,
                    fontFamily: 'Cairo',
                    height: 2.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'العودة للرئيسية',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
      ),
    );
  }
}
