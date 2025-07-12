import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hysun_security_2/controller/addsecurity_controller.dart';

class AddSecurityScreen extends StatefulWidget {
  const AddSecurityScreen({super.key});

  @override
  _AddSecurityScreenState createState() => _AddSecurityScreenState();
}

class _AddSecurityScreenState extends State<AddSecurityScreen>
    with TickerProviderStateMixin {
  final AddSecurityController controller = Get.put(AddSecurityController());
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Add Security Members',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E7D32),
                Color(0xFF388E3C),
                Color(0xFF4CAF50),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? size.width * 0.1 : 16.0,
              vertical: 20.0,
            ),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  ...controller.securityMembers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final member = entry.value;
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      curve: Curves.elasticOut,
                      child: SecurityField(
                        index: index + 1,
                        member: member,
                        onNameChanged: () =>
                            controller.updateEmailAndPassword(index),
                        onDelete: () =>
                            _deleteSecurityMemberWithAnimation(index),
                        isTablet: isTablet,
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  _buildActionButtons(isTablet),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F5E8),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.security,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Information',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Add new security members to your community',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isTablet) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _addSecurityMemberWithAnimation,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Another Security Member',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 20 : 16,
                horizontal: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: Colors.green.withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveAllSecurityMembersWithAnimation,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              'Save All Security Members',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 20 : 16,
                horizontal: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: Colors.green.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  void _addSecurityMemberWithAnimation() {
    controller.addNewSecurityMember();
  }

  void _deleteSecurityMemberWithAnimation(int index) {
    controller.deleteSecurityMember(index);
  }

  void _saveAllSecurityMembersWithAnimation() {
    // Add loading animation here if needed
    controller.saveAllSecurityMembers();
  }
}

class SecurityField extends StatefulWidget {
  final int index;
  final SecurityModel member;
  final VoidCallback onNameChanged;
  final VoidCallback onDelete;
  final bool isTablet;

  const SecurityField({
    super.key,
    required this.index,
    required this.member,
    required this.onNameChanged,
    required this.onDelete,
    this.isTablet = false,
  });

  @override
  _SecurityFieldState createState() => _SecurityFieldState();
}

class _SecurityFieldState extends State<SecurityField>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0xFFF8FFF8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildShiftDropdown(),
                  const SizedBox(height: 16),
                  if (widget.isTablet)
                    _buildTabletLayout()
                  else
                    _buildMobileLayout(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Security Member ${widget.index}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child:
                  const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            ),
            onPressed: () {
              _scaleController.forward().then((_) {
                _scaleController.reverse();
                widget.onDelete();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShiftDropdown() {
    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: DropdownButtonFormField<String>(
            value: widget.member.selectedShift.value.isEmpty
                ? null
                : widget.member.selectedShift.value,
            items: const [
              DropdownMenuItem(
                value: 'Shift Morning',
                child: Row(
                  children: [
                    Icon(Icons.wb_sunny, color: Color(0xFF4CAF50), size: 20),
                    SizedBox(width: 8),
                    Text('Shift Morning'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'Shift Night',
                child: Row(
                  children: [
                    Icon(Icons.nights_stay, color: Color(0xFF4CAF50), size: 20),
                    SizedBox(width: 8),
                    Text('Shift Night'),
                  ],
                ),
              ),
            ],
            decoration: InputDecoration(
              labelText: 'Select Shift',
              prefixIcon: const Icon(Icons.schedule,
                  color: Color(0xFF4CAF50), size: 20),
              labelStyle: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFE8F5E8), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF4CAF50), width: 2),
              ),
              fillColor: const Color(0xFFF8FFF8),
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (value) {
              if (value != null) {
                widget.member.selectedShift.value = value;
              }
            },
          ),
        ));
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: widget.member.name,
                label: 'Name',
                validator: widget.member.isNameValid,
                errorText: 'Name is required',
                icon: Icons.person,
                onChanged: (_) => widget.onNameChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: widget.member.number,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: widget.member.isNumberValid,
                errorText: 'Number is required',
                icon: Icons.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: widget.member.email,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: widget.member.password,
                label: 'Password',
                obscureText: true,
                icon: Icons.lock,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: widget.member.name,
                label: 'Name',
                validator: widget.member.isNameValid,
                errorText: 'Name is required',
                icon: Icons.person,
                onChanged: (_) => widget.onNameChanged(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: widget.member.number,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: widget.member.isNumberValid,
                errorText: 'Number is required',
                icon: Icons.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: widget.member.email,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: widget.member.password,
                label: 'Password',
                obscureText: true,
                icon: Icons.lock,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool readOnly = false,
    RxBool? validator,
    String? errorText,
    IconData? icon,
    Function(String)? onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: validator != null
          ? Obx(() => TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                readOnly: readOnly,
                onChanged: onChanged,
                style: TextStyle(
                  fontSize: 16,
                  color: readOnly
                      ? const Color(0xFF999999)
                      : const Color(0xFF2E7D32),
                ),
                decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: icon != null
                      ? Icon(icon, color: const Color(0xFF4CAF50), size: 20)
                      : null,
                  labelStyle: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE8F5E8), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF4CAF50), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  fillColor: readOnly
                      ? const Color(0xFFF5F5F5)
                      : const Color(0xFFF8FFF8),
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  errorText: !validator.value ? errorText : null,
                  errorStyle: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ))
          : TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              readOnly: readOnly,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 16,
                color: readOnly
                    ? const Color(0xFF999999)
                    : const Color(0xFF2E7D32),
              ),
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: icon != null
                    ? Icon(icon, color: const Color(0xFF4CAF50), size: 20)
                    : null,
                labelStyle: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFE8F5E8), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                fillColor: readOnly
                    ? const Color(0xFFF5F5F5)
                    : const Color(0xFFF8FFF8),
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
    );
  }
}
