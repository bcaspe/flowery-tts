import 'package:meta/meta.dart';

import 'enums.dart';
import 'models_abstract.dart';

/// An individual voice information.
@immutable
final class Voice implements TTSVoice {
  const Voice._({
    required this.id,
    required this.name,
    required this.gender,
    required this.source,
    required this.language,
  });

  /// {@template flowery.fromMap}
  /// Create a new instance of this class from a Map.
  /// {@endtemplate}
  factory Voice.fromMap(Map<String, dynamic> map) => Voice._(
        id: map['id'] as String,
        name: map['name'] as String,
        gender: Gender.values.byName(map['gender'] as String),
        source: map['source'] as String,
        language: VoiceLanguageInfo.fromMap(
          map['language'] as Map<String, dynamic>,
        ),
      );

  @override
  final String id;

  @override
  final String name;

  @override
  final Gender gender;

  @override
  final String source;

  @override
  final VoiceLanguageInfo language;

  /// {@template flowery.hashCode}
  /// The hash code for this object.
  /// {@endtemplate}
  @override
  int get hashCode => Object.hash(id, name, gender, source, language);

  /// Whether this voice's gender is male.
  bool get isMale => gender == Gender.Male;

  /// Whether this voice's gender is female.
  bool get isFemale => gender == Gender.Female;

  /// Whether this voice's gender is neutral.
  bool get isNeutral => gender == Gender.Neutral;

  /// {@template flowery.toMap}
  /// A map representation of this object.
  /// {@endtemplate}
  Map<String, Object> toMap() => {
        'id': id,
        'name': name,
        'gender': gender.name,
        'source': source,
        'language': language.toMap(),
      };

  /// {@template flowery.toString}
  /// A string representation of this object.
  /// {@endtemplate}
  @override
  String toString() => 'Voice(id: $id, name: $name, gender: $gender, '
      'source: $source, language: $language)';

  /// {@template flowery.equalsOperator}
  /// The equality operator.
  /// {@endtemplate}
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Voice &&
          other.id == id &&
          other.name == name &&
          other.gender == gender &&
          other.source == source &&
          other.language == language;
}

/// The language information of a [Voice].
@immutable
final class VoiceLanguageInfo implements TTSVoiceLanguageInfo {
  const VoiceLanguageInfo._({
    required this.name,
    required this.code,
    required this.region,
    required this.nameWithoutRegion,
  });

  /// {@macro flowery.fromMap}
  factory VoiceLanguageInfo.fromMap(Map<String, dynamic> map) {
    final name = map['name'] as String;
    final splits = name.split('(');
    final region = switch (splits.length) {
      1 => null,
      2 || > 2 when splits[1].contains(')') => splits.last.split(')').first,
      _ => splits[1].trimRight()
    };

    return VoiceLanguageInfo._(
      name: name,
      code: map['code'] as String,
      region: region,
      nameWithoutRegion: splits.first.trimRight(),
    );
  }

  @override
  final String name;

  @override
  final String code;

  /// Name of the region.
  final String? region;

  /// Name of the language without its region.
  final String nameWithoutRegion;

  /// Name of the country.
  @Deprecated('Use .region instead.')
  String? get country => region;

  /// Name of the language without its country.
  @Deprecated('Use .nameWithoutRegion instead.')
  String get nameWithoutCountry => nameWithoutRegion;

  /// {@macro flowery.hashCode}
  @override
  int get hashCode => Object.hash(name, code);

  /// {@macro flowery.toMap}
  Map<String, String> toMap() => {'name': name, 'code': code};

  /// {@macro flowery.toString}
  @override
  String toString() => 'VoiceLanguageInfo(name: $name, code: $code)';

  /// {@macro flowery.equalsOperator}
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceLanguageInfo && other.name == name && other.code == code;
}

/// Information of all voices.
@immutable
final class VoicesResponse implements TTSVoicesResponse {
  const VoicesResponse._({
    required this.count,
    required this.defaultVoice,
    required this.voices,
    required this.femaleVoices,
    required this.maleVoices,
    required this.neutralVoices,
    required this.languageCodes,
    required this.languageNames,
    required this.sources,
    required this.speakers,
  });

