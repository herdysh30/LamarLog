// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $JobApplicationsTable extends JobApplications
    with TableInfo<$JobApplicationsTable, JobApplication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobApplicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyNameMeta = const VerificationMeta(
    'companyName',
  );
  @override
  late final GeneratedColumn<String> companyName = GeneratedColumn<String>(
    'company_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleTitleMeta = const VerificationMeta(
    'roleTitle',
  );
  @override
  late final GeneratedColumn<String> roleTitle = GeneratedColumn<String>(
    'role_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _workplaceTypeMeta = const VerificationMeta(
    'workplaceType',
  );
  @override
  late final GeneratedColumn<String> workplaceType = GeneratedColumn<String>(
    'workplace_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('remote'),
  );
  static const VerificationMeta _jobTypeMeta = const VerificationMeta(
    'jobType',
  );
  @override
  late final GeneratedColumn<String> jobType = GeneratedColumn<String>(
    'job_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('fullTime'),
  );
  static const VerificationMeta _currentStatusMeta = const VerificationMeta(
    'currentStatus',
  );
  @override
  late final GeneratedColumn<String> currentStatus = GeneratedColumn<String>(
    'current_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('wishlist'),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('IDR'),
  );
  static const VerificationMeta _salaryPeriodMeta = const VerificationMeta(
    'salaryPeriod',
  );
  @override
  late final GeneratedColumn<String> salaryPeriod = GeneratedColumn<String>(
    'salary_period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('monthly'),
  );
  static const VerificationMeta _expectedSalaryMeta = const VerificationMeta(
    'expectedSalary',
  );
  @override
  late final GeneratedColumn<double> expectedSalary = GeneratedColumn<double>(
    'expected_salary',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _offeredSalaryMeta = const VerificationMeta(
    'offeredSalary',
  );
  @override
  late final GeneratedColumn<double> offeredSalary = GeneratedColumn<double>(
    'offered_salary',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vacancyUrlMeta = const VerificationMeta(
    'vacancyUrl',
  );
  @override
  late final GeneratedColumn<String> vacancyUrl = GeneratedColumn<String>(
    'vacancy_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recruiterNameMeta = const VerificationMeta(
    'recruiterName',
  );
  @override
  late final GeneratedColumn<String> recruiterName = GeneratedColumn<String>(
    'recruiter_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recruiterContactMeta = const VerificationMeta(
    'recruiterContact',
  );
  @override
  late final GeneratedColumn<String> recruiterContact = GeneratedColumn<String>(
    'recruiter_contact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
    'applied_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyName,
    roleTitle,
    location,
    workplaceType,
    jobType,
    currentStatus,
    priority,
    currency,
    salaryPeriod,
    expectedSalary,
    offeredSalary,
    vacancyUrl,
    recruiterName,
    recruiterContact,
    isArchived,
    appliedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_applications';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobApplication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_name')) {
      context.handle(
        _companyNameMeta,
        companyName.isAcceptableOrUnknown(
          data['company_name']!,
          _companyNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companyNameMeta);
    }
    if (data.containsKey('role_title')) {
      context.handle(
        _roleTitleMeta,
        roleTitle.isAcceptableOrUnknown(data['role_title']!, _roleTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleTitleMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('workplace_type')) {
      context.handle(
        _workplaceTypeMeta,
        workplaceType.isAcceptableOrUnknown(
          data['workplace_type']!,
          _workplaceTypeMeta,
        ),
      );
    }
    if (data.containsKey('job_type')) {
      context.handle(
        _jobTypeMeta,
        jobType.isAcceptableOrUnknown(data['job_type']!, _jobTypeMeta),
      );
    }
    if (data.containsKey('current_status')) {
      context.handle(
        _currentStatusMeta,
        currentStatus.isAcceptableOrUnknown(
          data['current_status']!,
          _currentStatusMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('salary_period')) {
      context.handle(
        _salaryPeriodMeta,
        salaryPeriod.isAcceptableOrUnknown(
          data['salary_period']!,
          _salaryPeriodMeta,
        ),
      );
    }
    if (data.containsKey('expected_salary')) {
      context.handle(
        _expectedSalaryMeta,
        expectedSalary.isAcceptableOrUnknown(
          data['expected_salary']!,
          _expectedSalaryMeta,
        ),
      );
    }
    if (data.containsKey('offered_salary')) {
      context.handle(
        _offeredSalaryMeta,
        offeredSalary.isAcceptableOrUnknown(
          data['offered_salary']!,
          _offeredSalaryMeta,
        ),
      );
    }
    if (data.containsKey('vacancy_url')) {
      context.handle(
        _vacancyUrlMeta,
        vacancyUrl.isAcceptableOrUnknown(data['vacancy_url']!, _vacancyUrlMeta),
      );
    }
    if (data.containsKey('recruiter_name')) {
      context.handle(
        _recruiterNameMeta,
        recruiterName.isAcceptableOrUnknown(
          data['recruiter_name']!,
          _recruiterNameMeta,
        ),
      );
    }
    if (data.containsKey('recruiter_contact')) {
      context.handle(
        _recruiterContactMeta,
        recruiterContact.isAcceptableOrUnknown(
          data['recruiter_contact']!,
          _recruiterContactMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JobApplication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobApplication(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_name'],
      )!,
      roleTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_title'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      workplaceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workplace_type'],
      )!,
      jobType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_type'],
      )!,
      currentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_status'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      salaryPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salary_period'],
      )!,
      expectedSalary: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}expected_salary'],
      ),
      offeredSalary: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}offered_salary'],
      ),
      vacancyUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vacancy_url'],
      ),
      recruiterName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recruiter_name'],
      ),
      recruiterContact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recruiter_contact'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $JobApplicationsTable createAlias(String alias) {
    return $JobApplicationsTable(attachedDatabase, alias);
  }
}

