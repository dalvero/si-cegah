import 'package:flutter/material.dart';
import 'package:si_cegah/services/auth_service.dart';
import 'package:si_cegah/services/child_service.dart';
import 'package:si_cegah/models/auth_models.dart';
import 'package:si_cegah/models/child_model.dart';

class Pengaturan extends StatefulWidget {
  const Pengaturan({super.key});

  @override
  State<Pengaturan> createState() => _PengaturanState();
}

class _PengaturanState extends State<Pengaturan> {
  final AuthService _authService = AuthService();
  final ChildService _childService = ChildService();

  User? _user;
  List<Child> _children = [];
  bool _isLoadingUser = true;
  bool _isLoadingChildren = true;
  String? _errorMessage;

  String _userName = "";
  String _email = "";
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadUser(), _loadChildren()]);
  }

  Future<void> _loadUser() async {
    try {
      setState(() => _isLoadingUser = true);

      await _authService.refreshCurrentUser();
      final current = _authService.currentUser;

      if (mounted) {
        setState(() {
          _user = current;
          _userName = current?.name ?? "";
          _email = current?.email ?? "";
          _photoUrl = null; // ganti kalau nanti ada URL foto di backend
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data user: $e';
          _isLoadingUser = false;
        });
      }
    }
  }

  Future<void> _loadChildren() async {
    try {
      setState(() => _isLoadingChildren = true);
      final isLoggedIn = await _authService.isLoggedIn();
      final token = await _authService.getToken();
      print('IS LOGGED IN: $isLoggedIn');
      print('TOKEN: $token');

      final children = await _childService.getChildren();

      if (mounted) {
        setState(() {
          _children = children;
          _isLoadingChildren = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data anak: $e';
          _isLoadingChildren = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  // Ambil warna avatar konsisten dari huruf depan
  final List<Color> avatarColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
  ];

  Color _getAvatarColor(String name) {
    if (name.isEmpty) return Colors.grey;
    int index = name.codeUnitAt(0) % avatarColors.length;
    return avatarColors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Pengaturan",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan profil
                _buildProfileHeader(),
                const SizedBox(height: 32),

                // Error message jika ada
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _errorMessage = null),
                          icon: const Icon(Icons.close),
                          color: Colors.red[600],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Menu sections
                _buildSectionTitle("Akun Saya"),
                const SizedBox(height: 16),
                _buildProfileCard(),
                const SizedBox(height: 24),

                _buildSectionTitle("Data Anak"),
                const SizedBox(height: 16),
                _buildChildCard(),
                const SizedBox(height: 24),

                _buildSectionTitle("Informasi"),
                const SizedBox(height: 16),
                _buildAboutCard(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF42A5F5), Color.fromARGB(255, 21, 185, 226)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: _isLoadingUser
                ? const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : CircleAvatar(
                    radius: 32,
                    backgroundColor: _photoUrl != null
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.2),
                    backgroundImage: _photoUrl != null
                        ? NetworkImage(_photoUrl!)
                        : null,
                    child: _photoUrl == null
                        ? Text(
                            (_userName.isNotEmpty
                                ? _userName[0].toUpperCase()
                                : "?"),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isLoadingUser
                    ? Container(
                        height: 22,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    : Text(
                        _userName.isNotEmpty ? _userName : "Nama belum diisi",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                const SizedBox(height: 4),
                _isLoadingUser
                    ? Container(
                        height: 14,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    : Text(
                        _email.isNotEmpty ? _email : "Email belum diisi",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.person_outline_rounded,
            title: "Nama",
            subtitle: _isLoadingUser
                ? "Memuat..."
                : (_userName.isNotEmpty ? _userName : "-"),
            isFirst: true,
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.email_outlined,
            title: "Email",
            subtitle: _isLoadingUser
                ? "Memuat..."
                : (_email.isNotEmpty ? _email : "-"),
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.phone_outlined,
            title: "Telepon",
            subtitle: _isLoadingUser ? "Memuat..." : (_user?.phone ?? "-"),
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.badge_outlined,
            title: "Role",
            subtitle: _isLoadingUser
                ? "Memuat..."
                : (_user?.role?.toString().split('.').last ?? "-"),
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.location_city_outlined,
            title: "Provinsi",
            subtitle: _isLoadingUser ? "Memuat..." : (_user?.province ?? "-"),
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.location_on_outlined,
            title: "Kota",
            subtitle: _isLoadingUser ? "Memuat..." : (_user?.city ?? "-"),
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.home_outlined,
            title: "Alamat",
            subtitle: _isLoadingUser ? "Memuat..." : (_user?.address ?? "-"),
          ),
          _buildDivider(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoadingUser ? null : _showEditProfileDialog,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text(
                  "Ubah Data Profil",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF42A5F5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isLoadingChildren
          ? _buildLoadingChildCard()
          : _children.isEmpty
          ? _buildEmptyChildCard()
          : _buildChildDataCard(
              _children.first,
            ), // Ambil anak pertama jika ada multiple
    );
  }

  Widget _buildLoadingChildCard() {
    return Column(
      children: [
        _buildLoadingMenuTile("Nama Panggilan", isFirst: true),
        _buildDivider(),
        _buildLoadingMenuTile("Nama Lengkap"),
        _buildDivider(),
        _buildLoadingMenuTile("Jenis Kelamin"),
        _buildDivider(),
        _buildLoadingMenuTile("Tanggal Lahir"),
        _buildDivider(),
        _buildLoadingMenuTile("Berat Badan"),
        _buildDivider(),
        _buildLoadingMenuTile("Tinggi Badan"),
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildEmptyChildCard() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(
                Icons.child_care_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                "Belum Ada Data Anak",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Tambahkan data anak untuk memulai pemantauan tumbuh kembang",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddChildDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                "Tambah Data Anak",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15E26A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChildDataCard(Child child) {
    return Column(
      children: [
        _buildMenuTile(
          icon: Icons.child_care_outlined,
          title: "Nama Panggilan",
          subtitle: child.name,
          isFirst: true,
        ),
        _buildDivider(),
        _buildMenuTile(
          icon: Icons.badge_outlined,
          title: "Nama Lengkap",
          subtitle: child.fullName ?? "-",
        ),
        _buildDivider(),
        _buildMenuTile(
          icon: Icons.wc_outlined,
          title: "Jenis Kelamin",
          subtitle: child.genderString,
        ),
        _buildDivider(),
        _buildMenuTile(
          icon: Icons.cake_outlined,
          title: "Tanggal Lahir",
          subtitle:
              "${child.dateOfBirth.day.toString().padLeft(2, '0')}/${child.dateOfBirth.month.toString().padLeft(2, '0')}/${child.dateOfBirth.year}",
        ),
        _buildDivider(),
        _buildMenuTile(
          icon: Icons.schedule_outlined,
          title: "Usia",
          subtitle: child.ageString,
        ),
        _buildDivider(),
        _buildMenuTile(
          icon: Icons.monitor_weight_outlined,
          title: "Berat Badan",
          subtitle: child.currentWeight != null
              ? "${child.currentWeight!.toStringAsFixed(1)} kg"
              : "-",
        ),
        _buildDivider(),
        _buildMenuTile(
          icon: Icons.height_outlined,
          title: "Tinggi Badan",
          subtitle: child.currentHeight != null
              ? "${child.currentHeight!.toStringAsFixed(1)} cm"
              : "-",
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showAddChildDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    "Tambah Anak",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF15E26A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(
                      color: Color(0xFF15E26A),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showEditChildDialog(child),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text(
                    "Edit Data",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF42A5F5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.info_outline,
            color: Color(0xFF42A5F5),
            size: 20,
          ),
        ),
        title: const Text(
          "Tentang Aplikasi",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const Text(
              "Aplikasi si-cegah adalah platform edukasi dan pemantauan stunting "
              "yang dikembangkan untuk membantu bidan dalam memberikan edukasi "
              "kepada orang tua. Aplikasi ini merupakan bagian dari penelitian ilmiah "
              "oleh dosen kesehatan.",
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isFirst = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, isFirst ? 20 : 16, 20, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF42A5F5), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMenuTile(String title, {bool isFirst = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, isFirst ? 20 : 16, 20, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.hourglass_empty,
              color: Colors.grey[400],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  height: 13,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey[200],
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ============== DIALOG MODALS ==============

  Future<void> _showAddChildDialog() async {
    final nameController = TextEditingController();
    final fullNameController = TextEditingController();
    DateTime? selectedDate;
    String selectedGender = 'MALE';
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Tambah Data Anak',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Panggilan *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    selectedDate == null
                        ? 'Pilih Tanggal Lahir *'
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365 * 10),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Kelamin *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('Laki-laki')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Perempuan')),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => selectedGender = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Berat Badan (kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tinggi Badan (cm)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (nameController.text.isEmpty || selectedDate == null) {
                        _showSnackBar(
                          'Nama dan tanggal lahir wajib diisi',
                          isError: true,
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      try {
                        final child = Child(
                          name: nameController.text,
                          fullName: fullNameController.text.isEmpty
                              ? null
                              : fullNameController.text,
                          dateOfBirth: selectedDate!,
                          gender: selectedGender == 'MALE'
                              ? Gender.male
                              : Gender.female,
                          currentWeight: weightController.text.trim().isEmpty
                              ? null
                              : double.tryParse(weightController.text.trim()),
                          currentHeight: heightController.text.trim().isEmpty
                              ? null
                              : double.tryParse(heightController.text.trim()),
                          allergies: [], // Pastikan array kosong, bukan null
                        );

                        await _childService.createChild(child);
                        Navigator.pop(context);
                        _showSnackBar('Data anak berhasil ditambahkan');
                        await _loadChildren();
                      } catch (e) {
                        _showSnackBar(
                          'Gagal menambah data anak: $e',
                          isError: true,
                        );
                      } finally {
                        setDialogState(() => isLoading = false);
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditChildDialog(Child child) async {
    final nameController = TextEditingController(text: child.name);
    final fullNameController = TextEditingController(
      text: child.fullName ?? '',
    );
    DateTime? selectedDate = child.dateOfBirth;
    String selectedGender = child.gender == Gender.male ? 'MALE' : 'FEMALE';
    final weightController = TextEditingController(
      text: child.currentWeight?.toString() ?? '',
    );
    final heightController = TextEditingController(
      text: child.currentHeight?.toString() ?? '',
    );
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Text(
                'Edit Data Anak',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showDeleteChildDialog(child),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Hapus Data',
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Panggilan *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate!,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365 * 10),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Kelamin *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('Laki-laki')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Perempuan')),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => selectedGender = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Berat Badan (kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tinggi Badan (cm)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (nameController.text.isEmpty) {
                        _showSnackBar(
                          'Nama panggilan wajib diisi',
                          isError: true,
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      try {
                        final updatedChild = child.copyWith(
                          name: nameController.text,
                          fullName: fullNameController.text.isEmpty
                              ? null
                              : fullNameController.text,
                          dateOfBirth: selectedDate,
                          gender: selectedGender == 'MALE'
                              ? Gender.male
                              : Gender.female,
                          currentWeight: weightController.text.isEmpty
                              ? null
                              : double.tryParse(weightController.text),
                          currentHeight: heightController.text.isEmpty
                              ? null
                              : double.tryParse(heightController.text),
                        );

                        await _childService.updateChild(
                          child.id!,
                          updatedChild,
                        );
                        Navigator.pop(context);
                        _showSnackBar('Data anak berhasil diperbarui');
                        await _loadChildren();
                      } catch (e) {
                        _showSnackBar(
                          'Gagal memperbarui data anak: $e',
                          isError: true,
                        );
                      } finally {
                        setDialogState(() => isLoading = false);
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteChildDialog(Child child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Anak'),
        content: Text(
          'Yakin ingin menghapus data ${child.name}? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _childService.deleteChild(child.id!);
        Navigator.pop(context); // Close edit dialog
        _showSnackBar('Data anak berhasil dihapus');
        await _loadChildren();
      } catch (e) {
        _showSnackBar('Gagal menghapus data anak: $e', isError: true);
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(text: _userName);
    final phoneController = TextEditingController(text: _user?.phone ?? '');
    final provinceController = TextEditingController(
      text: _user?.province ?? '',
    );
    final cityController = TextEditingController(text: _user?.city ?? '');
    final addressController = TextEditingController(text: _user?.address ?? '');
    String selectedRole = _user?.role?.toString().split('.').last ?? 'BIDAN';
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Edit Profil',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telepon',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    // Filter out ADMIN dari dropdown
                    if (selectedRole !=
                        'ADMIN') // Tetap tampilkan kalau user memang sudah admin
                      const DropdownMenuItem(
                        value: 'AYAH',
                        child: Text('Ayah'),
                      ),
                    const DropdownMenuItem(value: 'IBU', child: Text('Ibu')),
                    const DropdownMenuItem(
                      value: 'PENGASUH',
                      child: Text('Pengasuh'),
                    ),
                    const DropdownMenuItem(
                      value: 'TENAGA_KESEHATAN',
                      child: Text('Tenaga Kesehatan'),
                    ),
                    const DropdownMenuItem(
                      value: 'KADER',
                      child: Text('Kader'),
                    ),
                    const DropdownMenuItem(
                      value: 'BIDAN',
                      child: Text('Bidan'),
                    ),
                    // Tampilkan admin hanya jika user sudah admin
                    if (selectedRole == 'ADMIN')
                      const DropdownMenuItem(
                        value: 'ADMIN',
                        child: Text('Admin'),
                      ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => selectedRole = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: provinceController,
                  decoration: const InputDecoration(
                    labelText: 'Provinsi',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'Kota',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (nameController.text.isEmpty) {
                        _showSnackBar(
                          'Nama lengkap wajib diisi',
                          isError: true,
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      try {
                        await _authService.updateProfile(
                          name: nameController.text,
                          phone: phoneController.text.isEmpty
                              ? null
                              : phoneController.text,
                          role: selectedRole,
                          province: provinceController.text.isEmpty
                              ? null
                              : provinceController.text,
                          city: cityController.text.isEmpty
                              ? null
                              : cityController.text,
                          address: addressController.text.isEmpty
                              ? null
                              : addressController.text,
                        );

                        Navigator.pop(context);
                        _showSnackBar('Profil berhasil diperbarui');
                        await _loadUser();
                      } catch (e) {
                        _showSnackBar(
                          'Gagal memperbarui profil: $e',
                          isError: true,
                        );
                      } finally {
                        setDialogState(() => isLoading = false);
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
