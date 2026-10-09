import 'dart:math' as math;

import '../models/ai_topic_recommendation_model.dart';
import '../models/ai_topic_request_model.dart';
import '../models/topic_model.dart';

class AiTopicRecommendationService {
  const AiTopicRecommendationService();

  List<AiTopicRecommendationModel> recommend({
    required AiTopicRequestModel request,
    required List<TopicModel> topics,
    int limit = 3,
  }) {
    if (limit <= 0 || topics.isEmpty) return const [];

    final ranked = topics.map((topic) {
      final weightedScore = _weightedScore(topic, request);
      final cosineSimilarity = _cosineSimilarity(
        _requestText(request),
        _topicText(topic),
      );
      return AiTopicRecommendationModel(
        topic: topic,
        weightedScore: weightedScore,
        cosineSimilarity: cosineSimilarity,
        finalScore: 0.6 * weightedScore + 0.4 * cosineSimilarity,
      );
    }).toList();

    ranked.sort((left, right) {
      final scoreOrder = right.finalScore.compareTo(left.finalScore);
      return scoreOrder == 0
          ? left.topic.title.compareTo(right.topic.title)
          : scoreOrder;
    });
    return ranked.take(limit).toList(growable: false);
  }

  double _weightedScore(TopicModel topic, AiTopicRequestModel request) {
    final text = _topicText(topic).toLowerCase();
    final technology = topic.technology.toLowerCase();
    final criteria = <(double, double)>[];

    if (request.learningModules.isNotEmpty) {
      criteria.add((0.15, _bestMatch(request.learningModules, text)));
    }
    if (request.applicationFields.isNotEmpty) {
      criteria.add((0.25, _bestMatch(request.applicationFields, text)));
    }
    criteria.add((0.15, _levelMatch(topic, request.level)));
    criteria.add((0.15, _platformMatch(technology, request.platform)));
    if (request.technology.trim().isNotEmpty) {
      criteria.add((0.15, _textSimilarity(request.technology, technology)));
    }
    if (request.priorities.isNotEmpty) {
      criteria.add((0.15, _bestMatch(request.priorities, text)));
    }

    final activeWeight = criteria.fold<double>(
      0,
      (total, criterion) => total + criterion.$1,
    );
    if (activeWeight == 0) return 0;
    return criteria.fold<double>(
          0,
          (total, criterion) => total + criterion.$1 * criterion.$2,
        ) /
        activeWeight;
  }

  double _bestMatch(Iterable<String> values, String candidate) {
    if (values.isEmpty) return 0;
    return values
        .map((value) => _textSimilarity(value, candidate))
        .reduce((best, score) => score > best ? score : best);
  }

  double _textSimilarity(String left, String right) {
    final leftTerms = _expandedTerms(left);
    final rightTerms = _expandedTerms(right);
    if (leftTerms.isEmpty || rightTerms.isEmpty) return 0;
    final overlap = leftTerms.intersection(rightTerms).length;
    return overlap / leftTerms.length;
  }

  Set<String> _expandedTerms(String value) {
    final normalized = value.toLowerCase();
    final terms = _tokens(normalized);
    const aliases = <String, List<String>>{
      'mobile': ['flutter', 'di động', 'ứng dụng'],
      'mobile application': ['flutter', 'di động', 'ứng dụng'],
      'lập trình mobile': ['flutter', 'di động', 'ứng dụng'],
      'web': ['asp.net', 'website', 'react', 'web'],
      'trí tuệ nhân tạo': ['ai', 'machine', 'learning'],
      'machine learning': ['ai', 'trí tuệ', 'nhân tạo'],
      'big data': ['dữ liệu', 'spark', 'phân tích'],
      'dữ liệu lớn': ['big', 'data', 'spark'],
      'iot': ['esp32', 'cảm biến', 'thiết bị'],
      'cơ sở dữ liệu': ['database', 'sql', 'dữ liệu'],
      'dễ triển khai': ['đơn giản', 'quản lý', 'theo dõi'],
      'tính thực tế': ['thực tế', 'người dùng', 'ứng dụng'],
      'tính sáng tạo': ['thông minh', 'tự động', 'gợi ý'],
      'có ai': ['ai', 'machine', 'learning'],
      'phù hợp thời gian': ['quản lý', 'theo dõi'],
      'phù hợp kỹ năng': ['flutter', 'firebase', 'quản lý'],
      'khả năng mở rộng': ['hệ thống', 'nền tảng', 'dữ liệu'],
      'phát triển thành sản phẩm': ['người dùng', 'ứng dụng', 'hệ thống'],
    };
    for (final entry in aliases.entries) {
      if (normalized.contains(entry.key)) terms.addAll(entry.value);
    }
    terms.removeAll(_stopWords);
    return terms;
  }