class JobApplication extends DataClass implements Insertable<JobApplication> {
  final String id;
  final String companyName;
  final String roleTitle;
  final String location;
  final String workplaceType;
  final String jobType;
  final String currentStatus;
  final String priority;
  final String currency;
  final String salaryPeriod;
  final double? expectedSalary;
  final double? offeredSalary;
  final String? vacancyUrl;
  final String? recruiterName;
  final String? recruiterContact;
  final bool isArchived;
  final DateTime? appliedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const JobApplication({
    required this.id,
    required this.companyName,
    required this.roleTitle,
    required this.location,
    required this.workplaceType,
    required this.jobType,
    required this.currentStatus,
    required this.priority,
    required this.currency,
    required this.salaryPeriod,
    this.expectedSalary,
    this.offeredSalary,
    this.vacancyUrl,
    this.recruiterName,
    this.recruiterContact,
    required this.isArchived,
    this.appliedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_name'] = Variable<String>(companyName);
    map['role_title'] = Variable<String>(roleTitle);
    map['location'] = Variable<String>(location);
    map['workplace_type'] = Variable<String>(workplaceType);
    map['job_type'] = Variable<String>(jobType);
    map['current_status'] = Variable<String>(currentStatus);
    map['priority'] = Variable<String>(priority);
    map['currency'] = Variable<String>(currency);
    map['salary_period'] = Variable<String>(salaryPeriod);
    if (!nullToAbsent || expectedSalary != null) {
      map['expected_salary'] = Variable<double>(expectedSalary);
    }
    if (!nullToAbsent || offeredSalary != null) {
      map['offered_salary'] = Variable<double>(offeredSalary);
    }
    if (!nullToAbsent || vacancyUrl != null) {
      map['vacancy_url'] = Variable<String>(vacancyUrl);
    }
    if (!nullToAbsent || recruiterName != null) {
      map['recruiter_name'] = Variable<String>(recruiterName);
    }
    if (!nullToAbsent || recruiterContact != null) {
      map['recruiter_contact'] = Variable<String>(recruiterContact);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || appliedAt != null) {
      map['applied_at'] = Variable<DateTime>(appliedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  JobApplicationsCompanion toCompanion(bool nullToAbsent) {
    return JobApplicationsCompanion(
      id: Value(id),
      companyName: Value(companyName),
      roleTitle: Value(roleTitle),
      location: Value(location),
      workplaceType: Value(workplaceType),
      jobType: Value(jobType),
      currentStatus: Value(currentStatus),
      priority: Value(priority),
      currency: Value(currency),
      salaryPeriod: Value(salaryPeriod),
      expectedSalary: expectedSalary == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedSalary),
      offeredSalary: offeredSalary == null && nullToAbsent
          ? const Value.absent()
          : Value(offeredSalary),
      vacancyUrl: vacancyUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(vacancyUrl),
      recruiterName: recruiterName == null && nullToAbsent
          ? const Value.absent()
          : Value(recruiterName),
      recruiterContact: recruiterContact == null && nullToAbsent
          ? const Value.absent()
          : Value(recruiterContact),
      isArchived: Value(isArchived),
      appliedAt: appliedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(appliedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory JobApplication.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobApplication(
      id: serializer.fromJson<String>(json['id']),
      companyName: serializer.fromJson<String>(json['companyName']),
      roleTitle: serializer.fromJson<String>(json['roleTitle']),
      location: serializer.fromJson<String>(json['location']),
      workplaceType: serializer.fromJson<String>(json['workplaceType']),
      jobType: serializer.fromJson<String>(json['jobType']),
      currentStatus: serializer.fromJson<String>(json['currentStatus']),
      priority: serializer.fromJson<String>(json['priority']),
      currency: serializer.fromJson<String>(json['currency']),
      salaryPeriod: serializer.fromJson<String>(json['salaryPeriod']),
      expectedSalary: serializer.fromJson<double?>(json['expectedSalary']),
      offeredSalary: serializer.fromJson<double?>(json['offeredSalary']),
      vacancyUrl: serializer.fromJson<String?>(json['vacancyUrl']),
      recruiterName: serializer.fromJson<String?>(json['recruiterName']),
      recruiterContact: serializer.fromJson<String?>(json['recruiterContact']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      appliedAt: serializer.fromJson<DateTime?>(json['appliedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyName': serializer.toJson<String>(companyName),
      'roleTitle': serializer.toJson<String>(roleTitle),
      'location': serializer.toJson<String>(location),
      'workplaceType': serializer.toJson<String>(workplaceType),
      'jobType': serializer.toJson<String>(jobType),
      'currentStatus': serializer.toJson<String>(currentStatus),
      'priority': serializer.toJson<String>(priority),
      'currency': serializer.toJson<String>(currency),
      'salaryPeriod': serializer.toJson<String>(salaryPeriod),
      'expectedSalary': serializer.toJson<double?>(expectedSalary),
      'offeredSalary': serializer.toJson<double?>(offeredSalary),
      'vacancyUrl': serializer.toJson<String?>(vacancyUrl),
      'recruiterName': serializer.toJson<String?>(recruiterName),
      'recruiterContact': serializer.toJson<String?>(recruiterContact),
      'isArchived': serializer.toJson<bool>(isArchived),
      'appliedAt': serializer.toJson<DateTime?>(appliedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  JobApplication copyWith({
    String? id,
    String? companyName,
    String? roleTitle,
    String? location,
    String? workplaceType,
    String? jobType,
    String? currentStatus,
    String? priority,
    String? currency,
    String? salaryPeriod,
    Value<double?> expectedSalary = const Value.absent(),
    Value<double?> offeredSalary = const Value.absent(),
    Value<String?> vacancyUrl = const Value.absent(),
    Value<String?> recruiterName = const Value.absent(),
    Value<String?> recruiterContact = const Value.absent(),
    bool? isArchived,
    Value<DateTime?> appliedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => JobApplication(
    id: id ?? this.id,
    companyName: companyName ?? this.companyName,
    roleTitle: roleTitle ?? this.roleTitle,
    location: location ?? this.location,
    workplaceType: workplaceType ?? this.workplaceType,
    jobType: jobType ?? this.jobType,
    currentStatus: currentStatus ?? this.currentStatus,
    priority: priority ?? this.priority,
    currency: currency ?? this.currency,
    salaryPeriod: salaryPeriod ?? this.salaryPeriod,
    expectedSalary: expectedSalary.present
        ? expectedSalary.value
        : this.expectedSalary,
    offeredSalary: offeredSalary.present
        ? offeredSalary.value
        : this.offeredSalary,
    vacancyUrl: vacancyUrl.present ? vacancyUrl.value : this.vacancyUrl,
    recruiterName: recruiterName.present
        ? recruiterName.value
        : this.recruiterName,
    recruiterContact: recruiterContact.present
        ? recruiterContact.value
        : this.recruiterContact,
    isArchived: isArchived ?? this.isArchived,
    appliedAt: appliedAt.present ? appliedAt.value : this.appliedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  JobApplication copyWithCompanion(JobApplicationsCompanion data) {
    return JobApplication(
      id: data.id.present ? data.id.value : this.id,
      companyName: data.companyName.present
          ? data.companyName.value
          : this.companyName,
      roleTitle: data.roleTitle.present ? data.roleTitle.value : this.roleTitle,
      location: data.location.present ? data.location.value : this.location,
      workplaceType: data.workplaceType.present
          ? data.workplaceType.value
          : this.workplaceType,
      jobType: data.jobType.present ? data.jobType.value : this.jobType,
      currentStatus: data.currentStatus.present
          ? data.currentStatus.value
          : this.currentStatus,
      priority: data.priority.present ? data.priority.value : this.priority,
      currency: data.currency.present ? data.currency.value : this.currency,
      salaryPeriod: data.salaryPeriod.present
          ? data.salaryPeriod.value
          : this.salaryPeriod,
      expectedSalary: data.expectedSalary.present
          ? data.expectedSalary.value
          : this.expectedSalary,
      offeredSalary: data.offeredSalary.present
          ? data.offeredSalary.value
          : this.offeredSalary,
      vacancyUrl: data.vacancyUrl.present
          ? data.vacancyUrl.value
          : this.vacancyUrl,
      recruiterName: data.recruiterName.present
          ? data.recruiterName.value
          : this.recruiterName,
      recruiterContact: data.recruiterContact.present
          ? data.recruiterContact.value
          : this.recruiterContact,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobApplication(')
          ..write('id: $id, ')
          ..write('companyName: $companyName, ')
          ..write('roleTitle: $roleTitle, ')
          ..write('location: $location, ')
          ..write('workplaceType: $workplaceType, ')
          ..write('jobType: $jobType, ')
          ..write('currentStatus: $currentStatus, ')
          ..write('priority: $priority, ')
          ..write('currency: $currency, ')
          ..write('salaryPeriod: $salaryPeriod, ')
          ..write('expectedSalary: $expectedSalary, ')
          ..write('offeredSalary: $offeredSalary, ')
          ..write('vacancyUrl: $vacancyUrl, ')
          ..write('recruiterName: $recruiterName, ')
          ..write('recruiterContact: $recruiterContact, ')
          ..write('isArchived: $isArchived, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyName,
    roleTitle,
    location,
    workplaceType,
    jobType,
    currentStatus,
    priority,
    currency,
    salaryPeriod,
    expectedSalary,
    offeredSalary,
    vacancyUrl,
    recruiterName,
    recruiterContact,
    isArchived,
    appliedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobApplication &&
          other.id == this.id &&
          other.companyName == this.companyName &&
          other.roleTitle == this.roleTitle &&
          other.location == this.location &&
          other.workplaceType == this.workplaceType &&
          other.jobType == this.jobType &&
          other.currentStatus == this.currentStatus &&
          other.priority == this.priority &&
          other.currency == this.currency &&
          other.salaryPeriod == this.salaryPeriod &&
          other.expectedSalary == this.expectedSalary &&
          other.offeredSalary == this.offeredSalary &&
          other.vacancyUrl == this.vacancyUrl &&
          other.recruiterName == this.recruiterName &&
          other.recruiterContact == this.recruiterContact &&
          other.isArchived == this.isArchived &&
          other.appliedAt == this.appliedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class JobApplicationsCompanion extends UpdateCompanion<JobApplication> {
  final Value<String> id;
  final Value<String> companyName;
  final Value<String> roleTitle;
  final Value<String> location;
  final Value<String> workplaceType;
  final Value<String> jobType;
  final Value<String> currentStatus;
  final Value<String> priority;
  final Value<String> currency;
  final Value<String> salaryPeriod;
  final Value<double?> expectedSalary;
  final Value<double?> offeredSalary;
  final Value<String?> vacancyUrl;
  final Value<String?> recruiterName;
  final Value<String?> recruiterContact;
  final Value<bool> isArchived;
  final Value<DateTime?> appliedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const JobApplicationsCompanion({
    this.id = const Value.absent(),
    this.companyName = const Value.absent(),
    this.roleTitle = const Value.absent(),
    this.location = const Value.absent(),
    this.workplaceType = const Value.absent(),
    this.jobType = const Value.absent(),
    this.currentStatus = const Value.absent(),
    this.priority = const Value.absent(),
    this.currency = const Value.absent(),
    this.salaryPeriod = const Value.absent(),
    this.expectedSalary = const Value.absent(),
    this.offeredSalary = const Value.absent(),
    this.vacancyUrl = const Value.absent(),
    this.recruiterName = const Value.absent(),
    this.recruiterContact = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobApplicationsCompanion.insert({
    required String id,
    required String companyName,
    required String roleTitle,
    this.location = const Value.absent(),
    this.workplaceType = const Value.absent(),
    this.jobType = const Value.absent(),
    this.currentStatus = const Value.absent(),
    this.priority = const Value.absent(),
    this.currency = const Value.absent(),
    this.salaryPeriod = const Value.absent(),
    this.expectedSalary = const Value.absent(),
    this.offeredSalary = const Value.absent(),
    this.vacancyUrl = const Value.absent(),
    this.recruiterName = const Value.absent(),
    this.recruiterContact = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.appliedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyName = Value(companyName),
       roleTitle = Value(roleTitle),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<JobApplication> custom({
    Expression<String>? id,
    Expression<String>? companyName,
    Expression<String>? roleTitle,
    Expression<String>? location,
    Expression<String>? workplaceType,
    Expression<String>? jobType,
    Expression<String>? currentStatus,
    Expression<String>? priority,
    Expression<String>? currency,
    Expression<String>? salaryPeriod,
    Expression<double>? expectedSalary,
    Expression<double>? offeredSalary,
    Expression<String>? vacancyUrl,
    Expression<String>? recruiterName,
    Expression<String>? recruiterContact,
    Expression<bool>? isArchived,
    Expression<DateTime>? appliedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyName != null) 'company_name': companyName,
      if (roleTitle != null) 'role_title': roleTitle,
      if (location != null) 'location': location,
      if (workplaceType != null) 'workplace_type': workplaceType,
      if (jobType != null) 'job_type': jobType,
      if (currentStatus != null) 'current_status': currentStatus,
      if (priority != null) 'priority': priority,
      if (currency != null) 'currency': currency,
      if (salaryPeriod != null) 'salary_period': salaryPeriod,
      if (expectedSalary != null) 'expected_salary': expectedSalary,
      if (offeredSalary != null) 'offered_salary': offeredSalary,
      if (vacancyUrl != null) 'vacancy_url': vacancyUrl,
      if (recruiterName != null) 'recruiter_name': recruiterName,
      if (recruiterContact != null) 'recruiter_contact': recruiterContact,
      if (isArchived != null) 'is_archived': isArchived,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobApplicationsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyName,
    Value<String>? roleTitle,
    Value<String>? location,
    Value<String>? workplaceType,
    Value<String>? jobType,
    Value<String>? currentStatus,
    Value<String>? priority,
    Value<String>? currency,
    Value<String>? salaryPeriod,
    Value<double?>? expectedSalary,
    Value<double?>? offeredSalary,
    Value<String?>? vacancyUrl,
    Value<String?>? recruiterName,
    Value<String?>? recruiterContact,
    Value<bool>? isArchived,
    Value<DateTime?>? appliedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return JobApplicationsCompanion(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      roleTitle: roleTitle ?? this.roleTitle,
      location: location ?? this.location,
      workplaceType: workplaceType ?? this.workplaceType,
      jobType: jobType ?? this.jobType,
      currentStatus: currentStatus ?? this.currentStatus,
      priority: priority ?? this.priority,
      currency: currency ?? this.currency,
      salaryPeriod: salaryPeriod ?? this.salaryPeriod,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      offeredSalary: offeredSalary ?? this.offeredSalary,
      vacancyUrl: vacancyUrl ?? this.vacancyUrl,
      recruiterName: recruiterName ?? this.recruiterName,
      recruiterContact: recruiterContact ?? this.recruiterContact,
      isArchived: isArchived ?? this.isArchived,
      appliedAt: appliedAt ?? this.appliedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyName.present) {
      map['company_name'] = Variable<String>(companyName.value);
    }
    if (roleTitle.present) {
      map['role_title'] = Variable<String>(roleTitle.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (workplaceType.present) {
      map['workplace_type'] = Variable<String>(workplaceType.value);
    }
    if (jobType.present) {
      map['job_type'] = Variable<String>(jobType.value);
    }
    if (currentStatus.present) {
      map['current_status'] = Variable<String>(currentStatus.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (salaryPeriod.present) {
      map['salary_period'] = Variable<String>(salaryPeriod.value);
    }
    if (expectedSalary.present) {
      map['expected_salary'] = Variable<double>(expectedSalary.value);
    }
    if (offeredSalary.present) {
      map['offered_salary'] = Variable<double>(offeredSalary.value);
    }
    if (vacancyUrl.present) {
      map['vacancy_url'] = Variable<String>(vacancyUrl.value);
    }
    if (recruiterName.present) {
      map['recruiter_name'] = Variable<String>(recruiterName.value);
    }
    if (recruiterContact.present) {
      map['recruiter_contact'] = Variable<String>(recruiterContact.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobApplicationsCompanion(')
          ..write('id: $id, ')
          ..write('companyName: $companyName, ')
          ..write('roleTitle: $roleTitle, ')
          ..write('location: $location, ')
          ..write('workplaceType: $workplaceType, ')
          ..write('jobType: $jobType, ')
          ..write('currentStatus: $currentStatus, ')
          ..write('priority: $priority, ')
          ..write('currency: $currency, ')
          ..write('salaryPeriod: $salaryPeriod, ')
          ..write('expectedSalary: $expectedSalary, ')
          ..write('offeredSalary: $offeredSalary, ')
          ..write('vacancyUrl: $vacancyUrl, ')
          ..write('recruiterName: $recruiterName, ')
          ..write('recruiterContact: $recruiterContact, ')
          ..write('isArchived: $isArchived, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatusTransitionsTable extends StatusTransitions
    with TableInfo<$StatusTransitionsTable, StatusTransition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatusTransitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _applicationIdMeta = const VerificationMeta(
    'applicationId',
  );
  @override
  late final GeneratedColumn<String> applicationId = GeneratedColumn<String>(
    'application_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES job_applications (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fromStatusMeta = const VerificationMeta(
    'fromStatus',
  );
  @override
  late final GeneratedColumn<String> fromStatus = GeneratedColumn<String>(
    'from_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toStatusMeta = const VerificationMeta(
    'toStatus',
  );
  @override
  late final GeneratedColumn<String> toStatus = GeneratedColumn<String>(
    'to_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transitionedAtMeta = const VerificationMeta(
    'transitionedAt',
  );
  @override
  late final GeneratedColumn<DateTime> transitionedAt =
      GeneratedColumn<DateTime>(
        'transitioned_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    applicationId,
    fromStatus,
    toStatus,
    transitionedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'status_transitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatusTransition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('application_id')) {
      context.handle(
        _applicationIdMeta,
        applicationId.isAcceptableOrUnknown(
          data['application_id']!,
          _applicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_applicationIdMeta);
    }
    if (data.containsKey('from_status')) {
      context.handle(
        _fromStatusMeta,
        fromStatus.isAcceptableOrUnknown(data['from_status']!, _fromStatusMeta),
      );
    }
    if (data.containsKey('to_status')) {
      context.handle(
        _toStatusMeta,
        toStatus.isAcceptableOrUnknown(data['to_status']!, _toStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_toStatusMeta);
    }
    if (data.containsKey('transitioned_at')) {
      context.handle(
        _transitionedAtMeta,
        transitionedAt.isAcceptableOrUnknown(
          data['transitioned_at']!,
          _transitionedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transitionedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StatusTransition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatusTransition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      applicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}application_id'],
      )!,
      fromStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_status'],
      ),
      toStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_status'],
      )!,
      transitionedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transitioned_at'],
      )!,
    );
  }

  @override
  $StatusTransitionsTable createAlias(String alias) {
    return $StatusTransitionsTable(attachedDatabase, alias);
  }
}

class StatusTransition extends DataClass
    implements Insertable<StatusTransition> {
  final String id;
  final String applicationId;
  final String? fromStatus;
  final String toStatus;
  final DateTime transitionedAt;
  const StatusTransition({
    required this.id,
    required this.applicationId,
    this.fromStatus,
    required this.toStatus,
    required this.transitionedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['application_id'] = Variable<String>(applicationId);
    if (!nullToAbsent || fromStatus != null) {
      map['from_status'] = Variable<String>(fromStatus);
    }
    map['to_status'] = Variable<String>(toStatus);
    map['transitioned_at'] = Variable<DateTime>(transitionedAt);
    return map;
  }

  StatusTransitionsCompanion toCompanion(bool nullToAbsent) {
    return StatusTransitionsCompanion(
      id: Value(id),
      applicationId: Value(applicationId),
      fromStatus: fromStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(fromStatus),
      toStatus: Value(toStatus),
      transitionedAt: Value(transitionedAt),
    );
  }

  factory StatusTransition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatusTransition(
      id: serializer.fromJson<String>(json['id']),
      applicationId: serializer.fromJson<String>(json['applicationId']),
      fromStatus: serializer.fromJson<String?>(json['fromStatus']),
      toStatus: serializer.fromJson<String>(json['toStatus']),
      transitionedAt: serializer.fromJson<DateTime>(json['transitionedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'applicationId': serializer.toJson<String>(applicationId),
      'fromStatus': serializer.toJson<String?>(fromStatus),
      'toStatus': serializer.toJson<String>(toStatus),
      'transitionedAt': serializer.toJson<DateTime>(transitionedAt),
    };
  }

  StatusTransition copyWith({
    String? id,
    String? applicationId,
    Value<String?> fromStatus = const Value.absent(),
    String? toStatus,
    DateTime? transitionedAt,
  }) => StatusTransition(
    id: id ?? this.id,
    applicationId: applicationId ?? this.applicationId,
    fromStatus: fromStatus.present ? fromStatus.value : this.fromStatus,
    toStatus: toStatus ?? this.toStatus,
    transitionedAt: transitionedAt ?? this.transitionedAt,
  );
  StatusTransition copyWithCompanion(StatusTransitionsCompanion data) {
    return StatusTransition(
      id: data.id.present ? data.id.value : this.id,
      applicationId: data.applicationId.present
          ? data.applicationId.value
          : this.applicationId,
      fromStatus: data.fromStatus.present
          ? data.fromStatus.value
          : this.fromStatus,
      toStatus: data.toStatus.present ? data.toStatus.value : this.toStatus,
      transitionedAt: data.transitionedAt.present
          ? data.transitionedAt.value
          : this.transitionedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatusTransition(')
          ..write('id: $id, ')
          ..write('applicationId: $applicationId, ')
          ..write('fromStatus: $fromStatus, ')
          ..write('toStatus: $toStatus, ')
          ..write('transitionedAt: $transitionedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, applicationId, fromStatus, toStatus, transitionedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatusTransition &&
          other.id == this.id &&
          other.applicationId == this.applicationId &&
          other.fromStatus == this.fromStatus &&
          other.toStatus == this.toStatus &&
          other.transitionedAt == this.transitionedAt);
}

class StatusTransitionsCompanion extends UpdateCompanion<StatusTransition> {
  final Value<String> id;
  final Value<String> applicationId;
  final Value<String?> fromStatus;
  final Value<String> toStatus;
  final Value<DateTime> transitionedAt;
  final Value<int> rowid;
  const StatusTransitionsCompanion({
    this.id = const Value.absent(),
    this.applicationId = const Value.absent(),
    this.fromStatus = const Value.absent(),
    this.toStatus = const Value.absent(),
    this.transitionedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatusTransitionsCompanion.insert({
    required String id,
    required String applicationId,
    this.fromStatus = const Value.absent(),
    required String toStatus,
    required DateTime transitionedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       applicationId = Value(applicationId),
       toStatus = Value(toStatus),
       transitionedAt = Value(transitionedAt);
  static Insertable<StatusTransition> custom({
    Expression<String>? id,
    Expression<String>? applicationId,
    Expression<String>? fromStatus,
    Expression<String>? toStatus,
    Expression<DateTime>? transitionedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (applicationId != null) 'application_id': applicationId,
      if (fromStatus != null) 'from_status': fromStatus,
      if (toStatus != null) 'to_status': toStatus,
      if (transitionedAt != null) 'transitioned_at': transitionedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatusTransitionsCompanion copyWith({
    Value<String>? id,
    Value<String>? applicationId,
    Value<String?>? fromStatus,
    Value<String>? toStatus,
    Value<DateTime>? transitionedAt,
    Value<int>? rowid,
  }) {
    return StatusTransitionsCompanion(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      fromStatus: fromStatus ?? this.fromStatus,
      toStatus: toStatus ?? this.toStatus,
      transitionedAt: transitionedAt ?? this.transitionedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (applicationId.present) {
      map['application_id'] = Variable<String>(applicationId.value);
    }
    if (fromStatus.present) {
      map['from_status'] = Variable<String>(fromStatus.value);
    }
    if (toStatus.present) {
      map['to_status'] = Variable<String>(toStatus.value);
    }
    if (transitionedAt.present) {
      map['transitioned_at'] = Variable<DateTime>(transitionedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatusTransitionsCompanion(')
          ..write('id: $id, ')
          ..write('applicationId: $applicationId, ')
          ..write('fromStatus: $fromStatus, ')
          ..write('toStatus: $toStatus, ')
          ..write('transitionedAt: $transitionedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimelineLogsTable extends TimelineLogs
    with TableInfo<$TimelineLogsTable, TimelineLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimelineLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _applicationIdMeta = const VerificationMeta(
    'applicationId',
  );
  @override
  late final GeneratedColumn<String> applicationId = GeneratedColumn<String>(
    'application_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES job_applications (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    applicationId,
    title,
    note,
    loggedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timeline_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimelineLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('application_id')) {
      context.handle(
        _applicationIdMeta,
        applicationId.isAcceptableOrUnknown(
          data['application_id']!,
          _applicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_applicationIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimelineLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimelineLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      applicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}application_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
    );
  }

  @override
  $TimelineLogsTable createAlias(String alias) {
    return $TimelineLogsTable(attachedDatabase, alias);
  }
}

class TimelineLog extends DataClass implements Insertable<TimelineLog> {
  final String id;
  final String applicationId;
  final String title;
  final String note;
  final DateTime loggedAt;
  const TimelineLog({
    required this.id,
    required this.applicationId,
    required this.title,
    required this.note,
    required this.loggedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['application_id'] = Variable<String>(applicationId);
    map['title'] = Variable<String>(title);
    map['note'] = Variable<String>(note);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    return map;
  }

  TimelineLogsCompanion toCompanion(bool nullToAbsent) {
    return TimelineLogsCompanion(
      id: Value(id),
      applicationId: Value(applicationId),
      title: Value(title),
      note: Value(note),
      loggedAt: Value(loggedAt),
    );
  }

  factory TimelineLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimelineLog(
      id: serializer.fromJson<String>(json['id']),
      applicationId: serializer.fromJson<String>(json['applicationId']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String>(json['note']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'applicationId': serializer.toJson<String>(applicationId),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String>(note),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
    };
  }

  TimelineLog copyWith({
    String? id,
    String? applicationId,
    String? title,
    String? note,
    DateTime? loggedAt,
  }) => TimelineLog(
    id: id ?? this.id,
    applicationId: applicationId ?? this.applicationId,
    title: title ?? this.title,
    note: note ?? this.note,
    loggedAt: loggedAt ?? this.loggedAt,
  );
  TimelineLog copyWithCompanion(TimelineLogsCompanion data) {
    return TimelineLog(
      id: data.id.present ? data.id.value : this.id,
      applicationId: data.applicationId.present
          ? data.applicationId.value
          : this.applicationId,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimelineLog(')
          ..write('id: $id, ')
          ..write('applicationId: $applicationId, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('loggedAt: $loggedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, applicationId, title, note, loggedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineLog &&
          other.id == this.id &&
          other.applicationId == this.applicationId &&
          other.title == this.title &&
          other.note == this.note &&
          other.loggedAt == this.loggedAt);
}

class TimelineLogsCompanion extends UpdateCompanion<TimelineLog> {
  final Value<String> id;
  final Value<String> applicationId;
  final Value<String> title;
  final Value<String> note;
  final Value<DateTime> loggedAt;
  final Value<int> rowid;
  const TimelineLogsCompanion({
    this.id = const Value.absent(),
    this.applicationId = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimelineLogsCompanion.insert({
    required String id,
    required String applicationId,
    required String title,
    this.note = const Value.absent(),
    required DateTime loggedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       applicationId = Value(applicationId),
       title = Value(title),
       loggedAt = Value(loggedAt);
  static Insertable<TimelineLog> custom({
    Expression<String>? id,
    Expression<String>? applicationId,
    Expression<String>? title,
    Expression<String>? note,
    Expression<DateTime>? loggedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (applicationId != null) 'application_id': applicationId,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimelineLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? applicationId,
    Value<String>? title,
    Value<String>? note,
    Value<DateTime>? loggedAt,
    Value<int>? rowid,
  }) {
    return TimelineLogsCompanion(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      title: title ?? this.title,
      note: note ?? this.note,
      loggedAt: loggedAt ?? this.loggedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (applicationId.present) {
      map['application_id'] = Variable<String>(applicationId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimelineLogsCompanion(')
          ..write('id: $id, ')
          ..write('applicationId: $applicationId, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InterviewSchedulesTable extends InterviewSchedules
    with TableInfo<$InterviewSchedulesTable, InterviewSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InterviewSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _applicationIdMeta = const VerificationMeta(
    'applicationId',
  );
  @override
  late final GeneratedColumn<String> applicationId = GeneratedColumn<String>(
    'application_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES job_applications (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roundNameMeta = const VerificationMeta(
    'roundName',
  );
  @override
  late final GeneratedColumn<String> roundName = GeneratedColumn<String>(
    'round_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meetingUrlMeta = const VerificationMeta(
    'meetingUrl',
  );
  @override
  late final GeneratedColumn<String> meetingUrl = GeneratedColumn<String>(
    'meeting_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationNotesMeta = const VerificationMeta(
    'locationNotes',
  );
  @override
  late final GeneratedColumn<String> locationNotes = GeneratedColumn<String>(
    'location_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notificationId24hMeta = const VerificationMeta(
    'notificationId24h',
  );
  @override
  late final GeneratedColumn<int> notificationId24h = GeneratedColumn<int>(
    'notification_id24h',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notificationId1hMeta = const VerificationMeta(
    'notificationId1h',
  );
  @override
  late final GeneratedColumn<int> notificationId1h = GeneratedColumn<int>(
    'notification_id1h',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    applicationId,
    roundName,
    scheduledAt,
    meetingUrl,
    locationNotes,
    notificationId24h,
    notificationId1h,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'interview_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<InterviewSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('application_id')) {
      context.handle(
        _applicationIdMeta,
        applicationId.isAcceptableOrUnknown(
          data['application_id']!,
          _applicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_applicationIdMeta);
    }
    if (data.containsKey('round_name')) {
      context.handle(
        _roundNameMeta,
        roundName.isAcceptableOrUnknown(data['round_name']!, _roundNameMeta),
      );
    } else if (isInserting) {
      context.missing(_roundNameMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('meeting_url')) {
      context.handle(
        _meetingUrlMeta,
        meetingUrl.isAcceptableOrUnknown(data['meeting_url']!, _meetingUrlMeta),
      );
    }
    if (data.containsKey('location_notes')) {
      context.handle(
        _locationNotesMeta,
        locationNotes.isAcceptableOrUnknown(
          data['location_notes']!,
          _locationNotesMeta,
        ),
      );
    }
    if (data.containsKey('notification_id24h')) {
      context.handle(
        _notificationId24hMeta,
        notificationId24h.isAcceptableOrUnknown(
          data['notification_id24h']!,
          _notificationId24hMeta,
        ),
      );
    }
    if (data.containsKey('notification_id1h')) {
      context.handle(
        _notificationId1hMeta,
        notificationId1h.isAcceptableOrUnknown(
          data['notification_id1h']!,
          _notificationId1hMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InterviewSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InterviewSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      applicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}application_id'],
      )!,
      roundName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}round_name'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      meetingUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meeting_url'],
      ),
      locationNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_notes'],
      ),
      notificationId24h: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id24h'],
      ),
      notificationId1h: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id1h'],
      ),
    );
  }

  @override
  $InterviewSchedulesTable createAlias(String alias) {
    return $InterviewSchedulesTable(attachedDatabase, alias);
  }
}

class InterviewSchedule extends DataClass
    implements Insertable<InterviewSchedule> {
  final String id;
  final String applicationId;
  final String roundName;
  final DateTime scheduledAt;
  final String? meetingUrl;
  final String? locationNotes;
  final int? notificationId24h;
  final int? notificationId1h;
  const InterviewSchedule({
    required this.id,
    required this.applicationId,
    required this.roundName,
    required this.scheduledAt,
    this.meetingUrl,
    this.locationNotes,
    this.notificationId24h,
    this.notificationId1h,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['application_id'] = Variable<String>(applicationId);
    map['round_name'] = Variable<String>(roundName);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    if (!nullToAbsent || meetingUrl != null) {
      map['meeting_url'] = Variable<String>(meetingUrl);
    }
    if (!nullToAbsent || locationNotes != null) {
      map['location_notes'] = Variable<String>(locationNotes);
    }
    if (!nullToAbsent || notificationId24h != null) {
      map['notification_id24h'] = Variable<int>(notificationId24h);
    }
    if (!nullToAbsent || notificationId1h != null) {
      map['notification_id1h'] = Variable<int>(notificationId1h);
    }
    return map;
  }

  InterviewSchedulesCompanion toCompanion(bool nullToAbsent) {
    return InterviewSchedulesCompanion(
      id: Value(id),
      applicationId: Value(applicationId),
      roundName: Value(roundName),
      scheduledAt: Value(scheduledAt),
      meetingUrl: meetingUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(meetingUrl),
      locationNotes: locationNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(locationNotes),
      notificationId24h: notificationId24h == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationId24h),
      notificationId1h: notificationId1h == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationId1h),
    );
  }

  factory InterviewSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InterviewSchedule(
      id: serializer.fromJson<String>(json['id']),
      applicationId: serializer.fromJson<String>(json['applicationId']),
      roundName: serializer.fromJson<String>(json['roundName']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      meetingUrl: serializer.fromJson<String?>(json['meetingUrl']),
      locationNotes: serializer.fromJson<String?>(json['locationNotes']),
      notificationId24h: serializer.fromJson<int?>(json['notificationId24h']),
      notificationId1h: serializer.fromJson<int?>(json['notificationId1h']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'applicationId': serializer.toJson<String>(applicationId),
      'roundName': serializer.toJson<String>(roundName),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'meetingUrl': serializer.toJson<String?>(meetingUrl),
      'locationNotes': serializer.toJson<String?>(locationNotes),
      'notificationId24h': serializer.toJson<int?>(notificationId24h),
      'notificationId1h': serializer.toJson<int?>(notificationId1h),
    };
  }

  InterviewSchedule copyWith({
    String? id,
    String? applicationId,
    String? roundName,
    DateTime? scheduledAt,
    Value<String?> meetingUrl = const Value.absent(),
    Value<String?> locationNotes = const Value.absent(),
    Value<int?> notificationId24h = const Value.absent(),
    Value<int?> notificationId1h = const Value.absent(),
  }) => InterviewSchedule(
    id: id ?? this.id,
    applicationId: applicationId ?? this.applicationId,
    roundName: roundName ?? this.roundName,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    meetingUrl: meetingUrl.present ? meetingUrl.value : this.meetingUrl,
    locationNotes: locationNotes.present
        ? locationNotes.value
        : this.locationNotes,
    notificationId24h: notificationId24h.present
        ? notificationId24h.value
        : this.notificationId24h,
    notificationId1h: notificationId1h.present
        ? notificationId1h.value
        : this.notificationId1h,
  );
  InterviewSchedule copyWithCompanion(InterviewSchedulesCompanion data) {
    return InterviewSchedule(
      id: data.id.present ? data.id.value : this.id,
      applicationId: data.applicationId.present
          ? data.applicationId.value
          : this.applicationId,
      roundName: data.roundName.present ? data.roundName.value : this.roundName,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      meetingUrl: data.meetingUrl.present
          ? data.meetingUrl.value
          : this.meetingUrl,
      locationNotes: data.locationNotes.present
          ? data.locationNotes.value
          : this.locationNotes,
      notificationId24h: data.notificationId24h.present
          ? data.notificationId24h.value
          : this.notificationId24h,
      notificationId1h: data.notificationId1h.present
          ? data.notificationId1h.value
          : this.notificationId1h,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InterviewSchedule(')
          ..write('id: $id, ')
          ..write('applicationId: $applicationId, ')
          ..write('roundName: $roundName, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('meetingUrl: $meetingUrl, ')
          ..write('locationNotes: $locationNotes, ')
          ..write('notificationId24h: $notificationId24h, ')
          ..write('notificationId1h: $notificationId1h')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    applicationId,
    roundName,
    scheduledAt,
    meetingUrl,
    locationNotes,
    notificationId24h,
    notificationId1h,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InterviewSchedule &&
          other.id == this.id &&
          other.applicationId == this.applicationId &&
          other.roundName == this.roundName &&
          other.scheduledAt == this.scheduledAt &&
          other.meetingUrl == this.meetingUrl &&
          other.locationNotes == this.locationNotes &&
          other.notificationId24h == this.notificationId24h &&
          other.notificationId1h == this.notificationId1h);
}

class InterviewSchedulesCompanion extends UpdateCompanion<InterviewSchedule> {
  final Value<String> id;
  final Value<String> applicationId;
  final Value<String> roundName;
  final Value<DateTime> scheduledAt;
  final Value<String?> meetingUrl;
  final Value<String?> locationNotes;
  final Value<int?> notificationId24h;
  final Value<int?> notificationId1h;
  final Value<int> rowid;
  const InterviewSchedulesCompanion({
    this.id = const Value.absent(),
    this.applicationId = const Value.absent(),
    this.roundName = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.meetingUrl = const Value.absent(),
    this.locationNotes = const Value.absent(),
    this.notificationId24h = const Value.absent(),
    this.notificationId1h = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InterviewSchedulesCompanion.insert({
    required String id,
    required String applicationId,
    required String roundName,
    required DateTime scheduledAt,
    this.meetingUrl = const Value.absent(),
    this.locationNotes = const Value.absent(),
    this.notificationId24h = const Value.absent(),
    this.notificationId1h = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       applicationId = Value(applicationId),
       roundName = Value(roundName),
       scheduledAt = Value(scheduledAt);
  static Insertable<InterviewSchedule> custom({
    Expression<String>? id,
    Expression<String>? applicationId,
    Expression<String>? roundName,
    Expression<DateTime>? scheduledAt,
    Expression<String>? meetingUrl,
    Expression<String>? locationNotes,
    Expression<int>? notificationId24h,
    Expression<int>? notificationId1h,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (applicationId != null) 'application_id': applicationId,
      if (roundName != null) 'round_name': roundName,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (meetingUrl != null) 'meeting_url': meetingUrl,
      if (locationNotes != null) 'location_notes': locationNotes,
      if (notificationId24h != null) 'notification_id24h': notificationId24h,
      if (notificationId1h != null) 'notification_id1h': notificationId1h,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InterviewSchedulesCompanion copyWith({
    Value<String>? id,
    Value<String>? applicationId,
    Value<String>? roundName,
    Value<DateTime>? scheduledAt,
    Value<String?>? meetingUrl,
    Value<String?>? locationNotes,
    Value<int?>? notificationId24h,
    Value<int?>? notificationId1h,
    Value<int>? rowid,
  }) {
    return InterviewSchedulesCompanion(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      roundName: roundName ?? this.roundName,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      locationNotes: locationNotes ?? this.locationNotes,
      notificationId24h: notificationId24h ?? this.notificationId24h,
      notificationId1h: notificationId1h ?? this.notificationId1h,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (applicationId.present) {
      map['application_id'] = Variable<String>(applicationId.value);
    }
    if (roundName.present) {
      map['round_name'] = Variable<String>(roundName.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (meetingUrl.present) {
      map['meeting_url'] = Variable<String>(meetingUrl.value);
    }
    if (locationNotes.present) {
      map['location_notes'] = Variable<String>(locationNotes.value);
    }
    if (notificationId24h.present) {
      map['notification_id24h'] = Variable<int>(notificationId24h.value);
    }
    if (notificationId1h.present) {
      map['notification_id1h'] = Variable<int>(notificationId1h.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InterviewSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('applicationId: $applicationId, ')
          ..write('roundName: $roundName, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('meetingUrl: $meetingUrl, ')
          ..write('locationNotes: $locationNotes, ')
          ..write('notificationId24h: $notificationId24h, ')
          ..write('notificationId1h: $notificationId1h, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResumeAttachmentsTable extends ResumeAttachments
    with TableInfo<$ResumeAttachmentsTable, ResumeAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResumeAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _applicationIdMeta = const VerificationMeta(
    'applicationId',
  );
  @override
  late final GeneratedColumn<String> applicationId = GeneratedColumn<String>(
    'application_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES job_applications (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _originalFileNameMeta = const VerificationMeta(
    'originalFileName',
  );
  @override
  late final GeneratedColumn<String> originalFileName = GeneratedColumn<String>(
    'original_file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _privateFilePathMeta = const VerificationMeta(
    'privateFilePath',
  );
  @override
  late final GeneratedColumn<String> privateFilePath = GeneratedColumn<String>(
    'private_file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attachedAtMeta = const VerificationMeta(
    'attachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> attachedAt = GeneratedColumn<DateTime>(
    'attached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    applicationId,
    originalFileName,
    privateFilePath,
    fileSizeBytes,
    attachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resume_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResumeAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('application_id')) {
      context.handle(
        _applicationIdMeta,
        applicationId.isAcceptableOrUnknown(
          data['application_id']!,
          _applicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_applicationIdMeta);
    }
    if (data.containsKey('original_file_name')) {
      context.handle(
        _originalFileNameMeta,
        originalFileName.isAcceptableOrUnknown(
          data['original_file_name']!,
          _originalFileNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalFileNameMeta);
    }
    if (data.containsKey('private_file_path')) {
      context.handle(
        _privateFilePathMeta,
        privateFilePath.isAcceptableOrUnknown(
          data['private_file_path']!,
          _privateFilePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privateFilePathMeta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fileSizeBytesMeta);
    }
    if (data.containsKey('attached_at')) {
      context.handle(
        _attachedAtMeta,
        attachedAt.isAcceptableOrUnknown(data['attached_at']!, _attachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_attachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResumeAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResumeAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      applicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}application_id'],
      )!,
      originalFileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_file_name'],
      )!,
      privateFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}private_file_path'],
      )!,
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      )!,
      attachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}attached_at'],
      )!,
    );
  }

  @override
  $ResumeAttachmentsTable createAlias(String alias) {
    return $ResumeAttachmentsTable(attachedDatabase, alias);
  }
}

class ResumeAttachment extends DataClass
    implements Insertable<ResumeAttachment> {
  final String id;
  final String applicationId;
  final String originalFileName;
  final String privateFilePath;
  final int fileSizeBytes;
  final DateTime attachedAt;
  const ResumeAttachment({
    required this.id,
    required this.applicationId,
    required this.originalFileName,
    required this.privateFilePath,
    required this.fileSizeBytes,
    required this.attachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['application_id'] = Variable<String>(applicationId);
    map['original_file_name'] = Variable<String>(originalFileName);
    map['private_file_path'] = Variable<String>(privateFilePath);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['attached_at'] = Variable<DateTime>(attachedAt);
    return map;
  }

  ResumeAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return ResumeAttachmentsCompanion(
      id: Value(id),
      applicationId: Value(applicationId),
      originalFileName: Value(originalFileName),
      privateFilePath: Value(privateFilePath),
      fileSizeBytes: Value(fileSizeBytes),
      attachedAt: Value(attachedAt),
    );
  }

  factory ResumeAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResumeAttachment(
      id: serializer.fromJson<String>(json['id']),
      applicationId: serializer.fromJson<String>(json['applicationId']),
      originalFileName: serializer.fromJson<String>(json['originalFileName']),
      privateFilePath: serializer.fromJson<String>(json['privateFilePath']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      attachedAt: serializer.fromJson<DateTime>(json['attachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'applicationId': serializer.toJson<String>(applicationId),
      'originalFileName': serializer.toJson<String>(originalFileName),
      'privateFilePath': serializer.toJson<String>(privateFilePath),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'attachedAt': serializer.toJson<DateTime>(attachedAt),
    };
  }

  ResumeAttachment copyWith({
    String? id,
    String? applicationId,
    String? originalFileName,
    String? privateFilePath,
    int? fileSizeBytes,
    DateTime? attachedAt,
  }) => ResumeAttachment(
    id: id ?? this.id,
    applicationId: applicationId ?? this.applicationId,
    originalFileName: originalFileName ?? this.originalFileName,
    privateFilePath: privateFilePath ?? this.privateFilePath,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    attachedAt: attachedAt ?? this.attachedAt,
  );
  ResumeAttachment copyWithCompanion(ResumeAttachmentsCompanion data) {
    return ResumeAttachment(
      id: data.id.present ? data.id.value : this.id,
      applicationId: data.applicationId.present
          ? data.applicationId.value
          : this.applicationId,
      originalFileName: data.originalFileName.present
          ? data.originalFileName.value
          : this.originalFileName,
      privateFilePath: data.privateFilePath.present
          ? data.privateFilePath.value
          : this.privateFilePath,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      attachedAt: data.attachedAt.present
          ? data.attachedAt.value
          : this.attachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResumeAttachment(')
          ..write('id: $id, ')
          ..write('applicationId: $applicationId, ')
          ..write('originalFileName: $originalFileName, ')
          ..write('privateFilePath: $privateFilePath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('attachedAt: $attachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    applicationId,
    originalFileName,
    privateFilePath,
    fileSizeBytes,
    attachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResumeAttachment &&
          other.id == this.id &&
          other.applicationId == this.applicationId &&
          other.originalFileName == this.originalFileName &&
          other.privateFilePath == this.privateFilePath &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.attachedAt == this.attachedAt);
}

class ResumeAttachmentsCompanion extends UpdateCompanion<ResumeAttachment> {
  final Value<String> id;
  final Value<String> applicationId;
  final Value<String> originalFileName;
  final Value<String> privateFilePath;
  final Value<int> fileSizeBytes;
  final Value<DateTime> attachedAt;
  final Value<int> rowid;
  const ResumeAttachmentsCompanion({
    this.id = const Value.absent(),
    this.applicationId = const Value.absent(),
    this.originalFileName = const Value.absent(),
    this.privateFilePath = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.attachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResumeAttachmentsCompanion.insert({
    required String id,
    required String applicationId,
    required String originalFileName,
    required String privateFilePath,
    required int fileSizeBytes,
    required DateTime attachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       applicationId = Value(applicationId),
       originalFileName = Value(originalFileName),
       privateFilePath = Value(privateFilePath),
       fileSizeBytes = Value(fileSizeBytes),
       attachedAt = Value(attachedAt);
  static Insertable<ResumeAttachment> custom({
    Expression<String>? id,
    Expression<String>? applicationId,
    Expression<String>? originalFileName,
    Expression<String>? privateFilePath,
    Expression<int>? fileSizeBytes,
    Expression<DateTime>? attachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (applicationId != null) 'application_id': applicationId,
      if (originalFileName != null) 'original_file_name': originalFileName,
      if (privateFilePath != null) 'private_file_path': privateFilePath,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (attachedAt != null) 'attached_at': attachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResumeAttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? applicationId,
    Value<String>? originalFileName,
    Value<String>? privateFilePath,
    Value<int>? fileSizeBytes,
    Value<DateTime>? attachedAt,
    Value<int>? rowid,
  }) {
    return ResumeAttachmentsCompanion(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      originalFileName: originalFileName ?? this.originalFileName,
      privateFilePath: privateFilePath ?? this.privateFilePath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      attachedAt: attachedAt ?? this.attachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (applicationId.present) {
      map['application_id'] = Variable<String>(applicationId.value);
    }
    if (originalFileName.present) {
      map['original_file_name'] = Variable<String>(originalFileName.value);
    }
    if (privateFilePath.present) {
      map['private_file_path'] = Variable<String>(privateFilePath.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (attachedAt.present) {
      map['attached_at'] = Variable<DateTime>(attachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResumeAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('applicationId: $applicationId, ')
          ..write('originalFileName: $originalFileName, ')
          ..write('privateFilePath: $privateFilePath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('attachedAt: $attachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JobApplicationsTable jobApplications = $JobApplicationsTable(
    this,
  );
  late final $StatusTransitionsTable statusTransitions =
      $StatusTransitionsTable(this);
  late final $TimelineLogsTable timelineLogs = $TimelineLogsTable(this);
  late final $InterviewSchedulesTable interviewSchedules =
      $InterviewSchedulesTable(this);
  late final $ResumeAttachmentsTable resumeAttachments =
      $ResumeAttachmentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    jobApplications,
    statusTransitions,
    timelineLogs,
    interviewSchedules,
    resumeAttachments,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'job_applications',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('status_transitions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'job_applications',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('timeline_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'job_applications',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('interview_schedules', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'job_applications',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('resume_attachments', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$JobApplicationsTableCreateCompanionBuilder =
    JobApplicationsCompanion Function({
      required String id,
      required String companyName,
      required String roleTitle,
      Value<String> location,
      Value<String> workplaceType,
      Value<String> jobType,
      Value<String> currentStatus,
      Value<String> priority,
      Value<String> currency,
      Value<String> salaryPeriod,
      Value<double?> expectedSalary,
      Value<double?> offeredSalary,
      Value<String?> vacancyUrl,
      Value<String?> recruiterName,
      Value<String?> recruiterContact,
      Value<bool> isArchived,
      Value<DateTime?> appliedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$JobApplicationsTableUpdateCompanionBuilder =
    JobApplicationsCompanion Function({
      Value<String> id,
      Value<String> companyName,
      Value<String> roleTitle,
      Value<String> location,
      Value<String> workplaceType,
      Value<String> jobType,
      Value<String> currentStatus,
      Value<String> priority,
      Value<String> currency,
      Value<String> salaryPeriod,
      Value<double?> expectedSalary,
      Value<double?> offeredSalary,
      Value<String?> vacancyUrl,
      Value<String?> recruiterName,
      Value<String?> recruiterContact,
      Value<bool> isArchived,
      Value<DateTime?> appliedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$JobApplicationsTableReferences
    extends
        BaseReferences<_$AppDatabase, $JobApplicationsTable, JobApplication> {
  $$JobApplicationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$StatusTransitionsTable, List<StatusTransition>>
  _statusTransitionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.statusTransitions,
        aliasName: $_aliasNameGenerator(
          db.jobApplications.id,
          db.statusTransitions.applicationId,
        ),
      );

  $$StatusTransitionsTableProcessedTableManager get statusTransitionsRefs {
    final manager = $$StatusTransitionsTableTableManager(
      $_db,
      $_db.statusTransitions,
    ).filter((f) => f.applicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _statusTransitionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TimelineLogsTable, List<TimelineLog>>
  _timelineLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.timelineLogs,
    aliasName: $_aliasNameGenerator(
      db.jobApplications.id,
      db.timelineLogs.applicationId,
    ),
  );

  $$TimelineLogsTableProcessedTableManager get timelineLogsRefs {
    final manager = $$TimelineLogsTableTableManager(
      $_db,
      $_db.timelineLogs,
    ).filter((f) => f.applicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_timelineLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InterviewSchedulesTable, List<InterviewSchedule>>
  _interviewSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.interviewSchedules,
        aliasName: $_aliasNameGenerator(
          db.jobApplications.id,
          db.interviewSchedules.applicationId,
        ),
      );

  $$InterviewSchedulesTableProcessedTableManager get interviewSchedulesRefs {
    final manager = $$InterviewSchedulesTableTableManager(
      $_db,
      $_db.interviewSchedules,
    ).filter((f) => f.applicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _interviewSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ResumeAttachmentsTable, List<ResumeAttachment>>
  _resumeAttachmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.resumeAttachments,
        aliasName: $_aliasNameGenerator(
          db.jobApplications.id,
          db.resumeAttachments.applicationId,
        ),
      );

  $$ResumeAttachmentsTableProcessedTableManager get resumeAttachmentsRefs {
    final manager = $$ResumeAttachmentsTableTableManager(
      $_db,
      $_db.resumeAttachments,
    ).filter((f) => f.applicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _resumeAttachmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JobApplicationsTableFilterComposer
    extends Composer<_$AppDatabase, $JobApplicationsTable> {
  $$JobApplicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roleTitle => $composableBuilder(
    column: $table.roleTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workplaceType => $composableBuilder(
    column: $table.workplaceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobType => $composableBuilder(
    column: $table.jobType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentStatus => $composableBuilder(
    column: $table.currentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salaryPeriod => $composableBuilder(
    column: $table.salaryPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get expectedSalary => $composableBuilder(
    column: $table.expectedSalary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get offeredSalary => $composableBuilder(
    column: $table.offeredSalary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vacancyUrl => $composableBuilder(
    column: $table.vacancyUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recruiterName => $composableBuilder(
    column: $table.recruiterName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recruiterContact => $composableBuilder(
    column: $table.recruiterContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> statusTransitionsRefs(
    Expression<bool> Function($$StatusTransitionsTableFilterComposer f) f,
  ) {
    final $$StatusTransitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.statusTransitions,
      getReferencedColumn: (t) => t.applicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatusTransitionsTableFilterComposer(
            $db: $db,
            $table: $db.statusTransitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> timelineLogsRefs(
    Expression<bool> Function($$TimelineLogsTableFilterComposer f) f,
  ) {
    final $$TimelineLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timelineLogs,
      getReferencedColumn: (t) => t.applicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimelineLogsTableFilterComposer(
            $db: $db,
            $table: $db.timelineLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> interviewSchedulesRefs(
    Expression<bool> Function($$InterviewSchedulesTableFilterComposer f) f,
  ) {
    final $$InterviewSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.interviewSchedules,
      getReferencedColumn: (t) => t.applicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InterviewSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.interviewSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> resumeAttachmentsRefs(
    Expression<bool> Function($$ResumeAttachmentsTableFilterComposer f) f,
  ) {
    final $$ResumeAttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resumeAttachments,
      getReferencedColumn: (t) => t.applicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResumeAttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.resumeAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JobApplicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $JobApplicationsTable> {
  $$JobApplicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roleTitle => $composableBuilder(
    column: $table.roleTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workplaceType => $composableBuilder(
    column: $table.workplaceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobType => $composableBuilder(
    column: $table.jobType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentStatus => $composableBuilder(
    column: $table.currentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salaryPeriod => $composableBuilder(
    column: $table.salaryPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get expectedSalary => $composableBuilder(
    column: $table.expectedSalary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get offeredSalary => $composableBuilder(
    column: $table.offeredSalary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vacancyUrl => $composableBuilder(
    column: $table.vacancyUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recruiterName => $composableBuilder(
    column: $table.recruiterName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recruiterContact => $composableBuilder(
    column: $table.recruiterContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JobApplicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobApplicationsTable> {
  $$JobApplicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roleTitle =>
      $composableBuilder(column: $table.roleTitle, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get workplaceType => $composableBuilder(
    column: $table.workplaceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jobType =>
      $composableBuilder(column: $table.jobType, builder: (column) => column);

  GeneratedColumn<String> get currentStatus => $composableBuilder(
    column: $table.currentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get salaryPeriod => $composableBuilder(
    column: $table.salaryPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<double> get expectedSalary => $composableBuilder(
    column: $table.expectedSalary,
    builder: (column) => column,
  );

  GeneratedColumn<double> get offeredSalary => $composableBuilder(
    column: $table.offeredSalary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vacancyUrl => $composableBuilder(
    column: $table.vacancyUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recruiterName => $composableBuilder(
    column: $table.recruiterName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recruiterContact => $composableBuilder(
    column: $table.recruiterContact,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> statusTransitionsRefs<T extends Object>(
    Expression<T> Function($$StatusTransitionsTableAnnotationComposer a) f,
  ) {
    final $$StatusTransitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.statusTransitions,
          getReferencedColumn: (t) => t.applicationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StatusTransitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.statusTransitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> timelineLogsRefs<T extends Object>(
    Expression<T> Function($$TimelineLogsTableAnnotationComposer a) f,
  ) {
    final $$TimelineLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timelineLogs,
      getReferencedColumn: (t) => t.applicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimelineLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.timelineLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> interviewSchedulesRefs<T extends Object>(
    Expression<T> Function($$InterviewSchedulesTableAnnotationComposer a) f,
  ) {
    final $$InterviewSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.interviewSchedules,
          getReferencedColumn: (t) => t.applicationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InterviewSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.interviewSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> resumeAttachmentsRefs<T extends Object>(
    Expression<T> Function($$ResumeAttachmentsTableAnnotationComposer a) f,
  ) {
    final $$ResumeAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.resumeAttachments,
          getReferencedColumn: (t) => t.applicationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ResumeAttachmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.resumeAttachments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$JobApplicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobApplicationsTable,
          JobApplication,
          $$JobApplicationsTableFilterComposer,
          $$JobApplicationsTableOrderingComposer,
          $$JobApplicationsTableAnnotationComposer,
          $$JobApplicationsTableCreateCompanionBuilder,
          $$JobApplicationsTableUpdateCompanionBuilder,
          (JobApplication, $$JobApplicationsTableReferences),
          JobApplication,
          PrefetchHooks Function({
            bool statusTransitionsRefs,
            bool timelineLogsRefs,
            bool interviewSchedulesRefs,
            bool resumeAttachmentsRefs,
          })
        > {
  $$JobApplicationsTableTableManager(
    _$AppDatabase db,
    $JobApplicationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobApplicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobApplicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobApplicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyName = const Value.absent(),
                Value<String> roleTitle = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> workplaceType = const Value.absent(),
                Value<String> jobType = const Value.absent(),
                Value<String> currentStatus = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> salaryPeriod = const Value.absent(),
                Value<double?> expectedSalary = const Value.absent(),
                Value<double?> offeredSalary = const Value.absent(),
                Value<String?> vacancyUrl = const Value.absent(),
                Value<String?> recruiterName = const Value.absent(),
                Value<String?> recruiterContact = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime?> appliedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobApplicationsCompanion(
                id: id,
                companyName: companyName,
                roleTitle: roleTitle,
                location: location,
                workplaceType: workplaceType,
                jobType: jobType,
                currentStatus: currentStatus,
                priority: priority,
                currency: currency,
                salaryPeriod: salaryPeriod,
                expectedSalary: expectedSalary,
                offeredSalary: offeredSalary,
                vacancyUrl: vacancyUrl,
                recruiterName: recruiterName,
                recruiterContact: recruiterContact,
                isArchived: isArchived,
                appliedAt: appliedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyName,
                required String roleTitle,
                Value<String> location = const Value.absent(),
                Value<String> workplaceType = const Value.absent(),
                Value<String> jobType = const Value.absent(),
                Value<String> currentStatus = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> salaryPeriod = const Value.absent(),
                Value<double?> expectedSalary = const Value.absent(),
                Value<double?> offeredSalary = const Value.absent(),
                Value<String?> vacancyUrl = const Value.absent(),
                Value<String?> recruiterName = const Value.absent(),
                Value<String?> recruiterContact = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime?> appliedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => JobApplicationsCompanion.insert(
                id: id,
                companyName: companyName,
                roleTitle: roleTitle,
                location: location,
                workplaceType: workplaceType,
                jobType: jobType,
                currentStatus: currentStatus,
                priority: priority,
                currency: currency,
                salaryPeriod: salaryPeriod,
                expectedSalary: expectedSalary,
                offeredSalary: offeredSalary,
                vacancyUrl: vacancyUrl,
                recruiterName: recruiterName,
                recruiterContact: recruiterContact,
                isArchived: isArchived,
                appliedAt: appliedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JobApplicationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                statusTransitionsRefs = false,
                timelineLogsRefs = false,
                interviewSchedulesRefs = false,
                resumeAttachmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (statusTransitionsRefs) db.statusTransitions,
                    if (timelineLogsRefs) db.timelineLogs,
                    if (interviewSchedulesRefs) db.interviewSchedules,
                    if (resumeAttachmentsRefs) db.resumeAttachments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (statusTransitionsRefs)
                        await $_getPrefetchedData<
                          JobApplication,
                          $JobApplicationsTable,
                          StatusTransition
                        >(
                          currentTable: table,
                          referencedTable: $$JobApplicationsTableReferences
                              ._statusTransitionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JobApplicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).statusTransitionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.applicationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (timelineLogsRefs)
                        await $_getPrefetchedData<
                          JobApplication,
                          $JobApplicationsTable,
                          TimelineLog
                        >(
                          currentTable: table,
                          referencedTable: $$JobApplicationsTableReferences
                              ._timelineLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JobApplicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).timelineLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.applicationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (interviewSchedulesRefs)
                        await $_getPrefetchedData<
                          JobApplication,
                          $JobApplicationsTable,
                          InterviewSchedule
                        >(
                          currentTable: table,
                          referencedTable: $$JobApplicationsTableReferences
                              ._interviewSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JobApplicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).interviewSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.applicationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (resumeAttachmentsRefs)
                        await $_getPrefetchedData<
                          JobApplication,
                          $JobApplicationsTable,
                          ResumeAttachment
                        >(
                          currentTable: table,
                          referencedTable: $$JobApplicationsTableReferences
                              ._resumeAttachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JobApplicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).resumeAttachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.applicationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$JobApplicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobApplicationsTable,
      JobApplication,
      $$JobApplicationsTableFilterComposer,
      $$JobApplicationsTableOrderingComposer,
      $$JobApplicationsTableAnnotationComposer,
      $$JobApplicationsTableCreateCompanionBuilder,
      $$JobApplicationsTableUpdateCompanionBuilder,
      (JobApplication, $$JobApplicationsTableReferences),
      JobApplication,
      PrefetchHooks Function({
        bool statusTransitionsRefs,
        bool timelineLogsRefs,
        bool interviewSchedulesRefs,
        bool resumeAttachmentsRefs,
      })
    >;
typedef $$StatusTransitionsTableCreateCompanionBuilder =
    StatusTransitionsCompanion Function({
      required String id,
      required String applicationId,
      Value<String?> fromStatus,
      required String toStatus,
      required DateTime transitionedAt,
      Value<int> rowid,
    });
typedef $$StatusTransitionsTableUpdateCompanionBuilder =
    StatusTransitionsCompanion Function({
      Value<String> id,
      Value<String> applicationId,
      Value<String?> fromStatus,
      Value<String> toStatus,
      Value<DateTime> transitionedAt,
      Value<int> rowid,
    });

final class $$StatusTransitionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StatusTransitionsTable,
          StatusTransition
        > {
  $$StatusTransitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $JobApplicationsTable _applicationIdTable(_$AppDatabase db) =>
      db.jobApplications.createAlias(
        $_aliasNameGenerator(
          db.statusTransitions.applicationId,
          db.jobApplications.id,
        ),
      );

  $$JobApplicationsTableProcessedTableManager get applicationId {
    final $_column = $_itemColumn<String>('application_id')!;

    final manager = $$JobApplicationsTableTableManager(
      $_db,
      $_db.jobApplications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_applicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StatusTransitionsTableFilterComposer
    extends Composer<_$AppDatabase, $StatusTransitionsTable> {
  $$StatusTransitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toStatus => $composableBuilder(
    column: $table.toStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transitionedAt => $composableBuilder(
    column: $table.transitionedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$JobApplicationsTableFilterComposer get applicationId {
    final $$JobApplicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applicationId,
      referencedTable: $db.jobApplications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobApplicationsTableFilterComposer(
            $db: $db,
            $table: $db.jobApplications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatusTransitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StatusTransitionsTable> {
  $$StatusTransitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toStatus => $composableBuilder(
    column: $table.toStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transitionedAt => $composableBuilder(
    column: $table.transitionedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$JobApplicationsTableOrderingComposer get applicationId {
    final $$JobApplicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applicationId,
      referencedTable: $db.jobApplications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobApplicationsTableOrderingComposer(
            $db: $db,
            $table: $db.jobApplications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatusTransitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatusTransitionsTable> {
  $$StatusTransitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toStatus =>
      $composableBuilder(column: $table.toStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get transitionedAt => $composableBuilder(
    column: $table.transitionedAt,
    builder: (column) => column,
  );

  $$JobApplicationsTableAnnotationComposer get applicationId {
    final $$JobApplicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applicationId,
      referencedTable: $db.jobApplications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobApplicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobApplications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatusTransitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatusTransitionsTable,
          StatusTransition,
          $$StatusTransitionsTableFilterComposer,
          $$StatusTransitionsTableOrderingComposer,
          $$StatusTransitionsTableAnnotationComposer,
          $$StatusTransitionsTableCreateCompanionBuilder,
          $$StatusTransitionsTableUpdateCompanionBuilder,
          (StatusTransition, $$StatusTransitionsTableReferences),
          StatusTransition,
          PrefetchHooks Function({bool applicationId})
        > {
  $$StatusTransitionsTableTableManager(
    _$AppDatabase db,
    $StatusTransitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatusTransitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatusTransitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatusTransitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> applicationId = const Value.absent(),
                Value<String?> fromStatus = const Value.absent(),
                Value<String> toStatus = const Value.absent(),
                Value<DateTime> transitionedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatusTransitionsCompanion(
                id: id,
                applicationId: applicationId,
                fromStatus: fromStatus,
                toStatus: toStatus,
                transitionedAt: transitionedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String applicationId,
                Value<String?> fromStatus = const Value.absent(),
                required String toStatus,
                required DateTime transitionedAt,
                Value<int> rowid = const Value.absent(),
              }) => StatusTransitionsCompanion.insert(
                id: id,
                applicationId: applicationId,
                fromStatus: fromStatus,
                toStatus: toStatus,
                transitionedAt: transitionedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StatusTransitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({applicationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (applicationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.applicationId,
                                referencedTable:
                                    $$StatusTransitionsTableReferences
                                        ._applicationIdTable(db),
                                referencedColumn:
                                    $$StatusTransitionsTableReferences
                                        ._applicationIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StatusTransitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatusTransitionsTable,
      StatusTransition,
      $$StatusTransitionsTableFilterComposer,
      $$StatusTransitionsTableOrderingComposer,
      $$StatusTransitionsTableAnnotationComposer,
      $$StatusTransitionsTableCreateCompanionBuilder,
      $$StatusTransitionsTableUpdateCompanionBuilder,
      (StatusTransition, $$StatusTransitionsTableReferences),
      StatusTransition,
      PrefetchHooks Function({bool applicationId})
    >;
typedef $$TimelineLogsTableCreateCompanionBuilder =
    TimelineLogsCompanion Function({
      required String id,
      required String applicationId,
      required String title,
      Value<String> note,
      required DateTime loggedAt,
      Value<int> rowid,
    });
typedef $$TimelineLogsTableUpdateCompanionBuilder =
    TimelineLogsCompanion Function({
      Value<String> id,
      Value<String> applicationId,
      Value<String> title,
      Value<String> note,
      Value<DateTime> loggedAt,
      Value<int> rowid,
    });

final class $$TimelineLogsTableReferences
    extends BaseReferences<_$AppDatabase, $TimelineLogsTable, TimelineLog> {
  $$TimelineLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JobApplicationsTable _applicationIdTable(_$AppDatabase db) =>
      db.jobApplications.createAlias(
        $_aliasNameGenerator(
          db.timelineLogs.applicationId,
          db.jobApplications.id,
        ),
      );

  $$JobApplicationsTableProcessedTableManager get applicationId {
    final $_column = $_itemColumn<String>('application_id')!;

    final manager = $$JobApplicationsTableTableManager(
      $_db,
      $_db.jobApplications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_applicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TimelineLogsTableFilterComposer
    extends Composer<_$AppDatabase, $TimelineLogsTable> {
  $$TimelineLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$JobApplicationsTableFilterComposer get applicationId {
    final $$JobApplicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applicationId,
      referencedTable: $db.jobApplications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobApplicationsTableFilterComposer(
            $db: $db,
            $table: $db.jobApplications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimelineLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimelineLogsTable> {
  $$TimelineLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$JobApplicationsTableOrderingComposer get applicationId {
    final $$JobApplicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applicationId,
      referencedTable: $db.jobApplications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobApplicationsTableOrderingComposer(
            $db: $db,
            $table: $db.jobApplications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimelineLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimelineLogsTable> {
  $$TimelineLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  $$JobApplicationsTableAnnotationComposer get applicationId {
    final $$JobApplicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applicationId,
      referencedTable: $db.jobApplications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobApplicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobApplications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimelineLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimelineLogsTable,
          TimelineLog,
          $$TimelineLogsTableFilterComposer,
          $$TimelineLogsTableOrderingComposer,
          $$TimelineLogsTableAnnotationComposer,
          $$TimelineLogsTableCreateCompanionBuilder,
          $$TimelineLogsTableUpdateCompanionBuilder,
          (TimelineLog, $$TimelineLogsTableReferences),
          TimelineLog,
          PrefetchHooks Function({bool applicationId})
        > {
  $$TimelineLogsTableTableManager(_$AppDatabase db, $TimelineLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimelineLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimelineLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimelineLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> applicationId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimelineLogsCompanion(
                id: id,
                applicationId: applicationId,
                title: title,
                note: note,
                loggedAt: loggedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String applicationId,
                required String title,
                Value<String> note = const Value.absent(),
                required DateTime loggedAt,
                Value<int> rowid = const Value.absent(),
              }) => TimelineLogsCompanion.insert(
                id: id,
                applicationId: applicationId,
                title: title,
                note: note,
                loggedAt: loggedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimelineLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({applicationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (applicationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.applicationId,
                                referencedTable: $$TimelineLogsTableReferences
                                    ._applicationIdTable(db),
                                referencedColumn: $$TimelineLogsTableReferences
                                    ._applicationIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TimelineLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimelineLogsTable,
      TimelineLog,
      $$TimelineLogsTableFilterComposer,
      $$TimelineLogsTableOrderingComposer,
      $$TimelineLogsTableAnnotationComposer,
      $$TimelineLogsTableCreateCompanionBuilder,
      $$TimelineLogsTableUpdateCompanionBuilder,
      (TimelineLog, $$TimelineLogsTableReferences),
      TimelineLog,
      PrefetchHooks Function({bool applicationId})
    >;
typedef $$InterviewSchedulesTableCreateCompanionBuilder =
    InterviewSchedulesCompanion Function({
      required String id,
      required String applicationId,
      required String roundName,
      required DateTime scheduledAt,
      Value<String?> meetingUrl,
      Value<String?> locationNotes,
      Value<int?> notificationId24h,
      Value<int?> notificationId1h,
      Value<int> rowid,
    });
typedef $$InterviewSchedulesTableUpdateCompanionBuilder =
    InterviewSchedulesCompanion Function({
      Value<String> id,
      Value<String> applicationId,
      Value<String> roundName,
      Value<DateTime> scheduledAt,
      Value<String?> meetingUrl,
      Value<String?> locationNotes,
      Value<int?> notificationId24h,
      Value<int?> notificationId1h,
      Value<int> rowid,
    });

final class $$InterviewSchedulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InterviewSchedulesTable,
          InterviewSchedule
        > {
  $$InterviewSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $JobApplicationsTable _applicationIdTable(_$AppDatabase db) =>
      db.jobApplications.createAlias(
        $_aliasNameGenerator(
          db.interviewSchedules.applicationId,
          db.jobApplications.id,
        ),
      );

  $$JobApplicationsTableProcessedTableManager get applicationId {
    final $_column = $_itemColumn<String>('application_id')!;

    final manager = $$JobApplicationsTableTableManager(
      $_db,
      $_db.jobApplications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_applicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InterviewSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $InterviewSchedulesTable> {
  $$InterviewSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roundName => $composableBuilder(
    column: $table.roundName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meetingUrl => $composableBuilder(
    column: $table.meetingUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationNotes => $composableBuilder(
    column: $table.locationNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId24h => $composableBuilder(
    column: $table.notificationId24h,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId1h => $composableBuilder(
    column: $table.notificationId1h,
    builder: (column) => ColumnFilters(column),
  );

  $$JobApplicationsTableFilterComposer get applicationId {
    final $$JobApplicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applicationId,
      referencedTable: $db.jobApplications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobApplicationsTableFilterComposer(
            $db: $db,
            $table: $db.jobApplications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InterviewSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $InterviewSchedulesTable> {
  $$InterviewSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roundName => $composableBuilder(
    column: $table.roundName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meetingUrl => $composableBuilder(
    column: $table.meetingUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationNotes => $composableBuilder(
    column: $table.locationNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId24h => $composableBuilder(
    column: $table.notificationId24h,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId1h => $composableBuilder(
    column: $table.notificationId1h,
    builder: (column) => ColumnOrderings(column),
  );

  $$JobApplicationsTableOrderingComposer get applicationId {
    final $$JobApplicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applicationId,
      referencedTable: $db.jobApplications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobApplicationsTableOrderingComposer(
            $db: $db,
            $table: $db.jobApplications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InterviewSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InterviewSchedulesTable> {
  $$InterviewSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roundName =>
      $composableBuilder(column: $table.roundName, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meetingUrl => $composableBuilder(
    column: $table.meetingUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationNotes => $composableBuilder(
    column: $table.locationNotes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notificationId24h => $composableBuilder(
    column: $table.notificationId24h,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notificationId1h => $composableBuilder(
    column: $table.notificationId1h,
    builder: (column) => column,
  );

  $$JobApplicationsTableAnnotationComposer get applicationId {
    final $$JobApplicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applicationId,
      referencedTable: $db.jobApplications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobApplicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobApplications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InterviewSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InterviewSchedulesTable,
          InterviewSchedule,
          $$InterviewSchedulesTableFilterComposer,
          $$InterviewSchedulesTableOrderingComposer,
          $$InterviewSchedulesTableAnnotationComposer,
          $$InterviewSchedulesTableCreateCompanionBuilder,
          $$InterviewSchedulesTableUpdateCompanionBuilder,
          (InterviewSchedule, $$InterviewSchedulesTableReferences),
          InterviewSchedule,
          PrefetchHooks Function({bool applicationId})
        > {
  $$InterviewSchedulesTableTableManager(
    _$AppDatabase db,
    $InterviewSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InterviewSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InterviewSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InterviewSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> applicationId = const Value.absent(),
                Value<String> roundName = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<String?> meetingUrl = const Value.absent(),
                Value<String?> locationNotes = const Value.absent(),
                Value<int?> notificationId24h = const Value.absent(),
                Value<int?> notificationId1h = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterviewSchedulesCompanion(
                id: id,
                applicationId: applicationId,
                roundName: roundName,
                scheduledAt: scheduledAt,
                meetingUrl: meetingUrl,
                locationNotes: locationNotes,
                notificationId24h: notificationId24h,
                notificationId1h: notificationId1h,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String applicationId,
                required String roundName,
                required DateTime scheduledAt,
                Value<String?> meetingUrl = const Value.absent(),
                Value<String?> locationNotes = const Value.absent(),
                Value<int?> notificationId24h = const Value.absent(),
                Value<int?> notificationId1h = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterviewSchedulesCompanion.insert(
                id: id,
                applicationId: applicationId,
                roundName: roundName,
                scheduledAt: scheduledAt,
                meetingUrl: meetingUrl,
                locationNotes: locationNotes,
                notificationId24h: notificationId24h,
                notificationId1h: notificationId1h,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InterviewSchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({applicationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (applicationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.applicationId,
                                referencedTable:
                                    $$InterviewSchedulesTableReferences
                                        ._applicationIdTable(db),
                                referencedColumn:
                                    $$InterviewSchedulesTableReferences
                                        ._applicationIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InterviewSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InterviewSchedulesTable,
      InterviewSchedule,
      $$InterviewSchedulesTableFilterComposer,
      $$InterviewSchedulesTableOrderingComposer,
      $$InterviewSchedulesTableAnnotationComposer,
      $$InterviewSchedulesTableCreateCompanionBuilder,
      $$InterviewSchedulesTableUpdateCompanionBuilder,
      (InterviewSchedule, $$InterviewSchedulesTableReferences),
      InterviewSchedule,
      PrefetchHooks Function({bool applicationId})
    >;
typedef $$ResumeAttachmentsTableCreateCompanionBuilder =
    ResumeAttachmentsCompanion Function({
      required String id,
      required String applicationId,
      required String originalFileName,
      required String privateFilePath,
      required int fileSizeBytes,
      required DateTime attachedAt,
      Value<int> rowid,
    });
typedef $$ResumeAttachmentsTableUpdateCompanionBuilder =
    ResumeAttachmentsCompanion Function({
      Value<String> id,
      Value<String> applicationId,
      Value<String> originalFileName,
      Value<String> privateFilePath,
      Value<int> fileSizeBytes,
      Value<DateTime> attachedAt,
      Value<int> rowid,
    });

final class $$ResumeAttachmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ResumeAttachmentsTable,
          ResumeAttachment
        > {
  $$ResumeAttachmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $JobApplicationsTable _applicationIdTable(_$AppDatabase db) =>
      db.jobApplications.createAlias(
        $_aliasNameGenerator(
          db.resumeAttachments.applicationId,
          db.jobApplications.id,
        ),
      );

  $$JobApplicationsTableProcessedTableManager get applicationId {
    final $_column = $_itemColumn<String>('application_id')!;

    final manager = $$JobApplicationsTableTableManager(
      $_db,
      $_db.jobApplications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_applicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ResumeAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $ResumeAttachmentsTable> {
  $$ResumeAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalFileName => $composableBuilder(
    column: $table.originalFileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privateFilePath => $composableBuilder(
    column: $table.privateFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get attachedAt => $composableBuilder(
    column: $table.attachedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$JobApplicationsTableFilterComposer get applicationId {
    final $$JobApplicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applicationId,
      referencedTable: $db.jobApplications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobApplicationsTableFilterComposer(
            $db: $db,
            $table: $db.jobApplications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResumeAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResumeAttachmentsTable> {
  $$ResumeAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalFileName => $composableBuilder(
    column: $table.originalFileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privateFilePath => $composableBuilder(
    column: $table.privateFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get attachedAt => $composableBuilder(
    column: $table.attachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$JobApplicationsTableOrderingComposer get applicationId {
    final $$JobApplicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applicationId,
      referencedTable: $db.jobApplications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobApplicationsTableOrderingComposer(
            $db: $db,
            $table: $db.jobApplications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResumeAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResumeAttachmentsTable> {
  $$ResumeAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalFileName => $composableBuilder(
    column: $table.originalFileName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get privateFilePath => $composableBuilder(
    column: $table.privateFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get attachedAt => $composableBuilder(
    column: $table.attachedAt,
    builder: (column) => column,
  );

  $$JobApplicationsTableAnnotationComposer get applicationId {
    final $$JobApplicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.applicationId,
      referencedTable: $db.jobApplications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobApplicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobApplications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResumeAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResumeAttachmentsTable,
          ResumeAttachment,
          $$ResumeAttachmentsTableFilterComposer,
          $$ResumeAttachmentsTableOrderingComposer,
          $$ResumeAttachmentsTableAnnotationComposer,
          $$ResumeAttachmentsTableCreateCompanionBuilder,
          $$ResumeAttachmentsTableUpdateCompanionBuilder,
          (ResumeAttachment, $$ResumeAttachmentsTableReferences),
          ResumeAttachment,
          PrefetchHooks Function({bool applicationId})
        > {
  $$ResumeAttachmentsTableTableManager(
    _$AppDatabase db,
    $ResumeAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResumeAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResumeAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResumeAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> applicationId = const Value.absent(),
                Value<String> originalFileName = const Value.absent(),
                Value<String> privateFilePath = const Value.absent(),
                Value<int> fileSizeBytes = const Value.absent(),
                Value<DateTime> attachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResumeAttachmentsCompanion(
                id: id,
                applicationId: applicationId,
                originalFileName: originalFileName,
                privateFilePath: privateFilePath,
                fileSizeBytes: fileSizeBytes,
                attachedAt: attachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String applicationId,
                required String originalFileName,
                required String privateFilePath,
                required int fileSizeBytes,
                required DateTime attachedAt,
                Value<int> rowid = const Value.absent(),
              }) => ResumeAttachmentsCompanion.insert(
                id: id,
                applicationId: applicationId,
                originalFileName: originalFileName,
                privateFilePath: privateFilePath,
                fileSizeBytes: fileSizeBytes,
                attachedAt: attachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ResumeAttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({applicationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (applicationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.applicationId,
                                referencedTable:
                                    $$ResumeAttachmentsTableReferences
                                        ._applicationIdTable(db),
                                referencedColumn:
                                    $$ResumeAttachmentsTableReferences
                                        ._applicationIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ResumeAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResumeAttachmentsTable,
      ResumeAttachment,
      $$ResumeAttachmentsTableFilterComposer,
      $$ResumeAttachmentsTableOrderingComposer,
      $$ResumeAttachmentsTableAnnotationComposer,
      $$ResumeAttachmentsTableCreateCompanionBuilder,
      $$ResumeAttachmentsTableUpdateCompanionBuilder,
      (ResumeAttachment, $$ResumeAttachmentsTableReferences),
      ResumeAttachment,
      PrefetchHooks Function({bool applicationId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JobApplicationsTableTableManager get jobApplications =>
      $$JobApplicationsTableTableManager(_db, _db.jobApplications);
  $$StatusTransitionsTableTableManager get statusTransitions =>
      $$StatusTransitionsTableTableManager(_db, _db.statusTransitions);
  $$TimelineLogsTableTableManager get timelineLogs =>
      $$TimelineLogsTableTableManager(_db, _db.timelineLogs);
  $$InterviewSchedulesTableTableManager get interviewSchedules =>
      $$InterviewSchedulesTableTableManager(_db, _db.interviewSchedules);
  $$ResumeAttachmentsTableTableManager get resumeAttachments =>
      $$ResumeAttachmentsTableTableManager(_db, _db.resumeAttachments);
}
