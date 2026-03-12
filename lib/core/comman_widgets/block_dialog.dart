import 'dart:async';

import 'package:alert_her/core/comman_widgets/primary_button.dart';
import 'package:alert_her/core/constants/my_colors.dart';
import 'package:alert_her/core/routes/routes.dart';
import 'package:alert_her/core/services/local_storage.dart';
import 'package:alert_her/core/utils/string_extension.dart';
import 'package:alert_her/localizations/app_localizations.dart';
import 'package:alert_her/modules/user/presentation/viewmodels/auth_view_model.dart';
import 'package:alert_her/modules/user/presentation/viewmodels/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'text_sub_heading.dart';
import '../utils/sb.dart';

class BlockDialog extends StatefulWidget {

  const BlockDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<BlockDialog> createState() => _BlockDialogState();
}

class _BlockDialogState extends State<BlockDialog> {


  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Consumer<AuthViewModel>(
        builder: (mContext, authVM, child) {
          return Container(
            padding: const EdgeInsets.all(50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextSubHeading(text: AppLocalizations.of(context).translate('accountBlock'),fontSize: 18,fontWeight: FontWeight.w500,color: MyColors.black,),
                SB.h(20),
                TextSubHeading(text: AppLocalizations.of(context).translate('thisCredentialIsBlockByAdmin'),fontSize: 13,fontWeight: FontWeight.w400,color: MyColors.black,textAlign: TextAlign.center,),
                SB.h(40),
                PrimaryButton(
                  buttonText: AppLocalizations.of(context).translate('gotIt'),
                  fontWeight: FontWeight.w700,
                  bgColor: MyColors.red,
                  textSize: 16,
                  onPressed: () async {
                    final authVM = Provider.of<AuthViewModel>(context, listen: false);
                    authVM.resetValues();
                    authVM.handleLogout(context);

                    final homeVM = Provider.of<HomeViewModel>(context, listen: false);
                    homeVM.resetValues();

                    await LocalStorage().logout();
                    //context.go(Routes.loginMobile);
                    context.go(Routes.loginEmail);
                  },
                ),
              ],
            ),
          );
        }),
    );
  }
}