  Set<String> _tokens(String value) {
    return value
        .split(RegExp(r'[^\p{L}\p{N}+#.]+', unicode: true))
        .where((term) => term.length > 1)
        .toSet();
  }

  static const Set<String> _stopWords = {
    'và', 'của', 'cho', 'các', 'một', 'những', 'với', 'trong', 'theo',
    'để', 'hỗ', 'trợ', 'xây', 'dựng', 'ứng', 'dụng', 'hệ', 'thống',
    'tôi', 'muốn', 'làm', 'đề', 'tài', 'có', 'the', 'and', 'for', 'with',
  };

  double _levelMatch(TopicModel topic, String requestedLevel) {
    final text = '${topic.title} ${topic.description} ${topic.objective}'
        .toLowerCase();
    final advanced = <String>[
      'dự đoán', 'phân tích dữ liệu', 'hệ thống gợi ý', 'thông minh',
      'tự động', 'real-time', 'thời gian thực',
    ].any(text.contains);
    final basic = <String>[
      'quản lý lịch', 'quản lý chi tiêu', 'theo dõi', 'thông báo',
    ].any(text.contains);
    final estimatedLevel = advanced
        ? 'Nâng cao'
        : basic
        ? 'Cơ bản'
        : 'Trung bình';
    return estimatedLevel == requestedLevel ? 1 : 0.35;
  }

  double _platformMatch(String technology, String platform) {
    final wantsMobile = platform == 'Mobile' || platform == 'Web + Mobile';
    final wantsWeb = platform == 'Web' || platform == 'Web + Mobile';
    final hasMobile = technology.contains('flutter') ||
        technology.contains('android') ||
        technology.contains('ios');
    final hasWeb = technology.contains('web') ||
        technology.contains('asp.net') ||
        technology.contains('react');
    final matches = [
      if (wantsMobile) hasMobile,
      if (wantsWeb) hasWeb,
    ];
    if (matches.isEmpty) return 0.5;
    return matches.where((match) => match).length / matches.length;
  }

  double _cosineSimilarity(String left, String right) {
    final leftVector = _termFrequency(left);
    final rightVector = _termFrequency(right);
    if (leftVector.isEmpty || rightVector.isEmpty) return 0;

    var dotProduct = 0.0;
    for (final entry in leftVector.entries) {
      dotProduct += entry.value * (rightVector[entry.key] ?? 0);
    }
    final leftMagnitude = _magnitude(leftVector);
    final rightMagnitude = _magnitude(rightVector);
    if (leftMagnitude == 0 || rightMagnitude == 0) return 0;
    return dotProduct / (leftMagnitude * rightMagnitude);
  }

  Map<String, double> _termFrequency(String value) {
    final terms = _tokens(value.toLowerCase())..removeAll(_stopWords);
    final result = <String, double>{};
    for (final term in terms) {
      result[term] = (result[term] ?? 0) + 1;
    }
    return result;
  }

  double _magnitude(Map<String, double> vector) {
    final squaredSum = vector.values.fold<double>(
      0,
      (sum, value) => sum + value * value,
    );
    return math.sqrt(squaredSum);
  }

  String _requestText(AiTopicRequestModel request) => [
    request.message,
    ...request.learningModules,
    ...request.applicationFields,
    request.level,
    request.platform,
    request.technology,
    ...request.priorities,
  ].where((part) => part.trim().isNotEmpty).join(' ');

  String _topicText(TopicModel topic) =>
      '${topic.title} ${topic.description} ${topic.objective} '
      '${topic.scope} ${topic.technology}';
}