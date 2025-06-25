class ContractListTextStyles {
  static TextStyle rowTitle(BuildContext context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText(context),
      );

  static TextStyle rowSubtitle(BuildContext context) => TextStyle(
        fontSize: 14,
        color: AppColors.secondaryText(context),
      );
}