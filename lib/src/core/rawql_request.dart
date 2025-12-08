enum RawQlOperation {
  list,
  get,
  create,
  update,
  delete,
  count,
  aggregate;

  String toJson() => name;
}

enum FilterOperations {
  eq,
  ne,
  gt,
  gte,
  lt,
  lte,
  in_,
  nin,
  search,
  startsWith,
  endsWith;

  String toJson() {
    if (this == in_) return 'in';
    return name;
  }

  static FilterOperations fromJson(String value) {
    if (value == 'in') return in_;
    return FilterOperations.values.firstWhere((e) => e.name == value);
  }
}

class RawQlRequest {
  final String? id;
  final RawQlOperation type;
  final String entity;
  final Map<String, dynamic>? data;
  final RawQlFilter? filter;
  final RawQlOptions? options;
  final List<RawQlPipelineStep>? pipeline;

  RawQlRequest({
    this.id,
    required this.type,
    required this.entity,
    this.data,
    this.filter,
    this.options,
    this.pipeline,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type.toJson(),
      'entity': entity,
      if (data != null && data!.isNotEmpty) 'data': data,
      if (filter != null) 'filter': filter!.toJson(),
      if (options != null) 'options': options!.toJson(),
      if (pipeline != null && pipeline!.isNotEmpty)
        'pipeline': pipeline!.map((step) => step.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'RawQlRequest(${toJson()})';
  }
}

abstract class RawQlFilter {
  Map<String, dynamic> toJson();

  @override
  String toString() => 'RawQlFilter(${toJson()})';
}

class FieldFilter implements RawQlFilter {
  final String field;
  final FilterOperations op;
  final dynamic value;

  FieldFilter({required this.field, required this.op, required this.value});

  @override
  Map<String, dynamic> toJson() {
    return {'field': field, 'op': op.toJson(), 'value': value};
  }

  @override
  String toString() => 'FieldFilter(${toJson()})';
}

class LogicalFilter implements RawQlFilter {
  final List<RawQlFilter>? and;
  final List<RawQlFilter>? or;
  final RawQlFilter? not;

  LogicalFilter({this.and, this.or, this.not});

  @override
  Map<String, dynamic> toJson() {
    return {
      if (and != null && and!.isNotEmpty)
        'and': and!.map((filter) => filter.toJson()).toList(),
      if (or != null && or!.isNotEmpty)
        'or': or!.map((filter) => filter.toJson()).toList(),
      if (not != null) 'not': not!.toJson(),
    };
  }

  @override
  String toString() => 'LogicalFilter(${toJson()})';
}

class RawQlOptions {
  final List<SortOption>? sort;
  final int? limit;
  final int? skip;
  final int? page;
  final List<String>? select;
  final List<RawQlPopulate>? populate;

  RawQlOptions({
    this.sort,
    this.limit,
    this.skip,
    this.page,
    this.select,
    this.populate,
  });

  Map<String, dynamic> toJson() {
    return {
      if (sort != null && sort!.isNotEmpty)
        'sort': sort!.map((s) => s.toJson()).toList(),
      if (limit != null) 'limit': limit,
      if (skip != null) 'skip': skip,
      if (page != null) 'page': page,
      if (select != null && select!.isNotEmpty) 'select': select,
      if (populate != null && populate!.isNotEmpty)
        'populate': populate!.map((p) => p.toJson()).toList(),
    };
  }

  @override
  String toString() => 'RawQlOptions(${toJson()})';
}

class SortOption {
  final String field;
  final String direction; // 'asc' or 'desc'

  SortOption({required this.field, required this.direction});

  Map<String, dynamic> toJson() {
    return {'field': field, 'direction': direction};
  }

  @override
  String toString() => 'SortOption(${toJson()})';
}

class RawQlPopulate {
  final String field;
  final List<String>? select;
  final List<RawQlPopulate>? populate;

  RawQlPopulate({required this.field, this.select, this.populate});

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      if (select != null && select!.isNotEmpty) 'select': select,
      if (populate != null && populate!.isNotEmpty)
        'populate': populate!.map((p) => p.toJson()).toList(),
    };
  }

  @override
  String toString() => 'RawQlPopulate(${toJson()})';
}

// Pipeline Step Types
abstract class RawQlPipelineStep {
  Map<String, dynamic> toJson();

  @override
  String toString() => 'RawQlPipelineStep(${toJson()})';
}

class MatchStep implements RawQlPipelineStep {
  final RawQlFilter match;

  MatchStep({required this.match});

  @override
  Map<String, dynamic> toJson() {
    return {'match': match.toJson()};
  }

  @override
  String toString() => 'MatchStep(${toJson()})';
}

class GroupStep implements RawQlPipelineStep {
  final RawQlGroup group;

  GroupStep({required this.group});

  @override
  Map<String, dynamic> toJson() {
    return {'group': group.toJson()};
  }

  @override
  String toString() => 'GroupStep(${toJson()})';
}

class SortStep implements RawQlPipelineStep {
  final List<SortOption> sort;

  SortStep({required this.sort});

  @override
  Map<String, dynamic> toJson() {
    return {'sort': sort.map((s) => s.toJson()).toList()};
  }

  @override
  String toString() => 'SortStep(${toJson()})';
}

class LimitStep implements RawQlPipelineStep {
  final int limit;

  LimitStep({required this.limit});

  @override
  Map<String, dynamic> toJson() {
    return {'limit': limit};
  }

  @override
  String toString() => 'LimitStep(${toJson()})';
}

