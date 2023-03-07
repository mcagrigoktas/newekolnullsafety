import 'package:mcg_extension/mcg_extension.dart';

import 'account_settings/main.dart' deferred as accounting_settings;
import 'contracts/layout.dart' deferred as contracts;
import 'expenses/layout.dart' deferred as expenses;
import 'financial_analysis/layout.dart' deferred as financal_analysis;
import 'sales_contracts/layout.dart' deferred as sales_contracts;
import 'studentaccounting/layout.dart' deferred as student_accounting;

class AccountingMainRoutes {
  AccountingMainRoutes._();

  static Future<void>? goAccountingSettings() async {
    OverLoading.show();
    await accounting_settings.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(accounting_settings.AccountingSettingsPage());
  }

  static Future<void>? goFinancalAnalsis() async {
    OverLoading.show();
    await financal_analysis.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(financal_analysis.FinancialAnalysis());
  }

  static Future<void>? goExpenses() async {
    OverLoading.show();
    await expenses.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(expenses.Expenses());
  }

  static Future<void>? goSalesContracts() async {
    OverLoading.show();
    await sales_contracts.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(sales_contracts.SalesContracts());
  }

  static Future<void>? goContracts() async {
    OverLoading.show();
    await contracts.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(contracts.Contracts());
  }

  static Future<void>? goStudentAccounting({String? selectedKey}) async {
    OverLoading.show();
    await student_accounting.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(student_accounting.StudentAccounting(
      selectedKey: selectedKey,
    ));
  }
}
