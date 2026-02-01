import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';
import '../../../../core/routing/app_router.dart';
import 'widgets/transaction_card.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = context.read<TransactionsBloc>().state;
      if (state is TransactionsLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<TransactionsBloc>().add(const LoadMoreTransactionsEvent());
      }
    }
  }

  Future<void> _checkAuthentication() async {
    final authLocalDataSource = sl<AuthLocalDataSource>();
    final token = await authLocalDataSource.getAccessToken();
    setState(() {
      _isAuthenticated = token != null && token.isNotEmpty;
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: 'اشتراكاتي'),
        body: Stack(
          children: [
            const CustomBackground(),
            Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ],
        ),
      );
    }

    if (!_isAuthenticated) {
      return _UnauthenticatedTransactionsPage();
    }

    return BlocProvider(
      create: (context) => sl<TransactionsBloc>()..add(const LoadTransactionsEvent()),
      child: _TransactionsPageContent(scrollController: _scrollController),
    );
  }
}

class _UnauthenticatedTransactionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'اشتراكاتي'),
      body: Stack(
        children: [
          const CustomBackground(),
          Center(
            child: Padding(
              padding: Responsive.padding(
                context,
                horizontal: 24,
                vertical: 16,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lock Icon
                    Container(
                      padding: EdgeInsets.all(Responsive.width(context, 32)),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: Responsive.iconSize(context, 80),
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 24)),
                    Text(
                      'تسجيل الدخول مطلوب',
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: Responsive.fontSize(context, 24),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.spacing(context, 12)),
                    Text(
                      'للوصول إلى اشتراكاتك ومعاملاتك، يرجى تسجيل الدخول أو إنشاء حساب جديد',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: Responsive.fontSize(context, 16),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.spacing(context, 28)),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: Responsive.height(context, 56),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(
                              AppRouter.login,
                              arguments: {'returnTo': 'transactions'},
                            );

                            if (result == true && context.mounted) {
                              // After successful login, reload the transactions page
                              Navigator.of(context, rootNavigator: true)
                                  .pushReplacementNamed(AppRouter.transactions);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: Responsive.fontSize(context, 18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 24)),
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: Responsive.height(context, 56),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: OutlinedButton(
                          onPressed: () async {
                            final result = await Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(
                              AppRouter.register,
                              arguments: {'returnTo': 'transactions'},
                            );

                            if (result == true && context.mounted) {
                              // After successful registration, reload the transactions page
                              Navigator.of(context, rootNavigator: true)
                                  .pushReplacementNamed(AppRouter.transactions);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: const BorderSide(color: AppColors.primary),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: Text(
                            'إنشاء حساب جديد',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: Responsive.fontSize(context, 18),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsPageContent extends StatelessWidget {
  final ScrollController scrollController;

  const _TransactionsPageContent({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'اشتراكاتي'),
      body: Stack(
        children: [
          const CustomBackground(),
          BlocBuilder<TransactionsBloc, TransactionsState>(
            builder: (context, state) {
              if (state is TransactionsLoading) {
                if (state.cachedTransactions != null &&
                    state.cachedTransactions!.isNotEmpty) {
                  return _buildTransactionsList(
                    context,
                    state.cachedTransactions!,
                    isLoading: true,
                  );
                }
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state is TransactionsError) {
                if (state.cachedTransactions != null &&
                    state.cachedTransactions!.isNotEmpty) {
                  return _buildTransactionsList(
                    context,
                    state.cachedTransactions!,
                    errorMessage: state.message,
                  );
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: Responsive.iconSize(context, 64),
                        color: AppColors.error,
                      ),
                      SizedBox(height: Responsive.spacing(context, 16)),
                      Text(
                        state.message,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Responsive.spacing(context, 24)),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<TransactionsBloc>()
                              .add(const LoadTransactionsEvent(refresh: true));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              if (state is TransactionsEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: Responsive.iconSize(context, 80),
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: Responsive.spacing(context, 24)),
                      Text(
                        'لا توجد معاملات',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Responsive.spacing(context, 8)),
                      Text(
                        'لم تقم بأي معاملات حتى الآن',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (state is TransactionsLoaded) {
                return _buildTransactionsList(
                  context,
                  state.transactions,
                  total: state.total,
                  currentPage: state.currentPage,
                  lastPage: state.lastPage,
                  hasMore: state.hasMore,
                  isLoadingMore: state.isLoadingMore,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    List transactions, {
    int? total,
    int? currentPage,
    int? lastPage,
    bool? hasMore,
    bool isLoadingMore = false,
    bool isLoading = false,
    String? errorMessage,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TransactionsBloc>().add(const RefreshTransactionsEvent());
      },
      color: AppColors.primary,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (errorMessage != null)
            SliverToBoxAdapter(
              child: Container(
                margin: Responsive.padding(context, all: 16),
                padding: Responsive.padding(context, all: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error),
                    SizedBox(width: Responsive.spacing(context, 12)),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (total != null && total > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: Responsive.padding(
                  context,
                  horizontal: 24,
                  vertical: 16,
                ),
                  child: Text(
                    'إجمالي المعاملات: $total',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ),
            ),
          SliverPadding(
            padding: Responsive.padding(
              context,
              horizontal: 24,
              vertical: 8,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < transactions.length) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: Responsive.spacing(context, 12),
                      ),
                      child: TransactionCard(transaction: transactions[index]),
                    );
                  }
                  return null;
                },
                childCount: transactions.length,
              ),
            ),
          ),
          if (isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: Responsive.padding(context, all: 16),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
          if (isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: Responsive.padding(context, all: 16),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