  /// {@macro flowery.fromMap}
  factory VoicesResponse.fromMap(Map<String, dynamic> map) {
    final allVoices = <Voice>[];
    final maleVoices = <Voice>[];
    final femaleVoices = <Voice>[];
    final neutralVoices = <Voice>[];

    final language = (code: <String>{}, name: <String>{});
    final sources = <String>{};
    final speakers = <String>{};

    for (final voiceMap in map['voices'] as List) {
      final voice = Voice.fromMap(voiceMap as Map<String, dynamic>);

      allVoices.add(voice);

      switch (voice.gender) {
        case Gender.Male: maleVoices.add(voice);
        case Gender.Female: femaleVoices.add(voice);
        case Gender.Neutral: neutralVoices.add(voice);
        case Gender.Other: neutralVoices.add(voice);
      }
      language.code.add(voice.language.code);

      if (!voice.language.nameWithoutRegion.contains('Unknown')) {
        language.name.add(voice.language.nameWithoutRegion);
      }
      sources.add(voice.source);
      speakers.add(voice.name);
    }

    return VoicesResponse._(
      count: map['count'] as int,
      defaultVoice: Voice.fromMap(map['default'] as Map<String, dynamic>),
      voices: allVoices,
      femaleVoices: femaleVoices,
      maleVoices: maleVoices,
      neutralVoices: neutralVoices,
      languageCodes: language.code.toList()..sort(),
      languageNames: language.name.toList()..sort(),
      sources: sources.toList()..sort(),
      speakers: speakers.toList(),
    );
  }

  /// The number of [Voice] instances in [voices].
  @override
  final int count;

  @override
  final Voice defaultVoice;

  @override
  final List<Voice> voices;

  /// A list of female voices.
  final List<Voice> femaleVoices;

  /// A list of male voices.
  final List<Voice> maleVoices;

  /// A list of neutral voices.
  final List<Voice> neutralVoices;

  /// A list of language codes.
  final List<String> languageCodes;

  /// A list of language names.
  final List<String> languageNames;

  /// A list of voice sources.
  final List<String> sources;

  /// A list of voice speaker names.
  final List<String> speakers;

  @override
  int get hashCode => Object.hash(count, defaultVoice, Object.hashAll(voices));

  /// Find a [Voice] instance having `name` as name.
  ///
  /// The `name` parameter is case-insensitive.
  /// Return the [Voice] instance, if found or otherwise, `null`.
  Voice? getVoice(String name) => this[name];

  /// {@macro flowery.toMap}
  Map<String, Object> toMap() => {
        'count': count,
        'default': defaultVoice.toMap(),
        'voices': [for (final voice in voices) voice.toMap()],
      };

  /// {@macro flowery.toString}
  @override
  String toString() => 'VoicesResponse(count: $count, '
      'defaultVoice: $defaultVoice, voices: $voices)';

  /// {@macro flowery.equalsOperator}
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoicesResponse &&
          other.count == count &&
          other.defaultVoice == defaultVoice &&
          other.voices == voices;

  /// Find a [Voice] instance having `voiceName` as name.
  ///
  /// The `voiceName` parameter is case-insensitive.
  /// Return the [Voice] instance, if found or otherwise, `null`.
  Voice? operator [](String voiceName) {
    var name = voiceName.trim();
    if (name.isEmpty) return null;
    name = name.toLowerCase();

    // Given the pre-sorted nature of the "voices" property (by name),
    // the Binary Search algorithm is used here for efficient retrieval
    // of a specific Voice instance.
    var minIndex = 0;
    var maxIndex = count - 1;

    while (minIndex <= maxIndex) {
      final median = (minIndex + maxIndex) ~/ 2;
      switch (voices[median].name.toLowerCase().compareTo(name)) {
        case 0:
          return voices[median];
        case < 0:
          minIndex = median + 1;
        case > 0:
          maxIndex = median - 1;
      }
    }
    return null;
  }
}
