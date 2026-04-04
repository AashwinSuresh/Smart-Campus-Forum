import 'package:campusapp/models/post_model.dart';
import 'package:campusapp/pages/create_post.dart';
import 'package:campusapp/pages/profile_page.dart';
import 'package:campusapp/services/api_service.dart';
import 'package:campusapp/services/cache_service.dart';
import 'package:campusapp/widgets/post_cards.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => CommunityPageState();
}

class CommunityPageState extends State<CommunityPage> {
  List<PostModel> _posts = [];
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // 1. Load from cache instantly
    final cached = CacheService.getCachedPosts();
    if (cached.isNotEmpty) {
      if (mounted) {
        setState(() {
          _posts = cached.map((json) => PostModel.fromJson(Map<String, dynamic>.from(json))).toList();
          _isLoading = false; // Don't show total loading if we have cache
        });
      }
    }
    
    // 2. Then load from network
    await loadPosts();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userId = ApiService.supabase.auth.currentUser?.id;
    if (userId != null) {
      final profile = await ApiService.fetchUserProfile(userId);
      if (mounted) {
        setState(() => _userProfile = profile);
      }
    }
  }

  Future<void> loadPosts() async {
    // Only show loading if we don't have posts yet
    if (_posts.isEmpty) {
      setState(() => _isLoading = true);
    }
    
    final posts = await ApiService.fetchPosts();
    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Campus App',
          style: GoogleFonts.oswald(textStyle: const TextStyle(fontSize: 28)),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white10,
              backgroundImage: NetworkImage(
                _userProfile?['profile_pic_url'] ?? 
                'https://api.dicebear.com/7.x/avataaars/png?seed=${ApiService.supabase.auth.currentUser?.id ?? "anon"}',
              ),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: _isLoading
          ? _buildShimmerLoading()
          : _posts.isEmpty
              ? Center(
                  child: Text(
                    'No posts yet.\nBe the first to post!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadPosts,
                  color: Colors.white,
                  backgroundColor: Colors.grey[900],
                  child: ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      return PostCard(post: _posts[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 20, backgroundColor: Colors.white),
                    const SizedBox(width: 12),
                    Container(width: 100, height: 12, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 12),
                Container(width: double.infinity, height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              ],
            ),
          );
        },
      ),
    );
  }
}
