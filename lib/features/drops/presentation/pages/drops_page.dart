import 'package:flutter/material.dart';
import 'package:art_drop_finder/features/auth/domain/entities/artist.dart';
import 'package:art_drop_finder/features/drops/presentation/controllers/drops_controller.dart';
import 'package:art_drop_finder/features/drops/presentation/pages/create_drop_page.dart';
import 'package:art_drop_finder/features/drops/presentation/pages/manage_drops_page.dart';
import 'package:art_drop_finder/core/widgets/app_logo.dart';

class DropsPage extends StatefulWidget {
  final DropsController controller;
  final Artist artist;
  final VoidCallback onLogout;

  const DropsPage({
    super.key,
    required this.controller,
    required this.artist,
    required this.onLogout,
  });

  @override
  State<DropsPage> createState() => _DropsPageState();
}

class _DropsPageState extends State<DropsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogoTitle(title: 'Art Drop Finder'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(widget.artist.name),
            ),
          ),
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Abmelden',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Erstellen'),
            Tab(text: 'Verwalten'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CreateDropPage(controller: widget.controller),
          ManageDropsPage(controller: widget.controller, artist: widget.artist),
        ],
      ),
    );
  }
}
