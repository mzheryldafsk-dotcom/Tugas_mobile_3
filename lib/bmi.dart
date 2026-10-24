import 'package:flutter/material.dart';

enum Gender {
  male('Laki-laki', Icons.male, Color(0xFF1E88E5)),
  female('Perempuan', Icons.female, Color(0xFFD81B60));

  const Gender(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

class BmiCategory {
  final String label;
  final double upperLimit;
  final Color color;
  final String advice;

  const BmiCategory(this.label, this.upperLimit, this.color, this.advice);
}

const Map<Gender, List<BmiCategory>> bmiCategories = {
  Gender.male: [
    BmiCategory(
      'Kurus',
      18.0,
      Color(0xFFFB8C00),
      'Tingkatkan asupan gizi seimbang dan protein.',
    ),
    BmiCategory(
      'Normal',
      25.0,
      Color(0xFF43A047),
      'Pertahankan pola makan dan olahraga rutin.',
    ),
    BmiCategory(
      'Gemuk',
      27.0,
      Color(0xFFF4511E),
      'Kurangi makanan tinggi gula & lemak, perbanyak aktivitas.',
    ),
    BmiCategory(
      'Obesitas',
      double.infinity,
      Color(0xFFE53935),
      'Disarankan berkonsultasi dengan dokter atau ahli gizi.',
    ),
  ],
  Gender.female: [
    BmiCategory(
      'Kurus',
      17.0,
      Color(0xFFFB8C00),
      'Tingkatkan asupan gizi seimbang dan protein.',
    ),
    BmiCategory(
      'Normal',
      23.0,
      Color(0xFF43A047),
      'Pertahankan pola makan dan olahraga rutin.',
    ),
    BmiCategory(
      'Gemuk',
      27.0,
      Color(0xFFF4511E),
      'Kurangi makanan tinggi gula & lemak, perbanyak aktivitas.',
    ),
    BmiCategory(
      'Obesitas',
      double.infinity,
      Color(0xFFE53935),
      'Disarankan berkonsultasi dengan dokter atau ahli gizi.',
    ),
  ],
};

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  Gender _gender = Gender.male;
  double? _bmiResult;
  BmiCategory? _category;
  String? _errorMessage;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  BmiCategory _classify(double bmi) {
    final list = bmiCategories[_gender]!;
    return list.firstWhere((c) => bmi < c.upperLimit);
  }

  void _calculateBMI() {
    FocusScope.of(context).unfocus();

    final weight =
        double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0;
    final heightCm =
        double.tryParse(_heightController.text.replaceAll(',', '.')) ?? 0;

    setState(() {
      if (weight > 0 && heightCm > 0) {
        final heightM = heightCm / 100;
        final bmi = weight / (heightM * heightM);
        _bmiResult = bmi;
        _category = _classify(bmi);
        _errorMessage = null;
      } else {
        _bmiResult = null;
        _category = null;
        _errorMessage = 'Masukkan berat dan tinggi badan yang valid';
      }
    });
  }

  void _resetAll() {
    FocusScope.of(context).unfocus();
    _weightController.clear();
    _heightController.clear();
    setState(() {
      _bmiResult = null;
      _category = null;
      _errorMessage = null;
    });
  }

  void _onGenderChanged(Gender gender) {
    setState(() {
      _gender = gender;
      if (_bmiResult != null) {
        _category = _classify(_bmiResult!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = _gender.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kalkulator BMI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputCard(accent),
                const SizedBox(height: 20),
                _buildResultCard(),
                const SizedBox(height: 20),
                _buildCategoryTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(Color accent) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Jenis Kelamin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            SegmentedButton<Gender>(
              showSelectedIcon: false,
              segments: Gender.values
                  .map(
                    (g) => ButtonSegment<Gender>(
                      value: g,
                      icon: Icon(g.icon),
                      label: Text(g.label),
                    ),
                  )
                  .toList(),
              selected: {_gender},
              onSelectionChanged: (s) => _onGenderChanged(s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.selected)
                      ? accent
                      : Colors.transparent;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.selected)
                      ? Colors.white
                      : Colors.black87;
                }),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _weightController,
              label: 'Berat Badan (kg)',
              icon: Icons.monitor_weight_outlined,
              accent: accent,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _heightController,
              label: 'Tinggi Badan (cm)',
              icon: Icons.height,
              accent: accent,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _calculateBMI,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Hitung BMI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetAll,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent,
                      side: BorderSide(color: accent, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color accent,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: accent),
        filled: true,
        fillColor: const Color(0xFFF4F6FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final bmi = _bmiResult;
    final cat = _category;
    final color = cat?.color ?? Colors.grey;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            'Hasil BMI ${_gender.label}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bmi?.toStringAsFixed(1) ?? '--',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              cat?.label ?? 'Belum ada data',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            cat?.advice ?? 'Isi data lalu tekan "Hitung BMI".',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTable() {
    final list = bmiCategories[_gender]!;

    String rangeText(int i) {
      final upper = list[i].upperLimit;
      if (i == 0) return '< ${_fmt(upper)}';
      final lower = list[i - 1].upperLimit;
      if (upper == double.infinity) return '≥ ${_fmt(lower)}';
      return '${_fmt(lower)} – ${_fmt(upper)}';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori BMI ${_gender.label}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < list.length; i++)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _category == list[i]
                      ? list[i].color.withValues(alpha: 0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _category == list[i]
                        ? list[i].color
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 6, backgroundColor: list[i].color),
                    const SizedBox(width: 12),
                    Expanded(child: Text(list[i].label)),
                    Text(
                      rangeText(i),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}
