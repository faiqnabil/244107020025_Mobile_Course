class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const announcement = '/pengumuman/:id';
  static const notes = '/notes';

  static String announcementDetail(String id) => '/pengumuman/$id';
}
