
class OpenAIEmbeddingsResponse {
  final String object;
  final List<Embedding> data;
  final String model;
  final Usage usage;

  OpenAIEmbeddingsResponse({
    required this.object,
    required this.data,
    required this.model,
    required this.usage,
  });

  factory OpenAIEmbeddingsResponse.fromJson(Map<String, dynamic> json) {
    return OpenAIEmbeddingsResponse(
      object: json['object'],
      data: (json['data'] as List).map((e) => Embedding.fromJson(e)).toList(),
      model: json['model'],
      usage: Usage.fromJson(json['usage']),
    );
  }
}

class Embedding {
  final String object;
  final List<double> embedding;
  final int index;

  Embedding({
    required this.object,
    required this.embedding,
    required this.index,
  });

  factory Embedding.fromJson(Map<String, dynamic> json) {
    return Embedding(
      object: json['object'],
      embedding: (json['embedding'] as List).map((e) => e as double).toList(),
      index: json['index'],
    );
  }
}

class Usage {
  final int promptTokens;
  final int totalTokens;

  Usage({
    required this.promptTokens,
    required this.totalTokens,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['prompt_tokens'],
      totalTokens: json['total_tokens'],
    );
  }
}
