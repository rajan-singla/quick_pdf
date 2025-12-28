import 'package:flutter/material.dart';
import 'package:quick_pdf/src/common/widgets/feature_button.dart';
import 'package:quick_pdf/src/features/image_to_pdf/presentation/image_to_pdf_screen.dart';
import 'package:quick_pdf/src/core%20/services/recent_files_service.dart';
import 'package:open_file/open_file.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RecentFile> _recentFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    final files = await RecentFilesService.getRecentFiles();
    if (mounted) {
      setState(() {
        _recentFiles = files;
        _isLoading = false;
      });
    }
  }

  Future<void> _openFile(String filePath) async {
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QuickPDF")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Fast & crash-free PDF tools",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),

            const SizedBox(height: 18),

            /// ---- FEATURE BUTTONS ----
            FeatureButton(
              icon: Icons.image,
              label: "Image → PDF",
              color: Colors.orange,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ImageToPdfScreen()),
                );
                // Refresh recent files when returning
                _loadRecentFiles();
              },
            ),

            const SizedBox(height: 12),

            FeatureButton(
              icon: Icons.picture_as_pdf,
              label: "Merge PDFs",
              color: Colors.blue,
              onTap: () {},
            ),

            const SizedBox(height: 12),

            FeatureButton(
              icon: Icons.compress,
              label: "Compress PDF",
              color: Colors.green,
              onTap: () {},
            ),

            const SizedBox(height: 22),

            /// ---- RECENT FILES ----
            Text(
              "Recent Files",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_recentFiles.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.folder_open, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'No recent files',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._recentFiles.take(5).map((file) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _recentFileCard(
                      name: file.name,
                      size: file.formattedSize,
                      onTap: () => _openFile(file.path),
                    ),
                  )),

            const Spacer(),

            /// ---- BANNER AD PLACEHOLDER ----
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Banner Ad (Free Version)",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentFileCard({
    required String name,
    required String size,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.picture_as_pdf, color: Colors.red),
        ),
        title: Text(name),
        subtitle: Text(size),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
