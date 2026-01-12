import '../../domain/entities/home_data.dart';
import 'banner_model.dart';
import 'category_course_block_model.dart';
import 'course_model.dart';
import 'mentor_model.dart';
import 'partner_model.dart';

class HomeDataModel extends HomeData {
  const HomeDataModel({
    super.banners,
    super.latestCourses,
    super.freeCourses,
    super.popularCourses,
    super.topMentors,
    super.partners,
    super.categoryCourseBlocks,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      banners: _parseBanners(json['banners']),
      latestCourses: _parseCourses(json['latest_courses']),
      freeCourses: _parseCourses(json['free_courses']),
      popularCourses: _parseCourses(json['popular_courses']),
      topMentors: _parseMentors(json['top_mentors']),
      partners: _parsePartners(json['partners']),
      categoryCourseBlocks: _parseCategoryCourseBlocks(json['category_course_blocks']),
    );
  }

  static List<HomeBannerModel> _parseBanners(dynamic bannersData) {
    if (bannersData == null) return [];
    
    try {
      if (bannersData is Map && bannersData['data'] != null) {
        final data = bannersData['data'];
        if (data is List) {
          return data.map((b) => HomeBannerModel.fromJson(b)).toList();
        }
      } else if (bannersData is List) {
        return bannersData.map((b) => HomeBannerModel.fromJson(b)).toList();
      }
    } catch (e) {
      print('Error parsing banners: $e');
    }
    
    return [];
  }

  static List<CourseModel> _parseCourses(dynamic coursesData) {
    if (coursesData == null) return [];
    
    try {
      if (coursesData is Map && coursesData['data'] != null) {
        final data = coursesData['data'];
        if (data is List) {
          return data.map((c) => CourseModel.fromJson(c)).toList();
        }
      } else if (coursesData is List) {
        return coursesData.map((c) => CourseModel.fromJson(c)).toList();
      }
    } catch (e) {
      print('Error parsing courses: $e');
    }
    
    return [];
  }

  static List<MentorModel> _parseMentors(dynamic mentorsData) {
    if (mentorsData == null) return [];
    
    try {
      if (mentorsData is Map && mentorsData['data'] != null) {
        final data = mentorsData['data'];
        if (data is List) {
          return data.map((m) => MentorModel.fromJson(m)).toList();
        }
      } else if (mentorsData is List) {
        return mentorsData.map((m) => MentorModel.fromJson(m)).toList();
      }
    } catch (e) {
      print('Error parsing mentors: $e');
    }
    
    return [];
  }

  static List<PartnerModel> _parsePartners(dynamic partnersData) {
    if (partnersData == null) return [];
    
    try {
      // Partners has a special structure: { headers: {}, original: { data: {...} } }
      if (partnersData is Map) {
        if (partnersData['original'] != null && partnersData['original'] is Map) {
          final original = partnersData['original'];
          if (original['data'] != null && original['data'] is Map) {
            final data = original['data']['data'];
            if (data is List) {
              return data.map((p) => PartnerModel.fromJson(p)).toList();
            }
          }
        } else if (partnersData['data'] != null) {
          final data = partnersData['data'];
          if (data is Map && data['data'] != null && data['data'] is List) {
            return (data['data'] as List).map((p) => PartnerModel.fromJson(p)).toList();
          } else if (data is List) {
            return data.map((p) => PartnerModel.fromJson(p)).toList();
          }
        }
      } else if (partnersData is List) {
        return partnersData.map((p) => PartnerModel.fromJson(p)).toList();
      }
    } catch (e) {
      print('Error parsing partners: $e');
    }
    
    return [];
  }

  static List<CategoryCourseBlockModel> _parseCategoryCourseBlocks(dynamic blocksData) {
    if (blocksData == null) return [];
    
    try {
      if (blocksData is Map && blocksData['data'] != null) {
        final data = blocksData['data'];
        if (data is List) {
          return data.map((b) => CategoryCourseBlockModel.fromJson(b as Map<String, dynamic>)).toList();
        }
      } else if (blocksData is List) {
        return blocksData.map((b) => CategoryCourseBlockModel.fromJson(b as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error parsing category_course_blocks: $e');
    }
    
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'banners': {
        'data': banners.map((b) => (b as HomeBannerModel).toJson()).toList(),
      },
      'latest_courses': {
        'data': latestCourses.map((c) => (c as CourseModel).toJson()).toList(),
      },
      'free_courses': {
        'data': freeCourses.map((c) => (c as CourseModel).toJson()).toList(),
      },
      'popular_courses': {
        'data': popularCourses.map((c) => (c as CourseModel).toJson()).toList(),
      },
      'top_mentors': {
        'data': topMentors.map((m) => (m as MentorModel).toJson()).toList(),
      },
      'partners': {
        'data': partners.map((p) => (p as PartnerModel).toJson()).toList(),
      },
      'category_course_blocks': categoryCourseBlocks.map((b) => (b as CategoryCourseBlockModel).toJson()).toList(),
    };
  }
}