class SkipStep implements RawQlPipelineStep {
  final int skip;

  SkipStep({required this.skip});

  @override
  Map<String, dynamic> toJson() {
    return {'skip': skip};
  }

  @override
  String toString() => 'SkipStep(${toJson()})';
}

class ProjectStep implements RawQlPipelineStep {
  final Map<String, dynamic> project;

  ProjectStep({required this.project});

  @override
  Map<String, dynamic> toJson() {
    return {'project': project};
  }

  @override
  String toString() => 'ProjectStep(${toJson()})';
}

class LookupStep implements RawQlPipelineStep {
  final RawQlLookup lookup;

  LookupStep({required this.lookup});

  @override
  Map<String, dynamic> toJson() {
    return {'lookup': lookup.toJson()};
  }

  @override
  String toString() => 'LookupStep(${toJson()})';
}

class UnwindStep implements RawQlPipelineStep {
  final dynamic unwind; // String or RawQlUnwind

  UnwindStep({required this.unwind});

  @override
  Map<String, dynamic> toJson() {
    if (unwind is String) {
      return {'unwind': unwind};
    } else if (unwind is RawQlUnwind) {
      return {'unwind': (unwind as RawQlUnwind).toJson()};
    }
    return {'unwind': unwind};
  }

  @override
  String toString() => 'UnwindStep(${toJson()})';
}

class AddFieldsStep implements RawQlPipelineStep {
  final Map<String, dynamic> addFields;

  AddFieldsStep({required this.addFields});

  @override
  Map<String, dynamic> toJson() {
    return {'addFields': addFields};
  }

  @override
  String toString() => 'AddFieldsStep(${toJson()})';
}

class CountStep implements RawQlPipelineStep {
  final String count;

  CountStep({required this.count});

  @override
  Map<String, dynamic> toJson() {
    return {'count': count};
  }

  @override
  String toString() => 'CountStep(${toJson()})';
}

class GraphLookupStep implements RawQlPipelineStep {
  final RawQlGraphLookup graphLookup;

  GraphLookupStep({required this.graphLookup});

  @override
  Map<String, dynamic> toJson() {
    return {'graphLookup': graphLookup.toJson()};
  }

  @override
  String toString() => 'GraphLookupStep(${toJson()})';
}

class FacetStep implements RawQlPipelineStep {
  final Map<String, List<RawQlPipelineStep>> facet;

  FacetStep({required this.facet});

  @override
  Map<String, dynamic> toJson() {
    return {
      'facet': facet.map((key, value) => MapEntry(
            key,
            value.map((step) => step.toJson()).toList(),
          )),
    };
  }

  @override
  String toString() => 'FacetStep(${toJson()})';
}

// Aggregation Types
class RawQlGroup {
  final dynamic id; // String or Map<String, dynamic>
  final Map<String, RawQlAggregateField> fields;

  RawQlGroup({required this.id, required this.fields});

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fields': fields.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  @override
  String toString() => 'RawQlGroup(${toJson()})';
}

class RawQlAggregateField {
  final String op; // 'count', 'sum', 'avg', 'min', 'max'
  final String? field;

  RawQlAggregateField({required this.op, this.field});

  Map<String, dynamic> toJson() {
    return {'op': op, if (field != null) 'field': field};
  }

  @override
  String toString() => 'RawQlAggregateField(${toJson()})';
}

// Lookup Types
class RawQlLookup {
  final String from;
  final String localField;
  final String foreignField;
  final Map<String, dynamic>? let;
  final List<RawQlPipelineStep>? pipeline;
  final String? as;

  RawQlLookup({
    required this.from,
    required this.localField,
    required this.foreignField,
    this.let,
    this.pipeline,
    this.as,
  });

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'localField': localField,
      'foreignField': foreignField,
      if (let != null) 'let': let,
      if (pipeline != null)
        'pipeline': pipeline!.map((step) => step.toJson()).toList(),
      if (as != null) 'as': as,
    };
  }

  @override
  String toString() => 'RawQlLookup(${toJson()})';
}

class RawQlUnwind {
  final String path;
  final bool? preserveNullAndEmptyArrays;
  final String? includeArrayIndex;

  RawQlUnwind({
    required this.path,
    this.preserveNullAndEmptyArrays,
    this.includeArrayIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      if (preserveNullAndEmptyArrays != null)
        'preserveNullAndEmptyArrays': preserveNullAndEmptyArrays,
      if (includeArrayIndex != null) 'includeArrayIndex': includeArrayIndex,
    };
  }

  @override
  String toString() => 'RawQlUnwind(${toJson()})';
}

class RawQlGraphLookup {
  final String from;
  final String startWith;
  final String connectFromField;
  final String connectToField;
  final String as;
  final int? maxDepth;
  final String? depthField;
  final dynamic restrictSearchWithMatch;

  RawQlGraphLookup({
    required this.from,
    required this.startWith,
    required this.connectFromField,
    required this.connectToField,
    required this.as,
    this.maxDepth,
    this.depthField,
    this.restrictSearchWithMatch,
  });

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'startWith': startWith,
      'connectFromField': connectFromField,
      'connectToField': connectToField,
      'as': as,
      if (maxDepth != null) 'maxDepth': maxDepth,
      if (depthField != null) 'depthField': depthField,
      if (restrictSearchWithMatch != null)
        'restrictSearchWithMatch': restrictSearchWithMatch,
    };
  }

  @override
  String toString() => 'RawQlGraphLookup(${toJson()})';
}
